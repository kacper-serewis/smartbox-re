#include "IAP2AuthProbe.h"
#include <cassert>
using namespace iap2probe;

static Bytes emptyMessage(unsigned id) {
    return {0x40, 0x40, 0, 6, uint8_t(id >> 8), uint8_t(id)};
}
static AuthProbe fresh(unsigned &signCalls) {
    return AuthProbe(0xfe, Bytes(800, 0x42), [&signCalls](const Bytes &challenge) {
        assert(challenge.size() == 20); ++signCalls; return Bytes(256, 0x77);
    });
}
int main() {
    auto request = packet(0xff, 0, emptyMessage(0xaa00));
    for (size_t split = 0; split <= request.size(); ++split) {
        unsigned calls = 0; auto probe = fresh(calls); std::vector<Bytes> out;
        assert(probe.feed(request.data(), split, out));
        assert(probe.feed(request.data() + split, request.size() - split, out));
        assert(probe.certificateReplies == 1 && out.size() == 2);
        assert(be16(out[1].data() + 13) == 0xaa01);
        assert(checksumValid(out[1].data(), 9));
        assert(checksumValid(out[1].data() + 9, out[1].size() - 9));
        out.clear(); assert(probe.feed(request.data(), request.size(), out));
        assert(probe.certificateReplies == 1 && out.size() == 2); // duplicate replays, no new sequence
        auto challenge = packet(0, 1, message(0xaa02, Bytes(20, 0x12)));
        out.clear(); assert(probe.feed(challenge.data(), challenge.size(), out));
        assert(calls == 1 && probe.challengeReplies == 1 && out.size() == 2);
        auto success = packet(1, 2, emptyMessage(0xaa05));
        auto identify = packet(2, 2, emptyMessage(0x1d00));
        success.insert(success.end(), identify.begin(), identify.end());
        out.clear(); assert(probe.feed(success.data(), success.size(), out));
        assert(probe.done() && out.size() == 2);
    }
    for (size_t i = 0; i < request.size(); ++i) {
        unsigned calls = 0; auto probe = fresh(calls); std::vector<Bytes> out;
        auto corrupt = request; corrupt[i] ^= 1;
        assert(!probe.feed(corrupt.data(), corrupt.size(), out));
        assert(calls == 0 && out.empty());
    }
    {
        unsigned calls = 0; auto probe = fresh(calls); std::vector<Bytes> out;
        auto bad = packet(0xff, 0, emptyMessage(0xaa05));
        assert(!probe.feed(bad.data(), bad.size(), out) && !probe.authenticated);
    }
    {
        unsigned calls = 0; auto probe = fresh(calls); std::vector<Bytes> out;
        auto bad = packet(1, 0, emptyMessage(0xaa00));
        assert(!probe.feed(bad.data(), bad.size(), out));
    }
    {
        unsigned calls = 0; auto probe = fresh(calls); std::vector<Bytes> out;
        assert(probe.feed(request.data(), request.size(), out)); out.clear();
        auto bad = packet(0, 1, message(0xaa02, Bytes(32, 0x12)));
        assert(!probe.feed(bad.data(), bad.size(), out) && calls == 0);
    }
}
