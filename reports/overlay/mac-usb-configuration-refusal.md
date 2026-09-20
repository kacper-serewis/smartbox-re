# Why the unchanged Mac USB configuration returned not permitted

On the tested Mac17,9 / macOS 27.2 build 26B5086k, bridge 0.1.1 reached
`IOUSBDeviceController::createUSBDevice` through its kernel worker and returned
`0xe00002e2`. The configuration already existed and did not contain
`AllowMultipleCreates`.

The installed boot kernelcache was read from Preboot, its IM4P payload decoded
with the system Compression framework's LZFSE decoder, and the
`com.apple.iokit.IOUSBDeviceFamily` Mach-O fileset inspected with Capstone. This
was offline inspection; no kernel bytes, boot files, or live memory were changed.
The decompressed file SHA-256 is
`80b43e36ce5ee2fe0f2e0267e63b71bd2c97808409f04ef95ebf78e659c20e3f`.
Local artifacts: `firmwares/research/mac-kernel-inspect/`.

Relevant instructions in `createUSBDevice`, beginning at `0xfffffe000b163858`:

| Address | Finding |
| --- | --- |
| `0xfffffe000b163890` | Initialize error register `w23` to `0xe00002bd` |
| `0xfffffe000b1638a4`–`0xfffffe000b163910` | Task/entitlement gate; failure adds 4, yielding the earlier `0xe00002c1` |
| `0xfffffe000b16395c` | Check existing controller object at offset `0x168` |
| `0xfffffe000b163980` | Load key at `0xfffffe0007bea419`: `AllowMultipleCreates` |
| `0xfffffe000b163990` | Look up that key in the copied description dictionary |
| `0xfffffe000b163994` | Missing key branches to `0xfffffe000b163fa8` |
| `0xfffffe000b163fac` | Add `0x25` to the initial error: `0xe00002e2`, then return through cleanup |

This establishes a matching rejection path for the observed state and exact
error. Live retesting is still required to show that enabling replacement clears
this refusal and to discover any subsequent errors. It does not establish USB
role switching or CarPlay compatibility.

The reference [description helper](https://github.com/shinyquagsire23/macos_usb_gadget_poc/blob/c8349b449a2171c1b5b7c59b882728b130fc6b88/usb_device/alt_IOUSBDeviceControllerLib.c#L330-L333)
sets the same flag and documents its purpose. Bridge 0.2.0 therefore adds it to
Republish/Publish/Restore, while Check preserves the old unchanged request.

Live confirmation after the 0.2.0 reboot: Republish returned success, followed
by successful restoration, custom profile publication, and a second restoration.
The missing flag was the blocker for the tested unchanged configuration.
Evidence: `device-snapshots/mac-usb-bridge-20260920T163918.101897Z`.
