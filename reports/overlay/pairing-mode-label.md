# Active mode on the pairing screen

## PIN and receiver diagnostics extension

The current source also displays the receiver's four-digit pairing code in
mirroring mode, including leading zeros. The Bluetooth prompt becomes a receiver
status line (waiting, pairing, waiting for USB/video output, unsupported
resolution, invalid video, or sending video). Below the mode/PIN, a statistics
line shows current or last video dimensions and the forwarded-frame count. The
software version remains on the final line. No phone text or raw log messages
are inserted into LVGL.

These are pairing-screen diagnostics, not an overlay on the phone video. `Sent`
counts frames submitted to the vendor transport and does not confirm successful
decoding on the car. Dimensions are the phone video's dimensions, not a measured
head-unit resolution. Last dimensions and frame counts survive video teardown
within the application session. The PIN disappears during forwarding and returns
after teardown while the same receiver is still available. Stopping the receiver
clears it; CarPlay hides all mirroring diagnostics and restores the original
Bluetooth prompt.

The UI reads a separate bounded snapshot under a short mutex, without acquiring
the video-frame lock or reading status files on every redraw. The existing LVGL
object validation and UI-thread-only updates remain in place. The four-line
mode/PIN/stats/version block is intended for the existing 800×480 layout; the new
expanded layout has not yet been visually verified on the dongle. The live tests
below verified the earlier two-line mode/version layout only.

The extension passed the host label tests with AddressSanitizer and
UndefinedBehaviorSanitizer, plus the RV32 bridge/receiver checks in
`firmwares/research/emulation/mirror-20260920T184129.116020Z`. The bridge checks
include PIN publication, leading zeros, restoring the PIN after video teardown,
clearing it on receiver stop, hiding late PIN callbacks in CarPlay, last-video
statistics, and the unsupported-resolution status. Frame statistics count
forwarded access units, not the number of H.264 slice callbacks.

Built separately at
`firmwares/experiments/hw501_131_mirroring_density137.5_screeninfo/` with archive
SHA-256 `dee78e2cd39537176bf3039f749ae63ec6a8e9e76d2e5251b83a61634bf8cd7e`.
The verified app image occupies 4,964,352 of 5,242,880 bytes. This update has not
been flashed; the existing autorestart release was left intact.

## Original mode-label verification

The experimental bridge adds `Mode: CarPlay` or `Mode: Screen Mirroring` above
the existing `SW_Ver` line on the dongle's locally rendered pairing screen.
The Bluetooth name and version remain visible. It does not overlay phone video
or implement automatic switching between CarPlay and mirroring.

The label uses the bridge's active mode in memory, rather than a saved selection
that has not yet been applied. The LVGL timer hook refreshes the text on the UI
thread, including a runtime fallback from mirroring to CarPlay. It validates
retained objects, their LVGL class, and their current text before updating them;
deleted/reused objects and unrelated labels are left alone. The hooks are enabled
only after the existing executable hash check succeeds. A recovery launch without
the experimental bridge keeps the original pairing screen.

Implementation: `experiments/mirroring/pairing_label.h`, included in the bridge
and exported through its existing preload library. No drawing offsets, assets,
framebuffer memory, or video packets are patched.

Checks:

- Host tests with AddressSanitizer/UndefinedBehaviorSanitizer cover both modes,
  mode changes, unchanged redraws, deleted objects, reused objects, unrelated
  text, NULL refreshes, long strings and a disabled hook.
- The RV32 integration and RAM test payloads build successfully.
- Physical dongle → Mac USB preview:
  `mac-usb-session-20260920T182138.457555Z` decoded 206 frames at 800×480 with zero
  errors. The Screen Mirroring label and preserved version were visually verified
  with no clipping. Private captures are in `device-snapshots/`.
- `mac-usb-session-20260920T182332.913286Z` also visibly verified `Mode: CarPlay`
  above the version: 95 decoded frames, zero errors. Both mode tests use the same RAM library; mode is supplied
  by preparation, not baked into different screen assets.
- Native state and wire regression checks passed in Andes QEMU; evidence:
  `native-video-tests-20260920T182324.555575Z`.

Both USB tests verified restoration of the Mac's host role and original profile.
After reconnecting Wi-Fi, the explicit RAM launcher stop succeeded. At
18:27:21 UTC, the dongle had one running original application, no experimental
bridge loaded, and an idle updater. The RAM socket compatibility shim remains
loaded for the warm restart and disappears on a power cycle. Evidence is in
`mirroring-bench-20260920T181951.089811Z/label-test-restoration.json` under
`device-snapshots/`. No firmware was flashed.

The RAM launcher also now allows five seconds for receiver startup commands;
cheap readiness probes retain their short timeout. A regression test covers a
500-ms startup reply, which the old 200-ms deadline incorrectly rejected.

Reproduce the label checks:

```sh
xcrun clang -std=gnu11 -Wall -Wextra -Werror -fsanitize=address,undefined \
  experiments/mirroring/test_pairing_label.c -o /tmp/smartbox-test-pairing-label
/tmp/smartbox-test-pairing-label
python3 scripts/test_mirroring_bench.py
```

Use `bench_mirroring.py prepare --mode carplay` or `refresh --mode carplay` to
prepare a temporary CarPlay-mode test; the default is mirroring. Start validates
that the mode on the dongle still matches the saved test session. Neither test
mode writes the permanent mode selection or flashes firmware.
