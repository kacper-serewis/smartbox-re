#include "ProbePolicy.h"
#include <cassert>
#include <cstdio>
#include <initializer_list>
int main() {
    using P = ProbePolicy;
    for (bool ready : {false, true}) {
        P p;
        assert(p.request(false, true, ready) == P::Denied);
        assert(!p.used && !p.pending);
        assert(p.request(true, false, ready) == P::BadCommand);
        assert(!p.used && !p.pending);
    }
    P p;
    assert(p.request(true, true, false) == P::NotReady);
    assert(!p.used);
    assert(p.request(true, true, true) == P::Allow);
    assert(p.request(true, true, true) == P::AlreadyUsed);
    assert(!p.begin(false)); // Port became active before the worker ran.
    assert(!p.begin(true)); // No delayed or repeated operation after rejection.
    assert(p.request(true, true, true) == P::AlreadyUsed);
    P q;
    assert(q.request(true, true, true) == P::Allow);
    q.stop();
    assert(!q.begin(true));
    assert(q.request(true, true, true) == P::NotReady);
    P r;
    assert(r.request(true, true, true) == P::Allow);
    assert(r.begin(true));
    assert(!r.begin(true));
    puts("PASS: unauthorized/malformed/inactive requests, single attempt, state change, stop cancellation");
}
