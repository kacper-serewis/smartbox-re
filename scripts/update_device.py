#!/usr/bin/env python3
"""Inspect HW501 or install a verified, locally archived stock app update."""
import argparse
import base64
from datetime import datetime, timezone
import hashlib
import io
import json
from pathlib import Path
import tarfile
import time
from urllib.request import Request, ProxyHandler, build_opener


class Device:
    def __init__(self, base, snapshot):
        self.base = base.rstrip('/')
        self.snapshot = snapshot
        self.opener = build_opener(ProxyHandler({}))
        self.sequence = 0

    def request(self, endpoint, payload=None):
        data = None if payload is None else (json.dumps(payload, separators=(',', ':')).encode() if isinstance(payload, dict) else payload)
        req = Request(self.base+'/'+endpoint, data=data, headers={'Content-Type':'application/x-www-form-urlencoded'})
        with self.opener.open(req, timeout=20) as response:
            raw = response.read()
        self.sequence += 1
        (self.snapshot/f'{self.sequence:04d}-{endpoint}.txt').write_bytes(raw)
        if endpoint == 'getboxsettings':
            return raw.decode()
        obj = json.loads(raw)
        if not isinstance(obj, dict):
            raise ValueError(f'{endpoint}: expected a JSON object')
        return obj


def load_release(folder):
    metadata = json.loads((folder/'manifest.json').read_text())
    version = metadata['version']
    raw = (folder/f'hw501_{version}.tar').read_bytes()
    if hashlib.sha256(raw).hexdigest() != metadata['sha256'] or len(raw) != metadata['size']:
        raise ValueError('Archive hash or size mismatch')
    with tarfile.open(fileobj=io.BytesIO(raw), mode='r:') as tf:
        if sorted(m.name for m in tf.getmembers()) != ['app.img','appmd5sum.txt']:
            raise ValueError('Unexpected update archive contents')
        app = tf.extractfile('app.img').read()
        expected = tf.extractfile('appmd5sum.txt').read().decode().split()[0]
        if hashlib.md5(app).hexdigest() != expected:
            raise ValueError('Bundled image MD5 mismatch')
    chunkmeta = metadata['chunk_metadata']
    if chunkmeta['version'] != version or chunkmeta['filesize'] != len(raw):
        raise ValueError('Chunk metadata does not match release')
    if chunkmeta['itemsize'] <= 0 or chunkmeta['count'] != (len(raw)+chunkmeta['itemsize']-1)//chunkmeta['itemsize']:
        raise ValueError('Invalid chunk count')
    return metadata, raw


def stage(device, metadata, raw):
    infos = device.request('getboxinfos')
    if infos.get('hwtype') != 501:
        raise ValueError(f'Expected HW501, got {infos.get("hwtype")}')
    status = device.request('getupdatestatus', b'')
    if status.get('percent', 0) > 0 and status['percent'] < 100:
        raise ValueError('An update is already in progress; refusing to overwrite it')
    meta = metadata['chunk_metadata']
    count, size, version = meta['count'], meta['itemsize'], metadata['version']
    for pos in range(count):
        payload = raw[pos*size:(pos+1)*size]
        packet = dict(meta, result=1, version=version, pos=pos, datasize=len(payload), data=base64.b64encode(payload).decode())
        reply = device.request('uploadappdatas', packet)
        expected = {'result':1, 'version':version, 'pos':pos, 'count':count}
        if any(reply.get(k) != v for k,v in expected.items()):
            raise ValueError(f'Chunk {pos} rejected or mismatched: {reply}; flash was not requested')
        if pos % 16 == 0 or pos == count-1:
            print(f'Uploaded {pos+1}/{count} chunks', flush=True)
    status = device.request('getupdatestatus', b'')
    if any(status.get(k) != v for k,v in {'version':version, 'pos':count-1, 'count':count}.items()):
        raise ValueError(f'Staged upload not confirmed: {status}; flash was not requested')


def apply(device, version, timeout=180):
    status = device.request('requestupdate', b'')
    deadline = time.monotonic()+timeout
    last_percent = None
    while True:
        if status.get('version') != version or 'percent' not in status:
            raise ValueError(f'Unexpected update status: {status}. Update completion is unconfirmed; inspect status before taking further action.')
        percent = status['percent']
        if not isinstance(percent, (int, float)) or not 0 <= percent <= 100:
            raise ValueError(f'Invalid update percent: {status}')
        if percent != last_percent:
            print(f'Flash progress: {percent}%', flush=True)
            last_percent = percent
        if percent == 100:
            print('Adapter reports update complete. Re-plug it, reconnect Wi-Fi, and run inspect to verify the running version.', flush=True)
            return
        if time.monotonic() >= deadline:
            raise TimeoutError('Update completion is unconfirmed; inspect status before taking further action.')
        time.sleep(1)
        status = device.request('getupdatestatus', b'')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('action', choices=('inspect','stage','apply'), nargs='?', default='inspect')
    parser.add_argument('--device', default='http://192.168.5.1')
    parser.add_argument('--release', type=Path, default=Path('firmwares/hw501/131'))
    args = parser.parse_args()
    snapshot = Path('device-snapshots')/datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%S.%fZ')
    snapshot.mkdir(parents=True)
    device = Device(args.device, snapshot)
    # Save current settings before any writes; these are metadata, not a flash backup.
    for endpoint in ('getboxinfos','getcarlifeinfos','getboxsettings'):
        print(endpoint, json.dumps(device.request(endpoint), ensure_ascii=False), flush=True)
    print('Saved device metadata:', snapshot, flush=True)
    if args.action == 'inspect':
        print('getupdatestatus', device.request('getupdatestatus', b''), flush=True)
        return
    metadata, raw = load_release(args.release)
    label = metadata.get('label', f'stock v{metadata["version"]}')
    print(f'Validated {label}: {len(raw):,} bytes, SHA256 {metadata["sha256"]}', flush=True)
    stage(device, metadata, raw)
    if args.action == 'apply':
        apply(device, metadata['version'])
    else:
        print('Upload staged; flash was not requested.', flush=True)


if __name__=='__main__':
    main()
