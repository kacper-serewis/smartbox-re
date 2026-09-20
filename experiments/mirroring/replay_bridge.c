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
int main(int argc, char **argv) {
    if (argc != 4) return 2;
    FILE *input = fopen(argv[1], "rb");
    output = fopen(argv[2], "wb"); events = fopen(argv[3], "w");
    if (!input || !output || !events) return 1;
    stock_video = record; mirror_selected = native_ready = true;
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
