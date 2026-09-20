# Carlinkit Sony audio fix: before/after firmware analysis

**Result:** the release associated with Sony XAV audio fixes contains an explicit
Sony USB-product-name workaround in the car-facing `fakeiOSDevice` executable.
It adds 44.1 kHz, 16-bit stereo PCM to the main/media format masks and requests
`MediaQuality=0`, which selects 44.1 kHz over 48 kHz when both are available.
A second Sony-specific branch selects HomeKit pairing when the corresponding
feature is advertised. These are concrete compatibility changes, not proof that
either one alone fixes SmartBox on the XAV-AX1005DB.

## Releases and provenance

Carlinkit's [official CarlinKit 3.0 changelog](https://www.carlinkit.com/news_detail/6.html)
associates **2022.06.08.1109** with:

> Solve various audio problems of Sony XAV series car phone

The same entry mentions Volkswagen/Seat microphone fixes. It does not name the
XAV-AX1005DB specifically or explain the implementation.

Downloaded the two **stock U2W AUTOKIT** images from
[Ludwig V.'s public firmware archive](https://github.com/ludwig-v/wireless-carplay-dongle-reverse-engineering/blob/b437135316275a5d3c375bdd1ceac2a6bcf1315b/Firmware/U2W/README.md),
pinned to commit `b437135316275a5d3c375bdd1ceac2a6bcf1315b`:

| Release | Image bytes | SHA-256 |
|---|---:|---|
| 2022.01.24.1903 | 12,798,562 | `40980d6cd99bf9228afa821beb568fabc98488832bdd6f559c5f696a1f6becd9` |
| 2022.06.08.1109 | 13,444,618 | `3987f4bb633c10ca6f11764d3a456d014d63efe065fb353af91c84d8f9840060` |

January is the nearest earlier AUTOKIT image in that archive, **not a confirmed
immediate predecessor**. The official changelog itself jumps from August 2021
to June 2022. This comparison spans multiple changes and cannot date every
individual change to June 8. Image sizes and Git blob hashes were initially
checked against the pinned repository tree; SHA-256 hashes are enforced by the
reproduction script. These identify the mirror's bytes, not a vendor signature.
The decrypted `etc/software_version` matches each requested version.

## What changed

Both archives contain 79 regular files and two symlinks. **29 regular files
changed**, with no additions/removals at this archive level. Nested archives
are included by their container hashes, not recursively inventoried.
Full file hashes and decode records are in [comparison.json](comparison.json).

| Packed program | January bytes | June bytes |
|---|---:|---:|
| `usr/sbin/fakeiOSDevice` | 1,040,124 | 1,113,948 |
| `usr/sbin/AppleCarPlay` | 303,208 | 303,992 |
| `usr/sbin/ARMiPhoneIAP2` | 167,912 | 161,480 |

Packed size changes are not measures of added functionality. The executable
packing has two layers: the update archive's AES wrapper and a modified UPX
layout whose main compressed code block has an AES-encrypted 8 KiB prefix.
Restoring just the UPX magic is insufficient. Normal UPX also reported checksum
errors after prefix decryption, so it was not used to produce the evidence.

The analysis script directly decrypts and LZMA-decodes the original PT_LOAD
segments of `fakeiOSDevice`, `AppleCarPlay`, and `riddleBoxCfg`. It verifies the
block lengths against the original ELF program headers. It does not restore
the trailing section table, validate UPX checksums, or produce runnable binaries.
`ARMiPhoneIAP2` additionally uses an executable filter and was only compared as
a packed file. No firmware executable or device update command was run.

## Sony-specific format change

The January binary has no `SONY CAR AUDIO` string. Its corresponding format
selection has special handling for MISTRA and VOLVO, then chooses between
existing format bits using `MediaQuality`:
[January Thumb disassembly](evidence/before-format-selection.asm).

In June, the new Sony path is explicit:

1. `0x410ac` calls the helper at `0x52038`. That helper reads
   `/tmp/car_usb_product`: [USB product helper](evidence/usb-product-name.asm).
2. `0x410b0–0x410b8` checks whether the returned name contains `SONY CAR AUDIO`
   using imported `strstr`.
3. For a match, `0x410cc` and `0x410d8` OR `0x800` into two format masks.
   The containing function identifies the latter as the main-stream `media`
   output mask; the former is subsequently written to `/tmp/main_audio_format`.
4. `0x410c4–0x410e0` passes `MediaQuality` and zero to the configuration setter.
   Here `r8` is zero because the preceding MISTRA search failed.
5. If the main mask contains both `0x800` and `0x8000`, the subsequent setting
   read at `0x41128` selects which bit to remove. For zero, `0x41134` and
   `0x4114c` clear `0x8000` from the main and media masks.

Evidence: [Sony format branch](evidence/sony-format-selection.asm),
[containing format parser](evidence/format-context.asm), and
[result written to main_audio_format](evidence/format-result.asm).

The bit meanings are independently documented in the public
[AirPlayCommon.h definitions](https://github.com/45clouds/WirelessCarPlay/blob/master/source/Sources/AirPlayCommon.h#L346)
and [format conversion code](https://github.com/45clouds/WirelessCarPlay/blob/master/source/Sources/AirPlayUtils.c#L95):

| Mask | Format |
|---|---|
| `0x800` | PCM, 44,100 Hz, 16-bit, two channels |
| `0x8000` | PCM, 48,000 Hz, 16-bit, two channels |

Thus the Sony workaround does more than honor an ordinary quality toggle: it
**adds the 44.1 kHz capability even if that bit was absent**, then requests the
preference that removes 48 kHz when both are present. Configuration writes can
fail at runtime; the static branch does not prove the final setting took effect
in any particular session.

Conceptual reconstruction, not vendor source:

```text
if USB product name contains "SONY CAR AUDIO":
    main_output_formats  |= PCM_44100_16_STEREO
    media_output_formats |= PCM_44100_16_STEREO
    request MediaQuality = 0

if main_output_formats includes both stereo rates:
    if read MediaQuality == 0:
        clear PCM_48000_16_STEREO from main and media output formats
    else:
        clear PCM_44100_16_STEREO from main and media output formats
```

## Separate pairing change

At `0x39e18`, the June binary tests bit 38 of a feature field. When it is set,
it checks the USB product for `SONY CAR AUDIO` or `USB4931`, then calls the
routine at `0x39300` with a null second argument. That routine has the log label
`Send pair-setup HK`; other cases take the existing MFiSAP-labelled path.

Evidence: [Sony pairing selection](evidence/sony-pairing-selection.asm) and
[called routine's log label](evidence/pair-setup-hk-log.asm).
The public AirPlay feature definitions name bit 38 `HKPairingAndEncrypt`.
This supports a HomeKit pairing/control-encryption interpretation. It does
not establish that this branch caused the audio fix, or that this user's Sony
advertises that feature bit.

The decoded string diff also adds audio converter/ring-buffer/jitter-buffer
messages and an audio ChaCha decryption error, while removing older sample-rate
converter messages. See [added audio strings](diffs/fakeiOSDevice.audio-strings.added.txt)
and [removed audio strings](diffs/fakeiOSDevice.audio-strings.removed.txt).
String presence is supporting evidence only; no entire conversion algorithm
or its correctness has been reconstructed here.

## Implications for HW501

The strongest next candidate is a **Sony-specific car-facing 44.1 kHz PCM
preference**, with real sample-rate conversion when the phone-side stream
differs. Altering only a header or format advertisement would not correctly
convert 48 kHz samples to 44.1 kHz. The separate pairing branch should also be
checked against the Sony's advertised features and the HW501 handshake.

This explains a concrete reason that trying all HW501 Media modes may fail:
those settings affect the phone-facing format advertisement we traced, while
Carlinkit's Sony branch changes the car-facing format masks. It does not prove
the running HW501 has a 48 kHz mismatch; a Sony-session capture is still needed
to choose and validate a patch. See [HW501 investigation](../sony-xav-ax1005db.md).

Carlinkit uses ARM code and a different software stack from HW501's RV32
firmware. The portable result is the compatibility behavior, not an executable
or flashable image. No Carlinkit firmware should be installed on HW501.

## Reproduce

With the existing analysis environment (Python, capstone, OpenSSL):

```sh
.venv/bin/python scripts/compare_carlinkit_audio.py
```

The script downloads missing pinned images, or verifies cached copies in
`firmwares/carlinkit/`. It regenerates the inventory, text/script diffs, decoded
audio-string differences, and selected annotated ARM/Thumb disassembly.
The firmware cache is ignored by Git; reports and the analysis script are
reviewable repository artifacts.

The packing parameters come from the pinned upstream
[archive tool](https://github.com/ludwig-v/wireless-carplay-dongle-reverse-engineering/blob/b437135316275a5d3c375bdd1ceac2a6bcf1315b/Firmware_Tools/FirmwareU2W.sh)
and [reconstructed AES driver](https://github.com/ludwig-v/wireless-carplay-dongle-reverse-engineering/blob/b437135316275a5d3c375bdd1ceac2a6bcf1315b/Kernel/new-files/drivers/crypto/mxs-dcp-hewei.c).
Only the latter's decryption parameters were used; its other functionality was
not executed or applied. Block layout was checked against UPX v3.96 sources.

Validation: both outer images match pinned SHA-256, archive version labels
match, all six selected program decodes match their original PT_LOAD lengths,
and all seven disassembly excerpts cover their requested address ranges.
This is static comparative evidence; physical Sony/HW501 validation is pending.
