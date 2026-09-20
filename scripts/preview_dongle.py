#!/usr/bin/env python3
"""Temporary iPhone -> HW501 -> Mac preview, without CarPlay or firmware changes."""
import argparse
import base64
from datetime import datetime, timezone
from functools import partial
import hashlib
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
import json
from pathlib import Path
import re
import secrets
import socket
import subprocess
import threading
import time
from urllib.error import HTTPError
from urllib.parse import urlsplit
from urllib.request import Request

from recover_updater import Recovery, ROOT

FETCH = ROOT/'firmwares/research/recovery/ram-fetch'
FETCH_SHA = 'de8a51891db1cb333491b2dbb4a2ecda3f8df7c28643e0a7b18b69c6129a14a5'
RECEIVER = ROOT/'firmwares/research/mirroring-riscv/mirror-capture'
DECODER = ROOT/'firmwares/research/mirroring-build/mirror-preview'
MAX_VIDEO = 8*1024*1024
NAME = 'SmartBox Mirror Test'
PAGE = '''<!doctype html><meta charset="utf-8"><title>Dongle mirror preview</title>
<style>body{background:#15181c;color:#eee;font:17px system-ui;margin:28px}img{display:block;max-width:90vw;max-height:72vh;margin:20px 0;background:#000}pre{white-space:pre-wrap}</style>
<h1>Dongle mirror preview</h1><p>iPhone → dongle → Mac · No CarPlay connection required</p>
<p>Connect the iPhone to the dongle Wi-Fi, then choose <b>SmartBox Mirror Test</b> in Screen Mirroring.</p>
<p>This test records the mirrored screen locally. Audio is discarded.</p><pre id="state">Starting…</pre><img id="video" alt="Waiting for phone video">
<script>let busy=false;setInterval(async()=>{if(busy)return;busy=true;try{
const s=await(await fetch('status.json',{cache:'no-store'})).json();
document.querySelector('#state').textContent=s.message+(s.pin?'\\nPIN: '+s.pin:'')+'\\n'+s.bytes+' bytes received';
const d=await fetch('decoder.json',{cache:'no-store'});if(d.ok){const j=await d.json();document.querySelector('#state').textContent+='\\n'+j.width+'×'+j.height+' · '+j.frames_decoded+' decoded frames · '+j.decode_errors+' decoder errors';document.querySelector('#video').src='frame.jpg?t='+Date.now()}
}catch(e){}finally{busy=false}},250)</script>'''


class Packets:
    def __init__(self):
        self.sps = self.pps = None
        self.idr = False

    def convert(self, raw):
        starts = list(re.finditer(b'\x00\x00(?:\x00)?\x01', raw))
        slices = []
        keyframe = False
        for i, start in enumerate(starts):
            end = starts[i+1].start() if i+1 < len(starts) else len(raw)
            nal = raw[start.end():end]
            if not nal: continue
            kind = nal[0] & 31
            if kind in (7, 8):
                key = 'sps' if kind == 7 else 'pps'
                if getattr(self, key) != nal:
                    setattr(self, key, nal); self.idr = False
            elif kind in (1, 5):
                slices.append(len(nal).to_bytes(4,'big')+nal)
                keyframe |= kind == 5
        if not slices or not self.sps or not self.pps or not (self.idr or keyframe): return None
        self.idr = True
        return {k:base64.b64encode(v).decode() for k,v in dict(sps=self.sps,pps=self.pps,avcc=b''.join(slices)).items()}


def incremental(opener, url, offset, limit):
    try:
        with opener.open(Request(url, headers={'Range':f'bytes={offset}-'}),timeout=3) as response:
            data = response.read(limit+1)
            if len(data) > limit: raise ValueError('Remote capture exceeds the bounded download size')
            if response.status == 206:
                if not response.headers.get('Content-Range','').startswith(f'bytes {offset}-'):
                    raise ValueError('Unexpected byte range in capture response')
                return data
            if response.status != 200: raise ValueError('Unexpected capture response')
            return data[offset:]
    except HTTPError as error:
        if error.code in (404,416): return b''
        raise


