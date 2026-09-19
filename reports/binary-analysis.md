# HW501 binary analysis: v126, v128, v131

This extends the file comparison with ELF dependencies, exported/imported symbols, per-function byte fingerprints, data-section strings, and selected RISC-V disassembly. Your reported app version `HW501_20250630126` matches the version string in the v126 image; that string alone does not prove your installed partition is byte-identical to this download.

## Main results

| Component | v126 bytes | v128 bytes | v131 bytes | Finding |
|---|---:|---:|---:|---|
| `CPAAProxyEx` | 2,393,408 | 1,153,348 | 1,173,892 | Major restructuring in 128; connection handling and configuration changes in 131 |
| `libAutoProxy.so` | absent | 817,564 | 817,564 | Added Android Auto-related library; identical in 128 and 131 |
| `blueware` | 868,316 | 872,420 | 872,420 | Bluetooth stack build changes in 128, unchanged in 131 |
| `mdnsd` | 284,704 | 284,704 | 559,264 | Major discovery-stack replacement in 131 |
| `libdns_sd.so` | 26,056 | 26,056 | 46,544 | Discovery client API expands in 131 |
| `libiAP2Link.so` | 158,816 | 88,796 | 88,784 | Specific queue and flow-control changes in 131 |
| `libCoreUtils.so` | 801,880 | 646,232 | 646,232 | Same total size in 128/131, but MFi initialization code changes |
| `UpdateServer` | 187,388 | 187,388 | 187,388 | Byte-identical in all three |

## v126 → v128: restructuring and different component builds

### Android Auto code moves into a shared library

The executable's actual `DT_NEEDED` list gains `libAutoProxy.so`, `libssl.so.1.1`, and `libcrypto.so.1.1`. Its `.text` section shrinks from 1,685,944 to 910,088 bytes, and defined dynamic function symbols drop from 269 to 60.

Of the 210 named functions no longer defined in the main executable, 40 are defined in the new AutoProxy library. Including exported data and objects, 373 exported names removed from the executable appear in AutoProxy, including Android Auto `gal` protocol and Wi-Fi-discovery protobuf objects. This is stronger evidence of component separation than merely finding a new library filename; it does not establish that all those implementations are unchanged.

### Bluetooth stack build changes

The `blueware` binary's embedded build identifier changes:

```text
v126: ZA_NAS_BT01,V2.7.2,20250611
v128: ZA_NAS_BT01,V2.9.5,20251028
v131: identical to v128
```

New data strings in v128 include `BLE_TX_POWER`, `BT_HFP_AUDIO_BUFF_SIZE`, `BT_SOCKET_AV_PATH`, and `BT_SOCKET_MIC_PATH`. These identify areas worth investigating, but their presence alone does not establish defaults or behavior. The page's `BT version: 20240910` is a separate reported field; it is not this embedded stack build identifier.

### Several libraries are substantially reduced

For example, `libMSNUtils.so` shrinks from 1,523,212 to 298,420 bytes and loses exported `yyjson_*` routines; its logging strings also change. `liblvgl.so` loses exported canvas/grid/QR-code/spinner functions and some fonts. AirPlay and iAP2 libraries also shrink. Rebuild options, omitted features, and code restructuring can account for size reductions: these are not evidence by themselves of improved performance or removed user-facing functionality.

## v128 → v131: verified instruction-level changes

### 1. iAP2 packet insertion now handles failure

Function: `iAP2LinkQueueSendData` in `libiAP2Link.so`, 332 → 410 bytes.

In v128, the function calls `iAP2LinkAddPacketAfter` and continues processing without checking its return value. In v131, instructions at `0xba08–0xba10` compare the result against **255**. On that result, the new path logs queue details, calls `iAP2PacketDelete` at `0xba5e`, and sets the function's result to zero before leaving through its existing callback path.

Simplified description of the changed part, not recovered original source:

