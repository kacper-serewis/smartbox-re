#!/usr/bin/env python3
"""Collect local HW501 display diagnostics; standard library only, no internet needed.

Reads status/settings and asks the adapter to package its diagnostic logs. It does
not flash firmware, change configuration, or upload logs to an external service.
"""
import argparse
from datetime import datetime, timezone
import io
import json
from pathlib import Path
import re
import tarfile
import time
from urllib.parse import urljoin, urlsplit
from urllib.request import HTTPRedirectHandler, ProxyHandler, Request, build_opener

ROOT = Path(__file__).resolve().parents[1]
MAX_BYTES = 64 * 1024 * 1024
DISPLAY_PATTERN = re.compile(r'Recv proxy disply infos|set_carplay_screen_size|VideoWidth|WidthMM|HeightMM|widthPhysical|heightPhysical|carlifescreen|Auto setup proxy screen|sps pps width|Phone display override|DisplayScale|view.?areas?|safe.?area|initialViewArea|rightHandDrive|nightMode|primaryInputDevice', re.I)
VIDEO_PATTERN = re.compile(r'sps\s*pps|link video|send video|video stream|smartbox.mirror|recvCarPlayVideoFrame', re.I)
UPDATE_PATTERN = re.compile(r'UpdateServer|start update apps|end update apps|umount app|appupdate|supervisor|killed process|out of memory|squashfs.*error', re.I)


class NoRedirects(HTTPRedirectHandler):
    def redirect_request(self, req, fp, code, msg, headers, newurl):
        raise ValueError('Refusing HTTP redirect; collector only contacts the selected adapter')


