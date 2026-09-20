# Mirroring resolution limits measured on 2026-09-20

The Mac bench verifies the dongle's forwarding path. It does not emulate the
Corsa's video decoder. The car's negotiated screen is 800×480; that does not
establish the largest encoded stream its decoder accepts or how it scales one.

## Current bridge limits

Generated H.264 was replayed through the compiled RV32 bridge/native adapter in
Andes QEMU, using recording transport callbacks, then decoded by VideoToolbox.
Each row used 12 frames. The same cases were also tested as one changing stream,
including a return to 800×480 after rejected sizes.

| Encoded dimensions | Current bridge result |
| --- | --- |
| 800×480, 480×800 | Forwarded and decoded |
| 1024×600, 1280×720 | Forwarded and decoded |
| 1600×900, 1920×1080 | Forwarded and decoded |
| 720×1280, 1080×1920 | Rejected: height exceeds 1080 |
| 1936×1080 | Rejected: width exceeds 1920 |
| 1920×1088, without cropping to 1080 | Rejected: visible height exceeds 1080 |
| Return to 800×480 | Forwarding resumed and decoded |

There were zero decode errors: 84 accepted frames in the individual cases and
84 in the combined transition test. Forwarded VCL NALs and SPS/PPS matched
exactly. Encoder SEI is deliberately omitted by the bridge. These short fixtures
test geometry and state handling, not sustained dongle performance.

The bounds are explicit software guards in `h264_size.h` and `native_video.h`.
They are not measured hardware limits. In particular, portrait video is limited
by the same height bound; rotating a nominal 720p/1080p stream can exceed it.
The test does not raise these guards or change installed firmware.

Private evidence:
`device-snapshots/resolution-tests-20260920T181240.926616Z/report.json`.
Reproduce with:

```sh
python3 scripts/build_mirroring_riscv.py
.venv/bin/python scripts/test_mirroring_resolutions.py
```

## What is known on physical hardware

The preceding [USB bench test](mirroring-usb-bench-20260920.md) forwarded real
iPhone video at 1200×552 and 332×720 through the dongle to the Mac without decode
errors. The Mac had advertised 800×480. This proves the phone's encoded dimensions
can differ from the advertised screen size. Changing advertised dimensions or
physical millimetres does not perform scaling or guarantee a smaller AirPlay stream.

For the Corsa, first test the corrected bridge with its real landscape stream,
then rotate and return to landscape. Record the actual SPS dimensions alongside
what the car displays. Clean Mac output alone cannot establish car acceptance.
If the Corsa cannot accept the phone's native stream, fitting it to 800×480
requires a working size negotiation or actual decoding/scaling/re-encoding;
rewriting only SPS/header dimensions would corrupt the image.
