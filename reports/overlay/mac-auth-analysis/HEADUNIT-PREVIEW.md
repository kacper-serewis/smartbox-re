# Mac head-unit preview

> The runnable viewer has moved to the public
> [smartbox-carplay-viewer](https://github.com/kacper-serewis/smartbox-carplay-viewer)
> repository. This page is retained as the original HW501 validation record.

The owned HW501 smartBox-9302 now sends its real wired CarPlay output to the Mac
through the existing USB-C to USB-A adapter. This includes the dongle's Bluetooth
pairing screen and an attached iPhone's CarPlay interface. It is not the earlier
Wi-Fi mirror capture or a reconstruction of the dongle's screen.

## Run

Follow the standalone repository's installation guide. With its protocol-3
bridge loaded:

```sh
carplay-viewer --run --stage network --preview --seconds 45
```

The browser opens automatically. Native administrator dialogs publish and restore
the temporary USB configuration. The independent role helper restores Mac host
mode after 45 seconds (15 by default), or on SIGTERM/SIGINT. The local preview
server remains available for five minutes, showing the final frame after the USB
test ends. It listens only on 127.0.0.1 and serves only its page, status and JPEG;
it does not expose the snapshot directory or its generated private key.

No Mac reboot, firmware flashing, or new kernel extension is involved. Connect
the phone normally to see its CarPlay output. Audio is received and discarded;
touch input and audio playback are not implemented. This remains a bounded bench
test, not an unattended head-unit application.

## Verified captures

- `device-snapshots/mac-usb-session-20260920T174409.489425Z`: 70 decoded frames,
  800×480, zero decoder errors; pairing screen visibly verified. The first test
  still stopped the iAP2 parser on DeviceTimeUpdate (0x4e0b).
- `device-snapshots/mac-usb-session-20260920T174650.960002Z`: browser preview,
  87 decoded frames, 800×480, zero decoder errors; iPhone CarPlay interface visibly
  verified. It exposed DeviceInformationUpdate (0x4e09), subsequently handled.
- `device-snapshots/mac-usb-session-20260920T174811.563485Z`: longer 45-second
  role hold, 131 decoded frames, zero decoder errors, all 43 timing exchanges
  answered; 4,787 audio packets discarded. Both observed iAP2 notifications
  were acknowledged, with no protocol error and successful final USB result.
- All three tests verified restoration of Mac host mode and the original USB profile.
  The protocol errors are retained in the evidence, not reclassified as success.

The dongle's status page reports version 220.68 and 800×480 at 30 fps because
those are the receiver capabilities advertised by this test. They do not alone
prove video delivery. The screen packets, decoded image, and decoder counters do.

## Protocol path

1. Temporary native USB gadget with iAP2 bulk pipes and Apple NCM.
2. iAP2 authentication using a fresh locally generated RSA-2048 test identity,
   then identification and a scoped IPv6 CarPlayStartSession.
3. `/auth-setup`: X25519 agreement, RSA-SHA1 signature over server and client public
   keys, AES-CTR encrypted signature. The owned clone dongle accepts this test
   identity; acceptance by a real iPhone is not established.
4. Initial SETUP unwraps the session AES key using the continuing auth cipher;
   event TCP and timing UDP sockets bind to the same USB link-local address.
5. `/info`, RECORD, mode notifications, and screen SETUP (type 110).
6. Screen TCP frames have a 128-byte little-endian header. Video frames alone are
   AES-CTR decrypted using SHA-512-derived per-stream key/IV. AVC configuration
   and length-prefixed H.264 samples feed the existing macOS VideoToolbox decoder.

Media sockets accept only the established dongle peer on the USB scope. Requests,
headers, bodies, capture size, client counts and lifetime are bounded. Device
name/language/time notifications are acknowledged without modifying Mac settings.
The dongle's `disableBluetooth` message is acknowledged as a bench no-op; it does
not disable the Mac's Bluetooth radio.

## Firmware stale-screen quirk

An early rejected screen setup left `gScreenConnectionId` nonzero. Subsequent
calls to `_AirplayClientSendCmdSetupScreen` logged the old ID but returned without
sending a request. The branch at 0x4e324–0x4e34e proves this; see
`screen-setup-handler.asm`. Standard mode changes did not clear it. One physical
unplug/reconnect of the dongle cleared it. Following a successful video session,
a subsequent capture worked without another power cycle.

## Primary protocol references

- [CatPlay auth setup](https://github.com/catplay-labs/catplay/blob/master/core/catplay_hap/src/backend/auth_setup.rs)
- [CatPlay receiver](https://github.com/catplay-labs/catplay/blob/master/carplay/catplay_carplay/src/carplay_rx/sink/receiver.rs)
- [Screen encryption derivation](https://github.com/catplay-labs/catplay/blob/master/carplay/catplay_carplay/src/cipher/aes.rs)
- [Screen framing](https://github.com/catplay-labs/catplay/blob/master/carplay/catplay_carplay/src/screen/screen_frame.rs)
- [Device notifications](https://github.com/catplay-labs/catplay/blob/master/core/catplay_csm/src/msg/device_notifications.rs)

## Checks

```sh
python -m unittest discover -s tests -v
carplay-viewer-driver test
```

The Python tests check peer-side signature verification, malformed key requests,
replay refusal, persistent/fragmented RTSP framing, malformed lengths and duplicate
headers, codec bounds, and continuous AES decryption across multiple video frames.
The C++ tests check packet framing, authentication ordering, identification,
CarPlayStartSession nesting, and device metadata notifications.
