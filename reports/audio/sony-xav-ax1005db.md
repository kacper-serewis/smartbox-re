# Sony XAV-AX1005DB: CarPlay picture with no audio

## Reported observations

- Head unit: Sony XAV-AX1005DB.
- Phone: iPhone 17 Pro Max; current iOS version not established.
- Direct wired CarPlay from the phone has sound.
- Through SmartBox, CarPlay displays but music, Siri/navigation, and calls are
  reported silent.
- All three Media modes have been tried without success.
- Compatibility mode, Sony firmware version, and the running dongle build have
  not been confirmed for this failing session.
- The dongle works with factory CarPlay systems, according to the user.

This isolates the symptom to the connection through the dongle. It does not yet
distinguish phone output routing, advertised capabilities, car-facing stream
setup/transport, or audio resource ownership. No Sony-session logs have been
collected in this investigation and no fix has been installed.

Subsequent [Carlinkit before/after firmware analysis](carlinkit/README.md) found
an explicit Sony-specific 44.1 kHz PCM preference and a separate pairing change
in the release associated with Sony audio fixes. Those are now concrete HW501
investigation leads; neither has been ported or tested on this setup.

## Static firmware evidence

Inspected archived **stock HW501 v131**, not a live dump from the failing setup.
`CPAAProxyEx` SHA-256:
`a147d1b4fd2f73ed5a70b76c45cc5e5ca1aeaa8b1544d4aabc99b7a6618ecc84`.
The hash matches the existing [binary inventory](../binaries/131.json).
Address ranges and limitations are recorded in [the evidence index](evidence/index.json).

1. The stock English web page labels `audiomode` as **Media mode**, with
   values 0, 1, 2 displayed as Mode 1, Mode 2, Mode 3. In the executable,
   the configuration read at `0x390d4` stores it at object offset `0x23d4`.
   See [configuration read](evidence/media_mode_read.asm).
2. The helper at `0x34f8c` reads that field. A caller at `0x4d604` uses its
   result while constructing the audio-format advertisement for stream type
   102, and ultimately calls `AirPlayInfoArrayAddAudioFormat` at `0x4d678`.
   See [helper](evidence/media_mode_helper.asm) and
   [format selection](evidence/media_format_selection.asm).
   This establishes an effect on the phone-facing format advertisement;
   it does not establish that this is the setting's only effect. The helper
   includes an undecoded Andes instruction, so an exact mode-to-codec mapping
   is deliberately not claimed here.
3. Separately, `carplay_audio_start` forwards into the internal routine at
   `0x3632c`, whose own log label is `writeCarPlayAudioInit`. It logs stream
   type, audio type, format, rate, channel count, and input direction, then
   has paths calling the proxy stream setup at `0x24674`. It also logs the
   returned playback handler. See [audio startup](evidence/audio_start.asm).
4. The routine at `0x4e098`, labelled by its log string as `sendMainAudioModes`,
   calls `AirPlayReceiverSessionChangeResourceMode`. This is a concrete
   resource-ownership path to investigate, not evidence that ownership is
   actually wrong on this Sony. See [resource-mode call](evidence/main_audio_resource.asm).

These paths explain why exhausting the Media modes does not exhaust possible
firmware fixes. They do **not** identify a defective instruction or justify
forcing an arbitrary sample rate or codec.

GNU objdump leaves vendor-specific Andes instructions undecoded. Its nearest
exported-symbol labels are not reliable names for internal functions; the
addresses, call targets, and embedded log labels are the evidence used here.

## Next capture

With the dongle in the **Sony**, connect the Mac to the dongle Wi-Fi. Start
collection before reconnecting the iPhone to wireless CarPlay if possible,
so setup messages are retained. Play music for about 20 seconds and invoke
Siri once during the capture:

```sh
python3 scripts/collect_device.py --seconds 90
```

The existing collector saves `adapter-logs.tar` and settings under
`device-snapshots/offline-<timestamp>/`. It does not flash firmware, change
settings, or upload the archive to the vendor. It currently filters display
messages into `display-lines.txt`; **the original archive is required for
audio analysis**. Its diagnostic request also has historical Opel/Corsa
metadata hardcoded, so those request fields must not be mistaken for the
identity of this Sony setup.

Read archive members in memory without extracting remote paths. Look for:

| Message or field | What to examine |
|---|---|
| `AudioFormats streamtype:` | Capabilities read from the other endpoint |
| `SetAudioFormats streamType:` | Formats advertised by the proxy |
| `writeCarPlayAudioInit` | Selected stream, format, rate, channels and handler |
| `SetupProxyAudioStream` | Setup failures |
| `audio setup ctx:` / `complet status:` | Asynchronous setup completion status |
| `get response audio ctx:` / `data_port=` / `err=` | Car-facing setup response and destination |
| `Audio audio send to proxy error` | Transport failures |
| `not support audio stream type:` | Explicitly rejected stream combinations |
| `InitialModes audio:` / `Modes changed:` / `sendMainAudioModes` | Audio ownership transitions |

Availability of messages depends on logging and retention. Missing messages
alone do not prove a stage never ran. A successful setup status also does not
prove audible playback. If stock logging is insufficient, the next engineering
step is bounded instrumentation of the identified paths, followed by a test
on the Sony. A working factory-radio capture is useful for comparison, but
its capabilities should not be copied blindly into the Sony session.

## Validation status

Firmware hash checked against the repository inventory; disassembly excerpts
generated from that binary. No firmware edits, hardware tests, or successful
audio repair are claimed.
