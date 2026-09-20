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
    {
        AuthProbe probe(0xfe, Bytes(800, 0x42), [](const Bytes &) { return Bytes(256, 0x77); }, true);
        std::vector<Bytes> out;
        for (const auto &f : {request, packet(0, 1, message(0xaa02, Bytes(20, 0x12))),
                             packet(1, 2, emptyMessage(0xaa05)), packet(2, 2, emptyMessage(0x1d00))}) {
            out.clear(); assert(probe.feed(f.data(), f.size(), out));
        }
        assert(!probe.done() && out.size() == 2);
        const auto &f = out.back(); assert(f[5] == 3 && be16(f.data() + 13) == 0x1d01);
        auto id = identification(); assert(be16(id.data() + 2) == id.size());
        size_t pos = 6; bool usb = false;
        while (pos < id.size()) {
            unsigned n = be16(id.data() + pos), tag = be16(id.data() + pos + 2);
            assert(n >= 4 && pos + n <= id.size());
            if (tag == 16) usb = true;
            pos += n;
        }
        assert(pos == id.size() && usb);
        auto accepted = packet(3, 3, emptyMessage(0x1d02));
        out.clear(); assert(probe.feed(accepted.data(), accepted.size(), out)); assert(probe.done());
        auto available = packet(4, 3, {0x40,0x40,0,10,0x43,0,0,4,0,1});
        out.clear(); assert(probe.feed(available.data(), available.size(), out)); assert(probe.availabilityReceived);
        auto start = probe.startSession("fe80::1234", 51234);
        assert(start[5] == 4 && start[6] == 4 && be16(start.data() + 13) == 0x4301);
        assert(checksumValid(start.data(), 9) && checksumValid(start.data() + 9, start.size() - 9));
        assert(be16(start.data() + 17) == 0 && be16(start.data() + 21) == 0);
        assert(start[23] == 'f' && start[24] == 'e'); // nested list item begins at offset 23
        Bytes timeBody; parameter(timeBody, 0, Bytes(8, 0)); parameter(timeBody, 1, {0,120}); parameter(timeBody, 2, {60});
        Bytes timeMessage = {0x40,0x40,0,29,0x4e,0x0b};
        timeMessage.insert(timeMessage.end(), timeBody.begin(), timeBody.end());
        auto update = packet(5, 4, timeMessage);
        out.clear(); assert(probe.feed(update.data(), update.size(), out)); assert(out.size() == 1);
        timeMessage.back() = 0; timeMessage[timeMessage.size()-3] = 3; // unknown parameter tag
        auto badUpdate = packet(6, 4, timeMessage);
        out.clear(); assert(!probe.feed(badUpdate.data(), badUpdate.size(), out));
    }
}
