/* Local capture harness for the pinned UxPlay protocol library; no rendering. */
#include <errno.h>
#include <inttypes.h>
#include <math.h>
#include <pthread.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <unistd.h>
#include "raop.h"

typedef struct {
    pthread_mutex_t lock;
    FILE *video, *events;
    uint64_t bytes, packets, max_bytes;
    double first_video, duration;
    const char *reason;
    int failed;
    char *registered_key;
} capture_t;
static volatile sig_atomic_t interrupted;
static void on_signal(int sig) { interrupted = 1; }
static double monotime(void) {
    struct timespec t;
    clock_gettime(CLOCK_MONOTONIC, &t);
    return t.tv_sec + t.tv_nsec / 1e9;
}
static void noop(void *cls) {}
static void reset(void *cls, int reason) {}
static void video_reset(void *cls, reset_type_t reason) {}
static void audio(void *cls, raop_ntp_t *ntp, audio_decode_struct *data) {}
static double volume(void *cls) { return -20.0; }
static void set_volume(void *cls, float value) {}
static void metadata(void *cls, const void *data, int len) {}
static void progress(void *cls, uint32_t *a, uint32_t *b, uint32_t *c) {}
static void identifiers(void *cls, const char *a, const char *b) {}
static void running(void *cls, bool value) {}
static void hls_float(void *cls, float value) {}
static void hls_play(void *cls, const char *url, float position) {}
static float hls_remove(void *cls) { return 0.0f; }
static void hls_info(void *cls, playback_info_t *info) { memset(info, 0, sizeof(*info)); }
static void audio_format(void *cls, unsigned char *ct, unsigned short *spf,
                         bool *screen, bool *media, uint64_t *format) {}
static void admit(void *cls, char *id, char *model, char *name, bool *accepted) {
    *accepted = true; /* UxPlay's pairing still authenticates the session. */
}
static void pin(void *cls, char *value) {
    printf("\nEnter this AirPlay PIN on your iPhone: %s\n\n", value);
}
static void register_client(void *cls, const char *id, const char *pk, const char *name) {
    capture_t *c = cls;
    pthread_mutex_lock(&c->lock);
    free(c->registered_key);
    c->registered_key = strdup(pk);
    pthread_mutex_unlock(&c->lock);
}
static bool check_register(void *cls, const char *pk) {
    capture_t *c = cls;
    pthread_mutex_lock(&c->lock);
    bool match = c->registered_key && !strcmp(c->registered_key, pk);
    pthread_mutex_unlock(&c->lock);
    return match;
}
static int codec(void *cls, video_codec_t value) {
    capture_t *c = cls;
    if (value == VIDEO_CODEC_H264) return 0;
    pthread_mutex_lock(&c->lock);
    c->reason = "unsupported_codec";
    c->failed = 1;
    pthread_mutex_unlock(&c->lock);
    return -1;
}
static void dimensions(void *cls, float *sw, float *sh, float *w, float *h) {
    capture_t *c = cls;
    if (!isfinite(*sw) || !isfinite(*sh) || !isfinite(*w) || !isfinite(*h)) return;
    pthread_mutex_lock(&c->lock);
    if (fprintf(c->events, "{\"event\":\"dimensions\",\"source\":[%.3f,%.3f],"
                "\"display\":[%.3f,%.3f]}\n", *sw, *sh, *w, *h) < 0) {
        c->reason = "write_error"; c->failed = 1;
    }
    pthread_mutex_unlock(&c->lock);
    printf("Sender reports source %.0fx%.0f; display %.0fx%.0f\n", *sw, *sh, *w, *h);
}
static void video(void *cls, raop_ntp_t *ntp, video_decode_struct *data) {
    capture_t *c = cls;
    pthread_mutex_lock(&c->lock);
    if (c->reason) goto done;
    if (data->is_h265 || !data->data || data->data_len <= 0) {
        c->reason = "invalid_video"; c->failed = 1; goto done;
    }
    if ((uint64_t)data->data_len > c->max_bytes - c->bytes) {
        c->reason = "byte_limit"; goto done;
    }
    double now = monotime();
    if (c->first_video && now - c->first_video >= c->duration) {
        c->reason = "capture_complete"; goto done;
    }
    if (!c->first_video) {
        c->first_video = now;
        printf("Receiving H.264; capturing for up to %.0f seconds.\n", c->duration);
    }
    /* UxPlay owns this buffer until callback return. Preserve Annex B bytes. */
    size_t n = fwrite(data->data, 1, (size_t)data->data_len, c->video);
    if (n != (size_t)data->data_len) {
        c->bytes += n; c->reason = "write_error"; c->failed = 1; goto done;
    }
    int result = fprintf(c->events,
        "{\"event\":\"packet\",\"offset\":%" PRIu64 ",\"length\":%d,"
        "\"nals\":%d,\"local_ns\":%" PRIu64 ",\"remote_ns\":%" PRIu64 "}\n",
        c->bytes, data->data_len, data->nal_count, data->ntp_time_local, data->ntp_time_remote);
    c->bytes += n; c->packets++;
    if (result < 0) { c->reason = "write_error"; c->failed = 1; }
done:
    pthread_mutex_unlock(&c->lock);
}
static void log_message(void *cls, int level, const char *message) {
    fprintf(stderr, "[airplay:%d] %s\n", level, message);
}

