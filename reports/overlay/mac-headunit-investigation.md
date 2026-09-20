# Mac as the dongle's display receiver

The intended preview includes the dongle's own welcome/Bluetooth pairing UI and
the selected video source. The existing `preview_dongle.py` only captures the
standalone phone receiver. It does not meet that requirement.

## Physical inspection, 20 September 2026

Read-only diagnostics on smartBox-9302, restored density137.5/v131:

- macOS enumerates an `iPhone`, VID `05ac`, PID `12a8`, USB configuration 1.
- Its USB serial exactly matches the dongle's configfs gadget serial. This is
  the dongle, rather than an unrelated phone connected to the Mac.
- The dongle's UDC is `44100000.udc-controller`, state `configured`.
- Gadget configurations contain PTP; audio/HID; PTP/mux; and PTP/mux/vendor
  interfaces respectively. No active `usb0` network interface exists; only
  `wlan0` and loopback are present.
- There is no exposed framebuffer device. Reading the mapped `libDecEncLib.so`
  `gDisplayImage` and callback globals returned null while attached to the Mac.
  Thus no initialized welcome-screen image was available at that point.

Raw gadget evidence: `device-snapshots/headunit-usb-20260920T125554Z`.
Display-memory evidence: `device-snapshots/display-probe-20260920T125001Z`.
No USB configuration, process memory, firmware, or persistent settings were
changed by these probes. The diagnostic mechanism writes temporary reports.

## Why a normal video player is insufficient

The dongle needs a head-unit display session before generating its normal UI.
USB enumeration is not that session. In the wired CarPlay flow, the head unit
participates in USB role switching, iAP2 setup/authentication, and network/video
session establishment. The available open-source receiver inspected here uses
a Linux USB device controller and gadget interfaces; it is not a macOS USB
host application that can simply be launched beside the browser.

References inspected:

