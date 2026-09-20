#!/usr/bin/env python3
"""Recover the owned HW501 from the withdrawn mirroring supervisor, offline.

Uses the stock diagnostic filename's shell expansion to run fixed recovery
commands. `probe` only reads process/tool information and writes temporary logs.
`restore` starts a separate updater session, verifies it, then installs the
previous density137.5 image. No arbitrary shell-command option is exposed.
"""
import argparse
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import re
import secrets
import time
from urllib.parse import urlsplit

from collect_device import Collector
from update_device import Device, load_release, stage, apply

ROOT = Path(__file__).resolve().parents[1]
ROLLBACK = ROOT/'firmwares/experiments/hw501_131_density137.5'
ROLLBACK_SHA = '67d2247f9748c2e372215ffae1efd47d69fdd86746d627e74ac7c340e00edcbf'
UPDATER = ROOT/'firmwares/hw501/131/rootfs/bin/UpdateServer'
DETACH = ROOT/'firmwares/research/recovery/detach'
DETACH_SHA = 'ebaf99fd64ec30a622cd32ca4b3ed20be84bc1339a6f5b51ab34f1ef2ca2b6b6'
PORT = 8082


def process_table(text):
    result = {}
    for line in text.splitlines():
        match = re.fullmatch(r'(\d+) \((.*)\) (.*)', line)
        if not match:
            continue
        fields = match[3].split()
        if len(fields) < 20:
            continue
        pid = int(match[1])
        result[pid] = dict(pid=pid, name=match[2], state=fields[0],
                           ppid=int(fields[1]), pgid=int(fields[2]), sid=int(fields[3]),
                           start_time=int(fields[19]))
    return result


def alternate_url(base):
    parsed = urlsplit(base)
    host = parsed.hostname
    if not host or parsed.scheme != 'http' or parsed.username or parsed.password or parsed.query or parsed.fragment or parsed.path not in ('', '/'):
        raise ValueError('Use a plain HTTP adapter origin, such as http://192.168.5.1')
    host = f'[{host}]' if ':' in host else host
    return f'http://{host}:{PORT}'


