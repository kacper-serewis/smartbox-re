# HW501: first mirroring test, offline

**20 September: the image identified below is withdrawn. Do not follow its flash
instructions.** Physical tests on smartBox-9302 showed corrupted mirroring and
subsequent update disconnections at 1–3%. The supervisor's process-group cleanup
can kill the stock updater; this conflict was reproduced locally. A source fix
has passed regression tests but is not installed on the affected adapter.
smartBox-9302 has since been restored to density137.5, with flash readback and
reboot verified. Do not reinstall this image. For another affected device,
keep the recovery latch in place and collect:

```sh
python3 scripts/collect_device.py --mirroring --seconds 10
```

This reads mode, receiver, and update status and requests the diagnostic archive;
it does not start flashing. It also works while mirroring is disabled in recovery.
See [the investigation](../../reports/overlay/updater-supervisor-conflict.md).
The procedure below is retained as historical build documentation.

For your Opel Corsa 2017, HW501 adapter, and Mac. Use the spare adapter for this
first test. The firmware includes v131, density137.5, a CarPlay/Screen Mirroring
selector, and crash recovery. It has passed offline checks, including 22
supervisor fault tests, but has not been validated on the physical adapter/Corsa.

Everything below works without internet. These instructions do not require Docker,
a compiler, or rebuilding firmware. The referenced files are already on this Mac.

## 1. Prepare before connecting

Keep this guide open or saved locally. Open Terminal and enter:

```sh
cd /Users/kacperserewis/Documents/dev/smartbox-re
python3 --version
```

The experimental update is in:

```text
firmwares/experiments/hw501_131_mirroring_density137.5/
```

Its `hw501_131.tar` SHA-256 is:

```text
9bbc62e44225839cbf18d1f5c60a23f26d4d534714785a987f372081d62a58a8
```

This identifies the supervisor build prepared on 20 September 2026. The updater
checks the local manifest and archive automatically. The previous density137.5
firmware is also available locally for rollback.

## 2. Connect and inspect

Park the car and keep the adapter powered throughout the update. Plug the spare
adapter into the Corsa's CarPlay USB port. Connect the Mac to the adapter's Wi-Fi;
losing internet on the Mac is expected. The iPhone does not need to be connected
for flashing.

Run:

```sh
python3 scripts/update_device.py inspect
```

You should get device information, settings, and update status. Confirm hardware
type **501**. The command also saves a local metadata snapshot; that is not a full
flash backup. If it times out, check that the Mac is still on the adapter Wi-Fi
and try opening `http://192.168.5.1/`. Resolve access before proceeding.

## 3. Flash the experimental update

This command performs the flash:

```sh
python3 scripts/update_device.py apply \
  --release firmwares/experiments/hw501_131_mirroring_density137.5
```

It verifies the archive, checks the hardware type, uploads acknowledged chunks,
and requests installation. Leave power connected and wait for **100%** plus the
message **Adapter reports update complete**.

If it reports a timeout or unconfirmed completion, do not immediately unplug or
start another update. Keep power connected, reconnect Wi-Fi if necessary, and run
the `inspect` command again to read update status. A lost connection alone does
not establish either success or failure. Save the terminal output if the state
remains unclear.

After confirmed completion, unplug and reconnect the adapter once. Let it boot
for **at least 60 seconds**, then reconnect the Mac to its Wi-Fi. Use the same
60-second settling period after subsequent restarts: removing power during the
first 30 seconds can intentionally trigger the incomplete-startup recovery flag.

## 4. Check ordinary CarPlay first

Connect the iPhone to CarPlay normally and check the Corsa display. CarPlay is the
default when no connection mode has previously been saved. Density137.5 is retained.

On the Mac, open:

```text
http://192.168.5.1:8081/
```

You can also use **Connection mode** on the regular adapter settings page. Keep
this page open on the Mac for the mirroring pairing code.

The app version label may still show the normal v131 build: it does not identify
this custom image by itself. Check the new mode page. If it reports recovery,
follow step 7 rather than trying to enable mirroring.

## 5. Try Screen Mirroring

1. On the mode page, select **Screen Mirroring** and click **Save mode**.
2. Replug the adapter, allow at least 60 seconds, and reconnect the Mac to its Wi-Fi.
3. Reload the mode page. Check that it reports mirroring and displays a pairing code.
4. Connect the iPhone to the adapter's Wi-Fi.
5. On the iPhone, open **Control Center → Screen Mirroring → SmartBox Mirror**.
6. Enter the pairing code shown on the Mac. Use the current code after each restart.
7. Start with a simple, non-protected landscape screen, such as a photo. Check the
   actual Corsa display for a picture and movement.

