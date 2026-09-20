# HW501 findings

## Available releases

The history endpoint lists 131, 128, 127, and 126. The original server has working archives for **126, 128, and 131**. Both a direct archive request and the chunk API fail for 127; the API explicitly reports `update file not found`. Version codes 1–131 were checked against the original server's predictable archive URLs and, where unavailable, the chunk API: 3 present, 128 reported missing.

The `lastversion` endpoint still advertises 126 with version string `20250802126`. Therefore, “latest” and the history list disagree.

v131's web pages point to a second server, `114.132.94.163`, replacing `43.138.184.52`. The second server returns the same history and latest-version metadata. Full downloads of 126, 128, and 131 from that server have exactly the same SHA-256 as the original server; 127 is missing there too. Local copies of its metadata are in `firmwares/hw501/new-server/`, with verification results also preserved in [server-verification.json](server-verification.json).

## Image format and platform

All three archives contain exactly `app.img` and `appmd5sum.txt`. `app.img` is an XZ-compressed SquashFS application filesystem. These packages do not contain a bootloader, kernel, or a complete device flash backup.

Every ELF file in all three images is **32-bit RISC-V**, ELF machine 243. The main executables use the RISC-V ILP32D loader `/lib/ld-linux-riscv32-ilp32d.so.1`. The `CPAAProxyEx` binary in every version contains a build path ending in `libs/v821`; 128 and 131 also contain `libs/v821-ssl`. This is evidence that all three belong to the same V821-oriented software family. It does not establish compatibility with a particular physical board or its installed base system.

`UpdateServer` is byte-identical across all three versions. Its strings include an update command writing `/tmp/appupdate/app.img` to `/dev/by-name/app`, plus an MD5 comparison against `appmd5sum.txt`. This supports interpreting these as application-partition updates.

## v1.26 → v1.28

- 32 file/symlink entries unchanged, 10 changed, 25 added, 1 removed.
- `CPAAProxyEx`, `blueware`, and eight libraries change.
- Adds `libAutoProxy.so`, `libssl.so.1.1`, and `libcrypto.so.1.1`, plus SSL/crypto symlinks.
- Removes `libwebrtc_aec.so` as a separate file; this alone does not prove removal of echo cancellation functionality.
- Adds 20 images, mainly connection instructions and icons.
- Both configuration HTML pages, `UpdateServer`, and `mdnsd` remain byte-identical.

The new AutoProxy library and Android Auto-related strings suggest changes to the Android Auto implementation. Static comparison does not demonstrate connection reliability or specific bug fixes.

## v1.28 → v1.31

- 58 file/symlink entries unchanged, 9 changed, 6 added, none removed.
- Changes `CPAAProxyEx`, `mdnsd`, `libCoreUtils.so`, `libcrypto.so.1.1`, `libdns_sd.so`, `libiAP2Link.so`, `liblvgl.so`, and both configuration HTML pages.
- `blueware`, `UpdateServer`, `libAutoProxy.so`, `libssl.so.1.1`, and the AirPlay libraries remain byte-identical.
- Adds VAXT/DriveSync logos and four further instruction images.
- The UI adds 2.4 GHz channel choices 1, 6, and 11 alongside its existing 5 GHz choices. A new `PROXY_AP_USE_WIFI4` string appears in the main binary. This establishes UI/code changes, not verified radio operation on a device.
- The UI gives hardware and application versions separate rows and changes the update/log server IP to `114.132.94.163`.

## Apparent English updater regression in v1.31

In `131/rootfs/web/index_cptowlcp_en.html`, the history and normal update actions still call `startUpdateApp(...)` (lines 544 and 569), but the function definition present in v128 has been deleted. `startUpdateAppEx(...)` remains. The two included JavaScript libraries contain no replacement definition. The Chinese page still defines the wrapper (line 620).

In the bundled English page as inspected, calling those actions would reference an undefined function. This is a static finding; the page was not exercised on physical hardware. See [the English page diff](diffs/128-131/web__index_cptowlcp_en.html.diff).

The English history dialog's fallback URL also still lacks `/appupdate/` and reads `hwype` rather than `hwtype`. These defects are present in both v128 and v131, so they are not new regressions. The initial history prefetch uses the correct `/appupdate/` path.

## Version labels need care

| Archive label | app.img tar timestamp, UTC | Version-like string in CPAAProxyEx |
|---|---|---|
| 126 | 2025-08-02 08:19:27 | `20250630126` |
| 128 | 2025-12-18 10:07:33 | `20251218128` |
| 131 | 2026-09-15 08:38:42 | `2026081801` |

These are observed strings and archive timestamps, not proof of the application version that a running device will report. In particular, archive number 131 should not be taken to imply that every embedded version string ends in 131.

## Validation and limits

All three tar sizes match the chunk API. Their first and final chunks match byte-for-byte. Every image passes its bundled MD5; all SquashFS images extract successfully. The comparison records SHA-256 for each archive and regular file and compares symlink targets and file permissions. Timestamps are excluded from file-change counts.

The original release comparison was static and did not execute firmware or flash
an adapter. Later work includes the display experiments and a bounded
[QEMU application probe](../experiments/emulation/README.md). The latter starts
the stock application with Andes instruction support and substitute system
libraries, but encounters missing hardware and a SIGSEGV; it does not establish
full device emulation or real-world stability.