static raop_callbacks_t capture_callbacks(capture_t *c) {
    raop_callbacks_t callbacks = {0};
    callbacks.cls = c;
    callbacks.audio_process = audio; callbacks.video_process = video;
    callbacks.video_pause = noop; callbacks.video_resume = noop;
    callbacks.conn_feedback = noop; callbacks.conn_reset = reset;
    callbacks.video_reset = video_reset; callbacks.conn_init = noop; callbacks.conn_destroy = noop;
    callbacks.audio_flush = noop; callbacks.video_flush = noop;
    callbacks.audio_set_client_volume = volume; callbacks.audio_set_volume = set_volume;
    callbacks.audio_set_metadata = metadata; callbacks.audio_set_coverart = metadata;
    callbacks.audio_stop_coverart_rendering = noop; callbacks.audio_set_progress = progress;
    callbacks.audio_remote_control_id = identifiers; callbacks.export_dacp = identifiers;
    callbacks.audio_get_format = audio_format; callbacks.video_report_size = dimensions;
    callbacks.mirror_video_running = running; callbacks.report_client_request = admit;
    callbacks.display_pin = pin; callbacks.register_client = register_client;
    callbacks.check_register = check_register; callbacks.video_set_codec = codec;
    callbacks.on_video_play = hls_play; callbacks.on_video_scrub = hls_float;
    callbacks.on_video_rate = hls_float; callbacks.on_video_stop = noop;
    callbacks.on_video_playlist_remove = hls_remove; callbacks.on_video_acquire_playback_info = hls_info;
    return callbacks;
}