- [iAP2 transport investigation](https://wiomoc.de/misc/posts/mfi_iap.html)
- [CatPlay receiver session](https://github.com/catplay-labs/catplay/blob/master/catplay_carplay_rx_gadget/src/server.rs)
- [CatPlay accessory USB setup](https://github.com/catplay-labs/catplay/blob/master/usb/catplay_iap2_usb_gadget/src/accessory_gadget.rs)

These sources establish the additional transport requirements; they do not
establish compatibility with HW501 or a working Mac receiver.

## Native macOS device-controller access test

Further inspection found three `AppleT8142USBXDCI` device controllers on this
Mac. A native implementation is therefore not ruled out by the Linux receiver's
dependencies. The Mac's existing device configurations contain NCM interfaces.

The [local access probe](../../experiments/macos-usb/README.md) matched the owned
dongle to `usb-drd1` and attempted to submit that disconnected controller's
existing configuration unchanged. macOS returned `0xe00002c1` (privilege
violation); the descriptor remained unchanged. The user then ran that compiled
probe with `sudo` and supplied output showing the same error. Root alone is
insufficient for this operation. No role switch was sent, and no security
setting or kernel extension was changed.

The reference gadget kernel extension compiles locally for `arm64e`, but source
review found unchecked failure paths and a broadly exposed configuration method.
It was not installed. A scoped driver and an explicitly chosen startup-security
change are still required to pursue that native route; compilation alone does
not demonstrate compatibility or a head-unit session.

A new scoped `SmartBoxUSBProbe` has since been built with one root-triggered,
unchanged-configuration request and explicit error reporting. Its host-side
policy tests pass, and the client rejects an absent driver on the live Mac.
The bundle remains unsigned and unloaded. Details and the additional unsigned-kext
security prerequisite are in the [probe README](../../experiments/macos-usb/README.md).
The user explicitly approved the temporary startup-security/SIP changes. The
[live-test guide](../../experiments/macos-usb/LIVE_TEST.md) and checksum-checked
installer are prepared; Recovery changes, installation, and loading remain
pending local user action. Do not request the same authorization again.

After the user's Recovery restart, SIP was verified disabled and the dongle
still matched the expected controller. The exact pinned bundle was installed
at `/Library/Extensions/SmartBoxUSBProbe.kext`, with verified root:wheel
ownership. The authorized `kmutil load` request stopped with exit 27, requiring
System Settings approval. Its message listed `local.smartbox.USBProbe` and an
additional Apple identifier `com.apple.nke.rvi`; this experiment installed only
the SmartBox bundle. The driver is not yet attached in IORegistry and no kernel
probe request was sent. Privacy & Security was opened for the user to complete
the OS-required approval/restart. Evidence:
`device-snapshots/mac-usb-gadget-20260920T154139.171309Z`.

After the following approval/reboot, `kmutil showloaded` and IORegistry both
confirmed 0.1.0 loaded and attached to the correct controller. The authorized
root client reached the driver but received `0xe00002d8` (not ready) from its
request method. `ProbeCompleted` remained false, and the configuration remained
unchanged: this was a readiness refusal, not a successful kernel configuration
call. The exported controller status still reported disconnected/off-bus.

One suspected cause is the driver's assumption that `CurrentState` is directly
an OSDictionary; a lazy OSSerializer also appears as a dictionary through the
user-space registry APIs. Version 0.1.1 supports materializing that specific
controller property (bounded XML parse), keeps the disconnected/off-bus checks,
and publishes object type and exact readiness refusal reason. This cause is
not yet confirmed by live kernel diagnostics. No guard was removed.

Version 0.1.1 built with the now-selected SDK 27.0; policy tests passed. The
checksum-pinned upgrade was staged with the original bundle preserved at
`/Library/Application Support/SmartBoxUSBProbe/0.1.0.kext`. Its load request
returned exit 27 requiring System Settings approval again. The running kernel
still has 0.1.0, and 0.1.1 is not yet tested live. Evidence:
`device-snapshots/mac-usb-gadget-20260920T160628.454154Z`.

Evidence: `device-snapshots/mac-usb-gadget-20260920T130157.961930Z`.

## Kernel probe after the 0.1.1 reboot

The user rebooted and version 0.1.1 loaded. The root request succeeded;
`ProbeReadiness=ready` and `ProbeStateObjectType=OSSerializer` confirm the
readiness fix. The underlying configuration call returned `0xe00002e2`
(`not permitted`), with the descriptor unchanged and no role-switch request.
Evidence: `device-snapshots/mac-usb-gadget-20260920T161449.186683Z/kernel-test.json`.
This is not a successful configuration or CarPlay session, and the driver's
one-shot attempt is now consumed.

The reference helper's `alt_IOUSBDeviceDescriptionAppendConfiguration` sets
`AllowMultipleCreates=true` to permit creation when a descriptor already exists.
That flag is absent from our unchanged-descriptor request. It is a candidate
explanation, not yet established for this OS. A targeted unified-log search did
not expose the rejection reason. Further driver changes should be consolidated
before installation because the user wants to avoid repeated approval/reboot
cycles. No additional driver was installed following this test.

## Reusable native bridge

The native path has since advanced to a prepared reusable 0.2.0 bridge. Offline
inspection of the installed USB driver found the exact missing-flag refusal
path ([details](mac-usb-configuration-refusal.md)). The new bridge adds the
replacement flag, bounded description validation, repeated requests with IDs,
saved-configuration restoration, and explicit force-off/release controls.
The normal client is `scripts/mac_usb_bridge.py`; protocol tests and descriptor
tests passed with ASan/UBSan. The client refuses the currently loaded older
driver without sending a request. The generated iAP2/NCM profile is a local
starting point, not a tested head-unit configuration or working receiver.

Version 0.2.0 was installed with both artifact hashes and root:wheel ownership
verified. The previous exact 0.1.1 bundle is preserved at
`/Library/Application Support/SmartBoxUSBProbe/0.1.1.kext`; the older backup was
not changed. The load request returned exit 27, requiring System Settings
approval. IORegistry still reports protocol 2 (the running 0.1.1 driver).
Hardware configuration tests for 0.2.0 therefore remain pending approval/reboot.
Evidence: `device-snapshots/mac-usb-bridge-install-20260920T163536.599407Z`.
No role switch, custom configuration, dongle firmware, or further Mac security
policy change occurred during this upgrade. Kernel static analysis completed
without diagnostics after adding defensive null checks to the type adapters.

## Proposed Mac-only test path — not implemented

A temporary bench hook inside the actual dongle application could supply the
missing display setup and capture its common outgoing video path over Wi-Fi.
The Mac would decode that stream. This must invoke the real UI initialization,
not draw a replacement pairing page or merely resize a captured phone video.

Stock-code investigation identifies display setup event 1123, video-start event
1124, local UI encoding, and common configuration/frame senders at `0x4eca8`
and `0x4ee7c`. Those addresses apply only to the inspected v131 binary family;
they are not a ready-to-run injection recipe. Initialization dependencies,
thread ownership, and restoration still need verification before live use.

Acceptance requires observing the actual welcome screen, then a source switch
and rotation, followed by returning to the welcome screen. A RAM-only launch
must have bounded capture, exact executable checks, and restoration of the
stock application independent of the test process. The updater must remain
available. A Mac decoder result would still not prove Corsa decoder behavior.

The native sender tests and Swift preview compile successfully, but there is
currently **no working complete dongle-display preview or head-unit emulator**.
