#!/usr/bin/env python3
"""Load the corrected mirroring bridge into RAM for a bounded owned-dongle test."""
import argparse
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import re
import socket
import threading
from urllib.parse import urlsplit
from recover_updater import Recovery, process_table, ROOT
from preview_dongle import FETCH, FETCH_SHA

REMOTE='/tmp/smartbox-bench'
BUILD=ROOT/'firmwares/research/mirroring-riscv'
APP_MD5='809d9b880681b3d8ff583401993ed1c2'


def transfer(recovery, helper, local, remote):
    data=local.read_bytes()
    if not 1 <= len(data) <= 1024*1024:raise ValueError('Unexpected payload size')
    peer=urlsplit(recovery.base).hostname
    with socket.socket(socket.AF_INET,socket.SOCK_DGRAM) as route:
        route.connect((peer,80));host=route.getsockname()[0]
    errors=[]
    with socket.socket() as listener:
        listener.bind((host,0));listener.listen(1);listener.settimeout(15)
        port=listener.getsockname()[1]
        def send():
            try:
                connection,address=listener.accept()
                with connection:
                    if address[0]!=peer:raise ValueError('Unexpected transfer peer')
                    connection.settimeout(10);connection.sendall(data)
            except Exception as error:errors.append(str(error))
        thread=threading.Thread(target=send,daemon=True);thread.start()
        response=recovery.diagnostic(f'{helper} {host} {port} {remote} {len(data)}; md5sum {remote}')
        thread.join(timeout=16)
    if thread.is_alive() or errors or not response.split() or response.split()[0]!=hashlib.md5(data).hexdigest():
        raise ValueError(f'RAM payload did not verify: {remote}; {errors}')


def probe(recovery):
    recovery.check_identity()
    if recovery.read_json('getupdatestatus',payload={}):raise ValueError('Updater is not idle; no test started')
    result=recovery.diagnostic('md5sum /mnt/app/bin/CPAAProxyEx; cat /proc/[0-9]*/stat')
    if not re.search('^'+APP_MD5+r'\s+/mnt/app/bin/CPAAProxyEx$',result,re.M):raise ValueError('Expected restored density137.5 executable')
    apps=[p for p in process_table(result).values() if p['name']=='CPAAProxyEx']
    if len(apps)!=1:raise ValueError('Expected exactly one stock app')
    return apps[0]


