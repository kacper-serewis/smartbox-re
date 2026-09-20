/* Replay captured phone callbacks through the actual bridge, recording the
 * buffers submitted to the native app callback. Does not emulate the car. */
#define SMARTBOX_BRIDGE_TEST
#include "device_bridge.c"
#include <assert.h>
static FILE *output, *events;
static unsigned long long position;
static unsigned configs, pictures;
static void record(int event, void *buffer, int length, bool config) {
    assert(event == 2 && length > 0);
    assert(fwrite(buffer, 1, length, output) == (size_t)length);
    fprintf(events, "{\"event\":\"packet\",\"offset\":%llu,\"length\":%d,\"config\":%s}\n",
            position, length, config ? "true" : "false");
    position += length;
    if (config) configs++; else pictures++;
}
#ifdef SMARTBOX_NATIVE_TEST
static unsigned char native_app[0x3000];
static int native_locked;
static void *replay_app(void) { return native_app; }
static void replay_lock(void *p) { assert(p == native_app+0x20e8 && !native_locked); native_locked=1; }
static void replay_unlock(void *p) { assert(p == native_app+0x20e8 && native_locked); native_locked=0; }
static uint64_t replay_ticks(void) { return 1000; }
static int replay_config(void *p, int n, int w, int h, int x, int y, int vw, int vh) {
    assert(native_locked && x == 0 && y == 0 && w == vw && h == vh);
    unsigned parsed_w, parsed_h; size_t width;
    size_t end = start_code(p, n, 4, &width);
    assert(h264_size((unsigned char *)p+4, end-4, &parsed_w, &parsed_h));
    assert((unsigned)w == parsed_w && (unsigned)h == parsed_h);
    fprintf(events, "{\"event\":\"geometry\",\"width\":%d,\"height\":%d}\n", w, h);
    record(2,p,n,true); return 0;
}
static int replay_frame(void *p, int n) {
    size_t width; assert(native_locked && start_code(p,n,4,&width) == (size_t)n);
    record(2,p,n,false); return 0;
}
#endif
int main(int argc, char **argv) {
    if (argc != 4) return 2;
    FILE *input = fopen(argv[1], "rb");
    output = fopen(argv[2], "wb"); events = fopen(argv[3], "w");
    if (!input || !output || !events) return 1;
#ifdef SMARTBOX_NATIVE_TEST
    native_app[0x216e]=1; native_app[0x2444]=1;
    native_output = (native_video_t){.app=replay_app, .lock=replay_lock, .unlock=replay_unlock,
        .config=replay_config, .frame=replay_frame, .ticks=replay_ticks};
#endif
    native_bound = true; stock_video = record; mirror_selected = native_ready = true;
    unsigned char header[4];
    unsigned packets = 0;
    while (fread(header, 1, 4, input) == 4) {
        unsigned length = (unsigned)header[0]<<24 | (unsigned)header[1]<<16 | (unsigned)header[2]<<8 | header[3];
        assert(length >= 5 && length <= 1024*1024);
        unsigned char *data = malloc(length); assert(data);
        assert(fread(data, 1, length, input) == length);
        video_decode_struct packet = {.data = data, .data_len = (int)length};
        device_video(NULL, NULL, &packet);
        free(data); packets++;
    }
    assert(!ferror(input)); fclose(input); fclose(output); fclose(events);
    printf("{\"input_packets\":%u,\"configs\":%u,\"frames\":%u,\"bytes\":%llu}\n",
            packets, configs, pictures, position);
    return 0;
}