```c
// v128
iAP2LinkAddPacketAfter(queue, previous, &packet);
advance_payload();

// v131
index = iAP2LinkAddPacketAfter(queue, previous, &packet);
if (index == 255) {
    log_queue_details();
    iAP2PacketDelete(packet);
    result = 0;
    goto notify_and_return;
}
advance_payload();
```

This is a concrete error-handling improvement. It prevents this path from advancing as though insertion succeeded and cleans up the unqueued packet. Whether it fixes an observed disconnect or stall requires runtime testing.

Evidence: [v128](binaries/disassembly/128__libiAP2Link.so__iAP2LinkQueueSendData.asm), [v131](binaries/disassembly/131__libiAP2Link.so__iAP2LinkQueueSendData.asm).

### 2. iAP2 send-window handling gains a condition

Function: `iAP2LinkSendWindowAvailable`, 46 → 54 bytes.

On the path leading to the sequence-gap check, v131 first reads a byte at link-structure offset **191**. If that byte is zero, it returns true without performing the sequence-gap/window comparison. If nonzero, it retains the comparison against the byte at offset 199. V128 performs that comparison without the new offset-191 check.

The field's source-level name is not available in the stripped image. This establishes a flow-control logic change but does not justify naming the field or claiming a particular phone compatibility fix.

Evidence: [v128](binaries/disassembly/128__libiAP2Link.so__iAP2LinkSendWindowAvailable.asm), [v131](binaries/disassembly/131__libiAP2Link.so__iAP2LinkSendWindowAvailable.asm).

### 3. CarPlay timeout recovery is reorganized

Function: `_WaitConnectTimeoutHandler` in `CPAAProxyEx`, 332 → 212 bytes.

The older handler directly cancels/releases two dispatch sources and deallocates a DNS service reference, with a log describing deregistration of `_carplay-ctrl._tcp`. That block is absent from the v131 handler. Both versions retain paths that restart Bonjour browsing for `_airplay._tcp.` and can restart `mdnsd`, and both can dispatch an asynchronous callback.

This proves the timeout handler's cleanup/recovery sequence changed. It does **not** prove those resources are never cleaned up: asynchronous callbacks and other paths can handle cleanup. The callback reached from this handler still contains timer cancellation/release calls.

Evidence: [v128](binaries/disassembly/128__CPAAProxyEx___WaitConnectTimeoutHandler.asm), [v131](binaries/disassembly/131__CPAAProxyEx___WaitConnectTimeoutHandler.asm).

### 4. MFi initialization skips local setup when a remote certificate callback is configured

Function: `MFiPlatform_Initialize` in `libCoreUtils.so`, 296 → 314 bytes.

V131 adds a guard at `0x44660`: it loads **`gRemoteCopyCertificate`**, checks whether its value is nonzero, and immediately returns zero if so. The ELF relocation for GOT address `0x9e5b0` resolves to that exact symbol. Otherwise, it proceeds with the existing local MFi device initialization, including the `mfi_dev_path` setting, default `/dev/i2c-0`, address probing, and certificate-copy call.

This changes which initialization path runs when an existing remote-certificate mechanism is configured; it does not establish that authentication is disabled.

Evidence: [v128](binaries/disassembly/128__libCoreUtils.so__MFiPlatform_Initialize.asm), [v131](binaries/disassembly/131__libCoreUtils.so__MFiPlatform_Initialize.asm).

### 5. The system-check thread gains logging, not a newly introduced check

Function: `CarPlayProxyApp::check_sys_code_thread(void*)`, 40 → 72 bytes.

Both versions call two internal routines and clear the same object byte at offset `0x23bc` when the second routine returns zero. V131 adds an `MLOGD` call with `check system code failed` on that path. Finding this new string alone would incorrectly suggest that v131 introduced the entire check. The internal routines were not fully reconstructed, so this observation is limited to the wrapper.

