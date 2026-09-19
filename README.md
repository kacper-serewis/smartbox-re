# Smartbox HW501 firmware research

## Collect display information offline

With the adapter plugged into the Corsa, connect the iPhone to CarPlay and this Mac to the adapter's Wi-Fi. Internet is not needed. Run:

```sh
python3 scripts/collect_device.py
```

It samples the running app version and CarPlay display status for 60 seconds, then requests a local diagnostic-log archive. Output is saved under `device-snapshots/offline-<timestamp>/`, including `summary.json`, `display-lines.txt`, raw status responses, and the original log archive when available. It does not change settings or firmware or upload logs to the vendor. Use `--seconds 120` to allow more time to connect CarPlay, or `--no-logs` to collect status only. Reconnect to the internet afterward to review the saved files together.

## Downloaded firmware

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

## Local artifacts

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
