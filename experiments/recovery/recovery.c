#define _GNU_SOURCE
#define _FILE_OFFSET_BITS 64
#include <arpa/inet.h>
#include <dirent.h>
#include <errno.h>
#include <fcntl.h>
#include <limits.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/file.h>
#include <sys/socket.h>
#include <sys/stat.h>
#include <sys/time.h>
#include <sys/wait.h>
#include <time.h>
#include <unistd.h>

#ifndef SMARTBOX_ROOT
#define SMARTBOX_ROOT ""
#endif
#ifndef SSH_BIND
#define SSH_BIND "192.168.5.1:2222"
#endif
#define APP SMARTBOX_ROOT "/mnt/app"
#define RAM SMARTBOX_ROOT "/tmp/smartbox-rescue"
#define STATE SMARTBOX_ROOT "/mnt/UDISK/smartbox-recovery"
#define MODE SMARTBOX_ROOT "/mnt/UDISK/smartbox-mode"
#define LOG RAM "/recovery.log"
#define WEB_PORT 8083
static volatile sig_atomic_t stopping;
static pid_t app_pid, ssh_pid = -1, updater_pid = -1;
static unsigned long long app_start;
static int maintenance;
static void stop(int sig) { (void)sig; stopping = 1; }
static void tick(void) { struct timespec t = {0, 100000000}; nanosleep(&t, NULL); }
static int write_all(int fd, const void *data, size_t size) {
    const char *p = data;
    while (size) { ssize_t n = write(fd, p, size); if (n < 0 && errno == EINTR) continue;
        if (n <= 0) return -1;
        p += n; size -= (size_t)n;
    } return 0;
}
static int directory(const char *path) {
    struct stat s;
    if (mkdir(path, 0700) && errno != EEXIST) return -1;
    if (lstat(path, &s) || !S_ISDIR(s.st_mode) || s.st_uid != geteuid() || (s.st_mode & 0022)) return -1;
    return 0;
}
static struct dirent *next_entry(DIR *dir, int *error) {
    errno = 0;
    struct dirent *entry = readdir(dir);
    if (!entry && errno) *error = 1;
    return entry;
}
static int copy_file(const char *from, const char *to, mode_t mode) {
    char tmp[PATH_MAX]; if (snprintf(tmp, sizeof(tmp), "%s.new", to) >= (int)sizeof(tmp)) return -1;
    int in = open(from, O_RDONLY | O_CLOEXEC | O_NOFOLLOW), out = -1, result = -1;
    struct stat s;
    if (in < 0 || fstat(in, &s) || !S_ISREG(s.st_mode)) goto done;
    out = open(tmp, O_WRONLY | O_CREAT | O_TRUNC | O_CLOEXEC | O_NOFOLLOW, mode);
    if (out < 0 || fchmod(out, mode)) goto done;
    char buffer[16384]; ssize_t n;
    while ((n = read(in, buffer, sizeof(buffer))) > 0) if (write_all(out, buffer, (size_t)n)) goto done;
    if (n < 0 || fsync(out) || rename(tmp, to)) goto done;
    result = 0;
done:
    if (in >= 0) close(in);
    if (out >= 0) close(out);
    if (result) unlink(tmp);
    return result;
}
static int copy_tree(const char *from, const char *to) {
    if (directory(to)) return -1;
    DIR *dir = opendir(from); if (!dir) return -1;
    struct dirent *e; int result = 0, error = 0;
    while ((e = next_entry(dir, &error))) {
        if (!strcmp(e->d_name, ".") || !strcmp(e->d_name, "..")) continue;
        char a[PATH_MAX], b[PATH_MAX]; struct stat s;
        if (snprintf(a, sizeof(a), "%s/%s", from, e->d_name) >= (int)sizeof(a) ||
            snprintf(b, sizeof(b), "%s/%s", to, e->d_name) >= (int)sizeof(b) || lstat(a, &s)) { result = -1; break; }
        result = S_ISDIR(s.st_mode) ? copy_tree(a, b) : S_ISREG(s.st_mode) ? copy_file(a, b, s.st_mode & 0100 ? 0700 : 0600) : -1;
        if (result) break;
    }
    closedir(dir); return error ? -1 : result;
}
static int marker(const char *path) {
    int fd = open(path, O_WRONLY | O_CREAT | O_TRUNC | O_CLOEXEC | O_NOFOLLOW, 0600);
    if (fd < 0) return -1;
    int result = write_all(fd, "recovery\n", 9) || fsync(fd); close(fd);
    return result ? -1 : 0;
}
static unsigned long long start_time(pid_t pid) {
    char path[64], line[2048]; snprintf(path, sizeof(path), "/proc/%ld/stat", (long)pid);
    FILE *f = fopen(path, "r"); if (!f) return 0;
    char *ok = fgets(line, sizeof(line), f); fclose(f); if (!ok) return 0;
    char *p = strrchr(line, ')'); if (!p) return 0;
    p += 2;
    if (*p == 'Z') return 0;
    /* Field 3 is the state; field 22 is the creation time. */
    for (int field = 3; field < 22; field++) { p = strchr(p, ' '); if (!p) return 0; p++; }
    return strtoull(p, NULL, 10);
}
static int app_alive(void) { return app_start && start_time(app_pid) == app_start; }
static pid_t launch(char *const args[]) {
    pid_t pid = fork();
    if (!pid) {
        if (setsid() < 0 || chdir(RAM)) _exit(126);
        signal(SIGTERM, SIG_DFL); signal(SIGINT, SIG_DFL); signal(SIGPIPE, SIG_DFL);
        unsetenv("LD_PRELOAD"); unsetenv("LD_LIBRARY_PATH");
        int fd = open("/dev/null", O_RDONLY); if (fd < 0) _exit(126);
        dup2(fd, STDIN_FILENO); if (fd > 2) close(fd);
        execv(args[0], args); perror(args[0]); _exit(127);
    } return pid;
}
static int run(char *const args[]) {
    pid_t pid = launch(args); if (pid < 0) return -1;
    for (int i = 0; i < 100; i++) {
        int s; if (waitpid(pid, &s, WNOHANG) == pid) return WIFEXITED(s) && WEXITSTATUS(s) == 0 ? 0 : -1;
        tick();
    }
    kill(pid, SIGKILL); waitpid(pid, NULL, 0); return -1;
}
static int disable_experiments(void) {
    if (directory(MODE) || marker(MODE "/recovery-disabled")) return -1;
    int fd = open(MODE, O_RDONLY | O_DIRECTORY | O_CLOEXEC);
    if (fd < 0) return -1;
    int r = fsync(fd); close(fd); return r;
}
/* Unmount would fail if any executable, library, fd, or cwd still uses app.
 * Refuse preparation while those references remain; never kill unknown PIDs. */
