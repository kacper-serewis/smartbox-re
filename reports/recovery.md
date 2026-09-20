# HW501 recovery access and boot recovery investigation

2026-09-20. Implemented owner-key SSH and a recovery page through an SSH tunnel.
The initial package preserves density137.5 and normal CarPlay. Installation and
a complete restore on physical hardware remain untested. See the
[build and operating instructions](../experiments/recovery/README.md).

## Application recovery

Recovery starts from a small bootstrap and runs independently from RAM in its
own session. Dropbear accepts the supplied owner's Ed25519 key; password support
is compiled out. Its host key is generated on the adapter and retained separately
from the application partition. Neither an owner private key nor a shared device
host private key is included in firmware.

The recovery page binds to loopback. Restore preparation stops the tracked app
without signalling its process group, disables experiments, and starts the
unchanged vendor updater from RAM. This directly avoids the
[recorded supervisor/updater conflict](overlay/updater-supervisor-conflict.md).
The updater's SHTTPD 1.42 accepts only port numbers, not address:port bindings;
its deny-all ACL permits only `127.0.0.1/32`, reached through authenticated SSH.
Emulation verified both allowed access and rejection of source `127.0.0.2`.

Native and RV32 tests cover key authentication, a rejected alternate key, SSH
forwarding restrictions, the real tunneled webpage, host-key persistence,
malformed and cross-origin HTTP, app failure, bootstrap detachment, maintenance
respawn, a missing bundle, stale PIDs, open application files, reboot guards, and
updater survival. The real vendor updater is queried without requesting a flash.
The test runner records input hashes before running and rejects changes during
the run. Packaging requires a current passing full test report and enforces the
observed 5 MiB partition limit with complete image re-extraction verification.

One emulation discrepancy was resolved: pointing a static RV32 program at the
Bootlin sysroot causes QEMU to substitute that sysroot's empty `/proc` directory.
Static recovery/SSH tests now use the real root; only the dynamically linked
vendor updater uses the substitute loader/libraries. The recovery source also
uses 64-bit file offsets and treats directory-enumeration errors as failures.

## Recovery outside the application partition

The archived vendor updates contain only `app.img` and its checksum, and cannot
restore the bootloader, kernel, or base filesystem. Existing binary evidence
points toward the V821 family, but does not identify the precise board/chip
variant. There is no verified alternate boot slot, UART pinout, full flash backup,
or board-specific USB recovery procedure in this repository.

The [XFEL project's current support list](https://xfel.xboot.org/reference/support-list/)
lists V821, ID `0x00188200`, with basic FEL, reset, SID, JTAG, DDR, SPI NOR and SPI
NAND support. Its [source repository](https://github.com/xboot/xfel) supports ARM
and RISC-V Allwinner devices. This is a promising tooling lead, **not evidence
that this HW501 board exposes a usable recovery mode**.

Before attempting boot-level changes, establish the adapter's exact chip, flash
layout, boot configuration, USB recovery entry method, and a verified full-device
backup. Start with read-only identity and partition inspection through the new
SSH access once physically validated. Board-specific entry and boot-ROM identity
must be confirmed before choosing flash operations. No boot-ROM command or
bootloader modification was performed during this work.

## Validated local build

- Recovery fault/authentication tests: **11 native + 11 RV32 passed**.
- Existing update protocol tests: **5 passed**; incident-specific recovery tests: **7 passed**.
- Application image: **5,136,384 / 5,242,880 bytes**, leaving 106,496 bytes.
- Archive: `firmwares/experiments/hw501_131_recovery_density137.5/hw501_131.tar`.
- Archive SHA-256: `194a20884c4ef47b4d1243ceaa0a5e92adf80742d529d5249a72336320121758`.
- Image re-extraction, every file hash/mode, static RV32 binaries, bundled MD5, and update chunk metadata verified.
- Hardware tested: **no**. No device connection, upload, or flash performed.
