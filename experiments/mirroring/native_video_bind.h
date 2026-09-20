/* Internal addresses are valid only for these complete v131 executable hashes.
 * The density variants change a separate display-description getter. */
#ifndef SMARTBOX_NATIVE_VIDEO_BIND_H
#define SMARTBOX_NATIVE_VIDEO_BIND_H
#include <openssl/sha.h>
#include "native_video.h"
static native_video_t native_output;
static void (*native_post)(void *, unsigned, void *, int, long long);
static void (*native_active)(int);
static void native_started(void *app) { native_post(app, 1233, NULL, 0, 0); native_active(1); }
static bool native_bind(void *video_callback) {
#if defined(__riscv) && __riscv_xlen == 32
    const char *allowed[] = {
        "a147d1b4fd2f73ed5a70b76c45cc5e5ca1aeaa8b1544d4aabc99b7a6618ecc84",
        "12d009c2cda3e326eb6bc7488d9df42147858deb9b20d801e43254ccbc47a731",
        "7a5ecd0c883e43deeee68e11e7e5ba6a2b351dcf5e18488fa260587410179756",
        "ea5a4f6dddb80a8bf8368ca94babbb2aadd9ad618ed494872aea5fd1e33934eb"
    };
    Dl_info info;
    if ((uintptr_t)video_callback != 0x360f0 || !dladdr(video_callback, &info) ||
        (uintptr_t)info.dli_fbase != 0x10000) return false;
    FILE *f = fopen("/proc/self/exe", "rb"); if (!f) return false;
    SHA256_CTX ctx; unsigned char bytes[8192], digest[32]; size_t n, total = 0;
    SHA256_Init(&ctx);
    while ((n = fread(bytes, 1, sizeof(bytes), f))) {
        total += n; if (total > 4 * 1024 * 1024) { fclose(f); return false; }
        SHA256_Update(&ctx, bytes, n);
    }
    bool failed = ferror(f); fclose(f); if (failed) return false;
    SHA256_Final(digest, &ctx);
    char hex[65]; for (int i = 0; i < 32; i++) snprintf(hex + i*2, 3, "%02x", digest[i]);
    bool valid = false;
    for (size_t i = 0; i < sizeof(allowed)/sizeof(*allowed); i++) valid |= !strcmp(hex, allowed[i]);
    if (!valid) return false;
    native_output.lock = (void (*)(void *))dlsym(RTLD_DEFAULT, "_ZN6MMutex4lockEv");
    native_output.unlock = (void (*)(void *))dlsym(RTLD_DEFAULT, "_ZN6MMutex6unlockEv");
    if (!native_output.lock || !native_output.unlock) return false;
    native_output.app = (void *(*)(void))(uintptr_t)0x32eb8;
    native_output.config = (int (*)(void *, int, int, int, int, int, int, int))(uintptr_t)0x4eca8;
    native_output.frame = (int (*)(void *, int))(uintptr_t)0x4ee7c;
    native_output.ticks = (uint64_t (*)(void))(uintptr_t)0x32748;
    native_post = (void (*)(void *, unsigned, void *, int, long long))(uintptr_t)0x1fca0;
    native_active = (void (*)(int))(uintptr_t)0x4c850;
    native_output.started = native_started;
    return true;
#else
    (void)video_callback; return false;
#endif
}
#endif
