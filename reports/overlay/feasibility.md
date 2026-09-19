# Overlay over live CarPlay: first investigation

2026-09-19. Target: HW501 v131, observed CarPlay video 800×480 at 60 fps.

**No working live-overlay patch has been built.** The first investigation identifies the compressed-video input, outgoing video path, and a separate local-UI encoder. It does not identify an existing decoded CarPlay framebuffer or a compositor mixing the two sources.

## The two paths

```mermaid
flowchart LR
  A[iPhone CarPlay H.264] --> B[NAL framing and callback]
  B --> C[Video forwarding and packet encryption]
  C --> D[Car head unit]
  E[Adapter UI graphics] --> F[RGB565 to I420 buffer]
  F --> G[Local video encoder]
  G --> C
```

The two sources converge on the video sender, not on a proven shared pixel compositor. Drawing on the local UI buffer is therefore not enough to put a marker on top of the live phone image.

## Evidence

All ranges are extracted from SHA-pinned stock files by [analyze_overlay_path.py](../../scripts/analyze_overlay_path.py). The [evidence index](evidence/index.json) identifies source hashes and address ranges. This is static analysis; vendor-specific Andes instructions remain undecoded in places, and GNU objdump's nearest exported symbol names often do not name the containing routine.

1. **Incoming data remains compressed.** `libCarLifeStub.so:ScreenStreamProcessData`, `0x1ed8–0x2086`, calls `H264GetNextNALUnit`, normalizes NAL framing, and delivers encoded bytes through `screenVideoProcessCallback` with event value 2. One branch rewrites framing in place; another copies NAL payloads into an allocated buffer. Neither examined path draws pixels. [Disassembly](evidence/incoming_nal_framing.asm)
2. **The main callback forwards that source.** `CPAAProxyEx:carplay_video_process`, `0x360f0`, reaches internal routine `0x35eb0`. That routine reads the NAL header (`byte[4] & 31` at `0x35eca–0x35ed6`). Its ordinary forwarding path passes the encoded buffer and length to `0x35a58` at `0x35fa4–0x35fc0`. [Callback](evidence/video_callback.asm), [incoming routine](evidence/incoming_compressed_video.asm)
3. **The sender accepts encoded video from either source.** Routine `0x35a58` has codec-configuration and frame-send branches, including calls to `0x4eca8` and `0x4ee7c`. The outgoing routine at `0x4ee7c` wraps/encrypts video bytes and sends the packet. A future overlay must provide a coherent replacement encoded stream upstream of this stage, not paint over ciphertext. [Source selection](evidence/video_source_selection.asm), [outgoing routine](evidence/outgoing_compressed_video.asm)
4. **The graphics library is not evidence of an H.264 decoder.** `libDecEncLib.so:bltImgToDisplay`, `0x3878–0x3a74`, converts RGB565 image rectangles into the global I420 image through `RGB565ToI420` and invokes a sync callback. Its exported API inventory is dominated by pixel-format conversions and buffer operations; no named H.264 decoder API was found. [Disassembly](evidence/rgb565_to_i420_blit.asm)
5. **Local UI encoding is separate.** Internal routine `0x35c28` locks the display image, passes its planes/strides into encoder wrapper `0x50d98`, unlocks it, then sends the produced bytes through `0x35a58`. For example, the calls at `0x35c90`, `0x35cb0`, and `0x35cd2` show that sequence. The executable also contains extensive x264 code strings. This proves an existing local encode route, not usable live decode/re-encode performance. [UI encoding](evidence/local_ui_encode.asm), [encoder wrapper](evidence/local_encoder_wrapper.asm), [UI blit call site](evidence/ui_blit.asm)

No named video-decoder import/export was found across the archived application ELF inventory. That is a limited negative result: stripped code, the separate base rootfs, and the kernel are not fully covered. The saved kernel log begins partway through boot and cannot establish every available driver.

## Hardware constraint

Allwinner's official [V821 product page](https://www.allwinnertech.com/index.php?c=product&id=136) lists H.264/JPEG encoding and JPEG decoding. It does not advertise H.264 decoding. The page explicitly describes V821L2-WXX and notes variant differences, so this is a warning against assuming acceleration, not conclusive identification of the adapter's exact silicon. The firmware's V821 build paths support investigating this family but do not resolve the variant.

## What an actual first overlay requires

For the straightforward implementation, add a decoder before the sender, draw a small opaque marker into the decoded frame, encode it, and feed the resulting configuration/frames through the existing sender. Keep the same 800×480 output and pixel coordinates, preserving the density patch and touch mapping.

The missing prerequisite is a usable H.264 decoder and measured total processing latency. At 60 fps the frame interval is about 16.7 ms; sustained throughput must meet that rate to avoid a growing queue. No on-device decode or encode benchmark has been run. Lowering the frame rate is an experiment, not an established fix.

The next implementation should be a bounded capture at the incoming callback, followed by decoding and benchmarking a representative stream. Confirm profile, parameter sets, frame types, resolution changes, decoder availability in the base system, and available CPU/RAM before integrating a persistent transcode loop. Keep capture local and bounded; live CarPlay frames may contain personal information. The current offline logs are not a video capture and are insufficient for this benchmark.

A bypass should remain the default whenever an experimental pipeline is inactive. Switching between the original and regenerated streams requires matching parameter sets and a clean keyframe transition; blindly alternating frames from separate encoders is not an overlay. Transparent bitmap injection, an LVGL label, or an extra H.264 metadata message is not a demonstrated alternative in this head unit. A compressed-domain editing approach would need separate codec-level research and a real stream sample.

## Current deliverable and validation

- Saved nine reproducible, annotated disassembly ranges covering the relevant application/library paths.
- Verified the three input executable hashes and that each requested range starts at an emitted instruction.
- Existing density firmware archives remain untouched.
- No overlay package was built or installed, and no claim of live overlay performance is made.

Reproduce:

```sh
.venv/bin/python scripts/analyze_overlay_path.py
```
