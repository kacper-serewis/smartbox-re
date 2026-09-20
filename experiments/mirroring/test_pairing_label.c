#include <assert.h>
#include <stdbool.h>
#include <string.h>
static bool native_bound=true, mirror=false;
#include "pairing_label.h"
static const char *pairing_mode_name(void) { return mirror?"Screen Mirroring":"CarPlay"; }
typedef struct { bool valid, label; char text[256]; } label_t;
static unsigned writes;
static void set_text(void *obj, const char *s) { if(s)snprintf(((label_t *)obj)->text,256,"%s",s);writes++; }
static bool valid(const void *obj) { return ((const label_t *)obj)->valid; }
static bool type(const void *obj,const void *klass) { (void)klass;assert(valid(obj));return ((const label_t *)obj)->label; }
static char *get_text(const void *obj) { assert(valid(obj)&&type(obj,NULL));return (char *)((const label_t *)obj)->text; }
static uint32_t timer(void) { return 42; }
int main(void) {
    pairing_set_text=set_text;pairing_valid=valid;pairing_type=type;pairing_get_text=get_text;pairing_timer=timer;pairing_label_class=(void *)1;
    label_t a={.valid=true,.label=true},b={.valid=true,.label=true};
    lv_label_set_text(&a,"SW_Ver : 2026081801");
    assert(!strcmp(a.text,"Mode: CarPlay\nSW_Ver : 2026081801"));
    mirror=true;assert(lv_timer_handler()==42);
    assert(!strcmp(a.text,"Mode: Screen Mirroring\nSW_Ver : 2026081801"));
    unsigned before=writes;lv_timer_handler();assert(before==writes);
    mirror=false;lv_timer_handler();assert(strstr(a.text,"Mode: CarPlay"));
    lv_label_set_text(&b,"Please connect Bluetooth: smartBox-9302");
    assert(!strcmp(b.text,"Please connect Bluetooth: smartBox-9302"));
    a.valid=false;mirror=true;lv_timer_handler(); /* deletion: no text access */
    a.valid=true;lv_label_set_text(&a,"SW_Ver : 2026081801");
    a.label=false;lv_timer_handler(); /* reused allocation, different class */
    a.label=true;lv_label_set_text(&a,"SW_Ver : 2026081801");
    set_text(&a,"Unrelated new label");mirror=false;lv_timer_handler();
    assert(!strcmp(a.text,"Unrelated new label"));
    lv_label_set_text(&a,NULL);assert(!strcmp(a.text,"Unrelated new label"));
    char oversized[100];memset(oversized,'x',sizeof(oversized)-1);oversized[sizeof(oversized)-1]=0;
    memcpy(oversized,"SW_Ver : ",9);lv_label_set_text(&b,oversized);assert(!strcmp(b.text,oversized));
    native_bound=false;lv_label_set_text(&a,"SW_Ver : 2026081801");
    assert(!strcmp(a.text,"SW_Ver : 2026081801"));
    puts("PASS: mode label, runtime fallback, unrelated text, deletion, reuse, and disabled hook");
}
