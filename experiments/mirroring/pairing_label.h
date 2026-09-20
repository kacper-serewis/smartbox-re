/* LVGL text hooks for the SHA-checked application. All label operations remain
 * on the vendor UI thread. No retained label is dereferenced before validation.
 */
#ifndef SMARTBOX_PAIRING_LABEL_H
#define SMARTBOX_PAIRING_LABEL_H
#include <stdint.h>
#include <stdbool.h>
#include <stdio.h>
#include <string.h>
#include <dlfcn.h>
static const char *pairing_mode_name(void);
static void (*pairing_set_text)(void *, const char *);
static uint32_t (*pairing_timer)(void);
static bool (*pairing_valid)(const void *);
static bool (*pairing_type)(const void *, const void *);
static char *(*pairing_get_text)(const void *);
static const void *pairing_label_class;
static struct { void *object; char original[64], rendered[112]; } pairing_labels[4];
static void pairing_resolve(void) {
    if (!pairing_set_text) pairing_set_text = dlsym(RTLD_NEXT, "lv_label_set_text");
    if (!pairing_timer) pairing_timer = dlsym(RTLD_NEXT, "lv_timer_handler");
    if (!pairing_valid) pairing_valid = dlsym(RTLD_NEXT, "lv_obj_is_valid");
    if (!pairing_type) pairing_type = dlsym(RTLD_NEXT, "lv_obj_check_type");
    if (!pairing_get_text) pairing_get_text = dlsym(RTLD_NEXT, "lv_label_get_text");
    if (!pairing_label_class) pairing_label_class = dlsym(RTLD_NEXT, "lv_label_class");
}
static bool pairing_available(void) {
    return native_bound && pairing_set_text && pairing_valid && pairing_type && pairing_get_text && pairing_label_class;
}
void lv_label_set_text(void *object, const char *text) {
    pairing_resolve();
    if (!pairing_set_text) return;
    /* NULL asks LVGL to refresh its current text. Preserve that behavior. */
    if (!pairing_available() || !object || !text || strncmp(text, "SW_Ver : ", 9) ||
        strnlen(text, sizeof(pairing_labels[0].original)) >= sizeof(pairing_labels[0].original)) {
        pairing_set_text(object, text); return;
    }
    unsigned slot;
    for (slot=0; slot<4; slot++) {
        if (pairing_labels[slot].object == object || !pairing_labels[slot].object ||
            !pairing_valid(pairing_labels[slot].object)) break;
    }
    if (slot==4) { pairing_set_text(object, text); return; }
    pairing_labels[slot].object = object;
    snprintf(pairing_labels[slot].original, sizeof(pairing_labels[slot].original), "%s", text);
    snprintf(pairing_labels[slot].rendered, sizeof(pairing_labels[slot].rendered), "Mode: %s\n%s",
             pairing_mode_name(), text);
    pairing_set_text(object, pairing_labels[slot].rendered);
}
uint32_t lv_timer_handler(void) {
    pairing_resolve();
    if (pairing_available()) for (unsigned i=0; i<4; i++) {
        void *object = pairing_labels[i].object;
        if (!object) continue;
        if (!pairing_valid(object) || !pairing_type(object, pairing_label_class)) {
            pairing_labels[i].object = NULL; continue;
        }
        const char *current = pairing_get_text(object);
        if (!current || strcmp(current, pairing_labels[i].rendered)) {
            pairing_labels[i].object = NULL; continue;
        }
        char updated[112];
        snprintf(updated, sizeof(updated), "Mode: %s\n%s", pairing_mode_name(), pairing_labels[i].original);
        if (strcmp(updated, current)) {
            memcpy(pairing_labels[i].rendered, updated, strlen(updated)+1);
            pairing_set_text(object, updated);
        }
    }
    return pairing_timer ? pairing_timer() : 1;
}
#endif