class Collector:
    def __init__(self, base, output):
        self.base = base.rstrip('/')+'/'
        self.output = output
        self.opener = build_opener(ProxyHandler({}), NoRedirects())
        self.errors = []
        self.counter = 0

    def fetch(self, endpoint, payload=None, timeout=4):
        url = urljoin(self.base, endpoint)
        origin = lambda x: (urlsplit(x).scheme, urlsplit(x).netloc)
        if origin(url) != origin(self.base):
            raise ValueError('Refusing a log URL outside the adapter')
        body = None if payload is None else json.dumps(payload).encode()
        req = Request(url, data=body, headers={'Content-Type':'application/x-www-form-urlencoded'})
        with self.opener.open(req, timeout=timeout) as response:
            raw = response.read(MAX_BYTES+1)
        if len(raw) > MAX_BYTES:
            raise ValueError('Response exceeds the 64 MiB collection limit')
        return raw

    def status(self, endpoint, timeout=4, payload=None):
        try:
            raw = self.fetch(endpoint, payload=payload, timeout=timeout)
            self.counter += 1
            filename = re.sub(r'[^a-zA-Z0-9_.-]', '_', endpoint)
            (self.output/f'{self.counter:03d}-{filename}.txt').write_bytes(raw)
            if endpoint=='getboxsettings':
                return raw.decode(errors='replace')
            obj = json.loads(raw)
            if not isinstance(obj, dict):
                raise ValueError('Expected a JSON object')
            return obj
        except Exception as error:
            self.errors.append({'endpoint':endpoint,'time':datetime.now(timezone.utc).isoformat(),'error':str(error)})
            return None

    def logs(self):
        # Matches the bundled web UI's local getlogs call. Deliberately omits its
        # subsequent upload to the vendor server.
        fields = {'datetime':datetime.now().strftime('%Y%m%d%H%M%S'), 'carbrand':'Opel', 'carmodel':'Corsa', 'carmakeyear':'2017', 'carproblem':'Local display diagnostics'}
        raw = self.fetch('getlogs', fields, timeout=30)
        (self.output/'getlogs.json').write_bytes(raw)
        reply = json.loads(raw)
        if not isinstance(reply.get('logsurl'), str) or not reply['logsurl']:
            raise ValueError(f'No log archive URL in response: {reply}')
        archive = self.fetch(reply['logsurl'], timeout=30)
        (self.output/'adapter-logs.tar').write_bytes(archive)
        matches = []
        with tarfile.open(fileobj=io.BytesIO(archive), mode='r:*') as tf:
            for member in tf:
                if not member.isfile():
                    continue
                # Inspect in memory, never extract remote paths onto disk.
                stream = tf.extractfile(member)
                for index, line in enumerate(stream, 1):
                    text = line.decode('utf-8', errors='replace').rstrip()
                    if DISPLAY_PATTERN.search(text) or VIDEO_PATTERN.search(text) or UPDATE_PATTERN.search(text):
                        matches.append({'file':member.name,'line':index,'text':text[:3000]})
                        if len(matches) >= 2000:
                            return matches
        return matches


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--device', default='http://192.168.5.1')
    parser.add_argument('--seconds', type=int, default=60, help='Time to sample display status; default 60 seconds')
    parser.add_argument('--output', type=Path, default=ROOT/'device-snapshots')
    parser.add_argument('--no-logs', action='store_true', help='Read status/settings without requesting a log archive')
    parser.add_argument('--mirroring', action='store_true', help='Also sample the local mode page and mirroring receiver status')
    parser.add_argument('--mode-port', type=int, default=8081, help='Mode service port; default 8081')
    args = parser.parse_args()
    if not 0 <= args.seconds <= 600:
        parser.error('--seconds must be between 0 and 600')
    if urlsplit(args.device).scheme not in ('http','https'):
        parser.error('--device must be an HTTP(S) URL')
    if not urlsplit(args.device).hostname or not 1 <= args.mode_port <= 65535:
        parser.error('A device hostname and mode port between 1 and 65535 are required')
    started = datetime.now(timezone.utc)
    output = args.output/('offline-'+started.strftime('%Y%m%dT%H%M%S.%fZ'))
    output.mkdir(parents=True)
    collector = Collector(args.device, output)
    report = {'started_at':started.isoformat(),'device':args.device,'boxinfos':None,'boxsettings':None,'display_samples':[],'display_log_lines':[],'errors':collector.errors}
    mode_collector = None
    if args.mirroring:
        host = urlsplit(args.device).hostname
        host = f'[{host}]' if ':' in host else host
        mode_url = f'{urlsplit(args.device).scheme}://{host}:{args.mode_port}'
        mode_output = output/'mirroring'
        mode_output.mkdir()
        mode_collector = Collector(mode_url, mode_output)
        report.update(mode_service=mode_url, mode_samples=[], mirror_samples=[], update_samples=[], mode_errors=mode_collector.errors)
    connection = 'Screen Mirroring (SmartBox Mirror)' if args.mirroring else 'CarPlay'
    print(f'Offline collector: connect the Mac to adapter Wi-Fi and the iPhone to {connection}.', flush=True)
    print(f'Collecting for {args.seconds} seconds; no settings or firmware changes.', flush=True)
    print('Saving to:', output, flush=True)
    deadline = time.monotonic()+args.seconds
    last_display = None
    try:
        while True:
            infos = collector.status('getboxinfos')
            if infos:
                if infos != report['boxinfos']:
                    print(f'Adapter: HW{infos.get("hwtype")} | app code {infos.get("appversioncode")} | build {infos.get("appversionstr")} | system {infos.get("sysversionstr")}', flush=True)
                report['boxinfos'] = infos
                if report['boxsettings'] is None:
                    report['boxsettings'] = collector.status('getboxsettings')
            display = collector.status('getcarlifeinfos') if infos else None
            if display:
                report['display_samples'].append({'time':datetime.now(timezone.utc).isoformat(),'data':display})
                if display != last_display:
                    print('CarPlay display:', json.dumps(display, ensure_ascii=False), flush=True)
                    last_display = display
            elif infos:
                print('Adapter reachable; waiting for CarPlay display information...', flush=True)
            else:
                print('Adapter not reachable yet; check the Mac is on its Wi-Fi.', flush=True)
            if mode_collector:
                # Status only: never stage another upload or request flashing.
                update = collector.status('getupdatestatus', timeout=2, payload={})
                if update is not None:
                    report['update_samples'].append({'time':datetime.now(timezone.utc).isoformat(), 'data':update})
                    print('Update status:', json.dumps(update, ensure_ascii=False), flush=True)
                for endpoint, key in [('api/mode', 'mode_samples'), ('api/mirror', 'mirror_samples')]:
                    state = mode_collector.status(endpoint, timeout=2)
                    if state is not None:
                        report[key].append({'time':datetime.now(timezone.utc).isoformat(), 'data':state})
                        if key == 'mirror_samples':
                            print('Mirroring status:', json.dumps(state, ensure_ascii=False), flush=True)
            if time.monotonic() >= deadline:
                break
            time.sleep(min(5, max(0, deadline-time.monotonic())))
    except KeyboardInterrupt:
        print('\nSampling stopped; saving collected information.', flush=True)
    if report['boxinfos'] and not args.no_logs:
        print('Downloading diagnostic logs locally...', flush=True)
        try:
            report['display_log_lines'] = collector.logs()
            print(f'Saved log archive; found {len(report["display_log_lines"])} display-related lines.', flush=True)
        except Exception as error:
            collector.errors.append({'endpoint':'getlogs/archive','error':str(error)})
            print('Log download incomplete:', error, flush=True)
    report['finished_at'] = datetime.now(timezone.utc).isoformat()
    (output/'summary.json').write_text(json.dumps(report, indent=2, ensure_ascii=False)+'\n')
    (output/'display-lines.txt').write_text('\n'.join(f'{x["file"]}:{x["line"]}: {x["text"]}' for x in report['display_log_lines'])+'\n')
    print('\nSaved:', output/'summary.json', flush=True)
    mode_reachable = bool(report.get('mode_samples') or report.get('mirror_samples'))
    if not report['boxinfos'] and not mode_reachable:
        print('No adapter connection was captured. Reconnect its Wi-Fi and run again.', flush=True)
        return 1
    if args.mirroring and not report['boxinfos']:
        print('Mode service captured; the main application did not respond, so its diagnostic archive is unavailable.', flush=True)
    if args.mirroring and not report.get('mirror_samples'):
        print('No mirroring receiver status captured; check that the mode page is reachable on port', args.mode_port, flush=True)
    if not args.mirroring and not report['display_samples'] and not report['display_log_lines']:
        print('No display dimensions captured. Make sure CarPlay is running on the Corsa, then run again.', flush=True)
    print('You can reconnect to the internet now and tell me the collection is done.', flush=True)
    return 0


if __name__=='__main__':
    raise SystemExit(main())
