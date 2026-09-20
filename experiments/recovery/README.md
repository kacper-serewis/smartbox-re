# HW501 recovery access

Experimental recovery for HW501 v131, using the owner's Ed25519 public key.
The initial image preserves density137.5 and normal CarPlay. It does not add
mirroring. No device has been flashed or hardware recovery validated by this work.

## Connect after installation

Join the adapter's Wi-Fi and keep it powered. Use the private key corresponding
to the public key supplied when building the image:

```sh
ssh -p 2222 -i ~/.ssh/id_ed25519 root@192.168.5.1
```

Keep normal SSH host-key verification enabled. The adapter generates its own
Ed25519 host key on first boot and retains it in
`/mnt/UDISK/smartbox-recovery/hostkey`. The firmware contains only the owner's
public key. Check the host fingerprint on the trusted first connection; a later
unexpected change needs investigation. Key rotation requires a rebuilt image.

For the recovery page and updater, leave this tunnel running in a terminal:

```sh
ssh -N -p 2222 -i ~/.ssh/id_ed25519 \
  -o ExitOnForwardFailure=yes \
  -L 127.0.0.1:18083:127.0.0.1:8083 \
  -L 127.0.0.1:18082:127.0.0.1:8082 \
  root@192.168.5.1
```

Open <http://127.0.0.1:18083/>. Authentication and encryption are supplied by SSH;
the recovery page binds only to the device's loopback interface. The vendor
updater's SHTTPD does not support address-specific binding: it listens on port
8082 with a deny-all ACL allowing only source `127.0.0.1/32`. SSH listens on
`192.168.5.1:2222`; password authentication, remote forwarding, agent forwarding,
and X11 forwarding are compiled out. The authorized key limits local forwarding
to these two HTTP destinations. Full shell access is intentionally available to
the owner. Existing vendor services, including port 80, are unchanged.

The page provides status, a bounded recovery-log download, a persistent option
to disable experimental features, restore preparation, and a stock-mode reboot.
Browser write requests require a custom header and a matching localhost origin;
unexpected Host headers, cross-origin writes, oversized requests, and unknown
paths are rejected. The log covers recovery/SSH/updater output, not all CarPlay
diagnostics.

## Restore

Choose **Prepare firmware restore** on the page. This stops the tracked app
process, latches experiments off, and starts the unchanged stock UpdateServer in
its own session. It neither uploads nor flashes anything. Preparation refuses
an occupied updater port or unresolved references to the application partition.
The unchanged `blueware` and `mdnsd` executables are left to the stock updater's
existing shutdown sequence. Unknown processes are never forcibly killed.

Use a verified HW501 release with the existing tool, through the tunnel:

```sh
python3 scripts/update_device.py inspect --device http://127.0.0.1:18082
python3 scripts/update_device.py apply --device http://127.0.0.1:18082 \
  --release firmwares/hw501/131
```

`apply` uploads and requests the flash. Keep power connected until the updater
reports completion. The web reboot action is refused while the recovery updater
exists or the tracked application has stopped (which could indicate a normal
update), so verify completion before rebooting over SSH with `sync; reboot`.
Restoring stock firmware removes recovery access after reboot. Restoring the
earlier density-only image also removes it.

If preparation reports that the partition is in use, inspect process mappings,
open files, and working directories over SSH. Run `cd /tmp` in shell sessions
before preparing an update. If preparation fails after stopping CarPlay, it
leaves the app stopped and reports the error; correct the cause and retry.

## Process and storage design

`bin/CPAAProxyEx` becomes a static bootstrap. It copies the recovery bundle,
stock updater, and stock web files into private `/tmp/smartbox-rescue`, starts
`recoveryd` in a separate session, then execs `launch/CPAAProxyEx`. If recovery
startup fails, it falls back to `stock/CPAAProxyEx`, without experimental hooks.
Both relocated application executables retain the basename `CPAAProxyEx`, which
the vendor updater uses for process shutdown.

The daemon and Dropbear are static RV32 ILP32D binaries. They run from RAM and
have no executable/library dependency on `/mnt/app`. The vendor updater still
uses base-system libraries, as it did during the recorded physical recovery.
The daemon verifies the original app's PID and creation time before signalling
it. A RAM maintenance marker keeps a vendor init respawn from restarting the app
during a restore. Its holding process also executes from RAM.

Dropbear's relative authorized-key path is anchored in the verified private
runtime directory. This retains its directory-permission checks without treating
the system's sticky `/tmp` directory as the key directory. The host key is copied
from persistent storage into RAM. The daemon retries SSH startup if the Wi-Fi IP
is not yet present. App failure or supervisor cleanup does not terminate rescue
services. A running updater and established SSH sessions survive a graceful
recovery-daemon shutdown.

This protects against application failures **only while Linux and networking
remain functional**. The application partition supplies the bootstrap on each
boot. Corruption of that partition, loss of power midway through writing, base
system failure, or absent Wi-Fi can still prevent recovery. Wi-Fi startup is not
yet independent of vendor software. No bootloader, A/B slot, UART, or USB ROM
recovery path has been established. The device's account database, persistent
storage permissions, entropy availability, free RAM, CarPlay behavior, and a
complete stock restore still need physical testing.

## Build and validate

Prerequisites: Python 3.10+, SquashFS tools, Docker, the existing
`smartbox-mirror-builder:local` image, the pinned 2021.11 RV32 toolchain under
`firmwares/research/mirror-deps`, the archived HW501 v131 image, and the
[Andes QEMU build](../emulation/README.md). Artifacts and keys stay under ignored
`firmwares/`; no public or private owner key is committed to the repository.

```sh
python3 scripts/build_recovery.py --setup --authorized-key /path/to/owner.pub
docker build --platform linux/amd64 -f experiments/recovery/Dockerfile.tests \
  -t smartbox-recovery-tests:local experiments/recovery
python3 scripts/test_recovery.py
python3 scripts/build_recovery_firmware.py
```

`--setup` downloads the SHA-256-pinned Dropbear 2026.94 source over HTTPS. The
build verifies that archive, extracts it fresh, compiles only the server and key
generator, records all source/binary hashes, and includes upstream licensing.
`--deps` on the builder and test runner can select an existing toolchain location;
`--qemu` on the test runner can select an existing Andes build.

The output is
`firmwares/experiments/hw501_131_recovery_density137.5/hw501_131.tar`.
The packager requires a current passing full test report, verifies static RV32
executables, enforces the observed 5 MiB application-partition limit, re-extracts
and compares every file, and validates update-archive checksums/chunk metadata.
The mirroring packager now requires the same recovery bundle and tests; its
driver symlink bypasses the bootstrap. A combined mirroring/recovery image has
not been built or hardware-validated, and may require space reductions.

Tests use a disposable read-only container with no external network and no
device nodes exposed for firmware flashing. They exercise native and RV32
recovery code, real RV32 Dropbear key authentication, rejection of a different
key, forwarding restrictions, tunneled HTTP, malformed/cross-origin requests,
host-key persistence, app death, bootstrap detachment, maintenance respawns,
PID reuse protection, refusal of open application files, and updater survival.
The real vendor updater is started and queried without a flash request; simulated
updater/reboot programs test control actions. Explicit emulator wrappers replace
cross-architecture execs in tests; this is not a full dongle boot or flash test.
