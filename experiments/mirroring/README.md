# Screen mirroring receiver prototype

This directory contains the Mac capture harness and an experimental RV32 device
receiver/bridge. A validated update archive is available; see
[flashing instructions](FLASHING.md). The device image has not yet been tested
with an iPhone and Corsa. The Mac harness below captures compressed video locally.

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
