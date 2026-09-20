# Reusable Mac USB configuration bridge (0.2.0)

This replaces the one-shot access probe with a reusable, root-only configuration
bridge. It is still not a CarPlay receiver. Publication, user-space USB endpoints,
role switching, iAP2, and a video session are separate milestones.

The kernel driver stays on the exact prepared `usb-drd1` controller. Nothing
changes automatically when it loads. It accepts six named operations with
monotonically increasing request IDs; only one operation may be pending/running.
The client checks the matching completion ID, and does not retry on a timeout.

| Client flag | Action |
| --- | --- |
| `--status` (default) | Read controller and bridge state; requires no root |
| `--check` | Submit current configuration unchanged, preserving the original failing test |
| `--republish` | Submit current configuration with `AllowMultipleCreates=true` |
| `--publish FILE` | Validate and publish a JSON description, setting the replacement flag |
| `--restore` | Republish the saved original configuration with the replacement flag |
| `--force-off-bus` | Explicitly disconnect the device side of the prepared controller |
| `--release-off-bus` | Release a force-off request made by this driver instance |
| `--make-profile FILE` | Write an iAP2/NCM starting profile locally; do not publish it |
| `--validate FILE` | Validate a JSON profile locally; do not access the driver |

Configuration operations require device mode disconnected and off-bus, checked
again by the worker. Force-off may operate while connected only after this
driver has attempted configuration handling. Release-off requires a previous
successful force-off. These commands are not USB role-switch requests.

The driver deep-copies the original descriptor before its first configuration
attempt and exposes it as `ProbeOriginalDescription`. Failed configuration calls
can still have side effects, so recovery remains available after a failure.
Restore can run even if that failure removed the current description. It restores
the original USB fields but retains `AllowMultipleCreates=true` as a controller
instruction. The client compares the restored fields ignoring only that flag.
Restoration is explicit, not an automatic response to a client crash or timeout.

The client requires the exact owned dongle serial/VID/PID on the prepared port
for Check/Republish/Publish. Restore/ForceOffBus/ReleaseOffBus may run without
host-side dongle enumeration, since role switching can remove that enumeration;
they require the bridge's saved original descriptor. The kernel always checks
root privilege and the fixed controller, independently of the client.

## First test after installation

Build the normal Mac client and inspect the loaded bridge:

```sh
python3 scripts/mac_usb_bridge.py
```

It must report `ProbeVersion: "3"`. This script prints an evidence directory
containing a compiled `mac-usb-bridge`. Run that compiled helper as administrator
with `--republish`. Inspect `operation_result`, the before/after description,
and the device state. A successful API result is not proof of a CarPlay session.
Run `--restore` after the experiment and inspect `original_configuration_restored`.

For later configuration experiments, prepare/edit a local JSON file and validate
it before publishing. The wrapper rebuilds the user-space client only; changing
profiles or the normal app does not rebuild or reinstall the kernel extension.

```sh
python3 scripts/mac_usb_bridge.py --make-profile /tmp/smartbox-usb-profile.json
python3 scripts/mac_usb_bridge.py --validate /tmp/smartbox-usb-profile.json
```

The generated profile adds `SmartBoxIAP2` plus native Apple NCM interface names.
It inherits this Mac's identity fields; it is a bench starting point, not a proven
head-unit descriptor. Endpoint setup and USB role switching are not implemented
by this client. Do not infer that named interfaces alone negotiate CarPlay.

If a request times out, inspect `--status`. A timeout does not cancel the kernel
call. If it remains pending, do not queue retries. A stuck kernel call may still
require a restart; reusable controls cannot guarantee every failure is recoverable.

## Validation and limits

The same bounded descriptor schema runs in the kernel and in the Foundation
client/tests. Unknown keys, wrong types, oversized arrays/strings, duplicate
interface names, and unrecognized function names are rejected. Custom function
names must start with `SmartBox`; selected native NCM/mux names are also allowed.
The driver does not forward arbitrary USB commands, pointers, or XML.

Host tests run with ASan/UBSan. They exercise repeat/busy/stale requests, state
changes before execution, stop cancellation, and malformed descriptors. The
kernel bundle and client compile with warnings as errors. These checks do not
test actual kernel concurrency, hardware publication, or a CarPlay session.

Installation still uses the checksum-pinned installer and macOS approval/reboot.
No additional security policy changes are required by this revision. See
[installation and removal](LIVE_TEST.md) for the previously authorized setup.
