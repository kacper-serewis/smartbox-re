#!/usr/bin/env python3
"""Exercise inherited netlink reuse in disposable Linux, without a device."""
import os
from pathlib import Path
import socket
import subprocess
import json

ROOT=Path(__file__).resolve().parents[1]

def guest():
    root=Path('/tmp/bench-socket-test');root.mkdir()
    app=root/'app';library=root/'reuse.so'
    (root/'app.c').write_text(r'''
#include <errno.h>
#include <linux/netlink.h>
#include <stdlib.h>
#include <sys/socket.h>
#include <unistd.h>
int main(int argc,char **argv) {
    if(argc!=3)return 10;
    int fd=socket(AF_NETLINK,SOCK_RAW,NETLINK_USERSOCK);
    struct sockaddr_nl addr={.nl_family=AF_NETLINK,.nl_pid=atoi(argv[1])};
    int result=bind(fd,(void *)&addr,sizeof(addr));
    if(atoi(argv[2]))return result<0&&errno==EADDRINUSE?0:11;
    if(result)return 12;
    socklen_t size=sizeof(addr);
    if(getsockname(fd,(void *)&addr,&size)||addr.nl_pid!=(unsigned)atoi(argv[1]))return 13;
    if(addr.nl_pid==53){char data[8];if(recv(fd,data,sizeof(data),MSG_DONTWAIT)!=4)return 14;}
    return 0;
}
''')
    subprocess.run(['gcc','-Wall','-Wextra','-Werror',str(root/'app.c'),'-o',str(app)],check=True)
    subprocess.run(['gcc','-Wall','-Wextra','-Werror','-shared','-fPIC',
                    f'-DBENCH_APP="{app}"','-DBENCH_NETLINK_PROTOCOL=2',
                    str(ROOT/'experiments/mirroring/bench_socket.c'),'-o',str(library),'-ldl'],check=True)
    env=dict(os.environ,LD_PRELOAD=str(library));results=[]
    with socket.socket(socket.AF_NETLINK,socket.SOCK_RAW,2) as old, socket.socket(socket.AF_NETLINK,socket.SOCK_RAW,2) as other, socket.socket(socket.AF_NETLINK,socket.SOCK_RAW,2) as sender:
        old.bind((53,0));other.bind((54,0));sender.bind((0,0))
        sender.sendto(b'test',(53,0))
        for name,port,fail,passed in [('reuse_and_receive',53,0,(old.fileno(),)),
                                      ('no_inherited_socket',53,1,()),
                                      ('unrelated_port',54,1,(old.fileno(),other.fileno())),
                                      ('fresh_bind',55,0,(old.fileno(),))]:
            subprocess.run([str(app),str(port),str(fail)],env=env,pass_fds=passed,check=True)
            results.append(dict(case=name,passed=True))
    print(json.dumps(results,indent=2))

if __name__=='__main__':
    if str(ROOT)=='/work':guest()
    else:subprocess.run(['docker','run','--rm','--network','none','--platform','linux/amd64',
                         '-v',f'{ROOT}:/work:ro','smartbox-mirror-builder:local','python3',
                         '/work/scripts/test_bench_socket.py'],check=True)
