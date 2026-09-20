# Experimental Sony XAV-AX1005DB audio firmware

Built a fixed Sony audio profile for **SmartBox HW501, stock application v131**.
It implements the 44.1 kHz negotiation candidate found in the
[Carlinkit comparison](../carlinkit/README.md). **Boot and audible playback on
the Sony have not been tested. This is a test image, not a confirmed repair.**

The only supported target for this experiment is the Sony XAV-AX1005DB.
The profile runs unconditionally: there is no runtime manufacturer lock,
automatic radio detection, or fallback profile for other radios. It does not
remove all of the stock firmware's other protocol implementations.

## Image and provenance

- Update archive: `firmwares/experiments/hw501_131_sony_ax1005db_audio_v1/hw501_131.tar`
- SHA-256: `7609ee7de679607989bddfe6984806e6837f6a812ff9a75d12bf0a3372ab53bd`
- SquashFS image: 4,472,832 bytes, below the observed 5,242,880-byte app partition.
- Base archive SHA-256: `bbf89a7aaa399297609d1543fd0c977c6848c6284ecaa53e0fb4482af6a86466`.
- Base executable SHA-256: `a147d1b4fd2f73ed5a70b76c45cc5e5ca1aeaa8b1544d4aabc99b7a6618ecc84`.
- Full build metadata, executable hash, and exact patch sites: [build.json](build.json).

Only `bin/CPAAProxyEx` content changes. The builder verifies original filesystem
ownership, modes, timestamps, file sizes, and symlinks after repacking and
re-extraction. The app uses the normal stock updater and retains version 131.
There are no display-density or mirroring modifications in this image.
No device was contacted or flashed to build it.

## Implemented behavior

| Path | Stock behavior | Sony profile |
|---|---|---|
| Car `/info` main and main Media output-format masks | Retain the radio's advertised mask | Add `0x800` (44.1 kHz, 16-bit stereo PCM), remove `0x8000` (48 kHz, 16-bit stereo PCM) |
| Phone-facing stream 100 Media | Always offers `0x8800`, both PCM rates | Offer only `0x800`, 44.1 kHz PCM |
| Phone-facing stream 102 Media | Media setting or capability heuristic selects AAC-LC rate | Offer only `0x400000`, 44.1 kHz AAC-LC, regardless of Media setting |

The stock decoder can therefore receive media at 44.1 kHz and the stock
car-facing setup can select 44.1 kHz PCM. This patch **does not resample or
relabel 48 kHz samples**. If the phone ignores the offer, or the actual problem
is transport, pairing, or audio ownership, this image may still be silent.
The stock Media-mode control remains visible but cannot override this profile.

The main mask change preserves every other bit, including the upper 32 bits.
Microphone/input masks, telephony-specific masks, speech recognition, and
alternate-stream masks retain their stock handling. This is not a claim that
calls or Siri are fixed; they are part of the physical test below.

The separate Carlinkit Sony pairing change has **not** been ported. HW501 already
contains HomeKit pairing support and a different selection path; there is not
yet session evidence justifying a change to it.

## Patch evidence

The car `/info` parser stores audio formats in `gProxyInfos`; its
[getter](evidence/stock-format-getter.asm) returns that same structure to the
phone-facing advertisement code. In the
[parser](evidence/stock-car-format-parser.asm), generic main output is at
offset 16 and main Media output at offset 48. The Andes `lea.d` instruction at
`0x2ad84` computes the per-audio-type eight-byte slot; input formats are stored
separately, starting at offset 72.

The [new hook](evidence/patched-car-format-hook.asm) replaces the existing
`CFArrayCreateCopy` call at `0x2adb0`. The
[stub](evidence/patched-stub.asm) normalizes the two low words, logs the profile,
restores registers, and tail-calls the displaced function with its original
arguments and return address. It occupies verified zero padding at `0x12b860`,
with the executable PT_LOAD extended to cover the injected bytes. The patcher
rejects any executable other than the exact stock SHA-256, including an already
patched display or mirroring build.

Two existing instructions are also changed:

- `0x4d41a`: `c.lui t1,9` becomes `c.lui t1,1`; the following stock subtraction
  produces `0x800` instead of `0x8800`.
  [Before](evidence/stock-media-pcm-offer.asm), [after](evidence/patched-media-pcm-offer.asm).
- `0x4d604`: the Media-mode getter call becomes `lui a0,0x400`, feeding
  `0x400000` to the existing stream-102 advertisement path.
  [Before](evidence/stock-media-aac-offer.asm), [after](evidence/patched-media-aac-offer.asm).

The stock [PCM setup mapping](evidence/stock-pcm-rate-mapping.asm) remains intact.
The public [AirPlay format definitions](https://github.com/45clouds/WirelessCarPlay/blob/master/source/Sources/AirPlayCommon.h#L310)
identify the PCM and AAC-LC bits; the stock setup mapping also independently
maps `(44100, 16, 2)` to `0x800`.

## Offline validation and reproduction

Requirements: Python with `scripts/requirements-analysis.txt`, OpenSSL for the
earlier Carlinkit research, and `mksquashfs`/`unsquashfs` for packaging.

```sh
.venv/bin/python -m unittest discover -s scripts -p 'test_sony_audio_patch.py' -v
.venv/bin/python scripts/build_sony_firmware.py
```

Six tests pass. They execute the injected RV32 bytes, then the stock
audio-format advertisement function and its selection helpers with modeled
CF/log APIs. They cover all three Media settings, absent 44.1 kHz capability,
absent Media capability, upper-word preservation, microphone/telephony fields,
register/stack preservation, bounded memory writes, idempotent normalization,
incorrect/already-patched inputs, and exact changed-byte ranges. The unchanged
stock PCM mapping is executed for both 44.1 and 48 kHz to check that samples
are not simply relabeled. This does not emulate a CarPlay session or hardware.

Andes branch semantics in the test harness follow the local source of
[Andes QEMU](https://github.com/andestech/qemu/blob/32902627f26c5d760cd4efab499b989d566822f9/target/riscv/XAndesV5Isa.decode).
Other unsupported custom instructions cause the test to fail rather than being
silently skipped. The builder separately re-extracts the completed SquashFS,
compares the entire filesystem, and loads the tar using the real updater's
local validation routine, including the bundled image MD5 and chunk metadata.

## Physical test and rollback

This image is for an **HW501 dongle**, not for the Sony radio's firmware updater.
The existing updater checks the dongle hardware type before staging.
With the Mac connected to the adapter's Wi-Fi, installation commands are:

```sh
python3 scripts/update_device.py inspect
python3 scripts/update_device.py stage --release firmwares/experiments/hw501_131_sony_ax1005db_audio_v1
python3 scripts/update_device.py apply --release firmwares/experiments/hw501_131_sony_ax1005db_audio_v1
```

After the updater reports completion, re-plug the dongle. Reconnect the phone
so capabilities are negotiated again, then collect a session while testing
music, navigation/Siri, and an incoming/outgoing call:

```sh
python3 scripts/collect_device.py --seconds 120
```

Look for the `SonyAudio` log marker, stream-100 Media output `0x800`, stream-102
Media output `0x400000`, and media startup at 44100 Hz with two channels. Record
audible playback as well as setup errors. Version 131 alone does not identify
this image; use the marker or executable hash.

To restore the archived stock application while the normal updater is reachable:

```sh
python3 scripts/update_device.py stage --release firmwares/hw501/131
python3 scripts/update_device.py apply --release firmwares/hw501/131
```

The stock application archive is not a full-device recovery image. Runtime
boot, Sony playback, call behavior, and updating back to stock remain untested
for this particular build.
