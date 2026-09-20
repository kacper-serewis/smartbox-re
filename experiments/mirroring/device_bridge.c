/* Experimental HW501 v131 integration. Only the two phone-side entry points
 * are interposed. The vendor app and its car-facing transport keep running.
 * Symbol visibility keeps UxPlay's internals out of the vendor namespace. */
#define _GNU_SOURCE
#define main capture_unused_main
#include "receiver.c"
#undef main
#include <dlfcn.h>
#include <fcntl.h>
#include <sys/socket.h>
#include <sys/stat.h>
#include <sys/un.h>
#include "device_paths.h"
#include "h264_size.h"
#include "native_video_bind.h"

typedef int (*control_fn)(void *, unsigned, const void *, const void *, const void *, void *);
typedef int (*start_fn)(void *);
typedef void (*frame_fn)(int, void *, int, bool);
static control_fn stock_control;
static start_fn stock_start;
static frame_fn stock_video;
static pthread_mutex_t mode_lock = PTHREAD_MUTEX_INITIALIZER;
static pthread_mutex_t frame_lock = PTHREAD_MUTEX_INITIALIZER;
static bool mirror_selected, native_ready, stock_suppressed;
static bool native_bound;
static void *saved_server, *saved_client;
static const void *saved_start_command;
static raop_t *mirror_server;
static dnssd_t *mirror_dns;
static bool advertised_raop, advertised_airplay;
static capture_t receiver_state = {.lock = PTHREAD_MUTEX_INITIALIZER};
static unsigned char sps[4096], pps[4096];
static size_t sps_len, pps_len;
static bool config_sent, have_idr;
static uint64_t forwarded;
static char pairing_pin[5];
static const char *bridge_state = "starting";
static float source_width, source_height;
static double last_status;

/* All status fields are numbers or internal enum strings; no phone-provided text. */
static void status_write(void) {
    FILE *f = fopen(STATUS_FILE ".new", "w");
    if (!f) return;
    fprintf(f, "{\"state\":\"%s\",\"pin\":\"%s\",\"frames_forwarded\":%" PRIu64
            ",\"width\":%.0f,\"height\":%.0f,\"head_unit_verified\":false}\n",
            bridge_state, pairing_pin, forwarded, source_width, source_height);
    if (fclose(f) == 0) rename(STATUS_FILE ".new", STATUS_FILE);
}
static void device_pin(void *cls, char *value) {
    (void)cls;
    if (strlen(value) != 4 || strspn(value, "0123456789") != 4) return;
    pthread_mutex_lock(&frame_lock);
    memcpy(pairing_pin, value, 5); bridge_state = "pairing"; status_write();
    pthread_mutex_unlock(&frame_lock);
}
static void device_dimensions(void *cls, float *sw, float *sh, float *w, float *h) {
    (void)cls; (void)w; (void)h;
    if (!isfinite(*sw) || !isfinite(*sh) || *sw < 0 || *sh < 0 || *sw > 16384 || *sh > 16384) return;
    pthread_mutex_lock(&frame_lock);
    source_width = *sw; source_height = *sh; status_write();
    pthread_mutex_unlock(&frame_lock);
}
static void device_disconnect(void *cls) {
    (void)cls;
    pthread_mutex_lock(&frame_lock);
    native_video_release(&native_output);
    /* Avoid stop-event teardown of the shared car-side stream; return to waiting. */
    sps_len = pps_len = 0; config_sent = have_idr = false;
    source_width = source_height = 0;
    pairing_pin[0] = 0; bridge_state = "waiting"; status_write();
    pthread_mutex_unlock(&frame_lock);
}
static void device_reset(void *cls, reset_type_t reason) { (void)reason; device_disconnect(cls); }
static void device_conn_reset(void *cls, int reason) { (void)reason; device_disconnect(cls); }

/* UxPlay supplies Annex B. Normalize 3/4-byte start codes, send SPS/PPS together,
 * and wait for an IDR after every parameter-set change. Stock callback event 2
 * expects four-byte start codes and a separate configuration boolean. */