def deploy(recovery, output, seconds):
    helper = FETCH.read_bytes()
    if hashlib.sha256(helper).hexdigest() != FETCH_SHA: raise ValueError('RAM transfer helper hash mismatch')
    target = '/tmp/mirror-fetch-'+recovery.token
    for offset in range(0,len(helper),120):
        escaped = ''.join('\\0'+format(b,'03o') for b in helper[offset:offset+120])
        recovery.diagnostic(f"printf '%b' '{escaped}' {'>' if offset==0 else '>>'} {target}")
    result = recovery.diagnostic(f'chmod 700 {target}; md5sum {target}')
    if result.split()[0] != hashlib.md5(helper).hexdigest(): raise ValueError('RAM transfer helper did not verify')
    peer = urlsplit(recovery.base).hostname
    route = socket.socket(socket.AF_INET,socket.SOCK_DGRAM)
    route.connect((peer,80)); host = route.getsockname()[0]; route.close()
    listener = socket.socket(); listener.bind((host,0)); listener.listen(1); listener.settimeout(20)
    port = listener.getsockname()[1]
    receiver = RECEIVER.read_bytes()
    transfer_errors = []
    def send():
        try:
            conn, address = listener.accept()
            with conn:
                if address[0] != peer: raise ValueError('Unexpected transfer peer')
                conn.settimeout(15); conn.sendall(receiver)
        except Exception as error: transfer_errors.append(error)
        finally: listener.close()
    thread = threading.Thread(target=send,daemon=True); thread.start()
    binary = '/tmp/mirror-capture-'+recovery.token
    result = recovery.diagnostic(f'{target} {host} {port} {binary} {len(receiver)}; md5sum {binary}')
    thread.join(timeout=21)
    if thread.is_alive() or transfer_errors or not result.split() or result.split()[0] != hashlib.md5(receiver).hexdigest():
        raise ValueError(f'Receiver transfer failed: {transfer_errors}; {result}')
    remote = '/tmp/boxupdate/mirror-'+recovery.token
    mac = bytearray(secrets.token_bytes(6)); mac[0] = (mac[0]|2)&254
    identity = ':'.join(f'{b:02X}' for b in mac)
    command = (f"umask 077; mkdir {remote}; (cd {remote} || exit; unset LD_PRELOAD; "
               f"exec {binary} '{NAME}' {identity} {seconds} 120 {MAX_VIDEO} 1) "
               f"</dev/null >{remote}/receiver.log 2>&1 & echo $! >{remote}/receiver.pid")
    recovery.diagnostic(command)
    pidtext = recovery.diagnostic(f'cat {remote}/receiver.pid; cat {remote}/receiver.log')
    pid = int(pidtext.splitlines()[0])
    (output/'device-session.json').write_text(json.dumps(dict(pid=pid,remote=remote,binary=binary,helper=target,receiver_sha256=hashlib.sha256(receiver).hexdigest()),indent=2)+'\n')
    return remote,pid


