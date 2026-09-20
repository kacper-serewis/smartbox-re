# Update: working Mac head-unit video preview

The USB receiver now captures and decodes the dongle pairing screen and iPhone
CarPlay output. See [the preview guide and validation](HEADUNIT-PREVIEW.md).
The request-observer-only limitations below describe the earlier investigation.

# Mac receiver authentication and identification

Tested on the owned smartBox-9302, HW501 app 131/build 2026081801, on
20 September 2026. These results concern this adapter's phone-emulation path;
they do not establish what a real iPhone accepts.

## Firmware findings

The stock `CPAAProxyEx` function `iap2_dev_recv_data` receives certificate message
`0xaa01` at `0x30912`. It passes the certificate length to `0x51c8c`, which builds
a challenge request using a constant buffer. Lengths above 640 select a 20-byte
challenge; smaller certificates select 32 bytes. No certificate contents are
passed to that challenge builder.

The ordinary `0xaa03` response path at `0x30d70` calls the success-message builder
at `0x51dac` with its success argument set to 1, then requests identification.
A separate flagged path saves the response for forwarding; this investigation
does not generalize the ordinary-path result to every operating mode.

Annotated excerpts are in `certificate-handler.asm` and the existing
`reports/binaries/disassembly/131__CPAAProxyEx__iap2_dev_recv_data.asm`.
`power-message-builder.asm` is adjacent protocol research, not the authentication
decision function.

## Live verification

The Mac generates a fresh RSA-2048 self-signed test certificate and private key
locally. It returns the DER certificate and signs the dongle's 20-byte challenge
using RSA PKCS#1 v1.5/SHA-1 digest signing. It uses no Apple/car certificate or
private key, changes no firmware, and does not patch the authentication handler.

The dongle replied with:

1. `0xaa00` — certificate request.
2. `0xaa02` — challenge request.
3. `0xaa05` — authentication succeeded.
4. `0x1d00` — identification requested.
5. `0x1d02` — head-unit identification accepted, in the identification test.
6. `0x4300` — CarPlay availability, when the receiver continued reading.

Evidence directories:

- `device-snapshots/mac-usb-session-20260920T171912.244933Z`: authentication.
- `device-snapshots/mac-usb-session-20260920T172154.488769Z`: identification accepted.
- `device-snapshots/mac-usb-session-20260920T172246.341758Z`: USB network and dongle log snapshot.
- `device-snapshots/mac-usb-session-20260920T172714.121634Z`: availability captured.

The network snapshot shows a live IPv6 link-local `usb0` on the dongle and `en4`
under the Mac's prepared device controller. The dongle discovers the Mac's
built-in AirPlay advertisement on port 7000 and repeatedly attempts pair-verify.
This is not a successful CarPlay video session. The current receiver therefore
uses a separate temporary listener bound only to the USB interface's link-local
address, discovered through IORegistry rather than assuming an interface name.

## Repeatable probes

```sh
python3 scripts/mac_usb_session_probe.py --run --stage auth
python3 scripts/mac_usb_session_probe.py --run --stage identify --collect-network
python3 scripts/mac_usb_session_probe.py --run --stage network --collect-network
```

The default stage remains the earlier control-message capture. Authentication
and later stages explicitly generate their own local test identity. The runner
uses the existing loaded bridge, restores Mac host mode after 15 seconds, then
restores the original USB descriptor and releases the device-controller force-off.
Native administrator dialogs apply to publication/cleanup, not to any driver
installation. No restart is required for these user-space changes.

The network stage sends `CarPlayStartSession` (`0x4301`) with a nested wired-IP
list and a 32-bit port. Its observer captures one HTTP/RTSP header and returns
501; it does not implement video, pairing, or AirPlay session setup. A successful
USB write is insufficient: the runner also requires an actual observed request
to count that stage as successful.

The network test in `device-snapshots/mac-usb-session-20260920T173039.839770Z`
received `POST /auth-setup RTSP/1.0`, `User-Agent: AirPlay/535.3`, with a 33-byte
body from the dongle's USB link-local address. This proves the handoff to the
custom receiver. The observer intentionally returned 501; no AirPlay setup or
video was completed. That early test still reported the final USB read's abort
as an error even though request capture and restoration succeeded.

The final repeat in `device-snapshots/mac-usb-session-20260920T173144.981849Z`
captured the complete 33-byte request body as well. Its last USB read aborted
after about 8.7 seconds, before the 15-second role watchdog; this must not be
attributed to that watchdog. The observer had returned 501, and no working
AirPlay setup was provided. The runner now distinguishes successful request
observation from that terminal USB status, preserves the raw abort in evidence,
and still requires verified host-role/configuration restoration. Other transport
errors or absence of a captured/replied request do not count as success.

Two ordering details mattered: the IP must be a nested list item in `0x4301`,
and the listener must exist before iAP2 authentication begins. Otherwise the
dongle chooses macOS's existing AirPlay advertisement and is already connecting
when the custom invitation arrives. The final runner waits for the scoped
listener before sending DETECT. It also reads/acknowledges CarPlay availability
and continues draining link acknowledgements after the invitation.

The remaining receiver work starts at AirPlay `/auth-setup`, followed by
capability/display exchange, stream setup, and video decoding. The earlier
iAP2 authentication success does not mean this second protocol phase is done.
The previously observed 800×480 car resolution has not yet been negotiated with
the Mac receiver.

## Bounds and tests

The control parser handles fragmented/coalesced USB data, validates header and
payload checksums, limits packet/message sizes, verifies data sequences, and
replays replies to identical duplicate data packets. It allows only the messages
needed by this probe; it is not a complete iAP2 link implementation. The separate
role helper remains necessary because synchronous USB reads can outlast their
requested timeout. A DETECT timeout no longer starts a blocking read before a
successful send.

ASan/UBSan tests cover split points, corrupted frames, duplicate requests,
sequence wraparound, out-of-order authentication, unsupported challenges,
identification encoding, and the nested session-start address. Native builds use
warnings as errors. Actual live authentication and identification supplement,
rather than replace, these parser tests.

Reference message definitions:

- [Authentication messages](https://github.com/wiomoc/iap2/blob/master/iap2/control_session_message/authentication.py)
- [Head-unit identification](https://github.com/catplay-labs/catplay/blob/master/catplay_carplay_rx_gadget/src/iap2_session.rs)
- [CarPlay session messages](https://github.com/catplay-labs/catplay/blob/master/core/catplay_csm/src/msg/carplay_modern.rs)
