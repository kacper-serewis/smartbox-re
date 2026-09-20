/* Execute SHA-pinned stock RV32 video routines under Andes QEMU with modeled
 * transport, locking and lifecycle dependencies. No hardware or full app boot. */
#define _GNU_SOURCE
#include <assert.h>
#include <elf.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <unistd.h>
#include "native_video.h"
#include "h264_size.h"
#define BASE 0x10000000u
#define GP (BASE + 0x12fb40u)
static unsigned char *mapped;
static unsigned char original_config[8], original_frame[8];
static unsigned char app[0x3000], payload[64], old_config[16];
static int configs, frames, closes, posts, locked, config_error, frame_error;
static int geometry[6];
static void set32(unsigned offset, uint32_t value) { memcpy(app + offset, &value, 4); }
static int noop(void) { return 0; }
static int lock(void *p) { assert(p == app + 0x20e8 && !locked); locked = 1; return 0; }
static int unlock(void *p) { assert(p == app + 0x20e8 && locked); locked = 0; return 0; }
static void *singleton(void) { return app; }
static uint64_t ticks(void) { return 1234; }
static int opened(void) { return 1; }
static void *encoder_config(void *p, int *n) { (void)p; *n = sizeof(old_config); return old_config; }
static int close_video(int a, int b) { (void)a; (void)b; closes++; return 0; }
static int post(void *p, unsigned event) { assert(p == app && event == 1233); posts++; return 0; }
static int config(void *p, int n, int w, int h, int x, int y, int vw, int vh) {
    assert(locked && p == payload && n > 4);
    configs++; geometry[0]=w; geometry[1]=h; geometry[2]=x; geometry[3]=y; geometry[4]=vw; geometry[5]=vh;
    return config_error;
}
static int frame(void *p, int n) { assert(locked && p == payload && n > 4); frames++; return frame_error; }
/* Stock code's PC-relative addressing works at BASE; preserve our caller's gp.
 * Test helpers compile without gp-relative relaxation. */
extern void invoke(uintptr_t fn, void *a, void *b, int c, int d, int e);
__asm__(".text\n.align 2\n.global invoke\ninvoke:\n"
        "addi sp,sp,-16\nsw ra,12(sp)\nsw gp,8(sp)\n"
        "mv t0,a0\nmv a0,a1\nmv a1,a2\nmv a2,a3\nmv a3,a4\nmv a4,a5\n"
        "li gp,0x1012fb40\njalr t0\nlw gp,8(sp)\nlw ra,12(sp)\naddi sp,sp,16\nret\n");
static void hook(uint32_t address, void *target) {
    uintptr_t t = (uintptr_t)target;
    uint32_t hi = (t + 0x800) >> 12, lo = t - (hi << 12);
    uint32_t code[] = {(hi << 12) | (5 << 7) | 0x37,
                     ((lo & 4095) << 20) | (5 << 15) | 0x67};
    memcpy(mapped + address, code, sizeof(code));
}
static void load(const char *path) {
    FILE *f = fopen(path, "rb"); assert(f);
    Elf32_Ehdr h; assert(fread(&h, 1, sizeof(h), f) == sizeof(h));
    assert(!memcmp(h.e_ident, ELFMAG, 4) && h.e_machine == EM_RISCV && h.e_type == ET_EXEC);
    mapped = mmap((void *)BASE, 0x200000, PROT_READ|PROT_WRITE|PROT_EXEC,
                MAP_PRIVATE|MAP_ANONYMOUS|MAP_FIXED_NOREPLACE, -1, 0);
    assert(mapped == (void *)BASE);
    for (unsigned i = 0; i < h.e_phnum; i++) {
        Elf32_Phdr p; assert(!fseek(f, h.e_phoff+i*h.e_phentsize, SEEK_SET));
        assert(fread(&p, 1, sizeof(p), f) == sizeof(p));
        if (p.p_type != PT_LOAD) continue;
        assert(p.p_vaddr + p.p_memsz <= 0x200000);
        assert(!fseek(f, p.p_offset, SEEK_SET));
        assert(fread(mapped+p.p_vaddr, 1, p.p_filesz, f) == p.p_filesz);
    }
    fclose(f);
    hook(0x21370, lock); hook(0x1fc00, unlock); hook(0x32748, ticks);
    hook(0x32eb8, singleton); hook(0x1fca0, post); hook(0x4c850, noop);
    hook(0x4e788, opened); hook(0x50e20, encoder_config); hook(0x4e110, noop);
    hook(0x4ec38, close_video); hook(0x21d00, noop);
    memcpy(original_config, mapped+0x4eca8, 8); memcpy(original_frame, mapped+0x4ee7c, 8);
    hook(0x4eca8, config); hook(0x4ee7c, frame);
    *(uint32_t *)(mapped+0x12f24c) = BASE+0x180000; /* modeled relocated gAirPlayModeState */
    __builtin___clear_cache(mapped, mapped+0x200000);
}
static void reset(void) {
    memset(app, 0, sizeof(app)); memset(payload, 0, sizeof(payload));
    configs = frames = closes = posts = locked = config_error = frame_error = 0;
    app[0x216e] = 1; set32(0x2444, 1);
    set32(0x218c, 800); set32(0x2190, 480); set32(0x2184, 800); set32(0x2188, 480);
    *(uint32_t *)(mapped+0x12fb40+0x2b8+0x4dc) = 0;
    *(unsigned char *)(mapped+0x12fb40+0x2b8+0x4d8) = 1; /* already logged SPS */
}
static void incoming(int type, int is_config) {
    payload[4] = type;
    invoke(BASE+0x35eb0, app, payload, sizeof(payload), is_config, 0);
    assert(!locked);
}
static void common(int type, int ui) {
    payload[4] = type;
    invoke(BASE+0x35a58, app, payload, sizeof(payload), type, ui);
    assert(!locked);
}
extern int invoke8(uintptr_t fn, void *p, int len, int w, int h, int x, int y, int vw, int vh);
__asm__(".text\n.align 2\n.global invoke8\ninvoke8:\n"
        "addi sp,sp,-16\nsw ra,12(sp)\nsw gp,8(sp)\n"
        "mv t0,a0\nmv a0,a1\nmv a1,a2\nmv a2,a3\nmv a3,a4\nmv a4,a5\n"
        "mv a5,a6\nmv a6,a7\nlw a7,16(sp)\n"
        "li gp,0x1012fb40\njalr t0\nlw gp,8(sp)\nlw ra,12(sp)\naddi sp,sp,16\nret\n");
