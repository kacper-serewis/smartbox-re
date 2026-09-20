# Screen mirroring receiver prototype

This directory contains the Mac capture harness and an experimental RV32 device
receiver/bridge. The experimental flash image is **withdrawn** after corrupted
video and an updater/supervisor conflict on the physical adapter. The adapter
has been recovered to density137.5; see the [investigation](../../reports/overlay/updater-supervisor-conflict.md).
The Mac harness below captures compressed video locally.

## Preview the dongle on the Mac without the car

Live inspection of smartBox-9302 found no `/dev/fb0`, `/dev/disp`, or
`/sys/class/graphics`. The phone video is compressed H.264, so this preview runs a
standalone receiver on the dongle and decodes its captured packets on the Mac.
It is not a screenshot of the dongle's welcome screen and does not exercise the
Corsa's decoder, USB/MFi negotiation, or stock video-source handover.

```sh
python3 scripts/preview_dongle.py
```

The Mac and iPhone must be on the adapter Wi-Fi; the dongle can be powered by the
Mac. The script checks the device identity, copies a bounded transfer helper and
the receiver into `/tmp`, verifies their checksums, then opens a localhost preview
page. Select **SmartBox Mirror Test** in iPhone Screen Mirroring; the PIN appears
on the page when pairing starts. No firmware is flashed and the restored
density137.5 app remains running. The capture receiver uses its own identity and
dynamically allocated ports, alongside the existing app.

The mirrored phone screen is recorded locally, including visible notifications.
Audio is discarded. Limits: ten minutes total by default, two minutes after video
starts, or 8 MiB of video, whichever comes first. Ctrl-C stops the receiver. A
power cycle removes its temporary files. Do not start a firmware update during
this test. Evidence, raw packets, decoder logs, and preview images are saved under
`device-snapshots/dongle-preview-*`. The browser preview refreshes up to ten frames
per second; this is a diagnostic viewer, not a latency benchmark.

The full iPhone → physical dongle → Mac path worked on 20 September 2026. The
phone supplied 332×720 portrait and 1200×552 landscape video despite the 800×480
request. The completed capture decoded 1,742 frames without an error.
Evidence is in `device-snapshots/dongle-preview-20260920T121125.197999Z`.
This validates receiving and decoding, not the Corsa output path. The Mac pipeline
also decoded 72 generated transport-test frames with rotation changes and zero
errors.

Optional `--width`, `--height`, and `--fps` arguments change the advertised
display request; they do not resize the received video. A second physical test
using `--height 320` received 332×720 portrait and 1564×720 landscape video,
decoding 1,648 frames without errors before reaching the capture byte limit.
The last preview remains available until the total session timeout. See the
[output investigation](../../reports/overlay/mirroring-output-investigation.md)
for the comparison and the limits of the RV32 bridge replay.

The corrected car-output bridge has passed isolated native-routine tests and
replay of both recordings (3,390 decoded frames, zero errors). It sends new
codec settings and actual source dimensions on rotation, waits for a keyframe,
and keeps the welcome-screen encoder's dimensions unchanged. This candidate is
built locally, **not flashed or verified in the Corsa**. The standalone browser
preview above continues to test reception/Mac decoding; the final output test
requires the head unit. Run `python3 scripts/test_native_video.py` after the
RV32 build for the offline state and packet-format tests.

Local build prerequisites (already built on this Mac):

```sh
swiftc -O experiments/mirroring/preview.swift \
  -o firmwares/research/mirroring-build/mirror-preview
docker run --rm --platform linux/amd64 --network none --read-only \
  --tmpfs /tmp:rw,exec,nosuid,size=16m -v "$PWD:/work" \
  smartbox-mirror-builder:local \
  /work/firmwares/research/mirror-deps/riscv32-ilp32d--glibc--bleeding-edge-2021.11-1/bin/riscv32-buildroot-linux-gnu-gcc \
  -Os -Wall -Wextra -Werror -Wl,--build-id=none -s \
  -o /work/firmwares/research/recovery/ram-fetch /work/experiments/emulation/ram_fetch.c
```

Run the Docker command from this repository (the image works in `/work`). The
existing receiver comes from `scripts/build_mirroring_riscv.py`. The transfer
helper was tested under RV32/QEMU with fragmented TCP and rejected oversized
transfers; the physical deployment independently checked both file digests.