int main(int argc, char **argv) {
    /* The Python launcher validates these arguments and creates a private cwd. */
    if (argc != 7) {
        fprintf(stderr, "Usage: mirror-capture NAME MAC WALL_SECONDS VIDEO_SECONDS MAX_BYTES ADVERTISE\n");
        return 2;
    }
    setvbuf(stdout, NULL, _IOLBF, 0);
    unsigned int octets[6];
    char hw[6];
    if (sscanf(argv[2], "%x:%x:%x:%x:%x:%x", &octets[0], &octets[1], &octets[2],
               &octets[3], &octets[4], &octets[5]) != 6) return 2;
    for (int i = 0; i < 6; i++) { if (octets[i] > 255) return 2; hw[i] = (char)octets[i]; }
    double wall_seconds = atof(argv[3]);
    capture_t c = {.lock = PTHREAD_MUTEX_INITIALIZER, .duration = atof(argv[4]),
                   .max_bytes = strtoull(argv[5], NULL, 10)};
    if (!isfinite(wall_seconds) || !isfinite(c.duration) || wall_seconds <= 0 || c.duration <= 0 || !c.max_bytes) return 2;
    c.video = fopen("video.h264", "wbx");
    c.events = fopen("events.jsonl", "wx");
    if (!c.video || !c.events) { perror("capture output"); return 1; }
    setvbuf(c.events, NULL, _IOLBF, 0);
    signal(SIGINT, on_signal); signal(SIGTERM, on_signal); signal(SIGPIPE, SIG_IGN);
    raop_callbacks_t callbacks = capture_callbacks(&c);
    ntp_global_init();
    int error = 0, status = 1;
    bool raop_advertised = false, airplay_advertised = false;
    dnssd_t *dns = dnssd_init(argv[1], (int)strlen(argv[1]), hw, 6, 1, &error);
    raop_t *server = NULL;
    if (!dns || error) { fprintf(stderr, "Bonjour initialization failed: %d\n", error); goto cleanup; }
    dnssd_set_airplay_features(dns, 0, 0); /* no HLS */
    dnssd_set_airplay_features(dns, 4, 0);
    dnssd_set_airplay_features(dns, 27, 1); /* pairing, as in upstream default */
    dnssd_set_airplay_features(dns, 42, 0); /* H.264 only */
    server = raop_init(&callbacks);
    if (!server) goto cleanup;
    raop_set_log_callback(server, log_message, &c);
    raop_set_log_level(server, LOGGER_INFO);
    if (raop_init2(server, 0, argv[2], "receiver.key")) {
        /* Upstream destroy requires the HTTP daemon to have initialized. */
        fprintf(stderr, "Receiver initialization failed\n");
        return 1;
    }
    raop_set_dnssd(server, dns);
    raop_set_plist(server, "width", 800); raop_set_plist(server, "height", 480);
    raop_set_plist(server, "refreshRate", 60); raop_set_plist(server, "maxFPS", 30);
    raop_set_plist(server, "pin", 0); raop_set_plist(server, "hls", 0);
    unsigned short tcp[2] = {0}, udp[3] = {0}, port = 0;
    raop_set_tcp_ports(server, tcp); raop_set_udp_ports(server, udp);
    if (raop_start_httpd(server, &port) < 0) goto cleanup;
    raop_set_port(server, port);
    if (atoi(argv[6])) {
        error = dnssd_register_raop(dns, port);
        if (error) { fprintf(stderr, "Bonjour RAOP registration failed: %d\n", error); goto cleanup; }
        raop_advertised = true;
        error = dnssd_register_airplay(dns, port);
        if (error) { fprintf(stderr, "Bonjour AirPlay registration failed: %d\n", error); goto cleanup; }
        airplay_advertised = true;
    }
    printf("READY port=%u name=%s\n", port, argv[1]);
    printf("Choose this receiver in iPhone Control Center > Screen Mirroring.\n");
    double started = monotime();
    for (;;) {
        pthread_mutex_lock(&c.lock);
        double now = monotime();
        if (!c.reason && interrupted) c.reason = "interrupted";
        if (!c.reason && c.first_video && now - c.first_video >= c.duration) c.reason = "capture_complete";
        if (!c.reason && now - started >= wall_seconds) c.reason = "wall_timeout";
        bool stop = c.reason != NULL;
        pthread_mutex_unlock(&c.lock);
        if (stop) break;
        usleep(100000);
    }
    status = 0;
cleanup:
    if (airplay_advertised) dnssd_unregister_airplay(dns);
    if (raop_advertised) dnssd_unregister_raop(dns);
    if (server) raop_destroy(server); /* joins workers before closing capture files */
    if (dns) dnssd_destroy(dns);
    if (fclose(c.video) || ferror(c.events)) c.failed = 1;
    if (fclose(c.events)) c.failed = 1;
    if (c.failed) status = 1;
    FILE *summary = fopen("receiver-summary.json", "wx");
    if (summary) {
        if (fprintf(summary, "{\"reason\":\"%s\",\"bytes\":%" PRIu64 ",\"packets\":%" PRIu64
                    ",\"failed\":%s,\"requested\":[800,480],\"max_fps\":30}\n",
                    c.reason ? c.reason : "startup_error", c.bytes, c.packets, status ? "true" : "false") < 0) status = 1;
        if (fclose(summary)) status = 1;
    } else { status = 1; }
    printf("Stopped: %s; %" PRIu64 " bytes in %" PRIu64 " video packets.\n",
           c.reason ? c.reason : "startup_error", c.bytes, c.packets);
    free(c.registered_key);
    pthread_mutex_destroy(&c.lock);
    return status;
}
