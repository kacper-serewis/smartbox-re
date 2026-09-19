# CarPlay presentation controls in HW501 v131

Analysis date: 2026-09-19. Scope: archived stock `CPAAProxyEx`, supporting libraries, the existing Corsa diagnostic archive, and Apple's public vehicle-integration documentation. No new firmware was installed during this investigation.

## Findings

| Control | Evidence in this adapter | Practical implication | Status |
| --- | --- | --- | --- |
| Physical display size | `widthPhysical`, `heightPhysical`; cached display getter at `0x4dc4c` | Influences iOS scaling and launcher layout | User-tested: density125 gives 4×2, density150 gives 5×3; density137.5 built, outcome not yet reported |
| Driver side | `rightHandDrive` input, cached Boolean, output getter | Candidate for swapping the status bar and related app content between left and right | Complete input/output path identified; override not implemented or tested |
| Night mode | `nightMode` input/output and `setNightMode` command forwarding | Candidate for a configurable night-mode override | Paths identified; must handle both initial state and later commands |
| View/safe areas | `initialViewArea`, `viewAreas`, rectangle coordinates, nested `safeArea`, `drawUIOutsideSafeArea` | Describes where iOS may place content; can support alternate view shapes | Active parsing confirmed; Corsa supplied zero custom view areas in baseline |
| Bottom status bar | Apple documents a view-area flag for overriding status-bar position | Potentially move the vertical bar to the bottom | Exact flag encoding and this adapter's compatibility remain unknown |
| Pixel dimensions / aspect ratio | `widthPixels`, `heightPixels`, video configuration packet | Could request a different render geometry, with coordinated video and touch support | No verified higher-resolution/downscaling or rotation patch |
| Input capabilities | `primaryInputDevice`, `hidDevices`, `hidDescriptor`, `displayUUID` | Advertises actual input devices associated with a display | Not a demonstrated density/layout setting; preserve for working touch |

Apple describes the driver-side behavior in [CarPlay Audio and Navigation Apps](https://developer.apple.com/videos/play/wwdc2018/213/): status bar and app content switch sides for right-hand-drive vehicles. This supports the expected effect of the firmware's flag, but does not establish exactly which iOS 27 elements would move on the Corsa.

Apple's [2023 vehicle-systems presentation](https://developer.apple.com/videos/play/wwdc2023/10150/) describes automatic status-bar placement based on resolution/aspect ratio and an override through a view-area flag. It also distinguishes interactive content inside the safe area from optional background drawing outside it. We have not recovered the status-bar flag name or value; no numeric bit is inferred from unrelated `features` fields.

## Confirmed binary paths

The SHA-pinned extraction script [analyze_display_metadata.py](../../scripts/analyze_display_metadata.py) generates seven annotated disassembly ranges and a [key/address index](metadata-evidence/index.json). Annotations distinguish inline CFString object addresses from the ASCII text eight bytes later. GNU objdump's nearest symbol names often refer to earlier exported functions; they are not reliable names for these internal routines. Undecoded Andes instructions remain explicit unknowns.

### Display dictionary and rectangles

- [Input display array](metadata-evidence/display_array_input.asm): the code retrieves the `displays` array through `CFDictionaryGetTypedValue` at `0x2aef0–0x2af00`, then examines its entries.
- [Geometry parsing](metadata-evidence/display_geometry_input.asm): pixel size, frame rate, and physical dimensions are read at `0x2ba34–0x2bb0c`. The code reads `initialViewArea` at `0x2bb5a–0x2bb68` and `viewAreas` at `0x2bb78–0x2bb84`.
- Each view area supplies width/height and origin X/Y. At `0x2bc80–0x2bd34`, a nested `safeArea` supplies the same fields plus `drawUIOutsideSafeArea`. Selected rectangle values are stored at object offsets 560, 564, 568, and 572 (`0x2bd4e–0x2bd5a`). This is active parsing, not just unused strings.
- [Output getter](metadata-evidence/cached_display_output.asm): when a cached display array exists, the normal path returns it with retained ownership. Our existing density hook changes a copy at this point. A nested view-area experiment would need its own copied array/dictionaries to avoid modifying the original cache; the current patch does not do this.

Apple describes multiple declared view areas and dynamic transitions in [Advances in CarPlay Systems](https://developer.apple.com/videos/play/wwdc2019/252/). This establishes the protocol concept, not complete implementation of dynamic switching in this adapter.

### Driver side and night mode

- [Input](metadata-evidence/driver_side_and_night_input.asm): `rightHandDrive` is read at `0x2b7b4–0x2b7c8` and converted to a cached Boolean at object offset 228. Night mode uses the adjacent offset 232.
- [Output](metadata-evidence/driver_side_and_night_output.asm): the property getter matches `rightHandDrive` at `0x4d870–0x4d884` and returns the cached object at `0x4d886`; it matches `nightMode` at `0x4d8ac–0x4d8c0` and reads offset 232 at `0x4d8c2`.
- [Runtime night-mode command](metadata-evidence/night_mode_command.asm): `setNightMode` is matched at `0x294f0–0x29504`. The code reads its `nightMode` value, updates the cache, and forwards the dictionary through `AirPlayReceiverSessionSendCommand` at `0x2956c–0x29570`.

An initial-property-only night override could be superseded by a later command. These CF properties are not established HTTP endpoints or existing web settings.

### Video and input constraints

The [video configuration packet routine](metadata-evidence/video_config_packet.asm) handles encoded configuration data and geometry together. In particular, it serializes geometry fields around `0x4ed58–0x4ed8e`. This supports treating pixel-size changes as a video-path task, not merely adding two different numbers to the phone-facing dictionary. It does not prove that the adapter can rescale arbitrary video formats.

String inspection of the main executable and `libAirPlay.so` did not identify a named rotation/orientation or launcher row/column property. Absence of such strings is not proof that the protocol lacks related capabilities. We have no direct arbitrary-grid or freeform Dashboard layout control.

## What the Corsa actually supplied

The archived baseline `device-snapshots/offline-20260919T153949.251951Z/adapter-logs.tar` contains:

```text
Recv proxy disply viewareas:0 inInitialArea:0
SendProxyScreenVideoConfigFrame sps pps width:800 height:480 pos:0x0 size:800x480 len:32!
```

Together with the original 152×91 mm description, this provides no evidence of a custom safe-area border to reclaim. It does not expose the iPhone's internal layout margins. Introducing an inset rectangle would allocate less space to content, not automatically remove iOS padding.

## Sensible next experiments

1. **Sidebar side:** preserve the tested density and override only `rightHandDrive`, using a separate guarded getter hook and retained Boolean ownership. This has the clearest firmware path, but changes positioning rather than increasing app count.
2. **Bottom bar:** recover the actual view-area position flag before making a test build. Start with full-screen geometry if supported, retaining 800×480 and touch descriptors. Do not guess capability-bit values.
3. **More layout tuning:** continue varying physical dimensions independently of video pixels, comparing launcher, Dashboard, and navigation views. The outcome remains an iOS layout choice.

The offline collector now retains view-area, safe-area, input-device, driver-side, and night-mode log lines in addition to existing density markers. It still only collects diagnostics; it does not change settings or add logging to the firmware. A complete outgoing dictionary dump would require separate firmware instrumentation.

Reproduce the static evidence:

```sh
.venv/bin/python scripts/analyze_display_metadata.py
```
