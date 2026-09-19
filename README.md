# Smartbox HW501 firmware research

Downloaded and compared the public HW501 application updates on 2026-09-19.

| Release | Archive bytes | Status |
|---|---:|---|
| v1.26 | 3,840,000 | Downloaded, extracted, verified |
| v1.27 | — | Listed in history, but server reports missing update file |
| v1.28 | 4,341,760 | Downloaded, extracted, verified |
| v1.31 | 4,485,120 | Downloaded, extracted, verified |

Read [findings](reports/findings.md) for the meaningful differences and [comparison](reports/comparison.md) for every changed file and archive hash. [comparison.json](reports/comparison.json) contains all file hashes and pairwise comparisons. Web page diffs and added/removed binary strings are in `reports/diffs/`.

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
