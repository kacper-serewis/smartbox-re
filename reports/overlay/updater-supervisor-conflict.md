# Update interruption on smartBox-9302

2026-09-20. Device recovery is **not verified**. Do not reinstall the withdrawn
mirroring archive (`9bbc62e44225839cbf18d1f5c60a23f26d4d534714785a987f372081d62a58a8`).

## Physical evidence

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

No corrected flash release has been prepared or installed as part of this fix.
Repeating a regular update through the installed supervisor can hit the same bug.
Do not clear recovery or factory-reset as a workaround for the process-group bug.
Next evidence: collect stock logs plus both mode APIs and update status on the
affected device with `python3 scripts/collect_device.py --mirroring --seconds 10`.
The collector requires adapter Wi-Fi but no internet, and never stages or flashes.
