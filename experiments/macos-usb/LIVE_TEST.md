# Native Mac USB access test

The user authorized the temporary Mac startup-security/SIP changes for this
test. They require local action in Recovery; no further confirmation is needed
for the agreed test. This guide does not mean those changes have happened.

The driver is only an access probe. It will not show CarPlay, publish a custom
USB interface, or switch USB roles. Its code has compiled and its host-side guard
tests pass, but it has never been loaded into the Mac kernel. A kernel failure
can restart the Mac, so save open work before testing.

## 1. Recovery preparation

1. Save your work and shut down the Mac.
2. Hold the power button until startup options appear; select **Options → Continue**.
3. Open **Utilities → Startup Security Utility**, select the macOS installation,
   and open **Security Policy**. Note the original policy so it can be restored.
4. Select **Reduced Security** and **Allow user management of kernel extensions
   from identified developers**, then authenticate and apply it.
5. Open **Utilities → Terminal**, run `csrutil disable`, and follow the prompts
   for this macOS installation. The starting SIP status was **enabled**.
6. Restart into macOS. Do not change authenticated-root, Gatekeeper, AMFI, or
   NVRAM boot arguments. No such change is required by this prepared procedure.

Apple documents the [Recovery/SIP commands](https://developer.apple.com/documentation/security/disabling-and-enabling-system-integrity-protection)
and the [unsigned-kext security behavior](https://support.apple.com/en-ca/guide/security/sec8e454101b/web).
If the Recovery options or commands are rejected on this beta OS, record the
message rather than substituting other security changes.

## 2. Verify and install after returning

Connect the dongle directly to the same Mac port used for the probe. From the
repository root, first verify the bundle and port:

```sh
csrutil status
python3 scripts/install_mac_usb_probe.py
python3 scripts/probe_mac_usb_gadget.py
```

The USB report must show exactly one matching controller. The installer pins
both bundle-file hashes, rejects unexpected files/symlinks, and refuses to
overwrite a different installed bundle. It targets only this Mac model.

```sh
sudo python3 scripts/install_mac_usb_probe.py --install
sudo kmutil load -p /Library/Extensions/SmartBoxUSBProbe.kext
```

The installer only copies the bundle; `kmutil` requests its inclusion/loading.
Follow any macOS approval prompt in **System Settings → Privacy & Security**
and restart if required. If `kmutil` reports a signing, dependency, or policy
error, save that output for inspection. Do not force loading with unrelated flags.
Apple describes this [approval/reboot flow](https://developer.apple.com/documentation/apple-silicon/installing-a-custom-kernel-extension).

## 3. Run the one-shot test

First check whether the driver attached:

```sh
ioreg -r -c SmartBoxUSBProbe -l
```

If it is present, build the client and print its evidence directory:

```sh
python3 scripts/probe_mac_usb_gadget.py
```

Run the **compiled `probe-mac-usb` helper in that printed directory**, with
`sudo` and `--kernel-check-access`. It revalidates the owned dongle's identity,
its physical port, and the attached driver before submitting the command.

Success requires `kernel_configuration_result.success` true and
`description_unchanged` true. API success still does not prove a role switch or
CarPlay session. The driver allows only one accepted request per instance;
do not retry blindly after a timeout. The five-second client timeout cannot
cancel an already executing kernel call.

## 4. Remove the test and restore security

From a normally booted Mac, request removal from the kernel collection:

```sh
sudo kmutil unload -b local.smartbox.USBProbe
```

After a successful unload request, remove only this experiment's installed
bundle so it cannot be included again:

```sh
sudo rm -rf /Library/Extensions/SmartBoxUSBProbe.kext
```

Restart. On Apple Silicon, an unload request does not guarantee immediate
removal from the running kernel. Check `ioreg -r -c SmartBoxUSBProbe -l` is
empty and `kmutil showloaded` no longer lists `local.smartbox.USBProbe`.
If unload fails, keep its output; do not delete unrelated extensions or rebuild
all collections with guessed commands.

Return to Recovery, run `csrutil enable`, and restore the original startup
security policy (Full Security if that was the original setting). Restart and
verify `csrutil status` reports enabled. Do not leave the temporary settings in
place after the experiment.

If the driver prevents a normal boot, use Apple's
[Safe Mode procedure](https://support.apple.com/guide/mac-help/start-up-your-mac-in-safe-mode-mh21245/mac)
to reach macOS and remove this exact extension. Do not repeatedly trigger the
probe after an unexpected reboot.