static unsigned char wire[2*1024*1024];
static int wire_size;
static void *wire_buffer(int size) { assert(size > 0 && size <= (int)sizeof(wire)); return wire; }
static int wire_send(int fd, const void *buffer, int size) {
    assert(fd == 9 && buffer == wire && size > 128 && size <= (int)sizeof(wire)); wire_size=size; return size;
}
static int aes_copy(void *ctx, const void *src, int size, void *dst) {
    (void)ctx; assert(size > 0); memmove(dst, src, size); return 0;
}
static void check_wire(void) {
    /* Keep the actual header builder, Annex-B/AVCC converter and frame envelope.
     * Model allocation, network writes, mutexes and AES as an identity transform. */
    memcpy(mapped+0x4eca8, original_config, 8); memcpy(mapped+0x4ee7c, original_frame, 8);
    hook(0x4e73c, wire_buffer); hook(0x2ce48, wire_send); hook(0x21640, aes_copy);
    hook(0x1fee0, noop); hook(0x20500, noop); hook(0x22010, memset); hook(0x222a0, memcpy);
    *(uint32_t *)(mapped+0x12e108) = 9;
    *(uint32_t *)(mapped+0x12eff4) = BASE+0x180100;
    __builtin___clear_cache(mapped, mapped+0x200000);
    unsigned char cfg[] = {0,0,0,1,0x27,0x64,0,0x1f,0xac,0x13,0x14,0x50,0x32,0x0f,0x69,0xb8,0x08,0x68,0x30,0x36,0x82,0x21,0x19,0x60,0,0,0,1,0x28,0xee,0x3c,0xb0};
    assert(!invoke8(BASE+0x4eca8, cfg, sizeof(cfg), 800, 480, 0, 0, 800, 480));
    assert(wire_size > 128 && wire[4] == 1);
    float w,h,vw,vh; memcpy(&w,wire+16,4); memcpy(&h,wire+20,4); memcpy(&vw,wire+40,4); memcpy(&vh,wire+44,4);
    assert(w == 800 && h == 480 && vw == 800 && vh == 480);
    assert(wire[128] == 1 && wire[133] == 0xe1 && wire[134] == 0 && wire[135] == 20);
    assert(!memcmp(wire+136,cfg+4,20));
    unsigned char nal[] = {0,0,0,1,0x65,0xab,0xcd,0xef};
    invoke(BASE+0x4ee7c, nal, (void *)sizeof(nal), 0, 0, 0);
    assert(wire_size == 128+sizeof(nal) && wire[4] == 0);
    assert(!memcmp(wire+128,"\0\0\0\4",4) && !memcmp(wire+132,nal+4,4));
    puts("PASS: actual native wire routines build source/viewport headers, avcC and one-NAL AVCC frames (AES/network modeled)");
}
static void candidate_lock(void *p) { lock(p); }
static void candidate_unlock(void *p) { unlock(p); }
static void candidate_started(void *p) { post(p, 1233); }
static void check_candidate(void) {
    native_video_t n = {.app=singleton, .lock=candidate_lock, .unlock=candidate_unlock,
        .config=config, .frame=frame, .ticks=ticks, .started=candidate_started};
    reset(); app[0x216a]=1;
    assert(native_video_config(&n, payload, sizeof(payload), 332, 720));
    assert(configs == 1 && posts == 1 && app[0x216d]);
    assert(geometry[0] == 332 && geometry[1] == 720 && geometry[4] == 332 && geometry[5] == 720);
    assert(nv_word(app, 0x218c) == 800 && nv_word(app, 0x2190) == 480);
    common(1, 1); assert(!frames); /* Actual stock UI submission is suppressed. */
    assert(!native_video_frame(&n, payload, sizeof(payload), false));
    assert(!frames);
    assert(native_video_config(&n, payload, sizeof(payload), 332, 720));
    assert(native_video_frame(&n, payload, sizeof(payload), true));
    assert(native_video_frame(&n, payload, sizeof(payload), false));
    assert(native_video_config(&n, payload, sizeof(payload), 1564, 720));
    assert(geometry[0] == 1564 && geometry[1] == 720 && posts == 1);
    assert(native_video_frame(&n, payload, sizeof(payload), true));
    assert(!closes && !app[0x216c]);
    native_video_release(&n);
    assert(!app[0x216d] && !app[0x216a] && app[0x216c]);
    int before = configs; common(7, 1); common(5, 1);
    assert(configs == before + 1 && geometry[0] == 800 && geometry[1] == 480);
    puts("PASS: candidate claims source, sends actual geometry, gates keyframes/rotation, restores UI");
    reset(); app[0x216e]=0;
    assert(!native_video_config(&n, payload, sizeof(payload), 800, 480));
    assert(!configs && !n.owned);
    app[0x216e]=1; app[0x2172]=1;
    assert(!native_video_config(&n, payload, sizeof(payload), 800, 480));
    app[0x2172]=0; set32(0x2444, 2);
    assert(!native_video_config(&n, payload, sizeof(payload), 800, 480));
    set32(0x2444, 1); app[0x216d]=1;
    assert(!native_video_config(&n, payload, sizeof(payload), 800, 480));
    app[0x216d]=0; config_error=-1;
    assert(!native_video_config(&n, payload, sizeof(payload), 800, 480));
    assert(!app[0x216a] && !native_video_frame(&n, payload, sizeof(payload), true));
    config_error=0;
    assert(native_video_config(&n, payload, sizeof(payload), 800, 480));
    frame_error=-1;
    assert(!native_video_frame(&n, payload, sizeof(payload), true));
    assert(!app[0x216a] && app[0x216c]);
    frame_error=0;
    assert(native_video_config(&n, payload, sizeof(payload), 800, 480));
    app[0x216a]=0; /* Stock stream restarted after bridge's last configuration. */
    assert(!native_video_frame(&n, payload, sizeof(payload), true));
    native_video_release(&n);
    assert(!native_video_config(&n, payload, sizeof(payload), 1921, 720));
    assert(!native_video_config(&n, payload, sizeof(payload), 800, 0));
    puts("PASS: unavailable/restarting/foreign output and send failures do not advance configuration");
}
static void check_sps(void) {
    const unsigned char stock[] = {0x27,0x64,0,0x1f,0xac,0x13,0x14,0x50,0x32,0x0f,0x69,0xb8,0x08,0x68,0x30,0x36,0x82,0x21,0x19,0x60};
    unsigned w=0, h=0;
    assert(h264_size(stock, sizeof(stock), &w, &h) && w == 800 && h == 480);
    assert(!h264_size(stock, 4, &w, &h));
    unsigned char bad[64]; memset(bad, 0xff, sizeof(bad)); bad[0]=0x67;
    assert(!h264_size(bad, sizeof(bad), &w, &h));
    puts("PASS: bounded SPS parsing accepts captured stock geometry and rejects malformed input");
}
int main(int argc, char **argv) {
    assert(argc == 2 || argc == 3); setvbuf(stdout, NULL, _IONBF, 0); load(argv[1]);
    if (argc == 3) { assert(!strcmp(argv[2], "--wire")); check_wire(); return 0; }
    reset(); app[0x216a]=1; /* welcome screen configuration already sent */
    incoming(7, 1); incoming(5, 0);
    assert(configs == 0 && frames == 1 && app[0x216d] == 1);
    puts("REPRODUCED: incoming phone IDR forwarded using existing welcome-screen configuration");
    reset(); incoming(7, 1); incoming(5, 0);
    assert(configs == 1 && frames == 1);
    incoming(7, 1); incoming(5, 0);
    assert(configs == 1 && frames == 2);
    puts("REPRODUCED: subsequent phone configuration is not resent after rotation");
    reset(); *(uint32_t *)(mapped+0x12fb40+0x2b8+0x4dc)=1;
    incoming(7, 1);
    assert(closes == 1 && !configs && app[0x2172] && !app[0x216d]);
    puts("REPRODUCED: different SPS triggers asynchronous close without claiming phone source");
    reset(); common(7, 1); common(5, 1);
    assert(configs == 1 && frames == 1);
    assert(geometry[0] == 800 && geometry[1] == 480);
    app[0x216d]=1; common(1, 1); assert(frames == 1);
    puts("PASS: common transport forwards stored dimensions and suppresses UI while phone owns source");
    check_candidate(); check_sps();
    return 0;
}
