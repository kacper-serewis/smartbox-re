/* Native POSIX mode selection service. Build for macOS or RV32 Linux.
 * The driver owns phone-side session control; this service never kills CPAAProxyEx.
 * Driver ABI: DRIVER probe|start|stop carplay|mirroring. Zero means success.
 */
#define _POSIX_C_SOURCE 200809L
#include <arpa/inet.h>
#include <errno.h>
#include <fcntl.h>
#include <signal.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <strings.h>
#include <sys/select.h>
#include <sys/socket.h>
#include <sys/stat.h>
#include <sys/time.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <time.h>
#include <unistd.h>

static volatile sig_atomic_t stopping;
static const char *driver, *state_dir, *web_dir, *runtime_status, *reboot_command;
static const char *selected = "carplay", *active = "unknown", *error_code = "none";
static bool available_mirroring, lab;
static double reboot_at, reboot_requested_at;
static double now(void) {
    struct timespec t; clock_gettime(CLOCK_MONOTONIC, &t);
    return t.tv_sec + t.tv_nsec / 1e9;
}
static void stop_signal(int value) { (void)value; stopping = 1; }
static void pause_ms(void) { struct timespec t = {0, 50000000}; nanosleep(&t, NULL); }
static bool mode_valid(const char *s) { return !strcmp(s, "carplay") || !strcmp(s, "mirroring"); }
static void path(char *out, size_t size, const char *root, const char *name) {
    if (snprintf(out, size, "%s/%s", root, name) >= (int)size) { fputs("Path too long\n", stderr); exit(2); }
}
static int run_command(const char *command, const char *operation, const char *mode) {
    if (!command) return -1;
    pid_t child = fork();
    if (child < 0) { perror("driver fork"); return -1; }
    if (!child) {
        setpgid(0, 0);
        dup2(STDERR_FILENO, STDOUT_FILENO);
        execl(command, command, operation, mode, (char *)NULL);
        perror("driver exec");
        _exit(127);
    }
    setpgid(child, child);
    for (int i = 0; i < 100; i++) {
        int status;
        pid_t found = waitpid(child, &status, WNOHANG);
        if (found == child) return WIFEXITED(status) && WEXITSTATUS(status) == 0 ? 0 : -1;
        if (found < 0 && errno != EINTR) return -1;
        pause_ms();
    }
    kill(-child, SIGKILL);
    while (waitpid(child, NULL, 0) < 0 && errno == EINTR) {}
    return -1;
}
static int run_driver(const char *operation, const char *mode) {
    return run_command(driver, operation, mode);
}
static void restart_tick(void) {
    if (reboot_at && now() >= reboot_at) {
        reboot_at = 0;
        if (run_command(reboot_command, NULL, NULL)) error_code = "restart_failed";
        else reboot_requested_at = now();
    }
    /* A successful utility exit only acknowledges the request to init. */
    if (reboot_requested_at && now() - reboot_requested_at >= 15) {
        reboot_requested_at = 0;
        error_code = "restart_failed";
    }
}
static void read_mode(void) {
    char filename[4096], buffer[32] = {0};
    path(filename, sizeof(filename), state_dir, "connection-mode");
    FILE *f = fopen(filename, "r");
    if (!f) { if (errno != ENOENT) error_code = "invalid_settings"; return; }
    size_t n = fread(buffer, 1, sizeof(buffer) - 1, f);
    bool bad = ferror(f) || !feof(f);
    fclose(f);
    if (n && buffer[n - 1] == '\n') buffer[--n] = 0;
    if (!bad && strlen(buffer) == n && mode_valid(buffer)) selected = !strcmp(buffer, "mirroring") ? "mirroring" : "carplay";
    else error_code = "invalid_settings";
}
static int save_mode(const char *mode) {
    char temporary[4096], target[4096];
    path(temporary, sizeof(temporary), state_dir, ".mode.XXXXXX");
    path(target, sizeof(target), state_dir, "connection-mode");
    int fd = mkstemp(temporary);
    if (fd < 0) return -1;
    char value[32]; int length = snprintf(value, sizeof(value), "%s\n", mode);
    int result = write(fd, value, length) == length && !fsync(fd) ? 0 : -1;
    if (close(fd)) result = -1;
    if (!result && rename(temporary, target)) result = -1;
    if (result) { unlink(temporary); return -1; }
    int directory = open(state_dir, O_RDONLY);
    if (directory < 0) return -1;
    result = fsync(directory); close(directory);
    return result;
}
static void boot_mode(void) {
    available_mirroring = run_driver("probe", "mirroring") == 0;
    if (!driver) { error_code = "integration_unavailable"; return; }
    if (!strcmp(selected, "mirroring")) {
        if (available_mirroring && !run_driver("start", "mirroring")) { active = "mirroring"; return; }
        /* The driver must undo only its own partial mirroring startup. */
        if (run_driver("stop", "mirroring")) { error_code = "cleanup_failed"; return; }
        error_code = "start_failed";
    }
    if (!run_driver("start", "carplay")) active = "carplay";
    else error_code = "carplay_start_failed";
}
static int send_all(int fd, const void *bytes, size_t length) {
    const char *p = bytes;
    while (length) {
        ssize_t n = send(fd, p, length, 0);
        if (n < 0 && errno == EINTR) continue;
        if (n <= 0) return -1;
        p += n; length -= n;
    }
    return 0;
}
static void reply(int fd, int code, const char *type, const char *body, size_t length) {
    char header[768];
    int n = snprintf(header, sizeof(header), "HTTP/1.1 %d %s\r\nContent-Type: %s\r\nContent-Length: %zu\r\n"
        "Connection: close\r\nCache-Control: no-store\r\nX-Content-Type-Options: nosniff\r\n"
        "Content-Security-Policy: default-src 'self'; style-src 'self' 'unsafe-inline'; frame-ancestors 'none'\r\n\r\n",
        code, code == 200 ? "OK" : "Error", type, length);
    if (!send_all(fd, header, n)) send_all(fd, body, length);
}
static void message(int fd, int status, const char *text) {
    char body[256]; int n = snprintf(body, sizeof(body), "{\"message\":\"%s\"}\n", text);
    reply(fd, status, "application/json", body, n);
}
static void state_reply(int fd) {
    char body[512];
    int n = snprintf(body, sizeof(body), "{\"selected\":\"%s\",\"active\":\"%s\",\"pending\":%s,"
        "\"available\":{\"carplay\":true,\"mirroring\":%s},\"error\":\"%s\",\"lab\":%s,"
        "\"restart_on_save\":%s,\"restarting\":%s}\n",
        selected, active, strcmp(selected, active) ? "true" : "false",
        available_mirroring ? "true" : "false", error_code, lab ? "true" : "false",
        reboot_command ? "true" : "false", (reboot_at || reboot_requested_at) ? "true" : "false");
    reply(fd, 200, "application/json", body, n);
}
static void asset(int fd, const char *name, const char *type) {
    char filename[4096], buffer[32768]; path(filename, sizeof(filename), web_dir, name);
    FILE *f = fopen(filename, "rb");
    if (!f) { message(fd, 404, "Page unavailable"); return; }
    size_t n = fread(buffer, 1, sizeof(buffer), f);
    bool valid = !ferror(f) && feof(f); fclose(f);
    if (!valid) { message(fd, 500, "Page could not be read"); return; }
    reply(fd, 200, type, buffer, n);
}
static void client(int fd) {
    char request[8192 + 256] = {0}; size_t used = 0;
    char *end = NULL;
    while (!(end = strstr(request, "\r\n\r\n"))) {
        if (used >= 8192) { message(fd, 431, "Headers too large"); return; }
        ssize_t n = recv(fd, request + used, 8192 - used, 0);
        if (n <= 0) return;
        used += n; request[used] = 0;
    }
    size_t offset = (size_t)(end - request) + 4;
    *end = 0;
    char method[16], route[128], protocol[16], extra;
    char *line_end = strstr(request, "\r\n");
    if (!line_end) { message(fd, 400, "Invalid request"); return; }
    *line_end = 0;
    if (sscanf(request, "%15s %127s %15s %c", method, route, protocol, &extra) != 3 || strcmp(protocol, "HTTP/1.1")) {
        message(fd, 400, "Invalid request"); return;
    }
    size_t length = 0; bool got_length = false, custom = false;
    char host[256] = {0}, origin[300] = {0};
    for (char *line = line_end + 2; *line;) {
        char *next = strstr(line, "\r\n"); if (next) *next = 0;
        char *colon = strchr(line, ':');
        if (!colon) { message(fd, 400, "Invalid header"); return; }
        *colon++ = 0; while (*colon == ' ' || *colon == '\t') colon++;
        if (!strcasecmp(line, "Content-Length")) {
            char *last; errno = 0; unsigned long amount = strtoul(colon, &last, 10);
            if (got_length || errno || last == colon || *last || amount > 128) { message(fd, 400, "Invalid body length"); return; }
            got_length = true; length = amount;
        } else if (!strcasecmp(line, "Transfer-Encoding")) { message(fd, 400, "Unsupported transfer encoding"); return; }
        else if (!strcasecmp(line, "X-SmartBox-Mode")) custom = !strcmp(colon, "1");
        else if (!strcasecmp(line, "Host")) { if (strlen(colon) >= sizeof(host) || *host) { message(fd, 400, "Invalid host"); return; } strcpy(host, colon); }
        else if (!strcasecmp(line, "Origin")) { if (strlen(colon) >= sizeof(origin) || *origin) { message(fd, 400, "Invalid origin"); return; } strcpy(origin, colon); }
        if (!next) break;
        line = next + 2;
    }
    if (!*host) { message(fd, 400, "Host required"); return; }
    /* Consume the bounded declared body before replying, including rejection.
     * Closing a TCP socket with unread POST data can reset the response. */
    while (used < offset + length) {
        ssize_t n = recv(fd, request + used, offset + length - used, 0);
        if (n <= 0) return;
        used += n;
    }
    request[offset + length] = 0;
    if (!strcmp(method, "GET")) {
        if (!strcmp(route, "/api/mode")) state_reply(fd);
        else if (!strcmp(route, "/api/mirror") && runtime_status) {
            char body[1024];
            FILE *f = fopen(runtime_status, "r");
            if (!f) { message(fd, 503, "Receiver status unavailable"); return; }
            size_t n = fread(body, 1, sizeof(body), f);
            bool valid = n > 1 && n < sizeof(body) && !ferror(f) && feof(f);
            fclose(f);
            if (valid) reply(fd, 200, "application/json", body, n);
            else message(fd, 503, "Receiver status unavailable");
        }
        else if (!strcmp(route, "/") || !strcmp(route, "/index.html")) asset(fd, "index.html", "text/html; charset=utf-8");
        else if (!strcmp(route, "/mode.js")) asset(fd, "mode.js", "text/javascript; charset=utf-8");
        else message(fd, 404, "Not found");
        return;
    }
    if (strcmp(method, "POST") || strcmp(route, "/api/mode")) { message(fd, 405, "Method not allowed"); return; }
    char expected_origin[300]; snprintf(expected_origin, sizeof(expected_origin), "http://%s", host);
    if (!custom || (*origin && strcmp(origin, expected_origin))) { message(fd, 403, "Same-origin request required"); return; }
    if (!got_length) { message(fd, 411, "Content-Length required"); return; }
    const char *mode = request + offset;
    if (strlen(mode) != length || strncmp(mode, "mode=", 5) || !mode_valid(mode + 5)) {
        message(fd, 400, "Choose CarPlay or Screen Mirroring"); return;
    }
    mode += 5;
    if (reboot_at || reboot_requested_at) { message(fd, 409, "Adapter is already restarting"); return; }
    if (!strcmp(mode, "mirroring") && !available_mirroring) { message(fd, 409, "Screen Mirroring is unavailable in this build"); return; }
    if (reboot_command) {
        char pending[4096], recovery[4096];
        path(pending, sizeof(pending), state_dir, "boot-pending");
        path(recovery, sizeof(recovery), state_dir, "recovery-disabled");
        if (!access(pending, F_OK) && access(recovery, F_OK)) {
            message(fd, 409, "Adapter is still starting. Wait a moment and save again"); return;
        }
        if (access(reboot_command, X_OK)) { message(fd, 503, "Restart command is unavailable; mode was not saved"); return; }
    }
    if (save_mode(mode)) { message(fd, 500, "Could not save connection mode"); return; }
    selected = !strcmp(mode, "mirroring") ? "mirroring" : "carplay";
    if (!strcmp(error_code, "invalid_settings") || !strcmp(error_code, "restart_failed")) error_code = "none";
    if (reboot_command) reboot_at = now() + 2;
    state_reply(fd);
}
int main(int argc, char **argv) {
    const char *bind_address = "127.0.0.1"; int port = 8081;
    for (int i = 1; i < argc; i++) {
        if (!strcmp(argv[i], "--lab")) { lab = true; continue; }
        if (i + 1 >= argc) { fputs("Missing option value\n", stderr); return 2; }
        const char *option = argv[i++], *value = argv[i];
        if (!strcmp(option, "--state-dir")) state_dir = value;
        else if (!strcmp(option, "--web-dir")) web_dir = value;
        else if (!strcmp(option, "--driver")) driver = value;
        else if (!strcmp(option, "--runtime-status")) runtime_status = value;
        else if (!strcmp(option, "--reboot-command")) reboot_command = value;
        else if (!strcmp(option, "--bind")) bind_address = value;
        else if (!strcmp(option, "--port")) { char *last; long n = strtol(value, &last, 10); if (*last || n < 0 || n > 65535) return 2; port = n; }
        else { fprintf(stderr, "Unknown option: %s\n", option); return 2; }
    }
    if (!state_dir || !web_dir || (driver && driver[0] != '/') ||
        (reboot_command && reboot_command[0] != '/')) { fputs("Required: --state-dir DIR --web-dir DIR [--driver /absolute/executable] [--reboot-command /absolute/executable]\n", stderr); return 2; }
    umask(0077);
    if (mkdir(state_dir, 0700) && errno != EEXIST) { perror("state directory"); return 1; }
    char lock_path[4096]; path(lock_path, sizeof(lock_path), state_dir, "service.lock");
    int lock_fd = open(lock_path, O_CREAT | O_RDWR, 0600);
    struct flock lock = {.l_type = F_WRLCK, .l_whence = SEEK_SET, .l_start = 0, .l_len = 0};
    if (lock_fd < 0 || fcntl(lock_fd, F_SETLK, &lock)) { fputs("Mode service already running or state inaccessible\n", stderr); return 1; }
    fcntl(lock_fd, F_SETFD, FD_CLOEXEC);
    signal(SIGINT, stop_signal); signal(SIGTERM, stop_signal); signal(SIGPIPE, SIG_IGN);
    int server = socket(AF_INET, SOCK_STREAM, 0), yes = 1;
    if (server < 0) return 1;
    fcntl(server, F_SETFD, FD_CLOEXEC);
    setsockopt(server, SOL_SOCKET, SO_REUSEADDR, &yes, sizeof(yes));
    struct sockaddr_in address = {.sin_family = AF_INET, .sin_port = htons(port)};
    if (inet_pton(AF_INET, bind_address, &address.sin_addr) != 1 || bind(server, (struct sockaddr *)&address, sizeof(address)) || listen(server, 8)) {
        perror("listen"); close(server); return 1;
    }
    read_mode(); boot_mode();
    socklen_t size = sizeof(address); getsockname(server, (struct sockaddr *)&address, &size);
    printf("READY http://%s:%u selected=%s active=%s\n", bind_address, ntohs(address.sin_port), selected, active); fflush(stdout);
    while (!stopping) {
        restart_tick();
        if (stopping) break;
        fd_set readers; FD_ZERO(&readers); FD_SET(server, &readers);
        struct timeval wait = {.tv_sec = 0, .tv_usec = 200000};
        if (select(server + 1, &readers, NULL, NULL, &wait) <= 0) continue;
        int fd = accept(server, NULL, NULL); if (fd < 0) continue;
        fcntl(fd, F_SETFD, FD_CLOEXEC);
        struct timeval limit = {.tv_sec = 3};
        setsockopt(fd, SOL_SOCKET, SO_RCVTIMEO, &limit, sizeof(limit));
        setsockopt(fd, SOL_SOCKET, SO_SNDTIMEO, &limit, sizeof(limit));
        client(fd); close(fd);
    }
    close(server);
    if (strcmp(active, "unknown")) run_driver("stop", active);
    close(lock_fd);
    return 0;
}
