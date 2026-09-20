# macOS USB gadget access probe

**Current revision: 0.2.0, reusable bridge protocol 3.** Use
`python3 scripts/mac_usb_bridge.py` for read-only status and see
[the reusable bridge guide](BRIDGE.md) for current commands. The old probe and
the sections below document the earlier access investigation. The legacy
`--kernel-check-access` command is not the protocol-3 client.

This is an access test, not a CarPlay receiver. It targets the USB serial and
VID/PID previously verified against smartBox-9302's own gadget configuration.
It matches the host and device controllers through their shared `usb-drdN`
registry ancestor, rather than assuming the dongle is plugged into a particular
port. An external host-only hub may prevent such a match.

From the repository root:

```sh
python3 scripts/probe_mac_usb_gadget.py
python3 scripts/probe_mac_usb_gadget.py --check-access
```

The default command only reads the registry. `--check-access` submits the
controller's **existing configuration unchanged** through
`USBDeviceCommand=SetDeviceConfiguration`. It requires exactly one matching
dongle and controller, a saved configuration, and device mode disconnected and
off-bus. It sends no USB role-switch request and publishes no custom interface.
The test can exercise configuration handling; do not describe it as a purely
read-only operation even though the submitted values are unchanged.

Each invocation compiles the Objective-C helper with warnings treated as
errors and saves source hash, OS/security information, and JSON results in
`device-snapshots/mac-usb-gadget-*`. Exit 0 means inspection completed or the
configuration API accepted the request; 2 means the guard refused the test;
3 means the configuration API rejected it. API success does not prove a role
switch, usable custom endpoints, or a CarPlay session.

If administrator access is needed, run `sudo` on the **already compiled helper**
inside that invocation's output directory, with `--check-access`. The helper
rechecks the dongle, physical port, and controller state at execution time.
Enter the password only in the local terminal. This test does not install a
kernel extension or alter SIP, AMFI, Gatekeeper, or boot security.

## Physical result

On Mac17,9 / macOS 27.2 build 26B5086k, SIP enabled:

- Three `AppleT8142USBXDCI` controllers were found.
- The owned dongle matched the device controller on `usb-drd1`.
- The existing descriptor included Apple NCM and auxiliary NCM interfaces.
- The normal-user configuration call returned `0xe00002c1`, **privilege
  violation**. The description remained identical and device mode disconnected.
- The user subsequently ran the same compiled helper with `sudo` and supplied
  its complete output. It again returned `0xe00002c1`, with the description
  unchanged and device mode disconnected. Root access alone is insufficient.
  This is consistent with the reference prototype's private-entitlement gate;
  the error itself does not identify the exact kernel check.

Evidence: `device-snapshots/mac-usb-gadget-20260920T130157.961930Z`.
The administrator result is recorded separately as a summary explicitly
attributed to user-supplied terminal output, not an assistant-run root test.

