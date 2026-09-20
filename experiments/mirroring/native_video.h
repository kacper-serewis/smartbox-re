/* HW501 v131-only transport adapter. Bind only after checking the executable.
 * Caller serializes all operations with frame_lock. Stock mutex serializes UI
 * and transport state. Phone geometry is sent directly, never installed in the
 * welcome-screen encoder's object fields. */
#ifndef SMARTBOX_NATIVE_VIDEO_H
#define SMARTBOX_NATIVE_VIDEO_H
#include <stdbool.h>
#include <stdint.h>
#include <string.h>
typedef struct {
    void *(*app)(void);
    void (*lock)(void *), (*unlock)(void *);
    int (*config)(void *, int, int, int, int, int, int, int);
    int (*frame)(void *, int);
    uint64_t (*ticks)(void);
    void (*started)(void *);
    unsigned char *owned;
    bool configured, idr;
} native_video_t;
static uint32_t nv_word(unsigned char *app, size_t offset) {
    uint32_t value; memcpy(&value, app + offset, 4); return value;
}
static void nv_activity(native_video_t *n, unsigned char *app) {
    uint64_t ticks = n->ticks(); memcpy(app + 0x20c0, &ticks, sizeof(ticks));
}
static bool nv_ready(unsigned char *app) {
    /* 1 is the stock CarPlay output path; reject Android/unknown transports. */
    return app[0x216e] && !app[0x2172] && nv_word(app, 0x2444) == 1;
}
static bool native_video_config(native_video_t *n, void *data, int length, unsigned w, unsigned h) {
    if (!n->app || !w || !h || w > 1920 || h > 1080 || length < 5) return false;
    unsigned char *app = n->app(); if (!app) return false;
    n->lock(app + 0x20e8);
    n->configured = n->idr = false;
    if (!nv_ready(app) || (n->owned && n->owned != app)) { n->unlock(app + 0x20e8); return false; }
    bool claim = !n->owned;
    /* Do not take over an independently active stock phone session. */
    if (claim && app[0x216d]) { n->unlock(app + 0x20e8); return false; }
    n->owned = app; app[0x216d] = 1;
    app[0x216a] = 0; app[0x216c] = 1;
    /* Source-sized full viewport. No H.264 resizing or SPS rewriting. */
    int result = n->config(data, length, (int)w, (int)h, 0, 0, (int)w, (int)h);
    if (!result) { app[0x216a] = 1; n->configured = true; }
    nv_activity(n, app);
    n->unlock(app + 0x20e8);
    if (claim && n->started) n->started(app);
    return n->configured;
}
static bool native_video_frame(native_video_t *n, void *data, int length, bool idr) {
    unsigned char *app = n->owned;
    if (!app || !n->configured || length < 5) return false;
    n->lock(app + 0x20e8);
    if (!nv_ready(app) || !app[0x216d] || !app[0x216a] ||
        ((!n->idr || app[0x216c]) && !idr)) {
        n->configured = n->idr = false;
        n->unlock(app + 0x20e8); return false;
    }
    int result = n->frame(data, length);
    if (!result) { n->idr = true; app[0x216c] = 0; nv_activity(n, app); }
    else { n->configured = n->idr = false; app[0x216a] = 0; app[0x216c] = 1; }
    n->unlock(app + 0x20e8);
    return !result;
}
static void native_video_release(native_video_t *n) {
    unsigned char *app = n->owned;
    if (app) {
        n->lock(app + 0x20e8);
        app[0x216d] = 0; app[0x216a] = 0; app[0x216c] = 1;
        n->unlock(app + 0x20e8);
    }
    n->owned = NULL; n->configured = n->idr = false;
}
#endif
