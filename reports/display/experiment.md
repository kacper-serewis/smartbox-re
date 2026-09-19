# Corsa display-density experiment

## Verified baseline

The offline collection from 2026-09-19 confirms that the adapter runs app code **131**, build **2026081801**, over system **20250811**. The Corsa supplies one observed display description: **800×480 pixels, 60 fps, 152×91 mm**. The video uses the full 800×480 rectangle. The user confirmed Smart Display Zoom is still missing after the stock update.

Apple documents Smart Display Zoom as available for some screen configurations, but does not establish eligibility thresholds in [its public introduction](https://developer.apple.com/videos/play/wwdc2025/216/). This experiment does not guarantee that the setting will appear.

## What the experiment changes

The normal display-property getter returns the cached head-unit display array when one exists. The separate `set_carplay_screen_size*` code supplies a fallback and is not a reliable patch point for this connected-car case.

The patch intercepts the existing-array return at virtual address `0x4dc74`. It requires exactly one dictionary in the array, and checks all four observed dimensions. Only when those match does it:

1. Create a mutable copy of the display dictionary.
2. Replace `widthPhysical=152` with `190` and `heightPhysical=91` with `114`.
3. Return a new single-element array holding that copy, with the ownership expected by the caller.
4. Log `Phone display override: 800x480 152x91mm -> 190x114mm (experimental)`.

The car's original array/dictionary is never written to. Pixel dimensions, frame rate, UUID, features, touch information, and other properties are preserved. Allocation/number-creation failures, multiple displays, unexpected types, or differing dimensions use the original return path. No other firmware component is changed.

The new reported physical dimensions are approximately 25% larger. This is a test of how iOS interprets physical display size; it does not add physical pixels, guarantee smaller controls, or guarantee Smart Display Zoom eligibility.

## Offline install

The adapter must be powered and this Mac connected to its Wi-Fi. Internet is not required. From the project directory:

```sh
python3 scripts/update_device.py apply --release firmwares/experiments/hw501_131_density125
```

Wait for the adapter to report **100%**. Then unplug/reconnect it, reconnect CarPlay, and inspect CarPlay Settings → Display. Check the icon/text size and touch alignment as well as whether Smart Display Zoom appears. No second update is required merely because its displayed app version remains 131.

Collect evidence after CarPlay reconnects:

```sh
python3 scripts/collect_device.py
```

The incoming head-unit log and `getcarlifeinfos` are expected to continue reporting 800×480 and the original physical dimensions where present. Look for the separate **DisplayScale / Phone display override** log marker to confirm that the hook ran. Its absence means the patch did not execute or its exact-match guard did not pass; it does not establish that iOS rejected the new size.

## Return to stock v131

If the adapter's normal Wi-Fi updater is still available:

```sh
python3 scripts/update_device.py apply --release firmwares/hw501/131
```

Wait for 100%, then unplug/reconnect. This is an application rollback, not a full-device recovery mechanism. The user has no tested recovery method or full backup and has explicitly accepted the risk of damaging a spare adapter. The experiment has not yet been tested on physical hardware.

## Validation

- Exact stock executable SHA-256 is required before patching; other input binaries are rejected.
- Hook code uses standard RV32 instructions, stored in verified zero padding. The existing executable load segment is extended within that space, without moving sections or changing file length.
- Emulator tests execute the actual hook instructions with modeled CF APIs. They check altered values, preservation of unrelated fields and original objects, callee-saved registers, stack alignment, return ownership, cleanup, mismatched dimensions, unexpected types, multiple displays, and allocation failures. These do not emulate the complete firmware or iPhone.
- Rebuilding and re-extracting SquashFS verifies every file/symlink and permission against the build inputs. The numeric stock and rebuilt filesystem listings also match exactly, including UID/GID, modes, timestamps, names, and sizes. Only `bin/CPAAProxyEx` content changes relative to stock.
- App image: **4,472,832 bytes**, within the **5,242,880-byte** app partition observed in the device's kernel log.
- The tar checksum and bundled image MD5 are regenerated. Full patch details and addresses are in [patch.json](patch.json).

Rebuild and test:

```sh
.venv/bin/python -m unittest discover -s scripts -p 'test_display_patch.py' -v
.venv/bin/python scripts/build_display_firmware.py
```

Dependencies are listed in `scripts/requirements-analysis.txt`; building also needs `mksquashfs` and `unsquashfs`.
