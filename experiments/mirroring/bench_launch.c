/* Temporary RAM-only application replacement, with an independent deadline.
 * Captures original argv/environment/cwd in memory; never kills a process group.
 * Exit, signal, crash, startup failure or deadline restores the original app.
 */
#define _GNU_SOURCE
#include <errno.h>
#include <fcntl.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/file.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <sys/wait.h>
#include <time.h>
#include <unistd.h>
#ifndef BENCH_APP
#define BENCH_APP "/mnt/app/bin/CPAAProxyEx"
#endif
#ifndef BENCH_LIBRARY
#define BENCH_LIBRARY "/tmp/smartbox-bench/libsmartbox-mirror.so"
#endif
#ifndef BENCH_SOCKET
#define BENCH_SOCKET "/tmp/smartbox-bench/control.sock"
#endif
static volatile sig_atomic_t stopping;
static void stop(int sig) { (void)sig; stopping=1; }
static double seconds(void) { struct timespec t; clock_gettime(CLOCK_MONOTONIC,&t);return t.tv_sec+t.tv_nsec/1e9; }
static char *procfile(pid_t pid, const char *suffix) {
    char path[128];snprintf(path,sizeof(path),"/proc/%ld/%s",(long)pid,suffix);
    FILE *f=fopen(path,"rb");if(!f)return NULL;
    char *data=calloc(65537,1);if(!data){fclose(f);return NULL;}
    size_t n=fread(data,1,65536,f);int bad=ferror(f)||n==65536;fclose(f);
    if(bad){free(data);return NULL;}return data;
}
static unsigned long long started(pid_t pid) {
    char *data=procfile(pid,"stat");if(!data)return 0;
    char *end=strrchr(data,')'),*save=NULL;unsigned long long value=0;
    if(end && end[2]!='Z'){char *p=strtok_r(end+2," ",&save);for(int i=0;p;i++,p=strtok_r(NULL," ",&save))if(i==19){value=strtoull(p,NULL,10);break;}}
    free(data);return value;
}
static char **split(char *data) {
    char **array=calloc(258,sizeof(char *));if(!array)return NULL;
    unsigned n=0;for(char *p=data;*p;p+=strlen(p)+1){if(n>=256){free(array);return NULL;}array[n++]=p;}
    return array;
}
static int control(const char *command) {
    int fd=socket(AF_UNIX,SOCK_STREAM|SOCK_CLOEXEC,0);if(fd<0)return -1;
    struct timeval tv={0,200000};setsockopt(fd,SOL_SOCKET,SO_RCVTIMEO,&tv,sizeof(tv));setsockopt(fd,SOL_SOCKET,SO_SNDTIMEO,&tv,sizeof(tv));
    struct sockaddr_un addr={.sun_family=AF_UNIX};strcpy(addr.sun_path,BENCH_SOCKET);
    char reply[4]={0};int ok=connect(fd,(void *)&addr,sizeof(addr))==0 &&
        send(fd,command,strlen(command),MSG_NOSIGNAL)==(ssize_t)strlen(command) && recv(fd,reply,3,MSG_WAITALL)==3 && !strcmp(reply,"OK\n");
    close(fd);return ok?0:-1;
}
static void end_child(pid_t child) {
    if(child<=0)return;
    if(waitpid(child,NULL,WNOHANG)==child)return;
    kill(child,SIGTERM);double end=seconds()+2;
    while(seconds()<end){if(waitpid(child,NULL,WNOHANG)==child)return;usleep(50000);}
    kill(child,SIGKILL);while(waitpid(child,NULL,0)<0&&errno==EINTR){}
}
int main(int argc,char **argv) {
    if(argc!=4)return 2;
    char *tail=NULL;long parsed=strtol(argv[1],&tail,10);if(*tail||parsed<=1||parsed>4194304)return 2;pid_t original=(pid_t)parsed;
    unsigned long long start=strtoull(argv[2],&tail,10);if(*tail||!start)return 2;
    long duration=strtol(argv[3],&tail,10);if(*tail||duration<10||duration>300)return 2;
    if(setsid()<0)return 3;
    int lock=open("/tmp/smartbox-bench.lock",O_CREAT|O_RDWR|O_CLOEXEC,0600);if(lock<0||flock(lock,LOCK_EX|LOCK_NB))return 3;
    char path[128],exe[4096],cwd[4096];snprintf(path,sizeof(path),"/proc/%ld/exe",(long)original);
    ssize_t n=readlink(path,exe,sizeof(exe)-1);if(n<0)return 3;exe[n]=0;
    if(strcmp(exe,BENCH_APP)||started(original)!=start||access(BENCH_LIBRARY,R_OK))return 3;
    snprintf(path,sizeof(path),"/proc/%ld/cwd",(long)original);n=readlink(path,cwd,sizeof(cwd)-1);if(n<0)return 3;cwd[n]=0;
    char *argdata=procfile(original,"cmdline"),*envdata=procfile(original,"environ");if(!argdata||!envdata)return 3;
    char **args=split(argdata),**env=split(envdata);if(!args||!env||!args[0]||chdir(cwd))return 3;
    unsigned count=0;while(env[count]){if(!strncmp(env[count],"LD_PRELOAD=",11))return 3;count++;}
    char **experimental=calloc(count+2,sizeof(char *));if(!experimental)return 3;
    memcpy(experimental,env,count*sizeof(char *));experimental[count]="LD_PRELOAD=" BENCH_LIBRARY;
    signal(SIGTERM,stop);signal(SIGINT,stop);signal(SIGHUP,stop);
    if(started(original)!=start||kill(original,SIGTERM))return 3;
    double deadline=seconds()+2;while(started(original)==start&&seconds()<deadline)usleep(50000);
    if(started(original)==start)kill(original,SIGKILL);
    deadline=seconds()+2;while(started(original)==start&&seconds()<deadline)usleep(50000);
    if(started(original)==start){fprintf(stderr,"Original app did not stop; refusing duplicate\n");return 4;}
    pid_t child=-1;
    if(!stopping){child=fork();if(child==0){signal(SIGTERM,SIG_DFL);signal(SIGINT,SIG_DFL);signal(SIGHUP,SIG_DFL);execve(BENCH_APP,args,experimental);_exit(127);}}
    int ready=0,exited=0,status=0;double began=seconds();
    fprintf(stderr,"Bench child %ld; deadline %ld seconds\n",(long)child,duration);fflush(stderr);
    while(child>0&&!stopping&&seconds()-began<duration){
        if(waitpid(child,&status,WNOHANG)==child){exited=1;break;}
        if(!ready&&!control("probe mirroring\n")){if(control("start mirroring\n")){fprintf(stderr,"Receiver start failed\n");break;}ready=1;fprintf(stderr,"Mirroring ready\n");fflush(stderr);}
        if(!ready&&seconds()-began>15){fprintf(stderr,"Bridge readiness deadline\n");break;}
        usleep(100000);
    }
    if(!exited)end_child(child);
    unlink(BENCH_SOCKET);
    fprintf(stderr,"Restoring stock application; experimental wait status %d\n",status);fflush(stderr);
    signal(SIGTERM,SIG_DFL);signal(SIGINT,SIG_DFL);signal(SIGHUP,SIG_DFL);
    execve(BENCH_APP,args,env);
    perror("restore stock app");return 5;
}