This build forwards **video only**. Control it from the iPhone. Audio, car-screen
touch control, scaling, and portrait letterboxing are not implemented. The phone
may choose video dimensions the Corsa cannot display; selecting 800×480 in the
receiver does not force the phone to encode exactly that size.

The page's frame count means frames reached the stock application's video callback.
It does not prove that the car received or displayed them. Full iPhone pairing and
Corsa output are still experimental.

## 6. Return to CarPlay

Stop Screen Mirroring on the iPhone. In the adapter's mode page, select **CarPlay**,
save, and replug. Allow 60 seconds, then connect the iPhone normally.

Saving the selection alone does not change the running connection; it applies on
restart. An initialization failure may instead produce automatic CarPlay fallback,
which the page reports while preserving the saved mirroring selection.

## 7. Understand crash recovery

If the app crashes or fails startup, the supervisor attempts to restart the
density-patched original app **without the mirroring library**. The mode page runs
separately and reports recovery if its service and the adapter network are running.
It will not claim that a real CarPlay connection has been confirmed.

Mirroring stays disabled across reboots after recovery. Repeatedly replugging,
saving Screen Mirroring, or reflashing this same experimental image does not clear
the recovery flag. There is currently no web button to clear it. Clearing it
requires access to the device filesystem while the app is stopped, as described
in the [technical flashing notes](FLASHING.md).

If the original app also fails three times, automatic app retries stop. The page
can remain available, but working Wi-Fi, CarPlay, and the normal updater are not
guaranteed. This mechanism cannot recover every hang, kernel failure, or damaged
flash, and hardware-watchdog compatibility remains untested.

## 8. Restore the previous firmware

If the normal updater is still reachable, connect the Mac to adapter Wi-Fi and run:

```sh
python3 scripts/update_device.py apply \
  --release firmwares/experiments/hw501_131_density137.5
```

This removes the experimental supervisor/receiver and restores the earlier
density137.5 application image. Wait for confirmed 100% completion, then replug.

For unmodified stock v131 instead, use:

```sh
python3 scripts/update_device.py apply --release firmwares/hw501/131
```

Choose one rollback image. These commands depend on the normal updater; they are
not a FEL recovery method. If only port 8081 works, that alone does not establish
that the updater is available. If Wi-Fi or the updater is gone, stop attempting
these commands and record the observed behaviour for recovery investigation.

## 9. Save results before leaving the car

From the same repository directory, collect while the phone is mirroring and the
problem is visible. Keep the Mac connected to the adapter Wi-Fi:

```sh
python3 scripts/collect_device.py --mirroring --seconds 30
```

The collector saves locally and does not upload logs to the vendor. This option
samples `/api/mode` and `/api/mirror` on port 8081 alongside the regular device
information, then downloads the diagnostic archive if the main application is
reachable. It also preserves mode status when only the recovery page responds.
The summary includes receiver frame counts and reported dimensions; the filtered
log includes video configuration and send errors. Increasing frame counts mean
the bridge submitted frames, not that the head unit decoded them correctly.

For corruption over the welcome screen, leave the phone in one orientation and
mirror moving content during collection. Note whether rotating the phone or
stopping and restarting mirroring changes the symptom, but collect the original
failure first. The old screen remaining visible alone does not prove that two
streams are being sent: decoder configuration or reference-frame problems can
also leave old content on screen.

Record whether ordinary CarPlay worked, whether **SmartBox Mirror** appeared,
whether PIN pairing completed, what appeared on the car screen, and whether the
mode page reported recovery. You can reconnect to the internet afterward.

## Quick troubleshooting

| What you see | Next step |
|---|---|
| Mac has no internet | Expected on adapter Wi-Fi; local flashing still works. |
| Port 8081 does not open | Wait 60 seconds, confirm adapter Wi-Fi, check the regular page and `inspect`. |
| Recovery mode | Leave mirroring disabled; save diagnostics and check normal CarPlay or rollback. |
| SmartBox Mirror missing | Check the mode was saved and applied by restart; reload the page and confirm the iPhone is on adapter Wi-Fi. |
| PIN rejected | Reload the mode page and use its current code. |
| Frames increase but screen is blank | Capture both API statuses; callback submission is not proof of head-unit compatibility. |
| Update completion is unconfirmed | Keep power connected, inspect status, and save the error before taking another action. |