static size_t start_code(const unsigned char *p, size_t n, size_t pos, size_t *width) {
    for (; pos + 3 <= n; pos++) {
        if (p[pos] || p[pos + 1]) continue;
        if (p[pos + 2] == 1) { *width = 3; return pos; }
        if (pos + 4 <= n && !p[pos + 2] && p[pos + 3] == 1) { *width = 4; return pos; }
    }
    *width = 0; return n;
}
static void device_video(void *cls, raop_ntp_t *ntp, video_decode_struct *data) {
    (void)cls; (void)ntp;
    if (!data || data->is_h265 || !data->data || data->data_len < 5 || data->data_len > 1024 * 1024) return;
#ifdef SMARTBOX_BENCH
    if (receiver_state.video && receiver_state.events) {
        video(&receiver_state, ntp, data);
        fflush(receiver_state.video); fflush(receiver_state.events);
    }
#endif
    pthread_mutex_lock(&frame_lock);
    bool ready;
    pthread_mutex_lock(&mode_lock); ready = mirror_selected && native_ready; pthread_mutex_unlock(&mode_lock);
    if (!ready || !stock_video || !native_bound) { bridge_state = "waiting_for_stock_app"; status_write(); goto done; }
    const unsigned char *input = (void *)data->data;
    size_t n = data->data_len, width, pos = start_code(input, n, 0, &width), used = 0;
    unsigned char *frame = malloc(n * 2);
    if (!frame) goto done;
    bool idr = false, picture = false, bad = pos != 0;
    while (pos < n && !bad) {
        size_t begin = pos + width, next_width, next = start_code(input, n, begin, &next_width);
        size_t length = next - begin;
        if (!length) { bad = true; break; }
        unsigned type = input[begin] & 31;
        if (type == 7 || type == 8) {
            unsigned char *target = type == 7 ? sps : pps;
            size_t *count = type == 7 ? &sps_len : &pps_len;
            if (length + 4 > sizeof(sps)) { bad = true; break; }
            if (*count != length + 4 || memcmp(target + 4, input + begin, length)) {
                memcpy(target, "\0\0\0\1", 4); memcpy(target + 4, input + begin, length);
                *count = length + 4; config_sent = have_idr = false;
            }
        } else if (type == 1 || type == 5) {
            if (!type || type > 23 || used + length + 4 > n * 2) { bad = true; break; }
            memcpy(frame + used, "\0\0\0\1", 4); memcpy(frame + used + 4, input + begin, length);
            used += length + 4;
            if (type == 5) idr = true;
            if (type == 1 || type == 5) picture = true;
        } else if (!type || type > 23) bad = true;
        pos = next; width = next_width;
    }
    if (!bad && sps_len && pps_len) {
        if (!config_sent) {
            unsigned w, h;
            if (!h264_size(sps + 4, sps_len - 4, &w, &h)) {
                have_idr = false; bridge_state = "unsupported_video"; goto release_frame;
            }
            unsigned char config[8192];
            memcpy(config, sps, sps_len); memcpy(config + sps_len, pps, pps_len);
#if defined(SMARTBOX_BRIDGE_TEST) && !defined(SMARTBOX_NATIVE_TEST)
            stock_video(2, config, (int)(sps_len + pps_len), true);
            config_sent = true;
#else
            config_sent = native_video_config(&native_output, config, (int)(sps_len + pps_len), w, h);
#endif
            have_idr = false;
            if (!config_sent) { bridge_state = "waiting_for_car_video"; goto release_frame; }
            source_width = w; source_height = h;
        }
        if (picture && (have_idr || idr)) {
            /* Stock 0x4ee7c replaces only the leading Annex B start code with
             * one AVCC length. Give it exactly one VCL NAL per call. */
            size_t offset = 0;
            while (offset < used) {
                size_t next_width;
                size_t end = start_code(frame, used, offset + 4, &next_width);
                bool key = (frame[offset + 4] & 31) == 5;
#if defined(SMARTBOX_BRIDGE_TEST) && !defined(SMARTBOX_NATIVE_TEST)
                stock_video(2, frame + offset, (int)(end - offset), false);
#else
                if (!native_video_frame(&native_output, frame + offset, (int)(end - offset), key)) {
                    config_sent = have_idr = false;
                    bridge_state = "waiting_for_car_video"; goto release_frame;
                }
#endif
                (void)key;
                offset = end;
            }
            have_idr = true; forwarded++; pairing_pin[0] = 0;
            bridge_state = "forwarding_unverified";
        }
    } else if (bad) bridge_state = "invalid_video";
release_frame:
    free(frame);
    if (monotime() - last_status > 1) { last_status = monotime(); status_write(); }
done:
    pthread_mutex_unlock(&frame_lock);
}

