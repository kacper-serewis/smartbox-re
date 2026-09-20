/* RAM-only restart compatibility for HW501 v131's fixed netlink port 53.
 * UpdateServer and other vendor children retain this socket across app exit.
 * Reuse only an inherited socket with the exact family/protocol/port/groups.
 * Never touch another process or close its descriptors.
 */
#define _GNU_SOURCE
#include <dlfcn.h>
#include <dirent.h>
#include <errno.h>
#include <fcntl.h>
#include <linux/netlink.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <unistd.h>
#ifndef BENCH_APP
#define BENCH_APP "/mnt/app/bin/CPAAProxyEx"
#endif
#ifndef BENCH_NETLINK_PROTOCOL
#define BENCH_NETLINK_PROTOCOL 26
#endif
static int inherited=-1;
static int (*real_bind)(int,const struct sockaddr *,socklen_t);
static int protocol(int fd) {
    int p=-1; socklen_t n=sizeof(p);
    return getsockopt(fd,SOL_SOCKET,SO_PROTOCOL,&p,&n)==0?p:-1;
}
__attribute__((constructor)) static void init(void) {
    real_bind=dlsym(RTLD_NEXT,"bind");
    char exe[4096];ssize_t n=readlink("/proc/self/exe",exe,sizeof(exe)-1);
    if(n<0)return;
    exe[n]=0;if(strcmp(exe,BENCH_APP))return;
    unsetenv("LD_PRELOAD");
    DIR *dir=opendir("/proc/self/fd");if(!dir)return;
    struct dirent *entry;
    while((entry=readdir(dir))) {
        char *end;long fd=strtol(entry->d_name,&end,10);
        if(*end||fd<3||fd==dirfd(dir)||protocol((int)fd)!=BENCH_NETLINK_PROTOCOL)continue;
        struct sockaddr_nl addr={0};socklen_t size=sizeof(addr);
        if(getsockname((int)fd,(void *)&addr,&size)||size!=sizeof(addr)||
           addr.nl_family!=AF_NETLINK||addr.nl_pid!=53||addr.nl_groups)continue;
        if(inherited<0)inherited=fcntl((int)fd,F_DUPFD_CLOEXEC,64);
        /* Further vendor execs need not retain this inherited descriptor. */
        int flags=fcntl((int)fd,F_GETFD);
        if(flags>=0)fcntl((int)fd,F_SETFD,flags|FD_CLOEXEC);
        break;
    }
    closedir(dir);
}
int bind(int fd,const struct sockaddr *address,socklen_t size) {
    if(!real_bind)real_bind=dlsym(RTLD_NEXT,"bind");
    if(!real_bind){errno=ENOSYS;return -1;}
    int result=real_bind(fd,address,size),error=errno;
    if(result==0||error!=EADDRINUSE||inherited<0||!address||size!=sizeof(struct sockaddr_nl))return result;
    const struct sockaddr_nl *wanted=(const void *)address;
    if(wanted->nl_family!=AF_NETLINK||wanted->nl_pid!=53||wanted->nl_groups||protocol(fd)!=BENCH_NETLINK_PROTOCOL){errno=error;return -1;}
    int original_type=0,new_type=0; socklen_t type_size=sizeof(int);
    if(getsockopt(inherited,SOL_SOCKET,SO_TYPE,&original_type,&type_size)||
       getsockopt(fd,SOL_SOCKET,SO_TYPE,&new_type,&type_size)||original_type!=new_type){errno=error;return -1;}
    if(dup3(inherited,fd,O_CLOEXEC)<0)return -1;
    fprintf(stderr,"[bench] reused inherited USB notification socket on fd %d\n",fd);
    return 0;
}
