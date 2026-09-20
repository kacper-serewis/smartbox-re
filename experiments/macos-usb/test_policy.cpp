#include "ProbePolicy.h"
#include <cassert>
#include <cstdio>
#include <initializer_list>
int main() {
    using P = ProbePolicy;
    for (bool ready : {false, true}) {
        P p;
        assert(p.request(false, true, ready, 1) == P::Denied);
        assert(p.request(true, false, ready, 1) == P::BadCommand);
        assert(p.request(true, true, ready, 0) == P::BadCommand);
        assert(!p.lastID && !p.pending);
    }
    P p;
    assert(p.request(true, true, false, 1) == P::NotReady);
    assert(p.request(true, true, true, 1) == P::Allow);
    assert(p.request(true, true, true, 2) == P::Busy);
    assert(!p.begin(false)); // Port became active before the worker ran.
    assert(!p.begin(true)); // No delayed or repeated operation after rejection.
    assert(p.request(true, true, true, 1) == P::Stale);
    assert(p.request(true, true, true, 2) == P::Allow);
    assert(p.begin(true));
    assert(p.request(true, true, true, 3) == P::Busy);
    p.finish();
    assert(p.request(true, true, true, 3) == P::Allow);
    p.finish(); // Scheduling failure releases the slot, but consumes the ID.
    assert(p.request(true, true, true, 3) == P::Stale);
    assert(p.request(true, true, true, 4) == P::Allow);
    p.stop();
    assert(!p.begin(true));
    assert(p.request(true, true, true, 5) == P::NotReady);
    puts("PASS: root/command guards, busy/replay rejection, repeated requests, port changes, stop cancellation");
}
