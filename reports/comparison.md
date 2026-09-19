# HW501 firmware comparison

Retrieved: 2026-09-19T15:09:23.068898+00:00

| Version | Tar bytes | app.img bytes | Files/symlinks | app.img archive timestamp (UTC) |
|---|---:|---:|---:|---|
| 126 | 3,840,000 | 3,829,760 | 43 | 2025-08-02T08:19:27+00:00 |
| 128 | 4,341,760 | 4,333,568 | 67 | 2025-12-18T10:07:33+00:00 |
| 131 | 4,485,120 | 4,472,832 | 73 | 2026-09-15T08:38:42+00:00 |

## Pairwise file comparison

Files are compared by content, permission bits, and symlink targets; timestamps are excluded.

| From | To | Identical | Changed | Added | Removed |
|---:|---:|---:|---:|---:|---:|
| 126 | 128 | 32 | 10 | 25 | 1 |
| 126 | 131 | 28 | 14 | 31 | 1 |
| 128 | 131 | 58 | 9 | 6 | 0 |

### 126 → 128

Changed: `bin/CPAAProxyEx`, `bin/blueware`, `lib/libAirPlay.so`, `lib/libAirPlaySupport.so`, `lib/libAudioConverter.so`, `lib/libCarLifeStub.so`, `lib/libCoreUtils.so`, `lib/libMSNUtils.so`, `lib/libiAP2Link.so`, `lib/liblvgl.so`.

Added: `imgs/1.png`, `imgs/2.png`, `imgs/3.png`, `imgs/auto_tips.png`, `imgs/carplay_tips.png`, `imgs/icon_large.png`, `imgs/icon_medium.png`, `imgs/icon_small.png`, `imgs/step1_2.png`, `imgs/step2_2.png`, `imgs/step3_2.png`, `imgs/step3_logo.png`, `imgs/step3_qrcode.png`, `imgs/steptips_2.png`, `imgs/tstep1.png`, `imgs/tstep2.png`, `imgs/tstep3.png`, `imgs/v_1.png`, `imgs/v_2.png`, `imgs/v_3.png`, `lib/libAutoProxy.so`, `lib/libcrypto.so`, `lib/libcrypto.so.1.1`, `lib/libssl.so`, `lib/libssl.so.1.1`.

Removed: `lib/libwebrtc_aec.so`.


### 126 → 131

Changed: `bin/CPAAProxyEx`, `bin/blueware`, `bin/mdnsd`, `lib/libAirPlay.so`, `lib/libAirPlaySupport.so`, `lib/libAudioConverter.so`, `lib/libCarLifeStub.so`, `lib/libCoreUtils.so`, `lib/libMSNUtils.so`, `lib/libdns_sd.so`, `lib/libiAP2Link.so`, `lib/liblvgl.so`, `web/index_cptowlcp.html`, `web/index_cptowlcp_en.html`.

Added: `imgs/1.png`, `imgs/2.png`, `imgs/3.png`, `imgs/VAXT_logo_256.png`, `imgs/auto_tips.png`, `imgs/carplay_tips.png`, `imgs/driversync_logo.png`, `imgs/icon_large.png`, `imgs/icon_medium.png`, `imgs/icon_small.png`, `imgs/step1_2.png`, `imgs/step2_2.png`, `imgs/step3_2.png`, `imgs/step3_logo.png`, `imgs/step3_qrcode.png`, `imgs/steps4_1.png`, `imgs/steps4_2.png`, `imgs/steps4_3.png`, `imgs/steps4_jt.png`, `imgs/steptips_2.png`, `imgs/tstep1.png`, `imgs/tstep2.png`, `imgs/tstep3.png`, `imgs/v_1.png`, `imgs/v_2.png`, `imgs/v_3.png`, `lib/libAutoProxy.so`, `lib/libcrypto.so`, `lib/libcrypto.so.1.1`, `lib/libssl.so`, `lib/libssl.so.1.1`.

Removed: `lib/libwebrtc_aec.so`.


### 128 → 131

Changed: `bin/CPAAProxyEx`, `bin/mdnsd`, `lib/libCoreUtils.so`, `lib/libcrypto.so.1.1`, `lib/libdns_sd.so`, `lib/libiAP2Link.so`, `lib/liblvgl.so`, `web/index_cptowlcp.html`, `web/index_cptowlcp_en.html`.

Added: `imgs/VAXT_logo_256.png`, `imgs/driversync_logo.png`, `imgs/steps4_1.png`, `imgs/steps4_2.png`, `imgs/steps4_3.png`, `imgs/steps4_jt.png`.

## Advertised but unavailable

- v127: update file not found:/www/wwwroot/boxupdate/appupdate/hw501_update_v127.tar

## Archive SHA-256

- v126: `05cb3d1e6a2e18814fcedd1f2b981c29cedf271af3a8814e2810aa8ac773041d`
- v128: `7b761ff653abd6d2f325dd921a2d1f47b173b66a0dcd54ca869840f1faf08206`
- v131: `bbf89a7aaa399297609d1543fd0c977c6848c6284ecaa53e0fb4482af6a86466`

## Scope and verification

Source: http://43.138.184.52/appupdate/hw501_historyversion.json

Each downloaded tar matches the byte count and the first and final chunks from the appdatas endpoint. The bundled app.img MD5 matches in every release. Every tar and extracted file has a locally calculated SHA-256. These hashes establish local identity, not publisher authenticity. No firmware code was executed.

Unlisted archive discovery range: [1, 131]. See firmwares/hw501/discovery.json for exact HTTP and API outcomes. Unlisted files with different naming conventions and versions outside this range are outside this comparison.
