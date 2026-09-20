#!/usr/bin/env python3
"""Exercise real bench launcher process replacement/restoration in disposable Linux."""
from pathlib import Path
import os
import subprocess
import threading
import time
import json

ROOT=Path(__file__).resolve().parents[1]
def guest():
    root=Path('/tmp/smartbox-bench-test');root.mkdir(exist_ok=True)
    app=root/'fake-app';lib=root/'test.so';restore=root/'restore.so';bench=root/'bench'
    (root/'fake.c').write_text(r'''
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/socket.h>
#include <sys/un.h>
int main(void){FILE *f=fopen("/tmp/smartbox-bench-test/events","a");char *preload=getenv("LD_PRELOAD");int test=preload&&strstr(preload,"test.so")!=NULL;
fprintf(f,"%s %ld\n",test?"experimental":"original",(long)getpid());fclose(f);
if(test&&getenv("TEST_CRASH"))abort();
if(test&&getenv("TEST_CONTROL")){
 int fd=socket(AF_UNIX,SOCK_STREAM,0);struct sockaddr_un a={.sun_family=AF_UNIX};
 strcpy(a.sun_path,"/tmp/smartbox-bench-test/control.sock");unlink(a.sun_path);
 if(bind(fd,(void *)&a,sizeof(a))||listen(fd,1))return 2;
 for(;;){int c=accept(fd,NULL,NULL);char b[64]={0};read(c,b,63);
  int start=!strncmp(b,"start ",6);if(start)usleep(500000);write(c,"OK\n",3);close(c);
  if(start){FILE *r=fopen("/tmp/smartbox-bench-test/events","a");fputs("ready\n",r);fclose(r);}
 }
}
for(;;)sleep(1);}
''')
    (root/'lib.c').write_text('int bench_test_symbol;')
    subprocess.run(['gcc',str(root/'fake.c'),'-o',str(app)],check=True)
    subprocess.run(['gcc','-shared','-fPIC',str(root/'lib.c'),'-o',str(lib)],check=True)
    subprocess.run(['gcc','-shared','-fPIC',str(root/'lib.c'),'-o',str(restore)],check=True)
    subprocess.run(['gcc','-Wall','-Wextra','-Werror',f'-DBENCH_SOCKET_LIBRARY="{restore}"',f'-DBENCH_SOCKET="{root}/control.sock"',f'-DBENCH_APP="{app}"',f'-DBENCH_LIBRARY="{lib}"',
                    '/work/experiments/mirroring/bench_launch.c','-o',str(bench)],check=True)
    results=[]
    for mode in ('crash','signal','deadline','unreaped_original','compatibility_restart','slow_start','wrong_identity'):
        events=root/'events';events.unlink(missing_ok=True)
        env=dict(os.environ)
        if mode=='crash':env['TEST_CRASH']='1'
        if mode=='slow_start':env['TEST_CONTROL']='1'
        if mode=='compatibility_restart':env['LD_PRELOAD']=str(restore)
        original=subprocess.Popen([str(app)],env=env)
        thread=None
        if mode!='unreaped_original':
            thread=threading.Thread(target=original.wait);thread.start()
        process=None
        try:
            start=Path(f'/proc/{original.pid}/stat').read_text().rsplit(')',1)[1].split()[19]
            if mode=='wrong_identity':start=str(int(start)+1)
            process=subprocess.Popen([str(bench),str(original.pid),start,'10'],stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL)
            deadline=time.monotonic()+16
            signaled=False
            while time.monotonic()<deadline:
                lines=events.read_text().splitlines() if events.exists() else []
                if mode=='wrong_identity':
                    if process.poll() is not None:
                        assert process.returncode!=0 and original.poll() is None
                        break
                else:
                    experimental=[x for x in lines if x.startswith('experimental')]
                    if mode in ('signal','unreaped_original','compatibility_restart') and experimental and not signaled:
                        process.terminate();signaled=True
                    if mode=='slow_start' and 'ready' in lines and not signaled:
                        process.terminate();signaled=True
                    if any(x==f'original {process.pid}' for x in lines):
                        if mode=='slow_start':assert signaled, 'Receiver startup timed out prematurely'
                        assert experimental and original.poll() is not None
                        break
                time.sleep(.05)
            else:raise AssertionError(f'{mode}: restoration timed out: {lines}')
            results.append(dict(case=mode,passed=True))
        finally:
            for proc in (process,original):
                if proc and proc.poll() is None:proc.kill();proc.wait(timeout=3)
            if thread:thread.join(timeout=3)
    print(json.dumps(results,indent=2))

if __name__=='__main__':
    if str(ROOT)=='/work':guest()
    else:
        subprocess.run(['docker','run','--rm','--network','none','--platform','linux/amd64',
                        '-v',f'{ROOT}:/work:ro','smartbox-mirror-builder:local','python3',
                        '/work/scripts/test_mirroring_bench.py'],check=True)