The receiver uses the protocol libraries from [UxPlay](https://github.com/FDH2/UxPlay),
pinned to `57ea83411d5f7e0b38c5841987439340543f025c`. Its renderer and GStreamer
dependencies are not built. Keep the upstream copyright/license files with the
checkout; upstream includes GPL/LGPL components. This project does not vendor or
relicense those components. Any later distributed firmware needs to account for
the licenses of the components it includes.

## Build once

On this Mac the dependencies and receiver have already been built. For a fresh
Mac with Xcode command line tools:

```sh
brew install cmake pkgconf libplist openssl@3
python3 scripts/capture_mirroring.py --build
```

Source and binaries stay under ignored `firmwares/research/`. The build refuses
a different or modified upstream checkout instead of silently changing it.
Subsequent captures need no internet connection.

## Test with the iPhone

1. Connect the Mac and iPhone to the same Wi-Fi. Home Wi-Fi is fine; no car or
   dongle is needed for this stage.
2. Run `python3 scripts/capture_mirroring.py` from this repository.
3. Open iPhone Control Center → Screen Mirroring → **SmartBox Mirror Lab**.
   Enter the four-digit PIN shown in the terminal. If macOS requests local-network
   access for the receiver, allow it to make discovery work.
4. Show a simple landscape screen, then rotate once to portrait and back. The
   receiver records up to 30 seconds after video starts and stops automatically.
   It also stops after 180 seconds total or before exceeding 64 MiB of video.
5. The final output names a `device-snapshots/mirroring-*` directory to inspect.

The phone screen is recorded locally, including any notifications it shows.
Audio is received and discarded. A fresh receiver identity/key is generated for
each run so pairing is temporary. Ctrl-C stops capture cleanly.

## Files and interpretation

- `video.h264`: unchanged Annex B bytes from UxPlay's video callback.
- `events.jsonl`: callback boundaries, byte offsets, timestamps (nanoseconds),
  and dimensions reported by the phone. A callback can contain multiple NALs.
- `video-analysis.json`: unique SPS configurations, profile/level, bit depth,
  coded and cropped visible dimensions, and parser errors.
- `receiver-summary.json`: stop reason, recorded bytes/packets, error status.
- `receiver.log`, `capture.json`, `receiver.key`: diagnostics, capture settings,
  and local pairing material. The directory is private and ignored by Git.

The requested 800×480 at up to 30 fps is advisory. Only captured SPS data shows
what the phone actually encoded. Matching dimensions are necessary evidence,
not proof that the Corsa will accept the stream. Empty captures prove nothing
about iOS compatibility. Discovery and full pairing on iOS 27 still need a phone
test. Protected video and car-screen touch control are outside this prototype.

The RISC-V receiver build and experimental bridge to the stock video callback
are now implemented. Head-unit acceptance of the phone's codec and dimensions
remains unverified. See the
[architecture investigation](../../reports/overlay/screen-mirroring.md).

## Local checks

```sh
ctest --test-dir firmwares/research/mirroring-build --output-on-failure
python3 scripts/test_mirroring.py
python3 scripts/test_mirroring_transport.py
python3 scripts/inspect_h264.py path/to/video.h264
```

Checks exercise byte-exact capture, packet boundaries, size/time limits,
unsupported-codec rejection, the pairing registry, SPS cropping/rotation, and
a real local RTSP `/info` and PIN-start exchange. They do not simulate a complete
encrypted iPhone session or a head-unit connection.

The separate transport test uses macOS VideoToolbox to encode 72 generated
animation frames. An independent sender encrypts them with AES-CTR and feeds
fragmented TCP to UxPlay's actual mirror receiver, then the test compares the
capture byte-for-byte and decodes it with VideoToolbox. It exercises
800×480 → 480×800 → 800×480 configuration changes. No desktop pixels are captured.
It requires `swiftc` and `openssl`, and writes evidence to an ignored
`device-snapshots/transport-test-*` directory. Run `--build` again before this test
if the `test-transport` executable is missing.

This test starts **after key negotiation**, using a fixed test key in the test
executable only; production receiver pairing is unchanged. It does not verify
Apple discovery/pairing end to end, iOS resolution selection, or the dongle's
ability to display the stream. See [recorded results](../../reports/overlay/mirroring-local-test.md).
