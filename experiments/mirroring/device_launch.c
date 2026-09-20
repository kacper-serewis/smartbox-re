#define _GNU_SOURCE
#include <errno.h>
#include <fcntl.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/prctl.h>
#include <sys/socket.h>
#include <sys/stat.h>
#include <sys/un.h>
#include <unistd.h>
#include <sys/wait.h>
#include <time.h>
#include "device_paths.h"

static int driver(int argc, char **argv) {
    if (argc != 3 || (strcmp(argv[1], "probe") && strcmp(argv[1], "start") && strcmp(argv[1], "stop")) ||
        (strcmp(argv[2], "mirroring") && strcmp(argv[2], "carplay"))) return 2;
    int fd = socket(AF_UNIX, SOCK_STREAM | SOCK_CLOEXEC, 0);
    if (fd < 0) return 1;
    struct timeval timeout = {3, 0};
    setsockopt(fd, SOL_SOCKET, SO_RCVTIMEO, &timeout, sizeof(timeout));
    setsockopt(fd, SOL_SOCKET, SO_SNDTIMEO, &timeout, sizeof(timeout));
    struct sockaddr_un address = {.sun_family = AF_UNIX};
    strcpy(address.sun_path, CONTROL_SOCKET);
    if (connect(fd, (void *)&address, sizeof(address))) { close(fd); return 1; }
    char command[64]; int n = snprintf(command, sizeof(command), "%s %s\n", argv[1], argv[2]);
    size_t sent = 0;
    while (sent < (size_t)n) {
        ssize_t count = send(fd, command + sent, n - sent, MSG_NOSIGNAL);
        if (count < 0 && errno == EINTR) continue;
        if (count <= 0) { close(fd); return 1; }
        sent += count;
    }
    char response[8] = {0};
    size_t got = 0;
    while (got < sizeof(response) - 1 && !memchr(response, '\n', got)) {
        ssize_t count = recv(fd, response + got, sizeof(response) - 1 - got, 0);
        if (count < 0 && errno == EINTR) continue;
        if (count <= 0) break;
        got += count;
    }
    close(fd);
    return got >= 2 && response[0] == 'O' && response[1] == 'K' ? 0 : 1;
}