The experimental reference is
[macos_usb_gadget_poc](https://github.com/shinyquagsire23/macos_usb_gadget_poc),
inspected at commit `c8349b449a2171c1b5b7c59b882728b130fc6b88`. Its kernel
extension routes configuration publication through a kernel thread to bypass
the private `com.apple.private.usbdevice.setdescription` entitlement. That
extension was **not installed or loaded**. Its macOS 12 keyboard example is
not evidence that the same extension or a CarPlay receiver works on macOS 27.2.
The README's `spctl --master-disable` example must not be mistaken for a SIP
command; this probe executes neither that command nor any security-setting
change.

## Reference kernel-extension build and review

The pinned reference built successfully for `arm64e` using the installed Xcode
with signing disabled, into `firmwares/research/macos-usb-gadget-build`. The log
is `reference-kext-build.log` in the evidence directory above. There are warnings
about the old deployment target and duplicated Info.plist resource. Compilation
does not establish loadability or runtime compatibility on macOS 27.2.

Source review found that the reference's allocation/thread-start failures are
not fully handled, its configuration publication method does not implement a
caller privilege check, and its personality matches device controllers broadly.
It also discards the underlying configuration request's return value. It is a
research reference, not a reviewed driver ready for installation on this Mac.

The next native implementation needs a controller-scoped, administrator-only
interface, bounded operations with propagated errors, checked object/thread
lifecycle, and restoration behavior before custom USB interfaces are attempted.
Loading a third-party kernel extension on Apple Silicon additionally requires
user-managed startup security changes in Recovery and a reboot; signing and
other requirements depend on the prepared driver. See
[Apple's kernel extension security documentation](https://support.apple.com/en-ca/guide/security/sec8e454101b/web).
No kernel extension has been installed or loaded, and no security setting changed.

## Scoped replacement prepared locally

`SmartBoxUSBProbe.cpp` is a new, limited access probe, not a copy of the reference
driver and not a CarPlay receiver. Build it with:

```sh
python3 scripts/build_mac_usb_probe.py
```

The unsigned bundle is written to
`firmwares/research/mac-usb-probe/SmartBoxUSBProbe.kext`, together with build logs
and a source/artifact hash manifest. The build never invokes an installer,
signing identity, kernel loader, or security-setting command.

Its constraints are:

- Matches only the observed `AppleT8142USBXDCI` at `usb-drd1`; both the personality
  and runtime code restrict the controller. The client additionally verifies the
  owned dongle's serial and that the driver is attached to its controller.
- Does nothing automatically when loaded. Root must submit the single exact
  command `CheckConfigurationAccess=true` with no extra fields.
- Queues at most one attempt per driver instance onto a kernel timer/workloop.
- Requires disconnected, off-bus device mode at request and execution time.
- Republishes only the descriptor read from the controller itself. It accepts no
  arbitrary descriptors, addresses, interface names, or role-switch commands.
- Publishes the underlying configuration result before marking completion.
- Checks allocation/scheduling failures and cancels the timer before releasing
  the provider. Pending work is suppressed when the driver stops.

The helper supports `--kernel-check-access` for a future loaded-driver test:

```sh
python3 scripts/probe_mac_usb_gadget.py --kernel-check-access
```

Currently this correctly reports that the driver is not loaded. If it is later
installed and approved, the compiled helper from that invocation can be run with
`sudo` and `--kernel-check-access`. It waits up to five seconds for the result;
a timeout is inconclusive and does not cancel a kernel call already executing.
Do not infer permission to send a role-switch request from API success.

Validation completed: warning-free `arm64e` compilation/linking with SDK 26.5;
Info.plist lint; unsigned-artifact check; host-side policy tests under AddressSanitizer
and UndefinedBehaviorSanitizer for rejected callers/commands, inactive ports,
duplicate requests, port-state changes, and stopping. The absent-driver client
path ran on the physical Mac, leaving the descriptor unchanged. These tests do
not exercise actual kernel lifetime/concurrency or validate loading on macOS 27.2.

### Live-test boundary

This bundle is **unsigned and has never been loaded**. The ordinary Reduced
Security / third-party-extension setting is not a complete installation procedure
for this unsigned build. Apple's platform-security documentation states that
kext signatures are still checked with SIP on, and that turning SIP off permits
unsigned development kexts. Changing that policy would affect this Mac, not just
the dongle. The user has now explicitly authorized those temporary changes;
none has been performed, and the build scripts never perform them.

The [live-test guide](LIVE_TEST.md) now contains the approved Recovery steps,
checksum-checked installation, one-shot test, and removal/security restoration.
`scripts/install_mac_usb_probe.py` verifies only by default; `--install` stages
the pinned bundle as root after Recovery preparation and never loads it.
Its validation accepted the expected bundle and rejected modified bytes, an
extra file, and a symlink in temporary-directory tests.
Do not load the old reference binary as a substitute. The relevant Apple guides
are [custom kext installation](https://developer.apple.com/documentation/apple-silicon/installing-a-custom-kernel-extension)
and [kernel security](https://support.apple.com/en-ca/guide/security/sec8e454101b/web).
A return to normal security must include removing this test extension from the
Auxiliary Kernel Collection and rebooting; deleting the source or unplugging the
dongle does not unload a Mac kernel extension.

## First loaded-driver result and update

Version 0.1.0 loaded after approval and reboot, but refused the root request as
`not ready` before scheduling a configuration call. The exported controller
status was disconnected/off-bus. This does not establish configuration access.
Evidence is in `device-snapshots/mac-usb-gadget-20260920T160628.454154Z`.

Version 0.1.1 adds support for a lazy OSSerializer `CurrentState` property and
reports `ProbeStateObjectType` / `ProbeReadiness`. The type hypothesis was
subsequently confirmed on-device; the disconnected/off-bus requirement is preserved.
Only the controller-owned state is parsed, with a 16 KiB parse-length limit.
The current artifact was built with SDK 27.0, with guard tests passing.

The installer now permits `--upgrade` only from the exact pinned 0.1.0 bundle,
preserving it outside `/Library/Extensions` as
`/Library/Application Support/SmartBoxUSBProbe/0.1.0.kext`. The 0.1.1 bundle is
staged and then loaded after the user's approval/reboot.

## Version 0.1.1 live result

Evidence: `device-snapshots/mac-usb-gadget-20260920T161449.186683Z/kernel-test.json`.
The loaded driver reports `ProbeVersion=2`, `ProbeReadiness=ready`, and
`ProbeStateObjectType=OSSerializer`. The root request was accepted and the
kernel worker invoked the configuration API, which returned `0xe00002e2`
(`not permitted`). The descriptor remained unchanged and no role switch was
sent. This confirms the readiness fix, not successful USB configuration or a
working head-unit session. The instance's one-shot attempt has been consumed.

The reference implementation sets `AllowMultipleCreates=true` when building
configurations, with a comment explaining that this permits creation when the
controller already has a device description. Our unchanged-descriptor test
does not supply that flag. This is a plausible explanation for the new refusal,
not a confirmed cause on macOS 27.2. The targeted system-log search returned no
explicit explanation for the failed call.

Before another installed driver revision, consolidate the required bridge
operations and test configuration validation in user space. The user explicitly
wants to avoid an approval/reboot cycle for each small experiment. No further
driver update or security change was made after this result.

Subsequent offline inspection of the installed kernelcache identified the
matching `AllowMultipleCreates` rejection branch; see
[the disassembly findings](../../reports/overlay/mac-usb-configuration-refusal.md).
Version 0.2.0 implements the replacement flag and reusable commands described
in [BRIDGE.md](BRIDGE.md). Successful hardware publication still needs testing
after that revision loads.
