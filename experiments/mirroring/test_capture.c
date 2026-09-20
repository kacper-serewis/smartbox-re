/* Exercise the real callback without starting a network service. */
#define main receiver_main
#include "receiver.c"
#undef main
#undef NDEBUG
#include <assert.h>

int main(void) {
    unsigned char nal[] = {0, 0, 0, 1, 0x65, 0x88, 0x84};
    video_decode_struct packet = {.data = nal, .data_len = sizeof(nal), .nal_count = 1};
    capture_t c = {.lock = PTHREAD_MUTEX_INITIALIZER, .video = tmpfile(), .events = tmpfile(),
                   .max_bytes = 2 * sizeof(nal), .duration = 30};
    assert(c.video && c.events);
    video(&c, NULL, &packet);
    video(&c, NULL, &packet);
    video(&c, NULL, &packet);
    assert(c.bytes == 2 * sizeof(nal) && c.packets == 2 && !strcmp(c.reason, "byte_limit"));
    rewind(c.video);
    unsigned char readback[sizeof(nal) * 2];
    assert(fread(readback, 1, sizeof(readback), c.video) == sizeof(readback));
    assert(!memcmp(readback, nal, sizeof(nal)) && !memcmp(readback + sizeof(nal), nal, sizeof(nal)));
    c.reason = NULL; c.max_bytes = 1024; c.first_video = monotime() - 31;
    video(&c, NULL, &packet);
    assert(c.packets == 2 && !strcmp(c.reason, "capture_complete"));
    c.reason = NULL; packet.is_h265 = true;
    video(&c, NULL, &packet);
    assert(c.failed && c.packets == 2 && !strcmp(c.reason, "invalid_video"));
    assert(!check_register(&c, "test-key"));
    register_client(&c, "id", "test-key", "name");
    assert(check_register(&c, "test-key") && !check_register(&c, "other-key"));
    free(c.registered_key);
    fclose(c.video); fclose(c.events); pthread_mutex_destroy(&c.lock);
    puts("Capture bytes, boundaries, limits, codec rejection, and pairing registry passed.");
    return 0;
}