#ifndef STARTUP_SECONDS
#define STARTUP_SECONDS 15
#endif
#ifndef STABLE_SECONDS
#define STABLE_SECONDS 30
#endif
static volatile sig_atomic_t stopping;
static void stop_signal(int sig) { (void)sig; stopping = 1; }
static double now(void) {
    struct timespec t; clock_gettime(CLOCK_MONOTONIC, &t);
    return t.tv_sec + t.tv_nsec / 1e9;
}
static void tick(void) { struct timespec t = {0, 50000000}; nanosleep(&t, NULL); }
static int marker(const char *path, const char *reason) {
    int fd = open(path, O_WRONLY | O_CREAT | O_TRUNC | O_CLOEXEC, 0600);
    if (fd < 0) return -1;
    size_t n = strlen(reason);
    int result = write(fd, reason, n) == (ssize_t)n && !fsync(fd) ? 0 : -1;
    if (close(fd)) result = -1;
    fd = open(MODE_DIR, O_RDONLY | O_DIRECTORY | O_CLOEXEC);
    if (fd < 0) return -1;
    if (fsync(fd)) result = -1;
    close(fd); return result;
}
static void recovery_status(const char *reason, int status, int attempts) {
    FILE *f = fopen(STATUS_FILE ".new", "w");
    if (!f) return;
    fprintf(f, "{\"state\":\"recovery\",\"reason\":\"%s\",\"wait_status\":%d,"
               "\"attempts\":%d,\"pin\":\"\",\"head_unit_verified\":false}\n", reason, status, attempts);
    if (!fclose(f)) rename(STATUS_FILE ".new", STATUS_FILE);
}
static void child_setup(pid_t parent) {
    setpgid(0, 0);
    prctl(PR_SET_PDEATHSIG, SIGKILL);
    if (getppid() != parent) _exit(0);
    signal(SIGTERM, SIG_DFL); signal(SIGINT, SIG_DFL);
    unsetenv("LD_PRELOAD");
}
static pid_t launch_app(char **argv, int experimental) {
    pid_t parent = getpid(), child = fork();
    if (!child) {
        child_setup(parent);
        if (experimental && setenv("LD_PRELOAD", MIRROR_LIBRARY, 1)) _exit(126);
        execv(APP_ORIGINAL, argv);
        perror("start original CPAAProxyEx"); _exit(127);
    }
    if (child > 0) setpgid(child, child);
    return child;
}
static pid_t launch_page(int recovery) {
    pid_t parent = getpid(), child = fork();
    if (!child) {
        child_setup(parent);
        char *args[] = {"smartbox-mode", "--state-dir", MODE_DIR, "--web-dir", MODE_WEB,
                        "--bind", "0.0.0.0", "--port", "8081", "--runtime-status", STATUS_FILE,
                        NULL, NULL, NULL};
        if (!recovery) { args[11] = "--driver"; args[12] = MODE_DRIVER; }
        execv(MODE_BINARY, args); _exit(127);
    }
    if (child > 0) setpgid(child, child);
    return child;
}
static void terminate_group(pid_t pid) {
    if (pid <= 0) return;
    kill(-pid, SIGTERM);
    double end = now() + 1;
    while (now() < end) {
        if (waitpid(pid, NULL, WNOHANG) == pid) break;
        tick();
    }
    kill(-pid, SIGKILL); /* includes any remaining helpers in this group */
    while (waitpid(pid, NULL, 0) < 0 && errno == EINTR) {}
}
int main(int argc, char **argv) {
    const char *name = strrchr(argv[0], '/'); name = name ? name + 1 : argv[0];
    if (!strcmp(name, "smartbox-mode-driver")) return driver(argc, argv);
    umask(0077);
    unsetenv("LD_PRELOAD");
    signal(SIGTERM, stop_signal); signal(SIGINT, stop_signal);
    if (mkdir(MODE_DIR, 0700) && errno != EEXIST) { perror("mode state"); return 1; }
    int lock = open(MODE_DIR "/supervisor.lock", O_CREAT | O_RDWR | O_CLOEXEC, 0600);
    struct flock owner = {.l_type = F_WRLCK, .l_whence = SEEK_SET};
    if (lock < 0 || fcntl(lock, F_SETLK, &owner)) return 1;
    int recovery = access(RECOVERY_LATCH, F_OK) == 0 || access(BOOT_PENDING, F_OK) == 0;
    if (!recovery && marker(BOOT_PENDING, "experimental startup pending\n")) recovery = 1;
    if (recovery) {
        marker(RECOVERY_LATCH, "previous incomplete startup or recovery latch\n");
        recovery_status("latched", 0, 1);
    }
    unlink(CONTROL_SOCKET);
    if (!recovery) unlink(STATUS_FILE);
    pid_t app = launch_app(argv, !recovery), page = -1;
    int attempts = 1, page_attempts = 0, status = 0, stable = 0;
    double started = now(), retry_at = 0, page_retry_at = 0;
    while (!stopping) {
        double t = now();
        int failed = app < 0 && !retry_at;
        const char *reason = "app_exit";
        if (app > 0) {
            pid_t exited = waitpid(app, &status, WNOHANG);
            if (exited == app) { kill(-app, SIGKILL); app = -1; failed = 1; }
            else if (exited < 0 && errno != EINTR) { failed = 1; reason = "wait_failed"; }
        }
        if (!recovery && !failed && t - started >= STARTUP_SECONDS && access(CONTROL_SOCKET, F_OK)) {
            failed = 1; reason = "startup_timeout";
        }
        if (!recovery && failed) {
            /* Persist before retry: rebooting must not reload a known failing hook. */
            marker(RECOVERY_LATCH, reason);
            recovery = 1; attempts = 0;
            terminate_group(app); app = -1;
            terminate_group(page); page = -1; page_attempts = 0;
            unlink(CONTROL_SOCKET);
            recovery_status(reason, status, attempts);
            retry_at = t + 0.25;
        } else if (recovery && failed && !retry_at) {
            terminate_group(app); app = -1;
            if (attempts >= 3) {
                retry_at = -1;
                recovery_status("original_app_failed", status, attempts);
            } else {
                retry_at = t + attempts;
                recovery_status("retrying_original_app", status, attempts);
            }
        }
        if (recovery && app < 0 && retry_at > 0 && t >= retry_at) {
            attempts++; retry_at = 0; app = launch_app(argv, 0);
            recovery_status("original_app_started_unverified", status, attempts);
        }
        if (!recovery && !stable && t - started >= STABLE_SECONDS && !access(CONTROL_SOCKET, F_OK)) {
            unlink(BOOT_PENDING); stable = 1;
        }
        if (page > 0 && waitpid(page, NULL, WNOHANG) == page) {
            kill(-page, SIGKILL); page = -1; page_retry_at = t + 1;
        }
        if (page < 0 && page_attempts < 3 && t >= page_retry_at &&
            (recovery || !access(CONTROL_SOCKET, F_OK))) {
            page = launch_page(recovery); page_attempts++; page_retry_at = t + 1;
        }
        tick();
    }
    terminate_group(page); terminate_group(app);
    if (!recovery) unlink(BOOT_PENDING);
    unlink(CONTROL_SOCKET);
    close(lock);
    return 0;
}
