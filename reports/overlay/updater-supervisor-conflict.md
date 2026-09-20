# Update interruption on smartBox-9302

2026-09-20. **smartBox-9302 recovered, flash readback and reboot verified.** Do not reinstall the withdrawn
mirroring archive (`9bbc62e44225839cbf18d1f5c60a23f26d4d534714785a987f372081d62a58a8`).

## Successful physical recovery

The 11:49 offline capture confirmed recovery mode and a working stock diagnostics
handler. Its archive did not contain the updater termination log. Live inspection
then confirmed supervisor PID 119, original app PID/PGID 125, and UpdateServer PID
203 **also in PGID 125**. The cleanup conflict therefore applied on the device.

The stock diagnostics handler expands shell substitutions in its archive filename.
We used fixed commands through that local handler to inspect processes and deploy
a 324-byte, syscall-only RV32 session helper into `/tmp`. The source is
`experiments/emulation/recovery_detach.S`. The device's stripped BusyBox did not
provide `command`, `setsid`, or `base64`; octal `printf` transfers worked and the
helper checksum was verified. Early attempts to transfer it through a one-chunk
upload produced an empty staging file; checksum guards stopped before execution
or any flash request. The final recovery utility uses only the verified octal
transfer path.

The helper called `setsid` and executed the unchanged stock `/tmp/UpdateServer`
on port 8082. PID/PGID/session 1745 were verified, with no `/mnt/app` mappings and
a `/tmp` working directory. It survived the shutdown that killed the original
updater. The density137.5 archive was staged and flashed to **100%**.

Evidence:

- `device-snapshots/recovery-prepare-20260920T115829.288498Z`: helper checksum,
  independent session, process table and mappings.
- `device-snapshots/recovery-restore-20260920T115908.494544Z`: all upload
  acknowledgements and flash status, including 100%.
- `readback.json` in that restore directory: application partition readback over
  the exact image length matches MD5 `3d2016e72ac2710964e034980b0dd2e6`.
- `after-reboot/verification.json`: device restarted, only one CPAAProxyEx process,
  no smartbox-mode, and executable MD5 `809d9b880681b3d8ff583401993ed1c2` matches
  the earlier density137.5 binary. The normal port-80 updater responds again.

CarPlay in the Corsa was not retested during this PC-connected recovery. The
mirroring feature is removed; density137.5 is preserved. The temporary updater
and helper disappear at reboot. Persistent recovery flags were left untouched;
the restored density-only image does not use them.

The reproducible offline recovery utility is `scripts/recover_updater.py`, with
`probe` and `restore` actions. It defaults specifically to smartBox-9302 and pins
the inspected updater, detachment helper, and rollback image. It refuses a device
without the two expected CPAAProxyEx processes, including this now-recovered one.

Helper build (local toolchain/container already available):

```sh
docker run --rm --platform linux/amd64 --network none --read-only \
  --tmpfs /tmp:rw,exec,nosuid,size=16m -v "$PWD:/work" \
  smartbox-mirror-builder:local \
  /work/firmwares/research/mirror-deps/riscv32-ilp32d--glibc--bleeding-edge-2021.11-1/bin/riscv32-buildroot-linux-gnu-gcc \
  -nostdlib -static -march=rv32im -mabi=ilp32 \
  -Wl,--build-id=none,-z,noexecstack,-s \
  -o /work/firmwares/research/recovery/detach \
  /work/experiments/emulation/recovery_detach.S
```

Helper SHA-256:
`ebaf99fd64ec30a622cd32ca4b3ed20be84bc1339a6f5b51ab34f1ef2ca2b6b6`.
QEMU checks verified a new session, preserved arguments/environment, and failure
with exit 127 for missing arguments or an unsuccessful setsid call.

## Original failure evidence

- smartBox-9302: HW501, app 131/build 2026081801, system 20250811. Snapshots
  `20260920T101342.935799Z` through `20260920T101720.957396Z` show successful
  chunk acknowledgements and staging, followed by 1%/3% and loss of status or `{}`.
  Both 152-chunk experimental and 137-chunk stock/density-sized uploads failed.
- User reports both HTTP pages accessible afterward, with the mirror API reporting
  `{"state":"recovery","reason":"latched","wait_status":0,"attempts":1,"pin":"","head_unit_verified":false}`.
  This indicates the supervisor booted with its persistent recovery flag; the
  zero wait status is initialized state, not a record of the original failure.
- Snapshot `20260920T101818.510027Z` reached 100%, but its device metadata identifies
  **smartBox-76F9**, app 127/build 20251030127/system 20251112 before updating.
  It is the second adapter and does not prove recovery of smartBox-9302.
- A 137-chunk archive size alone cannot distinguish stock from density variants.

## Confirmed software conflict

Stock v131 CPAAProxyEx, addresses 0x49698–0x496c8, copies UpdateServer to `/tmp`,
copies the web files, then calls `system` with:

```text
/tmp/UpdateServer -root /tmp/boxupdate/ -index_files index_cptowlcp.html &
```

This helper inherits the app process group. Running the actual stock UpdateServer
under Andes RV32 QEMU with these arguments served `/getupdatestatus` as `{}` and
retained its original PID/process group: it did not daemonize. No flash request
was issued in that check; the container was read-only with no network or devices.

The updater enumerates `/mnt/app/bin`, runs `killall` on executable names (excluding
UpdateServer/wpa_cli/wpa_supplicant), and then attempts to unmount `/mnt/app` before
writing. Relevant v131 UpdateServer ranges: 0x23a6c–0x23b9e (kill enumeration),
0x23c34–0x24054 (update sequence), 0x237f4 onward (write loop). The last observed
1%/3% is a polling sample, not a direct count of bytes written.

The withdrawn supervisor calls `kill(-app, SIGKILL)` on app exit and uses group
termination during supervisor shutdown/recovery. That includes UpdateServer.
The intentional updater-driven app exit therefore conflicts with crash cleanup.
The conflict applies even when mirroring is already disabled by recovery.

Reproduction with the old supervisor, compiled both natively and for RV32/QEMU:
a simulated updater stayed in the app group, signaled the app to exit, and was
killed before its completion marker. No flash was written. Combined with the
actual updater's process-group behavior, this is a strong explanation of the
physical symptoms. Target logs/process inspection are still needed to establish
the exact interruption on smartBox-9302 and rule out additional failures.

## Local correction and limits

`device_launch.c` now leaves vendor helper groups intact on app exit and terminates
only the app PID during cleanup. Mode-page group cleanup is unchanged. This trades
blanket descendant cleanup for compatibility with vendor helpers that deliberately
outlive the app. It does not restore an already installed supervisor.

`test_mirroring_supervisor.py`: 13 tests passed natively and 13 under RV32/QEMU,
including updater survival on app exit and supervisor shutdown. Existing crash,
startup timeout, persistent recovery, and bounded retry checks passed. Children
are disposable Linux processes; these are not hardware flash/recovery tests.
`test_update_device.py`: five protocol/rejection tests passed. The actual withdrawn
archive hash is rejected before staging, regardless of its manifest label.

No corrected mirroring release has been prepared or installed as part of this fix.
Repeating a regular update through the installed supervisor can hit the same bug.
Do not clear recovery or factory-reset as a workaround for the process-group bug.
The diagnostic capture and subsequent live recovery above completed this next
investigation step. Ordinary firmware updates must use the normal updater after
recovery; do not run the recovery utility again on the restored device.
