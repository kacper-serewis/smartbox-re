# CarPlay / Screen Mirroring selection

Implemented as a small native POSIX service, with a web settings page and an
explicit interface to the future device integration. The same C code builds on
the Mac and as a **static RV32 ILP32D Linux executable**.

Implemented behavior:

- CarPlay is the default; the selected mode is written atomically and survives
  service/device restarts. Existing firmware audio/density settings are untouched.
- On the device, **Save & restart** writes and syncs the choice, acknowledges the
  request, then requests a normal reboot after two seconds. Startup applies the
  saved choice. The service reports `selected`, `active`, and `pending` separately.
  The browser waits for the mode page to return; Wi-Fi may need reconnecting.
  The Mac development preview still only saves, without rebooting.
- A driver probes mirroring availability and performs mode startup/cleanup.
  Failed mirroring startup falls back to CarPlay after successful cleanup,
  preserving the user's selected mode and reporting the fallback.
- Without a driver, mirroring is disabled and active mode is `unknown`.
  The page never claims that an unavailable receiver is running.
- One service instance owns a state directory. Invalid values, failed saves,
  and cross-origin browser writes are rejected. Hook execution is bounded.

**The previous flashable image is withdrawn; current changes are source/build
only until a replacement is packaged and tested.** A
launcher supervises the stock app process, loads a mirroring bridge, and starts
this service with a real Unix-socket driver. The bridge interposes phone-side
startup calls and feeds the exported stock video callback. See
[flashing and limitations](../mirroring/FLASHING.md). Physical switching and Corsa
video output remain untested. Service tests use a fake driver; separate RV32
tests load the real integration into the stock application.

On a crash or failed startup, the supervisor restarts the original app without
the mirroring library and starts this page without an integration driver. Active
connection is therefore reported as unconfirmed; `/api/mirror` explains recovery.
The separate page survives app-child failures. Recovery stays latched across
reboots; see the flashing guide for limits and the explicit reset procedure.

## Build and test

```sh
python3 scripts/build_mode_service.py
python3 scripts/test_mode_service.py
python3 scripts/preview_mode.py
```

The preview is available at `http://127.0.0.1:8081/`, with a visible development
label. It simulates driver actions and uses local state. It does not contact the
dongle. Pass `--state-dir PATH` to reuse that state when restarting the preview.

For the RV32 build (Docker required):

```sh
python3 scripts/build_mode_service.py --setup --riscv
python3 scripts/emulate_firmware.py --mode-tests
```

Setup downloads a SHA-256-verified Bootlin toolchain and creates a QEMU container.
Already completed on this Mac. The native binary and RV32 executable are under
`firmwares/research/mode-build/`. The latter is about 650 KiB uncompressed
(size can change with compiler/source changes).

The staging bundle under `firmwares/experiments/connection-mode/` contains the
RV32 executable, web page, JavaScript, both stock configuration pages with a new
Connection mode link, and a hash manifest marking it **not flashable**.

## Device driver contract

Installed launch shape:

```sh
smartbox-mode --state-dir /mnt/UDISK/smartbox-mode \
  --web-dir /mnt/app/mode-web --bind 0.0.0.0 --port 8081 \
  --driver /mnt/app/bin/smartbox-mode-driver \
  --runtime-status /tmp/smartbox-mirror.json --reboot-command /sbin/reboot
```

These paths are included in the experimental image. The existing
`/mnt/UDISK/boxsettings.ini` is not rewritten. `/api/mirror` supplies the pairing
PIN and receiver state. Frame counts record callback submission, not confirmed
display on the head unit.

The driver receives two arguments, runs without a shell, and returns zero on
success:

| Call | Required behavior |
|---|---|
| `probe mirroring` | Succeed only when receiver, phone-side mode control, and car-facing bridge are available. |
| `start carplay` | Enable the normal phone-side CarPlay connection and confirm startup. |
| `start mirroring` | Suppress phone-side CarPlay auto-connection, start mirroring reception/forwarding, and confirm readiness. |
| `stop MODE` | Idempotently clean up only that mode's owned phone-side resources, including partial startup. |

Each call has a five-second limit. Shared car-facing CarPlay transport and the
configuration network must remain available in either mode. The existing stock
application owns both sides, so a driver must not simply kill `CPAAProxyEx` to
switch away from phone-side CarPlay. Service shutdown calls `stop` for its active
mode. The saved selection remains on disk.

The API is `GET /api/mode` and `POST /api/mode` with form body
`mode=carplay` or `mode=mirroring` and header `X-SmartBox-Mode: 1`. POST saves the
choice; restart performs activation. With `--reboot-command`, a successful POST
also schedules that executable (no shell or arguments) after the reply. The
device launcher supplies `/sbin/reboot`, without force flags. Invalid requests,
failed persistence, missing reboot command, and incomplete experimental startup
do not schedule a reboot. Additional saves are rejected while restarting.
The recovery latch is never cleared by saving or restarting.

`restart_on_save` advertises this behavior; `restarting` reports a scheduled or
requested restart. A failed command or an unchanged service still running 15
seconds after command success reports `restart_failed`, preserving the saved
choice and allowing retry. This is not an automatic retry loop. A lost HTTP reply
does not undo a saved choice or its scheduled restart. The browser waits up to
two minutes and then asks the user to reconnect/reload if it cannot confirm state.
Serving defaults to loopback for local
development. The configuration endpoint stays up even if activation fails.

## Validation

Integration tests cover native macOS and the RV32 executable under
QEMU: restart persistence in both directions, response before reboot invocation,
duplicate-save rejection, reboot failure/retry, accepted-but-ineffective reboot,
incomplete-startup protection, failed-start
fallback, cleanup failure, corrupt saved settings, missing integration,
invalid/cross-origin writes, delayed HTTP bodies on rejected requests, failed
persistence, and static page serving.
Reboot tests use an explicit fake executable and never restart the test host.
All 15 service tests passed on native macOS and RV32 QEMU. The 13 supervisor
tests also passed on native Linux and RV32, including clean shutdown and updater
survival. The firmware components build successfully; JavaScript syntax and UI
states (device, restarting, failed restart, local preview) were checked locally.
The actual dongle reboot after saving has not yet been hardware-tested.
