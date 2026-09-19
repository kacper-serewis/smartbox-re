#!/usr/bin/env python3
"""Archive public HW501 firmware releases and verify them against the chunk API."""
import argparse
import base64
import concurrent.futures
import hashlib
import json
from pathlib import Path
import tarfile
import time
import urllib.error
import urllib.request
from datetime import datetime, timezone

BASE = 'http://43.138.184.52'


class UnavailableRelease(ValueError):
    pass


def request(url, method='GET'):
    for attempt in range(4):
        try:
            with urllib.request.urlopen(urllib.request.Request(url, method=method), timeout=45) as r:
                return r.read(), dict(r.headers)
        except urllib.error.HTTPError as e:
            if e.code < 500:
                raise
        except (TimeoutError, OSError):
            if attempt == 3:
                raise
        time.sleep(2 ** attempt)
    raise RuntimeError(f'Request failed: {url}')


def write_json(path, obj):
    path.write_text(json.dumps(obj, indent=2, ensure_ascii=False) + '\n')


def chunk(hw, version, pos):
    url = f'{BASE}/index.php?fun=appdatas&hw={hw}&version={version}&pos={pos}'
    raw, _ = request(url)
    obj = json.loads(raw)
    if obj.get('result') == 0 and 'update file not found:' in obj.get('errstr', ''):
        raise UnavailableRelease(obj['errstr'])
    if obj.get('result') != 1 or obj.get('version') != version or obj.get('pos') != pos:
        raise ValueError(f'Invalid chunk response: {url}')
    data = base64.b64decode(obj['data'], validate=True)
    if len(data) != obj['datasize']:
        raise ValueError(f'Invalid chunk size: {url}')
    return obj, data


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--hw', type=int, default=501)
    parser.add_argument('--output', type=Path, default=Path('firmwares'))
    parser.add_argument('--probe-unlisted', action='store_true', help='HEAD-check versions 1 through the highest advertised version')
    args = parser.parse_args()
    root = args.output / f'hw{args.hw}'
    root.mkdir(parents=True, exist_ok=True)
    history_url = f'{BASE}/appupdate/hw{args.hw}_historyversion.json'
    history = json.loads(request(history_url)[0])
    latest = json.loads(request(f'{BASE}/index.php?fun=lastversion&hw={args.hw}')[0])
    if history['hwtype'] != args.hw or latest['hwtype'] != args.hw:
        raise ValueError('Hardware mismatch')
    write_json(root / 'history.json', history)
    write_json(root / 'latest.json', latest)
    versions = {int(v['value']) for v in history['versions']} | {int(latest['versioncode'])}
    urls = lambda v: f'{BASE}/appupdate/hw{args.hw}_update_v{v}.tar'
    discovery = []
    if args.probe_unlisted:
        def probe(v):
            try:
                _, headers = request(urls(v), 'HEAD')
                return {'version': v, 'http_status': 200, 'bytes': headers.get('Content-Length')}
            except urllib.error.HTTPError as e:
                result = {'version': v, 'http_status': e.code}
                try:
                    obj, _ = chunk(args.hw, v, 0)
                    result['api_available'] = True
                    result['bytes'] = obj['filesize']
                except UnavailableRelease as missing:
                    result['api_available'] = False
                    result['api_error'] = str(missing)
                except Exception as error:
                    result['error'] = str(error)
                return result
            except Exception as e:
                return {'version': v, 'error': str(e)}
        with concurrent.futures.ThreadPoolExecutor(max_workers=4) as pool:
            discovery = list(pool.map(probe, range(1, max(versions) + 1)))
        versions.update(x['version'] for x in discovery if x.get('http_status') == 200 or x.get('api_available'))
        write_json(root / 'discovery.json', discovery)
    print(f'Discovered versions: {sorted(versions)}', flush=True)
    records = []
    unavailable = []
    for v in sorted(versions):
        folder = root / str(v)
        folder.mkdir(exist_ok=True)
        try:
            first, first_data = chunk(args.hw, v, 0)
        except UnavailableRelease as e:
            unavailable.append({'version': v, 'reason': str(e)})
            print(f'v{v}: unavailable: {e}', flush=True)
            continue
        size, step, count = first['filesize'], first['itemsize'], first['count']
        if size <= 0 or step <= 0 or count != (size + step - 1) // step:
            raise ValueError(f'Inconsistent metadata for {v}')
        target = folder / f'hw{args.hw}_{v}.tar'
        headers = {}
        if target.exists():
            data = target.read_bytes()
        else:
            try:
                data, headers = request(urls(v))
            except urllib.error.HTTPError as e:
                if e.code not in (403, 404):
                    raise
                parts = [first_data]
                for pos in range(1, count):
                    obj, payload = chunk(args.hw, v, pos)
                    if any(obj[k] != first[k] for k in ('filesize', 'itemsize', 'count')):
                        raise ValueError(f'Chunk metadata mismatch for {v}, {pos}')
                    expected = min(step, size - pos * step)
                    if len(payload) != expected:
                        raise ValueError(f'Chunk length mismatch for {v}, {pos}')
                    parts.append(payload)
                data = b''.join(parts)
        if len(data) != size or data[:len(first_data)] != first_data:
            raise ValueError(f'Archive size or first chunk mismatch for {v}')
        last, last_data = chunk(args.hw, v, count - 1)
        if any(last[k] != first[k] for k in ('filesize', 'itemsize', 'count')) or data[(count-1)*step:] != last_data:
            raise ValueError(f'Archive last chunk mismatch for {v}')
        temporary = target.with_suffix('.tar.tmp')
        temporary.write_bytes(data)
        temporary.replace(target)
        members = []
        with tarfile.open(target, 'r:') as tf:
            for member in tf:
                if not member.isfile():
                    raise ValueError(f'Unexpected non-file archive member: {member.name}')
                name = Path(member.name)
                if name.is_absolute() or '..' in name.parts:
                    raise ValueError(f'Unsafe archive member: {member.name}')
                payload = tf.extractfile(member).read()
                dest = folder / 'archive' / name
                dest.parent.mkdir(parents=True, exist_ok=True)
                dest.write_bytes(payload)
                members.append({'name': member.name, 'size': member.size, 'mtime': member.mtime, 'sha256': hashlib.sha256(payload).hexdigest()})
        expected_md5 = (folder / 'archive/appmd5sum.txt').read_text().split()[0]
        actual_md5 = hashlib.md5((folder / 'archive/app.img').read_bytes()).hexdigest()
        if expected_md5.lower() != actual_md5:
            raise ValueError(f'Bundled app.img MD5 mismatch for {v}')
        record = {'version': v, 'source': urls(v), 'size': len(data), 'sha256': hashlib.sha256(data).hexdigest(), 'app_md5': actual_md5, 'chunk_metadata': {k:x for k,x in first.items() if k != 'data'}, 'verification': 'Archive length, first and final chunks match appdatas; bundled app.img MD5 matches; SHA-256 recorded locally, no vendor signature available.', 'headers': headers, 'members': members}
        write_json(folder / 'manifest.json', record)
        records.append(record)
        print(f'v{v}: {len(data):,} bytes, SHA256 {record["sha256"]}', flush=True)
    write_json(root / 'manifest.json', {'retrieved_at': datetime.now(timezone.utc).isoformat(), 'hardware': args.hw, 'history_source': history_url, 'probe_range': [1, max(versions)] if args.probe_unlisted else None, 'unavailable': unavailable, 'releases': records})


if __name__ == '__main__':
    main()
