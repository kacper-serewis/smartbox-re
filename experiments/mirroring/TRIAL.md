# Corrected mirroring / automatic restart trial

Prepared 20 September 2026. This is a new experimental package, separate from
the withdrawn image described in USER_GUIDE.md and FLASHING.md. It contains the
corrected video bridge, pairing-screen mode labels, supervisor updater fix,
and Save & restart. It has not yet been boot-tested as a complete flashed image.

Release: `firmwares/experiments/hw501_131_mirroring_density137.5_autorestart`

Archive SHA-256:
`c65cf3edda804a7aeb239103325019f688d135eaccc35a7190be02950df30627`

The app image is 4,960,256 bytes within the 5,242,880-byte partition. Archive
hashes, re-extracted filesystem contents, native/RV32 mode and supervisor tests,
and the RV32 bridge checks passed. QEMU does not validate full hardware boot.

From the repository directory, connect the Mac to smartBox-9302 Wi-Fi. Keep the
dongle powered and finish any USB viewer session first. The preparation below
is specifically for this adapter running the restored density137.5 application:

```sh
python3 scripts/prepare_mirroring_trial.py --apply && \
python3 scripts/update_device.py apply \
  --release firmwares/experiments/hw501_131_mirroring_density137.5_autorestart
```

Preparation verifies the release and running executable, checks idle update
status, archives and clears only the old recovery-disabled/boot-pending flags.
It refuses an active experimental app or supervisor. It does not erase pairing
keys, change the mode, or restart the current app. The restored stock app ignores
these flags, so clearing them here cannot enable mirroring before the flash.
Do not rerun preparation to bypass recovery after this new trial fails.

Wait for 100% and `Adapter reports update complete`, then replug once and allow
60 seconds for the first boot. If completion is unconfirmed, leave power on
and use `python3 scripts/update_device.py inspect` before taking further action.

Reconnect Wi-Fi and open `http://192.168.5.1:8081/`. Select Screen Mirroring and
click **Save & restart**. Rejoin Wi-Fi after the automatic restart and select
**SmartBox Mirror** on the iPhone, using the PIN from the mode page. CarPlay is
selected initially on the inspected adapter. The saved choice persists; there
is no automatic handover when the phone starts mirroring. Recovery remains
latched if the new application fails.

For the Mac screen, keep the dongle in the previously prepared Mac USB port and
run after the mode restart has completed:

```sh
.venv/bin/python scripts/mac_usb_session_probe.py \
  --run --stage network --preview --seconds 45
```

Approve the native administrator dialogs. The browser opens automatically and
shows the dongle's car-facing USB video, including its pairing screen. The live
session lasts 45 seconds; after cleanup the page keeps the last frame. A mode
restart interrupts USB, so finish the viewer, switch modes, then start a new
viewer session. No Mac reboot is needed. Corsa compatibility of the corrected
mirroring video remains to be tested; this trial forwards video only.
