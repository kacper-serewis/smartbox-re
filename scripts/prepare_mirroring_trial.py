#!/usr/bin/env python3
"""Clear obsolete recovery flags on the restored smartBox-9302 before its next trial.

No flashing or application restart. Refuses an active experimental application.
Defaults to checks only; --apply archives and removes the two recovery flags.
"""
import argparse
from datetime import datetime, timezone
from pathlib import Path

from recover_updater import Recovery, process_table
from update_device import load_release

ROOT = Path(__file__).resolve().parents[1]
RELEASE = ROOT / 'firmwares/experiments/hw501_131_mirroring_density137.5_autorestart'
RELEASE_SHA = 'c65cf3edda804a7aeb239103325019f688d135eaccc35a7190be02950df30627'
RESTORED_MD5 = '809d9b880681b3d8ff583401993ed1c2'


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--apply', action='store_true')
    args = parser.parse_args()
    metadata, _ = load_release(RELEASE)
    if metadata['sha256'] != RELEASE_SHA:
        raise ValueError('This preparation is only for the verified autorestart trial archive')
    output = ROOT / 'device-snapshots' / ('prepare-mirroring-' + datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%S.%fZ'))
    output.mkdir(mode=0o700)
    print(f'Evidence: {output}', flush=True)
    r = Recovery('http://192.168.5.1', output, 'smartBox-9302')
    r.check_identity()
    status = r.read_json('getupdatestatus', payload={})
    if status.get('percent', 0) not in (0, 100):
        raise ValueError('An update may be active; no flags changed')
    processes = process_table(r.diagnostic('cat /proc/[0-9]*/stat'))
    apps = [p for p in processes.values() if p['name'] == 'CPAAProxyEx' and p['state'] != 'Z']
    if len(apps) != 1:
        raise ValueError('Expected only the restored application; no flags changed')
    pid = apps[0]['pid']
    maps = r.diagnostic(f'cat /proc/{pid}/maps')
    if '/mnt/app/bin/CPAAProxyEx' not in maps or 'libsmartbox-mirror.so' in maps:
        raise ValueError('Experimental or unexpected application is running; no flags changed')
    digest = r.diagnostic(f'md5sum /proc/{pid}/exe').split()
    if not digest or digest[0] != RESTORED_MD5:
        raise ValueError('Running executable is not the restored density137.5 build')
    # Archive just the obsolete flags, never the pairing private key.
    r.diagnostic('cat /mnt/UDISK/smartbox-mode/recovery-disabled')
    r.diagnostic('cat /mnt/UDISK/smartbox-mode/boot-pending')
    if not args.apply:
        print('Verified restored app and trial archive. Use --apply to clear the obsolete flags.')
        return
    # Recheck the running executable immediately before this narrowly scoped change.
    result = r.diagnostic(
        f'test "$(md5sum /proc/{pid}/exe)" = "{RESTORED_MD5}  /proc/{pid}/exe" && '
        'rm -f /mnt/UDISK/smartbox-mode/recovery-disabled /mnt/UDISK/smartbox-mode/boot-pending && '
        'sync && echo TRIAL_READY')
    if result.strip() != 'TRIAL_READY':
        raise ValueError('Flag cleanup was not confirmed; inspect evidence before flashing')
    print('Old recovery flags cleared. Current CarPlay app is unchanged; ready for the trial flash.')


if __name__ == '__main__':
    main()