class QuietHandler(SimpleHTTPRequestHandler):
    def log_message(self,*args): pass


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--device',default='http://192.168.5.1')
    parser.add_argument('--seconds',type=int,default=600)
    parser.add_argument('--no-open',action='store_true')
    args = parser.parse_args()
    if not 30 <= args.seconds <= 1800: parser.error('--seconds must be 30–1800')
    if not DECODER.exists(): raise RuntimeError('Build preview.swift before starting')
    output = ROOT/'device-snapshots'/('dongle-preview-'+datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%S.%fZ'))
    output.mkdir(mode=0o700)
    recovery = Recovery(args.device,output,'smartBox-9302'); recovery.check_identity()
    print('Deploying temporary receiver into RAM. No firmware changes. Evidence:',output,flush=True)
    remote,pid = deploy(recovery,output,args.seconds)
    (output/'index.html').write_text(PAGE)
    server = ThreadingHTTPServer(('127.0.0.1',0),partial(QuietHandler,directory=str(output)))
    threading.Thread(target=server.serve_forever,daemon=True).start()
    url = f'http://127.0.0.1:{server.server_port}/'
    print('Preview:',url,'\nSelect',NAME,'on the iPhone. Captures at most 8 MiB / 120 seconds of video.',flush=True)
    if not args.no_open: subprocess.run(['open',url],check=False)
    log = (output/'decoder.log').open('w')
    decoder = subprocess.Popen([str(DECODER),str(output)],stdin=subprocess.PIPE,stdout=log,stderr=log)
    buffers = {name:bytearray() for name in ('video.h264','events.jsonl','receiver.log')}
    events_offset = 0; pending = []; packets = Packets(); deadline = time.monotonic()+args.seconds+5
    previous_message = None
    try:
        while time.monotonic() < deadline:
            for name, data in buffers.items():
                more = incremental(recovery.http.opener,recovery.base+'/mirror-'+recovery.token+'/'+name,len(data),MAX_VIDEO if name=='video.h264' else 1024*1024)
                if more:
                    data.extend(more)
                    with (output/name).open('ab') as file:file.write(more)
            event_data = buffers['events.jsonl']
            while (end := event_data.find(b'\n',events_offset)) >= 0:
                item = json.loads(event_data[events_offset:end]); events_offset = end+1
                if item.get('event')=='packet': pending.append(item)
            while pending and pending[0]['offset']+pending[0]['length'] <= len(buffers['video.h264']):
                item = pending.pop(0)
                frame = packets.convert(buffers['video.h264'][item['offset']:item['offset']+item['length']])
                if frame:
                    decoder.stdin.write((json.dumps(frame)+'\n').encode()); decoder.stdin.flush()
            logtext = buffers['receiver.log'].decode(errors='replace')
            pins = re.findall(r'PIN on your iPhone:\s*(\d+)',logtext)
            message = 'Receiving phone video through dongle' if buffers['video.h264'] else 'Waiting for iPhone Screen Mirroring'
            if 'Stopped:' in logtext: message = 'Capture stopped: '+logtext.split('Stopped:')[-1].splitlines()[0]
            state = dict(message=message,pin=pins[-1] if pins else '',bytes=len(buffers['video.h264']))
            temporary = output/'status.new';temporary.write_text(json.dumps(state));temporary.replace(output/'status.json')
            if (message,state['pin']) != previous_message:
                print(message,('PIN '+state['pin']) if state['pin'] else '',flush=True);previous_message=(message,state['pin'])
            if decoder.poll() is not None: raise RuntimeError('Mac decoder exited; inspect decoder.log')
            time.sleep(.15)
    except KeyboardInterrupt: print('Stopping preview.',flush=True)
    finally:
        try:
            # Only signal the recorded process if /proc still names our unique binary.
            recovery.diagnostic(f'if [ "$(readlink /proc/{pid}/exe)" = "/tmp/mirror-capture-{recovery.token}" ]; then kill -TERM {pid}; fi')
        except Exception as error: print('Receiver cleanup unavailable; its runtime limit still applies:',error,flush=True)
        try: decoder.stdin.close()
        except BrokenPipeError: pass
        try: decoder.wait(timeout=10)
        except subprocess.TimeoutExpired: decoder.kill();decoder.wait()
        log.close();server.shutdown();server.server_close()
        if buffers['video.h264']:
            from inspect_h264 import inspect
            (output/'video-analysis.json').write_text(json.dumps(inspect(bytes(buffers['video.h264'])),indent=2)+'\n')
    print('Preview session saved:',output,flush=True)


if __name__=='__main__': main()