Evidence: [v128](binaries/disassembly/128__CPAAProxyEx___ZN15CarPlayProxyApp21check_sys_code_threadEPv.asm), [v131](binaries/disassembly/131__CPAAProxyEx___ZN15CarPlayProxyApp21check_sys_code_threadEPv.asm).

## Other v131 changes with supporting binary evidence

### Discovery stack

`mdnsd` grows from 184,634 to 431,956 bytes of executable `.text`. Its embedded engineering-build date changes from **Apr 6 2025** to **Aug 9 2026**. `libdns_sd.so` grows from 41 to 73 defined dynamic function symbols, with 33 added and one removed. This is a substantial replacement/rebuild of the discovery components, not a timestamp-only change. No exact upstream release number or bug-fix list has been established.

### Configuration hooks are actually referenced

The new `PROXY_AP_USE_WIFI4` string is loaded as an argument to `getenv` at `0x393fc`, parsed with `strtol`, and used in a branch at `0x39414`. `PROXY_DEVICE_AP_PSK` is also passed to `getenv`, as is `PROXY_USE_CHIPID_TO_BTADDRESS` in the Bluetooth startup path. These are active configuration-reading paths. Their values on your installed system are unknown.

Evidence: [Wi-Fi configuration](binaries/disassembly/131__CPAAProxyEx__wifi_configuration.asm), [AP password](binaries/disassembly/131__CPAAProxyEx__ap_password_configuration.asm), [Bluetooth address](binaries/disassembly/131__CPAAProxyEx__bt_address_configuration.asm).

### Graphics and crypto

`liblvgl.so` adds exported `lv_dither_none`, `lv_dither_ordered_hor`, and `lv_dither_ordered_ver`; its gradient functions change. This aligns with the new UI imagery and styling imports in the main executable.

Both crypto libraries identify themselves as **OpenSSL 1.1.1n**, but `libcrypto.so.1.1` has a different build timestamp and code bytes in v131. `libssl.so.1.1` is identical. There is insufficient evidence here to call this an OpenSSL version upgrade or a specific security patch.

### Components unchanged from v128

`blueware`, `UpdateServer`, `libAutoProxy.so`, `libAirPlay.so`, `libAirPlaySupport.so`, `libAudioConverter.so`, `libCarLifeStub.so`, `libMSNUtils.so`, `libDecEncLib.so`, `libprotobuf-lite.so`, `libatomic.so.1.2.0`, and `libssl.so.1.1` have identical SHA-256 hashes. Changes in callers or system configuration can still alter their runtime behavior.

## Method and limits

- All analysis is static; firmware code was not executed.
- ELF images advertise `rv32i2p0_m2p0_a2p0_f2p0_d2p0_c2p0_xandes5p0` and an Andes GCC 10.4.0 build. The available decoders do not interpret every Andes extension instruction. Those instructions remain as raw `.insn` words; no semantics are assigned to them here.
- GNU objdump's labels such as `SomeFunction+0x1234` can merely name the nearest exported symbol. They do not establish the containing function's true name. Exact symbol boundaries are used for the named-function excerpts; configuration snippets are explicitly address ranges.
- Most local symbols are stripped. The main executable has only 60 defined dynamic function symbols in v128 and v131, so named-function comparison is partial.
- Per-function byte changes include relocation and layout differences. The generated mnemonic fingerprints are only a coarse triage aid: matching mnemonics can hide changed constants, targets, or operands; differing raw Andes instructions may reflect address changes. They are not used as a count of behavioral changes.
- Data strings come from `.rodata`, `.data`, and `.comment`, avoiding printable instruction bytes. Adjacent binary data can still create false string fragments; conclusions use specific strings or confirmed references.

Raw metadata: [v126](binaries/126.json), [v128](binaries/128.json), [v131](binaries/131.json), [pairwise binary comparison](binaries/comparison.json). Full main-executable disassemblies are stored locally in `firmwares/hw501/<version>/analysis/CPAAProxyEx.asm`.
