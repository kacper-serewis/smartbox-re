# Experimental HW501 mirroring image

**Withdrawn on 20 September 2026:** the archive with SHA-256
`9bbc62e44225839cbf18d1f5c60a23f26d4d534714785a987f372081d62a58a8`
contains supervisor cleanup that can kill the stock updater. Do not install it.
The local updater now rejects this archive by its actual content hash. See the
[investigation](../../reports/overlay/updater-supervisor-conflict.md). A source fix
has passed native/RV32 tests; recovery of the already affected adapter remains
unverified. The build/flash instructions below describe the withdrawn image.

For the step-by-step car-side procedure, use the [offline user guide](USER_GUIDE.md).

The local update is built at:

`firmwares/experiments/hw501_131_mirroring_density137.5/hw501_131.tar`

This is a flashable **experimental** application update, not a hardware-validated
mirroring release. It preserves v131 and density137.5 (209×125 mm physical
metadata, 800×480 CarPlay video). CarPlay is the default on a device with no saved
mode. The update includes a real receiver and bridge; the selector is not a demo.

The image fits the observed 5 MiB app partition. Its manifest and SHA256SUMS record
the exact archive hash. The builder re-extracts the image, checks the filesystem,
and validates the update archive/chunk metadata with the upload tool.

## Flash offline

Connect the Mac to the powered adapter's Wi-Fi. From the repository directory:

```sh
python3 scripts/update_device.py apply \
  --release firmwares/experiments/hw501_131_mirroring_density137.5
```

The command verifies the local archive, checks HW501, uploads acknowledged chunks,
requests the update, and waits for the adapter to report 100%. Internet access is
not needed. Replug after confirmed completion and reconnect to its Wi-Fi.

## Choose the connection type

1. Check ordinary CarPlay first after flashing.
2. Open `http://192.168.5.1:8081/`, or **Connection mode** on the stock settings page.
3. Select **Screen Mirroring**, save, and replug the adapter. Changes apply at boot.
4. Rejoin the adapter Wi-Fi. The mode page shows the current AirPlay pairing code
   before connecting; note it or leave the page open on the Mac.
5. On the iPhone, open Control Center → Screen Mirroring → **SmartBox Mirror**.
   Enter the code. Start with an ordinary landscape screen while parked.
6. To return, select **CarPlay**, save, and replug.

If receiver initialization fails, the service attempts cleanup and CarPlay
fallback. The selected mode is preserved and the page reports the fallback.
An external supervisor now also detects app termination (including fatal signals
and failed exec), disables the
mirroring library persistently, and launches the density-patched original app.
The settings page runs as a separate supervised process and reports recovery.
The original app gets at most three launch attempts; if it also keeps failing,
retries stop and the page remains available if its own service can run.
The corrected source terminates only the application PID, preserving the vendor
updater helper. The withdrawn archive still contains the earlier group cleanup.

A missing integration socket after 15 seconds also triggers recovery. A
persistent boot-pending flag protects the first 30 seconds: if startup is
interrupted, the next launch skips mirroring. Normal shutdown clears this flag.
An early power removal can therefore intentionally trigger recovery too.

Recovery is latched in `/mnt/UDISK/smartbox-mode/recovery-disabled` (and possibly
`boot-pending`). Saving a mode or reflashing the app partition does not clear it.
Re-enabling the experiment requires explicitly removing both files while the app
is stopped, through a device shell/recovery tool; there is currently no web reset.
The mode page does not claim a confirmed CarPlay session during recovery.

This catches app exits, not every hang, kernel failure, power loss during flashing,
or failure of the supervisor itself. A missing startup socket is only a startup
check, not proof that the complete app is healthy. The supervisor now retains the
startup PID and runs CPAAProxyEx as a child; compatibility with the device's actual
watchdog/startup scripts still needs a hardware test. It is not brick protection.

## What this build does

- Runs the stock application under an external supervisor, retaining its basename.
- Interposes `AirPlayReceiverServerControl(startServer)` and
  `CarPlayControlClientStart` in mirroring mode, rather than killing the app.
- Receives ordinary AirPlay H.264 using the pinned UxPlay protocol implementation.
- Normalizes Annex B framing, separates SPS/PPS, waits for IDR frames after
  configuration changes, and calls the stock `carplay_video_process` export.
- Shows a per-start pairing PIN and receiver state at `/api/mirror`.
- Leaves existing `boxsettings.ini` settings alone. Mode/key persistence is in
  `/mnt/UDISK/smartbox-mode`; diagnostic state is under `/tmp/smartbox-*`.

The first version is video-only, controlled from the iPhone. Audio, car-screen
touch, scaling, portrait letterboxing, and protected video are not implemented.
The phone chooses the encoded dimensions despite the 800×480 request. Whether the
Corsa accepts that stream is unverified; a frame count means submitted to the
stock callback, not proof of a picture. iOS 27 pairing and the complete hardware
startup/session flow still need the first physical test. QEMU lacks the adapter's
USB/MFi hardware, and the stock app itself encounters a SIGSEGV there.

## Roll back through the normal updater

If the normal updater remains reachable, this restores the earlier density137.5
application image:

```sh
python3 scripts/update_device.py apply \
  --release firmwares/experiments/hw501_131_density137.5
```

Stock v131 is also available at `firmwares/hw501/131`. This update is not a full
flash backup or a FEL recovery image.

## Build and verify

Setup has already been performed on this Mac. The first command can take
`--setup` on a fresh environment; it verifies dependency archive SHA-256 values.

```sh
python3 scripts/build_mirroring_riscv.py
python3 scripts/build_mode_service.py --riscv
python3 scripts/test_mirroring_device.py
python3 scripts/test_mirroring_supervisor.py
python3 scripts/test_mirroring_transport.py --riscv
python3 scripts/test_mode_service.py
python3 scripts/emulate_firmware.py --mode-tests
.venv/bin/python scripts/test_display_patch.py
python3 scripts/test_update_device.py
python3 scripts/build_mirroring_firmware.py
```

The bridge/launcher use Bootlin's RV32 glibc 2.34 toolchain, the firmware's existing
OpenSSL 1.1.1/DNS libraries, and static libplist. The mode service is a static RV32
binary. Original dependencies and source checkouts remain under
`firmwares/research/`; source pins/licenses are recorded with the build and image.
The build is for local experimentation. Firmware has not been published or sent
to the adapter by these build/test commands.
