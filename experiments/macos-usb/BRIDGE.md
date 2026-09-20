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

## Live result after loading 0.2.0

On 20 September 2026, protocol 3 loaded and six successive root requests
completed successfully without another restart:

1. Republish existing configuration with the replacement flag.
2. Restore the saved original USB fields (comparison passed).
3. Publish the generated `SmartBoxIAP2` plus native NCM profile.
4. Force the device side off-bus.
5. Release that force-off.
6. Restore the original USB fields again (comparison passed).

Between steps 3 and 4, a normal non-administrator process successfully opened
`IOUSBDeviceInterfaceUserClient` for our custom interface, set interface class
FF/F0/00, created one OUT and one IN bulk pipe, committed the configuration, and
closed both the interface and user client. The call signatures were checked
against the installed kernel's method table. No data transfer or USB role-switch
request was sent; device mode remained disconnected throughout. In particular,
the force-off/release test does not prove behavior during an active session.

Evidence: `device-snapshots/mac-usb-bridge-20260920T163918.101897Z`.
The final state has the original NCM interfaces restored, with only the
`AllowMultipleCreates` controller instruction added. No dongle firmware changed.

The reproducible user-space endpoint probe is:

```sh
python3 scripts/mac_usb_interface.py
python3 scripts/mac_usb_interface.py --configure
```

Default mode only inspects interface properties. `--configure` requires an
already-published `SmartBoxIAP2` on the exact prepared controller in disconnected
device mode; it refuses an absent custom interface and never opens the native
NCM functions. `--configure` allocates endpoints, commits, and closes immediately.
The separate listening modes below exchange limited iAP2 packets. Restore the
configuration through the bridge after a publication experiment.

## USB role switching and iAP2 verified

Later tests on the same Mac, using the dongle's USB-A plug through its USB-C
adapter, successfully enumerated the Mac as a 480 Mbps USB device. The dongle's
`0x51` vendor request alone did not change the Mac's role. The scoped user-space
role helper also opens the matching port's `IOAccessoryManager` and temporarily
sets USB mode 0 (device), then restores the saved mode 2 (host) after 15 seconds.
This does not call the separate power/current control methods.

The interface API takes **zero-based configuration indices**. Class/endpoint
configuration must use index 0, while the on-wire configuration value is 1.
Using index 1 created inactive endpoints and returned `0xe0000001` on transfers.
With index 0, the live tests exchanged DETECT, SYN, SYN-ACK, ACK, and received the
first control message: `0xAA00`, RequestAuthenticationCertificate. The dongle also
bound `cdc_ncm` and created `usb0`; IP connectivity/video have not been tested.

Repeat the scoped test with the already-loaded protocol-3 bridge:

```sh
python3 scripts/mac_usb_session_probe.py                # build and read-only status
python3 scripts/mac_usb_session_probe.py --run          # through first control transfer
python3 scripts/mac_usb_session_probe.py --run --stage detect
```

Native administrator dialogs authorize the bridge's temporary publication and
restoration operations. No kernel rebuild, reinstall, firmware flash, or reboot
is needed. The helper checks the exact owned dongle and prepared port. It opens
the custom interface immediately after publication to avoid Apple's unclaimed
interface fallback. The runner restores the host role, forces device mode off
bus, restores the original descriptor, and releases the force-off.

This is a **probe**, not a complete receiver. It accepts only the tested single
control-session SYN-ACK format, checks checksums and sequence acknowledgement,
and captures one subsequent transfer without responding to authentication. It
does not implement stream reassembly or general link retransmission. A blocked
synchronous USB read has been observed to outlast its requested 100 ms timeout;
the independent role helper's 15-second restore disconnects and releases it.
Use the orchestrator for live tests, not a standalone listener without cleanup.
A stuck kernel call or killed role helper can still require manual recovery.

Evidence: `device-snapshots/mac-role-switch-20260920T164711.438482Z/` subdirectories
`combined-role`, `config-index-zero`, `syn-probe`, and `control-probe`. All three
cleanup requests and the original-configuration comparison passed after each
completed test. SYN-ACK validation/ACK encoding tests pass with ASan/UBSan.
The tracked orchestrator also completed end to end in
`device-snapshots/mac-usb-session-20260920T171500.199329Z`, reproducing `0xAA00`
and verifying host-mode restoration, the original descriptor, and release-off.

## Authentication and identification extension

The later `--stage auth` and `--stage identify` probes generate a local test
certificate/key and have received authentication success and identification
acceptance from this owned HW501. They require no MFi key from the car and make
no firmware changes. The network stage adds a USB-bound request observer; it
is still not a video receiver. See the [evidence and protocol limits](../../reports/overlay/mac-auth-analysis/README.md).

```sh
python3 scripts/mac_usb_session_probe.py --run --stage identify --collect-network
```

`--collect-network` adds read-only diagnostics over the dongle's Wi-Fi. Omit it
when that Wi-Fi connection is unavailable. Test keys stay in the local private
evidence directory. Authentication here only establishes this dongle's behavior;
it does not establish compatibility with real iPhone authentication.