class Recovery:
    def __init__(self, base, output, expected_device):
        self.base = base.rstrip('/')
        self.alternate = alternate_url(base)
        self.output = output
        self.expected_device = expected_device
        self.http = Collector(base, output)
        self.token = secrets.token_hex(8)
        self.sequence = 0

    def read_json(self, endpoint, base=None, payload=None):
        client = self.http if base is None else Collector(base, self.output)
        obj = json.loads(client.fetch(endpoint, payload=payload, timeout=5))
        if not isinstance(obj, dict):
            raise ValueError('Expected status object')
        return obj

    def check_identity(self, base=None):
        infos = self.read_json('getboxinfos', base)
        if (infos.get('hwtype'), infos.get('appversioncode'), infos.get('appversionstr'), infos.get('devicename')) != (501, 131, '2026081801', self.expected_device):
            raise ValueError(f'Unexpected adapter; no recovery action taken: {infos}')
        return infos

    def diagnostic(self, command, base=None):
        """Fixed caller-owned commands only; never execute the returned logs URL."""
        self.sequence += 1
        name = f'recovery-{self.token}-{self.sequence}.txt'
        expression = '$( { ' + command + '; } > /tmp/boxupdate/' + name + ' 2>&1)'
        if len(expression) > 850:
            raise ValueError('Diagnostic command exceeds the bounded filename buffer budget')
        fields = dict(datetime=expression, carbrand='Opel', carmodel='Corsa',
                      carmakeyear='2017', carproblem='Local updater recovery')
        client = self.http if base is None else Collector(base, self.output)
        reply = client.fetch('getlogs', payload=fields, timeout=30)
        (self.output/f'{self.sequence:02d}-diagnostic-response.json').write_bytes(reply)
        # The returned URL contains the literal expression; do not follow it.
        text = client.fetch(name, timeout=5).decode(errors='replace')
        (self.output/f'{self.sequence:02d}-diagnostic.txt').write_text(text)
        return text

    def probe(self):
        infos = self.check_identity()
        status = self.read_json('getupdatestatus', payload={})
        if status.get('percent', 0) not in (0, 100):
            raise ValueError(f'An update may still be active: {status}. No recovery action taken.')
        text = self.diagnostic("printf 'UPDATER_MD5\\n'; md5sum /tmp/UpdateServer; "
                               "printf '\\nPROCESSES\\n'; cat /proc/[0-9]*/stat")
        md5 = hashlib.md5(UPDATER.read_bytes()).hexdigest()
        if not re.search(r'^' + md5 + r'\s+/tmp/UpdateServer$', text, re.M):
            raise ValueError('Running updater copy does not match the locally inspected stock v131 binary')
        procs = process_table(text)
        apps = [p for p in procs.values() if p['name'] == 'CPAAProxyEx']
        if len(apps) < 2:
            raise ValueError('Expected supervisor and original application were not both found; inspect saved probe')
        report = dict(device=infos, update_status=status, processes=procs,
                      updater_md5=md5, temporary_only=True)
        (self.output/'probe.json').write_text(json.dumps(report, indent=2)+'\n')
        print('Verified affected adapter, stock updater copy, and supervisor/app processes.', flush=True)
        return report

    def prepare(self, probe):
        # Refuse reuse of an unknown listener or a previous unfinished recovery.
        from urllib.error import URLError
        import socket
        address = urlsplit(self.alternate)
        try:
            connection = socket.create_connection((address.hostname, PORT), timeout=2)
        except OSError as error:
            import errno
            if getattr(error, 'errno', None) not in (errno.ECONNREFUSED,):
                raise ValueError('Could not establish that recovery port 8082 is unused') from error
        else:
            connection.close()
            raise ValueError('Port 8082 is already in use; do not start another updater. Inspect the previous recovery first.')
        # The device's minimal BusyBox lacks setsid and base64. Transfer the tiny
        # syscall-only helper with printf octal escapes, entirely into RAM.
        helper = DETACH.read_bytes()
        if hashlib.sha256(helper).hexdigest() != DETACH_SHA or len(helper) > 32768:
            raise ValueError('Unexpected detachment helper; no device changes made')
        helper_path = '/tmp/recovery-detach-' + self.token
        for offset in range(0, len(helper), 120):
            escaped = ''.join('\\0'+format(b, '03o') for b in helper[offset:offset+120])
            redirect = '>' if offset == 0 else '>>'
            self.diagnostic(f"printf '%b' '{escaped}' {redirect} {helper_path}")
        result = self.diagnostic(f'chmod 700 {helper_path}; md5sum {helper_path}')
        if not re.search(r'^'+hashlib.md5(helper).hexdigest()+r'\s+'+re.escape(helper_path)+r'$', result, re.M):
            raise ValueError('Temporary helper checksum mismatch; nothing has been flashed')
        pidfile = '/tmp/boxupdate/recovery-' + self.token + '.pid'
        command = (f"unset LD_PRELOAD; cd /tmp || exit; {helper_path} /tmp/UpdateServer "
                   f"-ports {PORT} -root /tmp/boxupdate -index_files index_cptowlcp.html "
                   f"</dev/null >/tmp/recovery-{self.token}.log 2>&1 & echo $! > {pidfile}")
        self.diagnostic(command)
        until = time.monotonic()+10
        while True:
            try:
                self.check_identity(self.alternate)
                break
            except (OSError, URLError):
                if time.monotonic() >= until:
                    raise RuntimeError('Independent updater did not respond; nothing has been flashed')
                time.sleep(.25)
        text = self.diagnostic(f'cat {pidfile}; cat /proc/[0-9]*/stat', self.alternate)
        pid = int(text.splitlines()[0])
        procs = process_table(text)
        updater = procs.get(pid)
        if not updater or updater['name'] != 'UpdateServer' or updater['pgid'] != pid or updater['sid'] != pid:
            raise ValueError('Independent updater session was not confirmed; nothing has been flashed')
        if any(p['pgid'] == pid for p in procs.values() if p['name'] == 'CPAAProxyEx'):
            raise ValueError('Updater still shares a process group with the application; refusing to flash')
        maps = self.diagnostic(f'cat /proc/{pid}/maps; printf "\\nCWD\\n"; readlink /proc/{pid}/cwd', self.alternate)
        if '/mnt/app' in maps or not maps.rstrip().endswith('CWD\n/tmp'):
            raise ValueError('Independent updater may hold the application mount open; refusing to flash')
        # A fresh process must not have inherited an active upload/flash state.
        if self.read_json('getupdatestatus', self.alternate, payload={}):
            raise ValueError('Unexpected state in independent updater; refusing to overwrite it')
        (self.output/'independent-updater.json').write_text(json.dumps(updater, indent=2)+'\n')
        print(f'Independent updater verified on port {PORT}; PID/PGID/session {pid}.', flush=True)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('action', choices=('probe', 'restore'), nargs='?', default='probe')
    parser.add_argument('--device', default='http://192.168.5.1')
    parser.add_argument('--expected-device', default='smartBox-9302')
    args = parser.parse_args()
    output = ROOT/'device-snapshots'/('recovery-'+datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%S.%fZ'))
    output.mkdir(parents=True)
    print('Saving recovery evidence to:', output, flush=True)
    try:
        metadata, raw = load_release(ROLLBACK)
        if metadata['sha256'] != ROLLBACK_SHA:
            raise ValueError('Unexpected rollback archive')
        recovery = Recovery(args.device, output, args.expected_device)
        probe = recovery.probe()
        if args.action == 'probe':
            print('Probe complete. No updater was started and no firmware was staged or flashed.', flush=True)
            return
        recovery.prepare(probe)
        device = Device(recovery.alternate, output)
        device.opener = recovery.http.opener  # Proxy-free and rejects redirects.
        print('Restoring density137.5 v131 through the independent updater. Keep power connected.', flush=True)
        stage(device, metadata, raw)
        apply(device, metadata['version'])
        (output/'result.json').write_text(json.dumps({'reported_complete':True,'rollback_sha256':ROLLBACK_SHA})+'\n')
    except Exception as error:
        (output/'error.txt').write_text(str(error)+'\n')
        print('Recovery stopped:', error, flush=True)
        print('Do not repeat flashing or remove power if completion is unconfirmed. Share this evidence folder.', flush=True)
        raise SystemExit(1)


if __name__ == '__main__':
    main()
