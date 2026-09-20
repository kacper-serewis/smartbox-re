# Local encrypted video transport test

Tested 2026-09-19 on this Mac while the desktop was locked. No attempt was made
to unlock it or capture the user's desktop. This is a generated-media transport
test, not a Mac or iPhone Screen Mirroring session.

Command: `python3 scripts/test_mirroring_transport.py`

## Result: passed

- Apple VideoToolbox encoded 72 animated test frames as H.264 Main profile,
  level 3.1, progressive 8-bit 4:2:0.
- A separate sender derived the test AES-CTR key/IV with Python's SHA-512 and
  encrypted the compressed payload with the OpenSSL CLI. The sender did not use
  the receiver's encryption implementation.
- The real UxPlay mirroring TCP worker received the data in fragmented writes,
  decrypted it, converted its NAL framing, and invoked the production capture
  callback. Frame payloads exercised 14 different AES block-length remainders.
- Captured all 72 packets, totaling **478,287 bytes**, exactly matching the
  original encoded video after expected SPS/PPS insertion and framing conversion.
- Verified callback offsets/lengths/NAL counts, 30 fps remote timestamp spacing,
  and dimension changes **800×480 → 480×800 → 800×480**.
- VideoToolbox decoded all **72/72** captured frames without errors. Decoded
  dimensions matched the sequence and sampled pixels changed with the animation.
- The SPS inspector reported both landscape and portrait sizes without errors.

Captured H.264 SHA-256:
`7451f06f5f13f8699a31e24cb030018ca4f022f6cace494c75843b785ef6e0fe`

Detailed evidence is local under
`device-snapshots/transport-test-20260919T173341.787509Z/`: `report.json`, generated
source, encrypted wire input, captured H.264, packet events, and decoder input.
Encoder output may vary across macOS versions/hardware; the test checks against
each run's source instead of relying on this hash.

## Fix discovered

The pinned library supplies video timestamps in **nanoseconds**. Capture event
fields were incorrectly named `local_us`/`remote_us`; they now use
`local_ns`/`remote_ns`. Earlier captures with `_us` names from this prototype
also contain nanoseconds and must not be interpreted as microseconds.

## Remaining gaps

The test initializes the mirror worker after key negotiation with a fixed test
key. It does not exercise real Apple pairing, FairPlay setup, or normal session
control. The production receiver still uses its existing PIN pairing path.
Local `/info`, PIN-start, and Bonjour checks have passed independently, but they
do not establish an authenticated Apple session.

iOS 27 compatibility, actual phone-selected dimensions, and car-facing output
remain untested. The test confirms media transport/capture, not screen casting
on the HW501 or Corsa.

## RV32 follow-up

The same 72-frame encrypted transport test now passes under Andes QEMU using
the stock `libcrypto.so.1.1` and a glibc 2.34 sysroot. All 72 frames decoded;
478,287 captured bytes matched that run's generated source exactly. Evidence:
`device-snapshots/transport-test-20260919T191134.506925Z/`.

The emulation fork needed time64 socket-timeout support; the production receiver
was not changed to skip timeouts. A separate receive test confirms an actual
50 ms expiration. Bridge unit checks cover normalization, separate SPS/PPS,
IDR gating, malformed input, hook pass-through/suppression, and fallback. The
real integration also loads into stock CPAAProxyEx, where the real RV32 mode
driver successfully probes it and selects CarPlay. This does not reproduce the
physical USB/MFi session that the stock app requires.
