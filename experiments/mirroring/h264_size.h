/* Bounded SPS geometry reader for progressive 8-bit 4:2:0 AVC.
 * Does not modify encoded data; unsupported formats fail closed. */
#ifndef SMARTBOX_H264_SIZE_H
#define SMARTBOX_H264_SIZE_H
#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
typedef struct { const unsigned char *p; size_t bits, pos; bool bad; } sps_bits;
static uint32_t sps_read(sps_bits *b, unsigned count) {
    if (count > 32 || b->pos + count > b->bits) { b->bad = true; return 0; }
    uint32_t value = 0;
    while (count--) { value = (value << 1) | ((b->p[b->pos / 8] >> (7 - b->pos % 8)) & 1); b->pos++; }
    return value;
}
static uint32_t sps_ue(sps_bits *b) {
    unsigned zeros = 0;
    while (!b->bad && !sps_read(b, 1)) if (++zeros > 30) { b->bad = true; return 0; }
    return b->bad ? 0 : ((1u << zeros) - 1 + sps_read(b, zeros));
}
static int32_t sps_se(sps_bits *b) {
    uint32_t x = sps_ue(b); return (x & 1) ? (int32_t)((x + 1) / 2) : -(int32_t)(x / 2);
}
static bool h264_size(const unsigned char *nal, size_t length, unsigned *w, unsigned *h) {
    unsigned char rbsp[4096]; size_t used = 0; unsigned zeros = 0;
    if (length < 5 || length > sizeof(rbsp) || nal[0] & 0x80 || (nal[0] & 31) != 7) return false;
    for (size_t i = 1; i < length; i++) {
        unsigned v = nal[i];
        if (zeros >= 2 && v == 3) {
            if (i + 1 == length || nal[i + 1] > 3) return false;
            zeros = 0; continue;
        }
        rbsp[used++] = v; zeros = v ? 0 : zeros + 1;
    }
    sps_bits b = {rbsp, used * 8, 0, false};
    unsigned profile = sps_read(&b, 8); sps_read(&b, 8); sps_read(&b, 8);
    if (sps_ue(&b) > 31) return false;
    if (profile == 100) {
        if (sps_ue(&b) != 1 || sps_ue(&b) != 0 || sps_ue(&b) != 0) return false;
        sps_read(&b, 1);
        if (sps_read(&b, 1)) {
            for (unsigned i = 0; i < 8; i++) if (sps_read(&b, 1)) {
                int last = 8, next = 8;
                for (unsigned j = 0; j < (i < 6 ? 16u : 64u); j++) {
                    if (next) { int delta = sps_se(&b); if (delta < -128 || delta > 127) return false; next = (last + delta + 256) % 256; }
                    last = next ? next : last;
                }
            }
        }
    } else if (profile != 66 && profile != 77 && profile != 88) return false;
    if (sps_ue(&b) > 12) return false;
    unsigned order = sps_ue(&b);
    if (order == 0) { if (sps_ue(&b) > 12) return false; }
    else if (order == 1) {
        sps_read(&b, 1); sps_se(&b); sps_se(&b);
        unsigned cycle = sps_ue(&b); if (cycle > 255) return false;
        while (cycle--) sps_se(&b);
    } else if (order != 2) return false;
    if (sps_ue(&b) > 16) return false;
    sps_read(&b, 1);
    unsigned wm = sps_ue(&b), hm = sps_ue(&b);
    if (wm >= 120 || hm >= 68 || sps_read(&b, 1) != 1) return false;
    sps_read(&b, 1);
    uint32_t crop[4] = {0};
    if (sps_read(&b, 1)) for (int i = 0; i < 4; i++) { crop[i] = sps_ue(&b); if (crop[i] > 2048) return false; }
    unsigned width = (wm + 1) * 16, height = (hm + 1) * 16;
    unsigned cx = 2 * (crop[0] + crop[1]), cy = 2 * (crop[2] + crop[3]);
    if (b.bad || cx >= width || cy >= height || width - cx > 1920 || height - cy > 1080) return false;
    *w = width - cx; *h = height - cy; return true;
}
#endif
