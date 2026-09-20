# Mirroring output investigation — 20 September 2026

The physical smartBox-9302 can receive the phone's mirror stream cleanly. Mac
decoding and a replay through the RV32 bridge narrow the remaining investigation
to the stock output path and head-unit compatibility. They do not establish the
cause of the previously corrupted Corsa display.

Both physical tests used a temporary receiver in RAM alongside the restored
density137.5 application. Neither test flashed firmware or exercised a connected
head unit. Audio was discarded.

| Advertised size | Received portrait | Received landscape | Decoded frames | Decoder errors | Capture stop |
| --- | --- | --- | --- | --- | --- |
| 800×480 | 332×720 | 1200×552 | 1,742 | 0 | Video duration limit |
| 800×320 | 332×720 | 1564×720 | 1,648 | 0 | 8 MiB byte limit |

These are visible sizes parsed from SPS data. The landscape coded sizes were
1200×560 and 1568×720 respectively. Both streams used High profile, 8-bit 4:2:0,
and four reference frames; landscape level was 3.1 in the first capture and 3.2
in the second. Rotation was captured successfully in both tests.

The requested dimensions did not bound the actual stream dimensions. These
sessions were not a controlled comparison of identical phone content, so the
larger second stream cannot be attributed solely to the smaller display request.

## Bridge replay

`experiments/mirroring/replay_bridge.c` replays captured receiver callbacks through
the actual `device_bridge.c` implementation under RV32 QEMU. The native stock
video callback is a recording stub; it does not emulate the head unit or the
stock application's asynchronous state transitions.

The first physical capture produced seven configuration calls and 1,742 frame
calls. Concatenating the forwarded bytes reproduced all 6,369,602 input bytes
exactly. Input and output SHA-256:

`41c7b5048f61c84b0d1649b59f20c49e4e26ff96937c54f807ad3343fa175814`

The Mac decoded the replay output with 1,742 frames and zero errors. This checks
bridge packet conversion for this capture, not native callback timing, buffer
ownership, source handover, or Corsa decoding.

## Next investigation

Trace how the stock application sets the source dimensions and viewport sent
with SPS/PPS, and how it switches from its welcome-screen encoder to incoming
phone video. The outgoing configuration routine at `0x4eca8` uses dimensions
and viewport values stored in the application object; these must be reconciled
with the actual incoming stream and rotation changes. The incoming path also
has an asynchronous restart branch when SPS changes.

The corrupted display photograph alone cannot distinguish stale decoder state,
incorrect configuration, overlapping video sources, or unsupported video
parameters. Advertising a smaller size is not a demonstrated fix. Changing SPS
dimension fields alone would not rescale encoded video. A car-facing fix still
requires a real head-unit test after the native path is understood.

## Local evidence

- `device-snapshots/dongle-preview-20260920T121125.197999Z/`
- `device-snapshots/dongle-preview-20260920T121849.714114Z/`
- `device-snapshots/phone-bridge-replay/report.json`
- `device-snapshots/phone-bridge-replay/resolution-comparison.json`
- `reports/display/metadata-evidence/video_config_packet.asm`
- `reports/overlay/evidence/incoming_compressed_video.asm`
- `reports/overlay/evidence/video_source_selection.asm`

The snapshots include private screen recordings and stay local. The experimental
mirroring flash archive remains withdrawn; see
[updater recovery](updater-supervisor-conflict.md).
