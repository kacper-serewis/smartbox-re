# SmartBox HW501 CarPlay dongle firmware research and mods

> **Disclaimer:** This repository is coordinated by me and was written entirely by GPT-6-Astra.

Reverse engineering, firmware analysis, and experimental mods for the
**SmartBox HW501 USB wireless CarPlay adapter** sold on AliExpress and similar
marketplaces. The repository covers stock firmware downloads, offline device
diagnostics, binary analysis, display-density modifications, emulation, and an
experimental investigation into CarPlay/Screen Mirroring selection.

> **Compatibility:** This work targets dongles that report hardware type
> **HW501**. SmartBox (also displayed as `smartBox`) is used for several different
> products, so do not flash these images on another hardware family.

## Tools you can use now

These tools are implemented and documented. “No firmware change” means the tool
does not install or alter firmware; it may still save logs or screen captures on
the computer.

| Tool | What it does | Device impact | Start here |
|---|---|---|---|
| [Device inspector](scripts/update_device.py) | Reads the adapter identity, CarPlay information, settings, and update status into a timestamped local snapshot. | **No firmware change** | `python3 scripts/update_device.py inspect` |
| [Offline diagnostic collector](scripts/collect_device.py) | Samples display status and downloads the adapter's diagnostic archive while connected to its Wi-Fi. | **No firmware or setting change** | `python3 scripts/collect_device.py` |
| [Stock firmware downloader](scripts/download_firmwares.py) | Downloads public HW501 application updates, verifies their structure/checksums, and records provenance. No dongle connection is needed. | **Does not contact the dongle** | `python3 scripts/download_firmwares.py --probe-unlisted` |
| [Firmware comparison](scripts/compare_firmwares.py) | Extracts downloaded images, inventories every file, and produces hashes and version-to-version diffs. | **Local analysis only** | `python3 scripts/compare_firmwares.py` |
| [Mac Screen Mirroring capture](experiments/mirroring/README.md) | Runs a bounded AirPlay receiver on a Mac and saves the iPhone's H.264 video for protocol analysis. | **Does not contact the dongle; records the phone screen locally** | Build with `python3 scripts/capture_mirroring.py --build`, then run without `--build` |
| [Mode-page preview](experiments/mode/README.md) | Opens the CarPlay/Screen Mirroring settings UI with a simulated driver. | **Local simulation only** | `python3 scripts/preview_mode.py` |
| [Binary-analysis pipeline](reports/binary-analysis.md) | Reproduces firmware inventories, function evidence, and annotated RV32 disassembly. | **Local analysis only** | See [reproduction commands](#reproduce-the-binary-analysis) |
| [QEMU test environment](experiments/emulation/README.md) | Runs the mode-service tests and bounded probes of stock RV32 application code. | **Isolated local emulation** | See the [emulation guide](experiments/emulation/README.md#reproduce) |

### Tools that can write or build firmware

- [`build_sony_firmware.py`](scripts/build_sony_firmware.py) builds a fixed
  Sony XAV-AX1005DB audio profile from stock HW501 v131. The
  [experimental image](reports/audio/sony-build/README.md) passes offline
  negotiation and package checks; boot and audible playback are untested.
- [`update_device.py`](scripts/update_device.py) also has `stage` and `apply`
  actions. `stage` uploads an archive; `apply` requests a flash. Use them only
  with a verified release for the exact HW501 target. The tool explicitly rejects
  the withdrawn mirroring archive.
- [`build_display_firmware.py`](scripts/build_display_firmware.py) builds and
  verifies the v131 density profiles from a locally archived stock image. The
  output becomes device-writing only when installed with `update_device.py`.
- The [mirroring build scripts](experiments/mirroring/README.md) are development
  tools. Their components pass local/RV32 tests, but there is currently no safe,
  hardware-validated mirroring image to install.
- [`recover_updater.py`](scripts/recover_updater.py) is pinned to the one recorded
  `smartBox-9302` recovery incident. It is not a general recovery or unbricking
  tool and should not be used on another adapter.

## Current work and next milestones

| Workstream | Already completed | Still needed |
|---|---|---|
| Safe on-dongle Screen Mirroring | Receiver, bridge, selector, supervisor source fix, and native/RV32 tests. | Prepare a new image that does not contain the withdrawn supervisor, then verify boot, normal CarPlay, iPhone pairing, mirrored video on the Corsa, failure fallback, and a subsequent stock update on physical hardware. |
| Display-density tuning | density125 and density150 were tested on one car; density150 produced a 5×3 grid. density137.5 was installed with successful readback and reboot. | Test density137.5 in CarPlay and record its layout, Smart Display Zoom behavior, touch alignment, and stability. |
| More complete HW501 emulation | Andes QEMU runs the RV32 tests and reaches stock-app initialization. | Supply controlled substitutes for the missing base filesystem and hardware interfaces; current emulation cannot reproduce the USB/iAP2, MFi, Wi-Fi/Bluetooth, or car-facing environment. |
| Live CarPlay overlay | Static analysis identified the compressed-video receive, local encode, and car-facing send paths. | Capture a representative stream and measure on-device H.264 decode/draw/re-encode latency before attempting an overlay package. |

## Experiment status

“Experimental” does not mean ready for general use. Some work has been tested on
one physical adapter, some only in an emulator, and some is research with no
installable package. The current status is:

| Experiment | What it is | Current status |
|---|---|---|
| [Display density125](reports/display/experiment.md) | Changes the physical-size metadata reported to CarPlay to make interface elements smaller. | **Tested on one physical setup:** HW501 v131, Opel Corsa 2017, and iOS 27. Smaller items and Smart Display Zoom were confirmed, but the launcher remained 4×2. |
| [Display density150](reports/display/experiment.md#second-trial-density150--user-confirmed-53-grid) | A stronger version of the same guarded metadata patch. | **Tested on the same physical setup:** a 5×3 launcher grid was confirmed. Touch alignment and long-term stability were not separately verified. |
| [Display density137.5](reports/display/experiment.md#midpoint-trial-density1375--prepared-awaiting-car-test) | A midpoint between density125 and density150. | **Installed and reboot-verified, display result unknown:** flash readback succeeded during recovery, but CarPlay and the resulting interface layout were not retested. |
| [Mac screen-capture harness](experiments/mirroring/README.md) | Receives and records an iPhone Screen Mirroring H.264 stream on a Mac for protocol testing. | **Local prototype:** capture and transport tests pass. This does not test the dongle or car display. |
| [On-dongle Screen Mirroring and mode selector](experiments/mirroring/FLASHING.md) | An RV32 receiver/bridge and web selector intended to switch between normal CarPlay and Screen Mirroring. | **WITHDRAWN — DO NOT INSTALL:** the only built archive can terminate the stock updater during an update. The affected adapter was [recovered](reports/overlay/updater-supervisor-conflict.md) and a source fix passes native/RV32 tests, but no corrected image has been prepared or physically validated. The updater rejects the withdrawn archive hash. |
| [Connection-mode service](experiments/mode/README.md) | Saves the selected mode, exposes the settings page, dispatches startup, and falls back to CarPlay on failure. | **Component tested only:** native and RV32/QEMU tests pass. Physical mode switching was never verified; its device integration was part of the withdrawn image. The separate staging bundle is not flashable. |
| [HW501 emulation](experiments/emulation/README.md) | Runs RV32 components and probes the stock application with QEMU/Andes instruction support. | **Partial emulation:** tests run and the stock app reaches initialization, then fails around missing hardware. This is not a firmware boot, stable CarPlay session, or full dongle emulator. |
| [Live CarPlay overlay](reports/overlay/feasibility.md) | Research into drawing over the incoming CarPlay video stream. | **Research only:** relevant compressed-video paths were identified, but no overlay patch or installable package exists. On-device decode/re-encode performance is unknown. |

The density results apply only to the single hardware/car/iOS combination above.
Stock firmware is always the reference rollback where the normal updater remains
available; this repository does not provide a full-device recovery image.

## Collect display information offline

With the adapter plugged into the Corsa, connect the iPhone to CarPlay and this Mac to the adapter's Wi-Fi. Internet is not needed. Run:

```sh
python3 scripts/collect_device.py
```

It samples the running app version and CarPlay display status for 60 seconds, then requests a local diagnostic-log archive. Output is saved under `device-snapshots/offline-<timestamp>/`, including `summary.json`, `display-lines.txt`, raw status responses, and the original log archive when available. It does not change settings or firmware or upload logs to the vendor. Use `--seconds 120` to allow more time to connect CarPlay, or `--no-logs` to collect status only. Reconnect to the internet afterward to review the saved files together.

## Downloaded stock firmware

Downloaded and compared the public HW501 application updates on 2026-09-19.

| Release | Archive bytes | Status |
|---|---:|---|
| v1.26 | 3,840,000 | Downloaded, extracted, verified |
| v1.27 | — | Listed in history, but server reports missing update file |
| v1.28 | 4,341,760 | Downloaded, extracted, verified |
| v1.31 | 4,485,120 | Downloaded, extracted, verified |

Read [findings](reports/findings.md) for the meaningful differences and [comparison](reports/comparison.md) for every changed file and archive hash. [comparison.json](reports/comparison.json) contains all file hashes and pairwise comparisons. Web page diffs and added/removed binary strings are in `reports/diffs/`.

The deeper [binary analysis](reports/binary-analysis.md) identifies actual iAP2 queue handling, CarPlay timeout recovery, MFi initialization, Bluetooth build, and discovery-stack changes, with annotated disassembly as evidence.

The [Corsa display experiment](reports/display/experiment.md) documents the verified running v131 baseline, a guarded physical-display-metadata patch, emulator validation, and offline install/rollback commands. On their Opel Corsa 2017 with iOS 27, the user confirmed smaller screen items and Smart Display Zoom availability with density125, then **5 columns × 3 rows (15 apps per page)** with density150, up from 4×2. The successful density150 package is preserved under `firmwares/experiments/hw501_131_density150/`.

## Repository layout

Each available version has its own directory under `firmwares/hw501/<version>/`:

- `hw501_<version>.tar`: original update archive.
- `archive/app.img`: original SquashFS image.
- `archive/appmd5sum.txt`: publisher's bundled checksum.
- `rootfs/`: extracted application filesystem; this is not the complete device root filesystem.
- `manifest.json`, `inventory.json`, `strings/`, `extraction.log`: provenance and analysis.

The download directory is excluded from Git. The scripts and comparison reports are intended to be tracked. No device connection is needed, and neither script flashes a device or executes firmware programs.

## Reproduce

Requires Python 3.10+ and `unsquashfs` (`brew install squashfs` on macOS).

```sh
python3 scripts/download_firmwares.py --probe-unlisted
python3 scripts/compare_firmwares.py
```

The downloader saves the history and latest-version responses, checks predictable archive URLs for version codes 1 through the highest advertised version, and consults `appdatas` when those URLs are unavailable. Only 126, 128, and 131 were available in the initial scan of 1–131. Without `--probe-unlisted`, it checks the advertised releases only.

Archives are fetched directly from `http://43.138.184.52/appupdate/hw501_update_v<VERSION>.tar`, with a validated chunk-download fallback. Archive size and first/final chunks are checked against `appdatas`. The complete `app.img` is checked against its bundled MD5, and SHA-256 hashes are recorded for the archives and extracted files. Local checksums are not a vendor signature.

This covers HW501 on the identified update service, not every hardware family sold under the Smartbox name. The current scan cannot establish that no other versions exist outside the scanned range or under different names.

## Reproduce the binary analysis

```sh
python3 -m venv .venv
.venv/bin/python -m pip install -r scripts/requirements-analysis.txt
.venv/bin/python scripts/analyze_binaries.py
brew install binutils
.venv/bin/python scripts/disassemble_evidence.py
```

The disassembly script accepts `--objdump /path/to/riscv-capable-objdump`; it defaults to GNU objdump on PATH or Homebrew's keg location. Apple's bundled objdump cannot disassemble these RISC-V images. Function fingerprints are triage aids, not semantic-equivalence tests; see the binary report for limitations concerning Andes instructions and stripped symbols.