def prepare(recovery, refresh=False, mode='mirroring'):
    if mode not in ('carplay', 'mirroring'):raise ValueError('Invalid bench mode')
    app=probe(recovery)
    result=recovery.diagnostic(f'if test -e {REMOTE}; then echo EXISTS; fi')
    if 'EXISTS' in result and not refresh:raise ValueError('Bench directory already exists; use its saved session instead')
    if refresh:
        previous=json.loads((recovery.output/'bench-session.json').read_text())
        if previous['remote']!=REMOTE:raise ValueError('Unexpected previous bench path')
        maps=recovery.diagnostic(f'cat /proc/{app["pid"]}/maps')
        if REMOTE+'/libsmartbox-mirror.so' in maps:raise ValueError('Experimental library is still loaded')
        if REMOTE+'/libsocket-reuse.so' in maps:
            current=recovery.diagnostic(f'md5sum {REMOTE}/libsocket-reuse.so').split()[0]
            if current!=hashlib.md5((BUILD/'libsocket-reuse.so').read_bytes()).hexdigest():raise ValueError('Socket compatibility library is active; replug before changing it')
        recovery.diagnostic(f'touch {REMOTE}/refresh-pending; rm -f {REMOTE}/started {REMOTE}/control.sock /tmp/boxupdate/smartbox-bench-video.h264 /tmp/boxupdate/smartbox-bench-events.jsonl /tmp/boxupdate/smartbox-bench.json')
    data=FETCH.read_bytes()
    if hashlib.sha256(data).hexdigest()!=FETCH_SHA:raise ValueError('RAM transfer helper hash mismatch')
    helper='/tmp/bench-fetch-'+recovery.token
    for offset in range(0,len(data),120):
        escaped=''.join('\\0'+format(x,'03o') for x in data[offset:offset+120])
        recovery.diagnostic(f"printf '%b' '{escaped}' {'>' if offset==0 else '>>'} {helper}")
    result=recovery.diagnostic(f'chmod 700 {helper}; md5sum {helper}; mkdir -p {REMOTE}/state')
    if result.split()[0]!=hashlib.md5(data).hexdigest():raise ValueError('Transfer helper did not verify')
    files={}
    for source,target in [('libsmartbox-bench.so','libsmartbox-mirror.so'),('smartbox-bench','launcher'),('libsocket-reuse.so','libsocket-reuse.so')]:
        temporary=REMOTE+'/'+target+'.incoming-'+recovery.token
        transfer(recovery,helper,BUILD/source,temporary)
        recovery.diagnostic(f'mv {temporary} {REMOTE}/{target}')
        files[target]=dict(sha256=hashlib.sha256((BUILD/source).read_bytes()).hexdigest(),md5=hashlib.md5((BUILD/source).read_bytes()).hexdigest())
    recovery.diagnostic(f"chmod 700 {REMOTE}/launcher; printf '{mode}\\n' > {REMOTE}/state/connection-mode")
    session=dict(remote=REMOTE,files=files,original=app,temporary_only=True,mode=mode)
    (recovery.output/'bench-session.json').write_text(json.dumps(session,indent=2)+'\n')
    recovery.diagnostic(f'rm -f {REMOTE}/refresh-pending')
    return session


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('action',choices=['prepare','refresh','start','status','stop','collect'])
    parser.add_argument('--session',type=Path)
    parser.add_argument('--seconds',type=int,default=300)
    parser.add_argument('--mode',choices=['carplay','mirroring'],default='mirroring',help='Mode installed by prepare/refresh; start uses the saved mode')
    args=parser.parse_args()
    if not 10<=args.seconds<=300:parser.error('Duration must be 10..300 seconds')
    if args.action!='prepare' and not args.session:parser.error('--session is required')
    output=args.session or ROOT/'device-snapshots'/('mirroring-bench-'+datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%S.%fZ'))
    output.mkdir(mode=0o700,parents=True,exist_ok=True)
    r=Recovery('http://192.168.5.1',output,'smartBox-9302')
    r.sequence=len(list(output.glob('*-diagnostic.txt')))+100
    print('Evidence:',output,flush=True)
    if args.action in ('prepare','refresh'):
        print(json.dumps(prepare(r,args.action=='refresh',args.mode),indent=2));return
    session=json.loads((output/'bench-session.json').read_text())
    if session['remote']!=REMOTE:raise ValueError('Unexpected bench path')
    r.check_identity()
    if args.action=='start':
        app=probe(r)
        mode=session.get('mode','mirroring')
        if mode not in ('carplay','mirroring'):raise ValueError('Invalid saved bench mode')
        remote_mode=r.diagnostic(f'cat {REMOTE}/state/connection-mode').strip()
        if remote_mode!=mode:raise ValueError('Remote mode differs from saved session')
        checks=r.diagnostic(f'md5sum {REMOTE}/launcher {REMOTE}/libsmartbox-mirror.so {REMOTE}/libsocket-reuse.so; if test -e {REMOTE}/started; then echo STARTED; fi; if test -e {REMOTE}/refresh-pending; then echo PENDING; fi')
        if 'PENDING' in checks:raise ValueError('Previous refresh incomplete')
        for source,target in [('libsmartbox-bench.so','libsmartbox-mirror.so'),('smartbox-bench','launcher'),('libsocket-reuse.so','libsocket-reuse.so')]:
            if hashlib.sha256((BUILD/source).read_bytes()).hexdigest()!=session['files'][target]['sha256']:raise ValueError('Local bench build differs; refresh required')
        if 'STARTED' in checks:raise ValueError('This bench session has already run')
        for target,item in session['files'].items():
            if not re.search('^'+item['md5']+r'\s+'+re.escape(REMOTE+'/'+target)+'$',checks,re.M):raise ValueError('Bench payload changed')
        command=(f'if test -e /tmp/boxupdate/smartbox-bench.log; then mv /tmp/boxupdate/smartbox-bench.log /tmp/boxupdate/smartbox-bench-{r.token}.log; fi; touch {REMOTE}/started; {REMOTE}/launcher {app["pid"]} {app["start_time"]} {args.seconds} {mode}'
                 f' </dev/null >/tmp/boxupdate/smartbox-bench.log 2>&1 & echo $! > {REMOTE}/launcher.pid')
        r.diagnostic(command)
    elif args.action=='stop':
        # The launcher restores the original app on TERM; never target a restored app.
        result=r.diagnostic(f'cat {REMOTE}/launcher.pid; cat /proc/[0-9]*/stat')
        pid=int(result.splitlines()[0]);process=process_table(result).get(pid)
        if process and process['name']=='launcher':
            r.diagnostic(f'if test "$(readlink /proc/{pid}/exe)" = {REMOTE}/launcher; then kill -TERM {pid}; fi')
    elif args.action=='collect':
        for remote,local,limit in [('smartbox-bench-video.h264','video.h264',8*1024*1024),
                                   ('smartbox-bench-events.jsonl','events.jsonl',4*1024*1024),
                                   ('smartbox-bench.json','bridge-status.json',65536),
                                   ('smartbox-bench.log','bench.log',1024*1024)]:
            data=r.http.fetch(remote,timeout=10)
            if len(data)>limit:raise ValueError('Evidence exceeds expected bound')
            (output/local).write_bytes(data)
    print(r.diagnostic('cat /tmp/boxupdate/smartbox-bench.json; cat /tmp/boxupdate/smartbox-bench.log; cat /proc/[0-9]*/stat')[:2000])


if __name__=='__main__':main()
