# Corsa display-density experiment

## User-confirmed result — 2026-09-19

**density150 achieves the requested larger launcher grid.** After installing it, the user reported: “yup, way more icons 5 cols and 3 rows now”. That is **15 apps per page**, up from 8, on the Opel Corsa 2017 / HW501 / iOS 27 configuration. The Smart Display Zoom toggle state for this result was not specified. This confirms the visible grid through the user's hardware test; touch alignment and long-term stability were not separately reported.

After installing the density patch, the user reported: “It works, screen items are smaller and the smart display zoom is available.” This confirms smaller UI elements and availability of the setting on their Opel Corsa 2017 with the HW501 adapter and iOS 27. This is a user-reported hardware test; no post-patch diagnostic collection has been reviewed yet.

For the first patch, density125, the user subsequently confirmed that the launcher still had two rows of four apps, with more space between them, with Smart Display Zoom both enabled and disabled. The second trial below resolved the launcher app-count limitation in this configuration.

The first trial's package is `firmwares/experiments/hw501_131_density125/hw501_131.tar`, based on app v131/build 2026081801. Its SHA-256 is `f3f4a93505bde70608ff6bdc90d123e332129c5129da84d78ee858264e682963`. It remains available as a fallback; the successful 5×3 build is density150 below.

## Second trial: density150 — user-confirmed 5×3 grid

This package reports **228×137 mm**, approximately 50% larger than stock and 20% larger than the first trial. It uses the same guarded hook, preserving 800×480 pixels, 60 fps, and touch metadata. These percentages describe the reported physical dimensions, not a guaranteed change in UI scale. The user confirmed a 5×3 launcher grid with this build; results on other configurations are untested.

Package: `firmwares/experiments/hw501_131_density150/hw501_131.tar`. SHA-256: `d24f0df1339b434e90b33955c8734a49611a380357bbbc1466008d2d21548ce3`. Details: [patch-density150.json](patch-density150.json). The first trial's package and report are preserved separately.

Install while connected to the adapter's Wi-Fi:

```sh
python3 scripts/update_device.py apply --release firmwares/experiments/hw501_131_density150
```

Wait for 100%, unplug/reconnect, and reconnect CarPlay. Compare launcher rows and columns with Smart Display Zoom both off and on, check text size and touch alignment, then optionally run `python3 scripts/collect_device.py`. This build logs `Phone display override: 800x480 152x91mm -> 228x137mm (experimental)`.

To return to the first, user-tested density patch:

```sh
python3 scripts/update_device.py apply --release firmwares/experiments/hw501_131_density125
```

Both profiles passed the six emulator tests (12 tests total). The new package also passed filesystem metadata/content verification and the updater's archive validation. Its app image remains 4,472,832 bytes. To rebuild this second trial, use `.venv/bin/python scripts/build_display_firmware.py --density 150`.

## Verified baseline

The offline collection from 2026-09-19 confirms that the adapter runs app code **131**, build **2026081801**, over system **20250811**. The Corsa supplies one observed display description: **800×480 pixels, 60 fps, 152×91 mm**. The video uses the full 800×480 rectangle. The user confirmed Smart Display Zoom is still missing after the stock update.

Apple documents Smart Display Zoom as available for some screen configurations, but does not establish eligibility thresholds in [its public introduction](https://developer.apple.com/videos/play/wwdc2025/216/). The successful result above applies to this tested configuration.

## How the first trial works

The normal display-property getter returns the cached head-unit display array when one exists. The separate `set_carplay_screen_size*` code supplies a fallback and is not a reliable patch point for this connected-car case.

The patch intercepts the existing-array return at virtual address `0x4dc74`. It requires exactly one dictionary in the array, and checks all four observed dimensions. Only when those match does it:

1. Create a mutable copy of the display dictionary.
2. Replace `widthPhysical=152` with `190` and `heightPhysical=91` with `114`.
3. Return a new single-element array holding that copy, with the ownership expected by the caller.
4. Log `Phone display override: 800x480 152x91mm -> 190x114mm (experimental)`.

The car's original array/dictionary is never written to. Pixel dimensions, frame rate, UUID, features, touch information, and other properties are preserved. Allocation/number-creation failures, multiple displays, unexpected types, or differing dimensions use the original return path. No other firmware component is changed.

The new reported physical dimensions are approximately 25% larger. The patch changes how iOS interprets physical display size without adding physical pixels. In the user's test, this produced smaller screen items and made Smart Display Zoom available.

## Offline install of the first trial (density125)

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

Wait for 100%, then unplug/reconnect. This is an application rollback, not a full-device recovery mechanism. The user has no tested recovery method or full backup and has explicitly accepted the risk of damaging a spare adapter.

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