static void stop_receiver(void) {
    if (advertised_airplay) dnssd_unregister_airplay(mirror_dns);
    if (advertised_raop) dnssd_unregister_raop(mirror_dns);
    advertised_airplay = advertised_raop = false;
    if (mirror_server) raop_destroy(mirror_server);
    if (mirror_dns) dnssd_destroy(mirror_dns);
    mirror_server = NULL; mirror_dns = NULL;
    device_disconnect(NULL);
}
static int start_receiver(void) {
    if (mirror_server) return 0;
    unsigned char mac[6]; unsigned short pin_number;
    FILE *random = fopen("/dev/urandom", "rb");
    if (!random) return -1;
    size_t got = fread(mac, 1, sizeof(mac), random);
    size_t pin_got = fread(&pin_number, 1, sizeof(pin_number), random); fclose(random);
    if (got != sizeof(mac) || pin_got != sizeof(pin_number)) return -1;
    pin_number %= 10000;
    mac[0] = (mac[0] | 2) & 0xfe;
    char address[18]; snprintf(address, sizeof(address), "%02X:%02X:%02X:%02X:%02X:%02X", mac[0], mac[1], mac[2], mac[3], mac[4], mac[5]);
    int error = 0;
    mirror_dns = dnssd_init("SmartBox Mirror", 15, (char *)mac, 6, 1, &error);
    if (!mirror_dns || error) goto failed;
    dnssd_set_airplay_features(mirror_dns, 0, 0); dnssd_set_airplay_features(mirror_dns, 4, 0);
    dnssd_set_airplay_features(mirror_dns, 27, 1); dnssd_set_airplay_features(mirror_dns, 42, 0);
    raop_callbacks_t cb = capture_callbacks(&receiver_state);
    cb.video_process = device_video; cb.video_report_size = device_dimensions;
    cb.display_pin = device_pin;
    cb.conn_reset = device_conn_reset; cb.video_reset = device_reset;
    /* These callbacks also run for short-lived /info and pairing connections.
     * Reset only on an explicit video teardown, not every HTTP disconnect. */
    cb.conn_destroy = noop; cb.video_flush = noop;
    ntp_global_init(); mirror_server = raop_init(&cb);
    if (!mirror_server) goto failed;
    raop_set_log_callback(mirror_server, log_message, NULL);
    raop_set_log_level(mirror_server, LOGGER_WARNING);
    if (raop_init2(mirror_server, 0, address, MODE_DIR "/receiver.key")) {
        /* Upstream cannot destroy an incompletely initialized HTTP daemon. */
        mirror_server = NULL; goto failed;
    }
    raop_set_dnssd(mirror_server, mirror_dns);
    raop_set_plist(mirror_server, "width", 800); raop_set_plist(mirror_server, "height", 480);
    raop_set_plist(mirror_server, "refreshRate", 60); raop_set_plist(mirror_server, "maxFPS", 30);
    raop_set_plist(mirror_server, "pin", 10000 + pin_number); raop_set_plist(mirror_server, "hls", 0);
    unsigned short tcp[2] = {0}, udp[3] = {0}, port = 0;
    raop_set_tcp_ports(mirror_server, tcp); raop_set_udp_ports(mirror_server, udp);
    if (raop_start_httpd(mirror_server, &port) < 0) goto failed;
    raop_set_port(mirror_server, port);
    if (dnssd_register_raop(mirror_dns, port)) goto failed;
    advertised_raop = true;
    if (dnssd_register_airplay(mirror_dns, port)) goto failed;
    advertised_airplay = true;
    pthread_mutex_lock(&frame_lock);
    snprintf(pairing_pin, sizeof(pairing_pin), "%04u", pin_number);
    bridge_state = "waiting"; status_write(); pthread_mutex_unlock(&frame_lock);
    return 0;
failed:
    stop_receiver();
    return -1;
}