static int app_references(void) {
    DIR *dir = opendir("/proc"); if (!dir) return 1;
    struct dirent *e; int found = 0, error = 0;
    while (!found && (e = next_entry(dir, &error))) {
        if (e->d_name[0] < '0' || e->d_name[0] > '9') continue;
        char path[PATH_MAX], line[4096];
        /* These unchanged vendor daemons are stopped by UpdateServer's own
         * executable-name enumeration before it unmounts the application. */
        snprintf(path, sizeof(path), "/proc/%s/exe", e->d_name);
        ssize_t executable_n = readlink(path, line, sizeof(line)-1);
        if (executable_n >= 0) {
            line[executable_n] = 0;
            if (!strcmp(line, APP "/bin/blueware") || !strcmp(line, APP "/bin/mdnsd")) continue;
        }
        snprintf(path, sizeof(path), "/proc/%s/maps", e->d_name);
        FILE *f = fopen(path, "r");
        if (f) { while (fgets(line, sizeof(line), f)) if (strstr(line, APP "/")) { found = 1; break; } fclose(f); }
        snprintf(path, sizeof(path), "/proc/%s/cwd", e->d_name);
        ssize_t n = readlink(path, line, sizeof(line)-1);
        if (n >= 0) { line[n] = 0; if (!strcmp(line, APP) || !strncmp(line, APP "/", strlen(APP)+1)) found = 1; }
        snprintf(path, sizeof(path), "/proc/%s/fd", e->d_name);
        DIR *fds = opendir(path);
        if (fds) {
            struct dirent *entry;
            while ((entry = next_entry(fds, &error))) {
                char link[PATH_MAX];
                if (snprintf(link, sizeof(link), "%s/%s", path, entry->d_name) >= (int)sizeof(link)) { found = 1; break; }
                n = readlink(link, line, sizeof(line)-1);
                if (n >= 0) { line[n] = 0; if (!strcmp(line, APP) || !strncmp(line, APP "/", strlen(APP)+1)) { found = 1; break; } }
            } closedir(fds);
        }
    } closedir(dir); return found || error;
}
static int listening(int port) {
    int fd = socket(AF_INET, SOCK_STREAM | SOCK_CLOEXEC, 0); if (fd < 0) return 0;
    struct sockaddr_in address = {.sin_family = AF_INET, .sin_port = htons((unsigned short)port)};
    inet_pton(AF_INET, "127.0.0.1", &address.sin_addr);
    int ok = !connect(fd, (void *)&address, sizeof(address)); close(fd); return ok;
}
static const char *prepare(void) {
    if (updater_pid > 0) return "Restore updater already started on forwarded port 18082.\n";
    if (listening(8082)) return "ERROR: updater port is occupied; inspect it over SSH.\n";
    if (disable_experiments() || marker(RAM "/maintenance")) return "ERROR: could not save maintenance state.\n";
    maintenance = 1;
    if (app_alive()) {
        kill(app_pid, SIGTERM);
        for (int i = 0; i < 40 && app_alive(); i++) tick();
        if (app_alive()) return "ERROR: application has not stopped; inspect it over SSH.\n";
    }
    if (app_references()) return "ERROR: application partition is still in use; inspect processes, open files, and working directories over SSH.\n";
    /* This SHTTPD version accepts a port number, not address:port. Its ACL
     * defaults to deny and admits only the SSH server's loopback connection. */
    char *args[] = {RAM "/UpdateServer", "-ports", "8082", "-acl", "-0.0.0.0/0,+127.0.0.1/32", "-dir_list", "no", "-root", RAM "/web", "-index_files", "index_cptowlcp.html", NULL};
    updater_pid = launch(args);
    if (updater_pid < 0) return "ERROR: could not start updater.\n";
    for (int i = 0; i < 30; i++) {
        if (waitpid(updater_pid, NULL, WNOHANG) == updater_pid) { updater_pid = -1; return "ERROR: updater exited; download the recovery log.\n"; }
        if (listening(8082)) return "Restore prepared. Use update_device.py with --device http://127.0.0.1:18082 and your verified HW501 release. Nothing has been flashed.\n";
        tick();
    }
    return "ERROR: updater did not become reachable; inspect it over SSH.\n";
}
static void reply(int fd, int code, const char *type, const char *body, size_t n) {
    char headers[512];
    int size = snprintf(headers, sizeof(headers), "HTTP/1.1 %d %s\r\nContent-Type: %s\r\nContent-Length: %zu\r\nConnection: close\r\nCache-Control: no-store\r\nX-Content-Type-Options: nosniff\r\nX-Frame-Options: DENY\r\nContent-Security-Policy: default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'; frame-ancestors 'none'\r\n\r\n", code, code == 200 ? "OK" : "Error", type, n);
    if (size > 0 && size < (int)sizeof(headers) && !write_all(fd, headers, (size_t)size)) write_all(fd, body, n);
}
static void text_reply(int fd, int code, const char *body) { reply(fd, code, "text/plain; charset=utf-8", body, strlen(body)); }
static void file_reply(int fd, const char *path, const char *type) {
    char data[65536]; int in = open(path, O_RDONLY | O_CLOEXEC | O_NOFOLLOW);
    if (in < 0) { text_reply(fd, 404, "File unavailable\n"); return; }
    struct stat s; if (!fstat(in, &s) && s.st_size > (off_t)sizeof(data)) lseek(in, -(off_t)sizeof(data), SEEK_END);
    ssize_t n = read(in, data, sizeof(data)); close(in);
    if (n < 0) text_reply(fd, 500, "Read failed\n"); else reply(fd, 200, type, data, (size_t)n);
}
static void request(int fd) {
    struct timeval timeout = {2, 0};
    setsockopt(fd, SOL_SOCKET, SO_RCVTIMEO, &timeout, sizeof(timeout)); setsockopt(fd, SOL_SOCKET, SO_SNDTIMEO, &timeout, sizeof(timeout));
    char data[8192], method[16], path[128], version[16]; size_t used = 0;
    /* Absolute deadline also prevents a slow sender from monopolizing the loop. */
    struct timespec start, current; clock_gettime(CLOCK_MONOTONIC, &start);
    while (used < sizeof(data)-1) {
        ssize_t n = read(fd, data+used, sizeof(data)-1-used); if (n <= 0) return;
        used += (size_t)n; data[used] = 0;
        if (memchr(data, 0, used)) return;
        if (strstr(data, "\r\n\r\n")) break;
        clock_gettime(CLOCK_MONOTONIC, &current); if (current.tv_sec-start.tv_sec >= 2) return;
    }
    char *end = strstr(data, "\r\n\r\n");
    if (!end || sscanf(data, "%15s %127s %15s", method, path, version) != 3 || strcmp(version, "HTTP/1.1")) { text_reply(fd, 400, "Invalid request\n"); return; }
    char *first = strstr(data, "\r\n");
    if (!first || first == end) { text_reply(fd, 400, "Host header required\n"); return; }
    *end = 0;
    char host[128] = "", origin[160] = ""; int token = 0, hosts = 0, origins = 0, invalid = 0;
    char *line = first + 2;
    while (line && *line) {
        char *next = strstr(line, "\r\n"); if (next) { *next = 0; next += 2; }
        char *colon = strchr(line, ':'); if (!colon) { invalid = 1; break; }
        *colon++ = 0; while (*colon == ' ' || *colon == '\t') colon++;
        if (!strcasecmp(line, "Host")) { hosts++; if (strlen(colon) >= sizeof(host)) invalid = 1; else strcpy(host, colon); }
        else if (!strcasecmp(line, "Origin")) { origins++; if (strlen(colon) >= sizeof(origin)) invalid = 1; else strcpy(origin, colon); }
        else if (!strcasecmp(line, "X-SmartBox-Recovery")) token += !strcmp(colon, "1");
        else if (!strcasecmp(line, "Transfer-Encoding") || (!strcasecmp(line, "Content-Length") && strcmp(colon, "0"))) invalid = 1;
        line = next;
    }
    /* Only localhost tunnel origins. Prevent DNS rebinding and browser CSRF. */
    char expected[160]; snprintf(expected, sizeof(expected), "http://%s", host);
    if (invalid || hosts != 1 || origins > 1 ||
        (strcmp(host, "127.0.0.1:18083") && strcmp(host, "localhost:18083") && strcmp(host, "127.0.0.1:8083")) ||
        (origins && strcmp(origin, expected))) { text_reply(fd, 403, "Use the localhost SSH tunnel\n"); return; }
    if (!strcmp(method, "GET")) {
        if (!strcmp(path, "/")) file_reply(fd, RAM "/index.html", "text/html; charset=utf-8");
        else if (!strcmp(path, "/logs")) file_reply(fd, LOG, "text/plain; charset=utf-8");
        else if (!strcmp(path, "/status")) {
            char body[400]; snprintf(body, sizeof(body), "{\"application_running\":%s,\"maintenance\":%s,\"ssh_process_running\":%s,\"updater_process_running\":%s,\"experiments_disabled\":%s,\"hardware_validated\":false}\n", app_alive()?"true":"false", maintenance?"true":"false", ssh_pid>0?"true":"false", updater_pid>0?"true":"false", !access(MODE "/recovery-disabled", F_OK)?"true":"false");
            reply(fd, 200, "application/json", body, strlen(body));
        } else text_reply(fd, 404, "Not found\n");
    } else if (!strcmp(method, "POST") && token == 1) {
        if (!strcmp(path, "/disable")) {
            int failed = disable_experiments();
            text_reply(fd, failed?500:200, failed?"Could not save the recovery setting.\n":"Experimental features disabled for the next boot.\n");
        }
        else if (!strcmp(path, "/prepare")) { const char *msg = prepare(); text_reply(fd, !strncmp(msg,"ERROR",5)?409:200, msg); }
        else if (!strcmp(path, "/reboot")) {
            if (updater_pid > 0 || !app_alive()) { text_reply(fd, 409, "An updater exists or the application has stopped. Verify no update is in progress and reboot over SSH.\n"); return; }
            if (disable_experiments()) { text_reply(fd, 500, "Could not save stock mode\n"); return; }
            text_reply(fd, 200, "Reboot requested\n"); sync();
            char *args[] = {SMARTBOX_ROOT "/sbin/reboot", NULL}; launch(args);
        } else text_reply(fd, 404, "Not found\n");
    } else text_reply(fd, 403, "Recovery action header required\n");
}
static int serve(void) {
    if (chdir(RAM)) return 1;
    int lock = open(RAM "/lock", O_RDWR | O_CREAT | O_CLOEXEC | O_NOFOLLOW, 0600);
    if (lock < 0 || flock(lock, LOCK_EX | LOCK_NB)) return 1;
    maintenance = !access(RAM "/maintenance", F_OK);
    signal(SIGTERM, stop); signal(SIGINT, stop); signal(SIGPIPE, SIG_IGN);
    setvbuf(stderr, NULL, _IONBF, 0);
    if (directory(STATE)) return 1;
    if (access(STATE "/hostkey", F_OK)) {
        char *args[] = {RAM "/dropbearmulti", "dropbearkey", "-t", "ed25519", "-f", STATE "/hostkey.new", NULL};
        unlink(STATE "/hostkey.new");
        if (run(args) || rename(STATE "/hostkey.new", STATE "/hostkey")) return 1;
        sync();
    }
    if (copy_file(STATE "/hostkey", RAM "/hostkey", 0600)) return 1;
    int sock = socket(AF_INET, SOCK_STREAM | SOCK_CLOEXEC, 0); if (sock < 0) return 1;
    int yes = 1; setsockopt(sock, SOL_SOCKET, SO_REUSEADDR, &yes, sizeof(yes));
    struct sockaddr_in address = {.sin_family = AF_INET, .sin_port = htons(WEB_PORT)};
    inet_pton(AF_INET, "127.0.0.1", &address.sin_addr);
    if (bind(sock, (void *)&address, sizeof(address)) || listen(sock, 8)) return 1;
    fcntl(sock, F_SETFL, O_NONBLOCK);
    if (marker(RAM "/ready")) return 1;
    time_t retry = 0;
    while (!stopping) {
        struct stat log_stat;
        if (!lstat(LOG, &log_stat) && S_ISREG(log_stat.st_mode) && log_stat.st_size > 1048576) {
            int log = open(LOG, O_WRONLY | O_TRUNC | O_CLOEXEC | O_NOFOLLOW);
            if (log >= 0) close(log);
        }
        if (ssh_pid > 0 && waitpid(ssh_pid, NULL, WNOHANG) == ssh_pid) { ssh_pid = -1; retry = time(NULL)+3; }
        if (updater_pid > 0 && waitpid(updater_pid, NULL, WNOHANG) == updater_pid) updater_pid = -1;
        if (ssh_pid < 0 && time(NULL) >= retry) {
            /* Password auth and syslog are compiled out; -s/-E are therefore
             * absent from this build's command-line parser. */
            /* Relative key directory is anchored in our verified private RAM
             * cwd. Dropbear checks it without rejecting the sticky /tmp parent. */
            char *args[] = {RAM "/dropbearmulti", "dropbear", "-F", "-p", SSH_BIND, "-r", RAM "/hostkey", "-D", "./keys", "-P", RAM "/ssh.pid", "-I", "900", "-T", "3", NULL};
            ssh_pid = launch(args); retry = time(NULL)+3;
        }
        int client = accept4(sock, NULL, NULL, SOCK_CLOEXEC);
        if (client >= 0) { request(client); close(client); } else tick();
    }
    /* Stop only the listener; established sessions and updater remain alive. */
    if (ssh_pid > 0) kill(ssh_pid, SIGTERM);
    unlink(RAM "/ready"); close(sock); close(lock); return 0;
}
static int bootstrap(int argc, char **argv) {
    (void)argc;
    umask(0077); unsetenv("LD_PRELOAD"); unsetenv("LD_LIBRARY_PATH");
    if (directory(RAM)) goto fallback;
    int lock = open(RAM "/bootstrap.lock", O_CREAT | O_RDWR | O_CLOEXEC | O_NOFOLLOW, 0600);
    if (lock < 0 || flock(lock, LOCK_EX | LOCK_NB)) goto fallback;
    int running = open(RAM "/lock", O_CREAT | O_RDWR | O_CLOEXEC | O_NOFOLLOW, 0600);
    if (running < 0) goto fallback;
    if (!flock(running, LOCK_EX | LOCK_NB)) {
        unlink(RAM "/ready");
        if (copy_tree(APP "/recovery", RAM)) { close(running); goto fallback; }
        char pid[32], birth[32]; snprintf(pid, sizeof(pid), "%ld", (long)getpid());
        snprintf(birth, sizeof(birth), "%llu", start_time(getpid()));
        close(running);
        pid_t child = fork();
        if (!child) {
            if (setsid() < 0 || chdir(RAM)) _exit(126);
            int log = open(LOG, O_WRONLY | O_CREAT | O_APPEND | O_NOFOLLOW, 0600);
            int null = open("/dev/null", O_RDONLY);
            if (log < 0 || null < 0) _exit(126);
            dup2(null, 0); dup2(log, 1); dup2(log, 2);
            long max = sysconf(_SC_OPEN_MAX); if (max < 0) max = 1024;
            for (int fd = 3; fd < max; fd++) close(fd);
            execl(RAM "/recoveryd", "recoveryd", "--serve", pid, birth, (char *)NULL); _exit(127);
        }
        for (int i = 0; i < 100 && access(RAM "/ready", F_OK); i++) tick();
    } else close(running);
    close(lock);
    if (!access(RAM "/maintenance", F_OK)) {
        /* A vendor init respawn must not restart CarPlay during a restore. */
        execl(RAM "/recoveryd", "recoveryd", "--hold", (char *)NULL);
        return 1;
    }
    if (!access(RAM "/ready", F_OK)) { execv(APP "/launch/CPAAProxyEx", argv); perror("recovery app"); }
fallback:
    fprintf(stderr, "Recovery startup unavailable; starting stock application only\n");
    execv(APP "/stock/CPAAProxyEx", argv); perror("stock app"); return 127;
}
int main(int argc, char **argv) {
    if (argc == 4 && !strcmp(argv[1], "--serve")) {
        app_pid = (pid_t)strtol(argv[2], NULL, 10); app_start = strtoull(argv[3], NULL, 10);
        if (app_pid <= 1 || !app_start) return 2;
        return serve();
    }
    if (argc == 2 && !strcmp(argv[1], "--hold")) { chdir(RAM); for (;;) pause(); }
    return bootstrap(argc, argv);
}
