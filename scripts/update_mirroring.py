#!/usr/bin/env python3
"""Upgrade the healthy, corrected mirroring build on smartBox-9302.

Upload first, gracefully stop the verified supervisor, then flash through the
surviving stock updater. This prevents an intentional update from latching app
crash recovery. No recovery flags are removed. Defaults to read-only checks.
"""
import argparse
from datetime import datetime, timezone
import json
from pathlib import Path
import time

from recover_updater import Recovery, process_table
from update_device import Device, load_release, stage, apply

ROOT = Path(__file__).resolve().parents[1]
RELEASE = ROOT / 'firmwares/experiments/hw501_131_mirroring_density137.5_screeninfo'
RELEASE_SHA = 'dee78e2cd39537176bf3039f749ae63ec6a8e9e76d2e5251b83a61634bf8cd7e'
SUPERVISOR_MD5 = 'bfb9e647a9bab5e5f4e44b5b1104a4f8'
APP_MD5 = '809d9b880681b3d8ff583401993ed1c2'


def processes(r):
    return process_table(r.diagnostic('cat /proc/[0-9]*/stat'))


def clean_flags(r):
    result = r.diagnostic('test ! -e /mnt/UDISK/smartbox-mode/recovery-disabled && '
                          'test ! -e /mnt/UDISK/smartbox-mode/boot-pending && echo CLEAN')
    if result.strip() != 'CLEAN':
        raise ValueError('Recovery or startup guard is present; no flags will be cleared. Inspect the mode page first.')


def preflight(r):
    r.check_identity()
    status = r.read_json('getupdatestatus', payload={})
    if status.get('percent', 0) not in (0, 100):
        raise ValueError('An update may be active; refusing another update')
    clean_flags(r)
    procs = processes(r)
    apps = [p for p in procs.values() if p['name'] == 'CPAAProxyEx' and p['state'] != 'Z']
    if len(apps) != 2:
        raise ValueError('Expected the healthy corrected supervisor and its application')
    children = [p for p in apps if any(parent['pid'] == p['ppid'] for parent in apps)]
    if len(children) != 1:
        raise ValueError('Unexpected application/supervisor relationship')
    child = children[0]
    supervisor = procs[child['ppid']]
    for proc, expected in ((supervisor, SUPERVISOR_MD5), (child, APP_MD5)):
        result = r.diagnostic(f'md5sum /proc/{proc["pid"]}/exe').split()
        if not result or result[0] != expected:
            raise ValueError('Running application or supervisor is not the verified build')
    return supervisor


def stop_supervisor(r, expected):
    clean_flags(r)
    current = processes(r).get(expected['pid'])
    identity_fields = ('pid', 'name', 'ppid', 'pgid', 'sid', 'start_time')
    if not current or any(current[k] != expected[k] for k in identity_fields):
        raise ValueError('Supervisor identity changed during upload; flash not requested')
    pid = expected['pid']
    result = r.diagnostic(
        f'test "$(md5sum /proc/{pid}/exe)" = "{SUPERVISOR_MD5}  /proc/{pid}/exe" && '
        f'kill -TERM {pid} && echo STOP_REQUESTED')
    if result.strip() != 'STOP_REQUESTED':
        raise ValueError('Could not confirm supervisor shutdown request')
    deadline = time.monotonic() + 10
    while True:
        apps = [p for p in processes(r).values() if p['name'] == 'CPAAProxyEx' and p['state'] != 'Z']
        if not apps:
            break
        if time.monotonic() >= deadline:
            raise ValueError('Application did not stop cleanly; flash not requested')
        time.sleep(0.2)
    clean_flags(r)


def upgrade(r, device, metadata, raw, supervisor, progress):
    stage(device, metadata, raw)
    # Before stopping the app, persist which image and process this run owns.
    (r.output / 'staged.json').write_text(json.dumps(dict(
        sha256=metadata['sha256'], supervisor=supervisor), indent=2) + '\n')
    progress['shutdown_requested'] = True
    stop_supervisor(r, supervisor)
    status = device.request('getupdatestatus', b'')
    meta = metadata['chunk_metadata']
    if any(status.get(k) != v for k, v in {
        'version': metadata['version'], 'pos': meta['count'] - 1, 'count': meta['count']}.items()):
        raise ValueError('Surviving updater did not confirm the staged image; flash not requested')
    progress['flash_requested'] = True
    apply(device, metadata['version'])
    count = metadata['app_size'] // 512
    result = r.diagnostic(f'dd if=/dev/by-name/app bs=512 count={count} 2>/dev/null | md5sum').split()
    if not result or result[0] != metadata['app_md5']:
        raise ValueError('Flash readback did not match; keep power connected and inspect evidence')
    (r.output / 'result.json').write_text(json.dumps(dict(
        reported_complete=True, readback_matches=True, sha256=metadata['sha256']), indent=2) + '\n')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('action', choices=('check', 'apply'), default='check', nargs='?')
    args = parser.parse_args()
    metadata, raw = load_release(RELEASE)
    if metadata['sha256'] != RELEASE_SHA or metadata['app_size'] % 512:
        raise ValueError('Unexpected screen-info trial image')
    out = ROOT / 'device-snapshots' / ('mirroring-update-' + datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%S.%fZ'))
    out.mkdir(mode=0o700)
    print('Evidence:', out, flush=True)
    r = Recovery('http://192.168.5.1', out, 'smartBox-9302')
    progress = dict(shutdown_requested=False, flash_requested=False)
    try:
        supervisor = preflight(r)
        if args.action == 'check':
            print('Verified healthy supervisor, application, clear recovery flags, and target archive. No update staged or requested.')
            return
        device = Device(r.base, out)
        device.opener = r.http.opener
        print('Uploading screen-info firmware. Keep power connected.', flush=True)
        upgrade(r, device, metadata, raw, supervisor, progress)
        print('Flash readback verified. Replug once, wait 60 seconds, then reconnect Wi-Fi.', flush=True)
    except Exception as error:
        (out / 'error.json').write_text(json.dumps(dict(error=str(error), **progress), indent=2) + '\n')
        print('Update stopped:', error, flush=True)
        if progress['flash_requested']:
            print('Keep power connected. Do not repeat flashing until completion/readback is confirmed.', flush=True)
        elif progress['shutdown_requested']:
            print('No flash was requested. Replug to restore the installed app before retrying.', flush=True)
        else:
            print('No flash was requested; installed application was not stopped.', flush=True)
        raise SystemExit(1)


if __name__ == '__main__':
    main()
