/* RV32 tests use stock crypto/DNS; the final car callback is a recording stub. */
#define SMARTBOX_BRIDGE_TEST
#include "device_bridge.c"
#undef NDEBUG
#include <assert.h>
static int configs, frames, starts, controls;
static unsigned char last_frame[128];
static int last_length;
unsigned char CFStringGetCString(const void *s, char *out, int n, unsigned encoding) {
    (void)encoding; return snprintf(out, n, "%s", (const char *)s) < n;
}
static int record_control(void *s, unsigned f, const void *c, const void *q, const void *p, void *o) {
    (void)s; (void)f; (void)c; (void)q; (void)p; (void)o; controls++; return 0;
}
static int record_start(void *s) { (void)s; starts++; return 0; }
static void record_frame(int event, void *buffer, int length, bool config) {
    assert(event == 2 && length >= 5 && length < (int)sizeof(last_frame));
    memcpy(last_frame, buffer, length); last_length = length;
    if (config) { assert((last_frame[4] & 31) == 7); configs++; }
    else { assert((last_frame[4] & 31) == 1 || (last_frame[4] & 31) == 5); frames++; }
}
static void feed(const unsigned char *p, size_t n) {
    video_decode_struct data = {.data = (unsigned char *)p, .data_len = (int)n};
    device_video(NULL, NULL, &data);
}
int main(void) {
    stock_control = record_control; stock_start = record_start; stock_video = record_frame;
    assert(command("probe mirroring\n") == 0);
    assert(command("start mirroring\n") != 0);
    assert(AirPlayReceiverServerControl((void *)1, 1, "startServer", NULL, NULL, NULL) == 0);
    assert(CarPlayControlClientStart((void *)2) == 0 && controls == 1 && starts == 1);
    mirror_selected = true; native_ready = false;
    assert(AirPlayReceiverServerControl((void *)1, 1, "startServer", NULL, NULL, NULL) == 0 && controls == 1);
    const unsigned char packet[] = {0,0,1,0x67,0x42,0,30, 0,0,0,1,0x68,0xee, 0,0,1,0x06,0x11, 0,0,1,0x65,0x99};
    feed(packet, sizeof(packet)); assert(configs == 0 && frames == 0);
    assert(CarPlayControlClientStart((void *)2) == 0 && starts == 1);
    feed(packet, sizeof(packet)); assert(configs == 1 && frames == 1);
    assert(last_length == 6 && !memcmp(last_frame, "\0\0\0\1\x65\x99", 6));
    feed(packet, sizeof(packet)); assert(configs == 1 && frames == 2);
    const unsigned char predicted[] = {0,0,0,1,0x41,0x55};
    feed(predicted, sizeof(predicted)); assert(frames == 3);
    device_disconnect(NULL); feed(predicted, sizeof(predicted)); assert(frames == 3);
    const unsigned char config[] = {0,0,1,0x67,0x42,0,31, 0,0,1,0x68,0xee};
    feed(config, sizeof(config)); assert(configs == 2 && frames == 3);
    feed(predicted, sizeof(predicted)); assert(frames == 3);
    const unsigned char idr[] = {0,0,1,0x65,0x66};
    feed(idr, sizeof(idr)); assert(frames == 4);
    const unsigned char bad[] = {0,0,1,0x65,1,0,0,1};
    feed(bad, sizeof(bad)); assert(frames == 4);
    device_pin(NULL, "1234"); assert(!strcmp(pairing_pin, "1234"));
    device_pin(NULL, "x\"\n!"); assert(!strcmp(pairing_pin, "1234"));
    assert(command("stop mirroring\n") == 0);
    assert(command("start carplay\n") == 0 && !mirror_selected && controls == 2 && starts == 2);
    assert(command("start carplay\n") == 0 && controls == 2 && starts == 2);
    assert(command("bogus\n") != 0);
    puts("PASS: mode hooks, fallback, Annex B normalization, config/IDR gating, malformed input, PIN sanitization");
    return 0;
}
