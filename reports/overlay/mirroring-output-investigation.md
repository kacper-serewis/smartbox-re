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

## Native path findings and candidate correction

`scripts/test_native_video.py` now runs the actual v131 incoming and common
video routines under Andes QEMU. It maps the pinned ELF at an offset, preserves
its global pointer, and substitutes transport/lifecycle dependencies. It
reproduces three integration failures:

1. With the welcome-screen configuration already sent, the incoming callback
   can forward the phone's IDR without replacing that configuration.
2. Once phone video is active, another configuration call does not necessarily
   clear `this+0x216a` (configuration sent). A rotation's SPS/PPS can be skipped.
3. In the different-SPS branch, the callback requests an asynchronous stream
   close and sets `this+0x2172` without claiming the phone source. The old bridge
   nevertheless treated the configuration call as accepted.

The new source routes mirrored video through the lower-level native senders
`0x4eca8` and `0x4ee7c`. `native_video.h` holds the stock application's video
mutex, claims the phone source, sends fresh configuration using dimensions
parsed from SPS, and gates frames on successful configuration and an IDR. Send
failures or a stock stream reset invalidate the bridge's configuration state.
Disconnect releases the source and makes the welcome screen resend its own
configuration. The welcome-screen encoder's dimension fields stay unchanged;
mutating them could affect an already-running local encode.

The frame sender replaces only the leading Annex B start code with one AVCC
length. The bridge therefore sends each VCL NAL separately. The supplied phone
captures contain one VCL NAL per callback, sometimes preceded by SPS/PPS, so
this additional constraint is not demonstrated as the cause of the photograph.

`native_video_bind.h` enables internal addresses only after verifying the whole
executable SHA-256 against stock v131 or one of the three generated density
variants, the exported callback address, and mutex symbols. The adapter accepts
the stock CarPlay output type, an already-ready stream, and supported progressive
8-bit 4:2:0 AVC up to 1920×1080. Unknown executables disable mirroring hooks and
leave stock startup available. These checks do not establish car compatibility.

The native wire test also executes the original header builder, SPS/PPS-to-avcC
converter, and frame envelope routine. It checks source/viewport dimensions and
single-NAL AVCC framing. Allocation, locking, socket writes and AES are modeled;
this is not a test of encryption or a real car session.

Both physical captures were replayed through the corrected bridge and native
adapter with recording transport callbacks: **3,390 frames decoded, zero errors,
and byte-identical H.264**. Geometry calls matched all three observed sizes:
332×720, 1200×552 and 1564×720. Replay evidence:
`device-snapshots/native-video-tests-20260920T124408.126380Z/report.json`.

The bridge unit tests, stock preload/driver IPC and Bonjour receiver startup
tests passed. The whole stock app still encounters missing-hardware failures
and SIGSEGV in QEMU; the isolated routine tests do not remove that limitation.

Reproduce (captures stay local):

```sh
python3 scripts/build_mirroring_riscv.py
python3 scripts/test_native_video.py \
  --capture device-snapshots/dongle-preview-20260920T121125.197999Z \
  --capture device-snapshots/dongle-preview-20260920T121849.714114Z
```

Omit `--capture` to run the native state and wire tests without private recordings.
The corrected library is built locally; no new firmware archive was packaged
or flashed during this investigation. The old mirroring archive stays withdrawn.

## Remaining hardware check

The next check is a real Corsa session: successful welcome-screen handover,
portrait/landscape changes, disconnect/reconnect, and return to the welcome
screen. Its decoder's acceptance and scaling of these source sizes remain
unverified. The Mac browser preview exercises reception and Mac decoding; it
cannot validate the car-facing path. Actual conversion to fixed 800×480 video
would require decode/scale/encode, which is not implemented or benchmarked here.

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
