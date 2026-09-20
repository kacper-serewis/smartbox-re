/* Test-only entry into the real mirroring TCP receiver after key negotiation.
 * No Bonjour or pairing: fixed test key, local client, short bounded lifetime. */
#define main receiver_main
#include "receiver.c"
#undef main
#undef NDEBUG
#include <assert.h>
#include <arpa/inet.h>
#include <sys/socket.h>
#include "raop_rtp_mirror.h"

int main(int argc, char **argv) {
    assert(argc == 3);
    alarm(20);
    signal(SIGPIPE, SIG_IGN);
    FILE *input = fopen(argv[1], "rb");
    assert(input);
    assert(!fseek(input, 0, SEEK_END));
    long length = ftell(input);
    assert(length > 0 && length < 16 * 1024 * 1024);
    rewind(input);
    unsigned char *wire = malloc(length);
    assert(wire && fread(wire, 1, length, input) == (size_t)length);
    fclose(input);
    capture_t c = {.lock = PTHREAD_MUTEX_INITIALIZER, .duration = 15, .max_bytes = 16 * 1024 * 1024,
                   .video = fopen("video.h264", "wbx"), .events = fopen("events.jsonl", "wx")};
    assert(c.video && c.events);
    raop_callbacks_t cb = {0};
    cb.cls = &c; cb.video_process = video; cb.video_report_size = dimensions;
    cb.video_set_codec = codec; cb.video_pause = noop; cb.video_resume = noop;
    cb.conn_reset = reset; cb.video_reset = video_reset; cb.mirror_video_running = running;
    logger_t *logger = logger_init();
    logger_set_callback(logger, log_message, NULL);
    logger_set_level(logger, LOGGER_WARNING);
    ntp_global_init();
    timing_protocol_t protocol = NTP;
    raop_ntp_t *ntp = raop_ntp_init(logger, &cb, "127.0.0.1", 4, 0, &protocol);
    assert(ntp);
    unsigned char key[16];
    for (int i = 0; i < 16; i++) key[i] = i;
    uint64_t stream_id = 123456789;
    raop_rtp_mirror_t *mirror = raop_rtp_mirror_init(logger, &cb, ntp, "127.0.0.1", 4, key);
    assert(mirror);
    raop_rtp_mirror_init_aes(mirror, &stream_id);
    unsigned short port = 0;
    raop_rtp_mirror_start(mirror, &port, 0);
    assert(port);
    int fd = socket(AF_INET, SOCK_STREAM, 0);
    struct sockaddr_in address = {.sin_family = AF_INET, .sin_port = htons(port),
                                  .sin_addr.s_addr = htonl(INADDR_LOOPBACK)};
    assert(fd >= 0 && !connect(fd, (struct sockaddr *)&address, sizeof(address)));
    const size_t fragments[] = {1, 7, 113, 4093};
    size_t pos = 0, index = 0;
    while (pos < (size_t)length) {
        size_t n = fragments[index++ % 4];
        if (n > (size_t)length - pos) n = length - pos;
        ssize_t sent = send(fd, wire + pos, n, 0);
        assert(sent > 0);
        pos += sent;
        if (index < 8) usleep(2000); /* force partial initial header reads */
    }
    free(wire);
    uint64_t expected = strtoull(argv[2], NULL, 10), received = 0;
    double until = monotime() + 5;
    while (monotime() < until) {
        pthread_mutex_lock(&c.lock);
        received = c.packets;
        pthread_mutex_unlock(&c.lock);
        if (received >= expected) break;
        usleep(10000);
    }
    raop_rtp_mirror_destroy(mirror);
    close(fd);
    raop_ntp_destroy(ntp);
    logger_destroy(logger);
    assert(!fclose(c.video)); assert(!fclose(c.events));
    pthread_mutex_destroy(&c.lock);
    printf("Transport captured %" PRIu64 " packets, %" PRIu64 " bytes\n", received, c.bytes);
    assert(!c.failed && received == expected);
    return 0;
}
