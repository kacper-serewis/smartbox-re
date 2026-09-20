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

int main(int argc, char **argv) {
    const char *name = strrchr(argv[0], '/'); name = name ? name + 1 : argv[0];
    if (!strcmp(name, "smartbox-mode-driver")) return driver(argc, argv);
    mkdir(MODE_DIR, 0700);
    unlink(CONTROL_SOCKET); unlink(STATUS_FILE);
    pid_t parent = getpid(), child = fork();
    if (child == 0) {
        prctl(PR_SET_PDEATHSIG, SIGTERM);
        if (getppid() != parent) _exit(0);
        /* The stock process loads the integration before the settings driver starts. */
        for (int i = 0; i < 100 && access(CONTROL_SOCKET, F_OK); i++) usleep(100000);
        unsetenv("LD_PRELOAD");
        int log = open("/tmp/smartbox-mode.log", O_WRONLY | O_CREAT | O_TRUNC, 0600);
        if (log >= 0) { dup2(log, 1); dup2(log, 2); if (log > 2) close(log); }
        execl("/mnt/app/bin/smartbox-mode", "smartbox-mode", "--state-dir", MODE_DIR,
              "--web-dir", "/mnt/app/mode-web", "--bind", "0.0.0.0", "--port", "8081",
              "--driver", "/mnt/app/bin/smartbox-mode-driver", "--runtime-status", STATUS_FILE, (char *)NULL);
        _exit(127);
    }
    /* Keep the stock process PID and basename for the vendor watchdog. */
    if (setenv("LD_PRELOAD", MIRROR_LIBRARY, 1)) return 1;
    execv(APP_ORIGINAL, argv);
    perror("start stock CPAAProxyEx");
    if (child > 0) kill(child, SIGTERM);
    return 127;
}
