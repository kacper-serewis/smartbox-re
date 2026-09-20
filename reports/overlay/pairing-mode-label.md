# Active mode on the pairing screen

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
The Mac lost its Wi-Fi association after the final test, so the explicit RAM
launcher stop and dongle application restoration check could not reach the
device at that point. The launcher's independent 300-second deadline remains
the fallback; no firmware was flashed.

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