int AirPlayReceiverServerControl(void *server, unsigned flags, const void *command,
                                 const void *qualifier, const void *params, void *out) {
    char name[64] = {0};
    typedef unsigned char (*get_string_fn)(const void *, char *, int, unsigned);
    get_string_fn get_string = (get_string_fn)dlsym(RTLD_DEFAULT, "CFStringGetCString");
    if (get_string && command) get_string(command, name, sizeof(name), 0x08000100);
    pthread_mutex_lock(&mode_lock);
    if (mirror_selected && !strcmp(name, "startServer") && !qualifier && !params && !out) {
        saved_server = server; saved_start_command = command; stock_suppressed = true;
        pthread_mutex_unlock(&mode_lock); return 0;
    }
    pthread_mutex_unlock(&mode_lock);
    return stock_control ? stock_control(server, flags, command, qualifier, params, out) : -1;
}
int CarPlayControlClientStart(void *client) {
    pthread_mutex_lock(&mode_lock);
    saved_client = client; native_ready = true;
    bool suppress = mirror_selected;
    pthread_mutex_unlock(&mode_lock);
    if (suppress) return 0;
    return stock_start ? stock_start(client) : -1;
}
static int command(const char *line) {
    if (!strcmp(line, "probe mirroring\n")) return native_bound && stock_video && stock_control && stock_start ? 0 : -1;
    if (!strcmp(line, "start mirroring\n")) {
        pthread_mutex_lock(&mode_lock);
        bool allowed = mirror_selected;
        pthread_mutex_unlock(&mode_lock);
        return allowed && native_bound ? start_receiver() : -1; /* switching is boot-only */
    }
    if (!strcmp(line, "stop mirroring\n")) { stop_receiver(); return 0; }
    if (!strcmp(line, "start carplay\n")) {
        pthread_mutex_lock(&mode_lock);
        mirror_selected = false;
        void *server = saved_server, *client = saved_client;
        const void *start = saved_start_command;
        bool suppressed = stock_suppressed;
        stock_suppressed = false;
        pthread_mutex_unlock(&mode_lock);
        if (suppressed && stock_control(server, 1, start, NULL, NULL, NULL)) return -1;
        if (suppressed && client && stock_start(client)) return -1;
        pthread_mutex_lock(&frame_lock); bridge_state = "carplay"; status_write(); pthread_mutex_unlock(&frame_lock);
        return 0;
    }
    /* Mode UI shutdown does not own the stock application. */
    if (!strcmp(line, "stop carplay\n")) return 0;
    return -1;
}
static void *control_loop(void *arg) {
    int listener = (int)(intptr_t)arg;
    for (;;) {
        int fd = accept4(listener, NULL, NULL, SOCK_CLOEXEC);
        if (fd < 0) { if (errno == EINTR) continue; break; }
        struct timeval limit = {2, 0}; setsockopt(fd, SOL_SOCKET, SO_RCVTIMEO, &limit, sizeof(limit));
        char line[64] = {0}; size_t used = 0;
        while (used < sizeof(line) - 1) {
            ssize_t n = recv(fd, line + used, sizeof(line) - 1 - used, 0);
            if (n < 0 && errno == EINTR) continue;
            if (n <= 0) break;
            used += n;
            if (memchr(line, '\n', used)) break;
        }
        int result = command(line);
        const char *reply = result ? "ERR\n" : "OK\n";
        send(fd, reply, strlen(reply), MSG_NOSIGNAL); close(fd);
    }
    close(listener); return NULL;
}
#ifndef SMARTBOX_BRIDGE_TEST
__attribute__((constructor)) static void integration_init(void) {
    unsetenv("LD_PRELOAD"); /* vendor subprocesses must not inherit this hook */
    stock_control = (control_fn)dlsym(RTLD_NEXT, "AirPlayReceiverServerControl");
    stock_start = (start_fn)dlsym(RTLD_NEXT, "CarPlayControlClientStart");
    stock_video = (frame_fn)dlsym(RTLD_DEFAULT, "_Z21carplay_video_processiPvib");
#ifdef SMARTBOX_BENCH
    fprintf(stderr, "[bench] control=%p start=%p video=%p\n", (void *)stock_control, (void *)stock_start, (void *)stock_video);
#endif
    if (!stock_control || !stock_start || !stock_video) return;
    native_bound = native_bind((void *)stock_video);
#ifdef SMARTBOX_BENCH
    fprintf(stderr, "[bench] native_bound=%d\n", native_bound);
    receiver_state.max_bytes = 8 * 1024 * 1024; receiver_state.duration = 120;
    receiver_state.video = fopen("/tmp/boxupdate/smartbox-bench-video.h264", "wx");
    receiver_state.events = fopen("/tmp/boxupdate/smartbox-bench-events.jsonl", "wx");
    if (!receiver_state.video || !receiver_state.events) { perror("bench capture files"); return; }
#endif
    FILE *f = fopen(MODE_FILE, "r"); char value[32] = {0};
    if (f) { size_t n = fread(value, 1, sizeof(value) - 1, f); fclose(f); mirror_selected = native_bound && n == 10 && !memcmp(value, "mirroring\n", 10); }
    int listener = socket(AF_UNIX, SOCK_STREAM | SOCK_CLOEXEC, 0);
    struct sockaddr_un address = {.sun_family = AF_UNIX}; strcpy(address.sun_path, CONTROL_SOCKET);
    if (listener < 0 || bind(listener, (void *)&address, sizeof(address)) || chmod(CONTROL_SOCKET, 0600) || listen(listener, 4)) {
        if (listener >= 0) close(listener); mirror_selected = false; return;
    }
    pthread_t thread;
    if (pthread_create(&thread, NULL, control_loop, (void *)(intptr_t)listener)) {
        close(listener); unlink(CONTROL_SOCKET); mirror_selected = false; return;
    }
    pthread_detach(thread);
#ifdef SMARTBOX_BENCH
    fprintf(stderr, "[bench] control ready, mirror_selected=%d\n", mirror_selected);
#endif
}
#endif
