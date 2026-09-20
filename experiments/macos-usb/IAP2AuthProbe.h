#pragma once
#include "IAP2Probe.h"
#include <functional>
#include <string>
#include <vector>

namespace iap2probe {
using Bytes = std::vector<uint8_t>;
inline unsigned be16(const uint8_t *p) { return (unsigned(p[0]) << 8) | p[1]; }
inline void append16(Bytes &v, unsigned n) { v.push_back(uint8_t(n >> 8)); v.push_back(uint8_t(n)); }
inline uint8_t checksum(const Bytes &v) {
    uint8_t sum = 0; for (auto b : v) sum += b; return uint8_t(-sum);
}
inline Bytes packet(uint8_t seq, uint8_t ack, const Bytes &payload = {}) {
    Bytes result{0xff, 0x5a}; append16(result, 9 + (payload.empty() ? 0 : payload.size() + 1));
    result.insert(result.end(), {0x40, seq, ack, uint8_t(payload.empty() ? 0 : 1)});
    result.push_back(checksum(result));
    if (!payload.empty()) {
        result.insert(result.end(), payload.begin(), payload.end()); result.push_back(checksum(payload));
    }
    return result;
}
inline Bytes message(unsigned id, const Bytes &value) {
    Bytes result{0x40, 0x40}; append16(result, 10 + value.size()); append16(result, id);
    append16(result, 4 + value.size()); append16(result, 0);
    result.insert(result.end(), value.begin(), value.end()); return result;
}
inline void parameter(Bytes &out, unsigned id, const Bytes &value) {
    append16(out, 4 + value.size()); append16(out, id); out.insert(out.end(), value.begin(), value.end());
}
inline Bytes text(const char *s) {
    Bytes v; do { v.push_back(uint8_t(*s)); } while (*s++); return v;
}
inline Bytes identification() {
    Bytes p;
    parameter(p, 0, text("SmartBox Mac Bench")); parameter(p, 1, text("MacReceiverTest"));
    parameter(p, 2, text("Local Development")); parameter(p, 3, text("SMARTBOX-MAC-001"));
    parameter(p, 4, text("0.1")); parameter(p, 5, text("1"));
    parameter(p, 6, {0xae,0x00,0xae,0x02,0xae,0x03,0x43,0x01});
    parameter(p, 7, {0xae,0x01,0x43,0x00});
    parameter(p, 8, {2}); parameter(p, 9, {0,0});
    parameter(p, 12, text("en")); parameter(p, 13, text("en"));
    Bytes usb;
    parameter(usb, 0, {0x03,0xe9}); parameter(usb, 1, text("USB_USE"));
    parameter(usb, 2, {}); parameter(usb, 3, {1}); parameter(usb, 4, {});
    parameter(p, 16, usb); // Logical USB-host CarPlay component; NCM control interface 1.
    Bytes result{0x40,0x40}; append16(result, 6 + p.size()); append16(result, 0x1d01);
    result.insert(result.end(), p.begin(), p.end()); return result;
}

// Bounded bench exchange through optional identification and session invitation.
// No device changes or video-session support; signing uses a local test identity.
class AuthProbe {
public:
    using Sign = std::function<Bytes(const Bytes &)>;
    bool authenticated = false, identificationRequested = false, identificationAccepted = false, availabilityReceived = false;
    unsigned certificateReplies = 0, challengeReplies = 0;
    std::vector<unsigned> messages;
    std::string error;
    AuthProbe(uint8_t peerSyn, Bytes certificate, Sign sign, bool identify = false)
        : peer(peerSyn), cert(std::move(certificate)), signer(std::move(sign)), identify(identify) {}
    bool done() const { return authenticated && (identify ? identificationAccepted : identificationRequested); }
    Bytes startSession(const std::string &address, uint16_t port) {
        if (!identificationAccepted || !port || address.empty() || address.size() > 64) return {};
        // Wired addresses are a list of nested parameters, not a bare string.
        Bytes params, addresses; parameter(addresses, 0, text(address.c_str()));
        parameter(params, 0, addresses);
        parameter(params, 2, {0,0,uint8_t(port >> 8),uint8_t(port)});
        parameter(params, 3, text("220.68"));
        Bytes m{0x40,0x40}; append16(m, 6 + params.size()); append16(m, 0x4301);
        m.insert(m.end(), params.begin(), params.end());
        return packet(nextSeq++, peer, m);
    }

    bool feed(const uint8_t *data, size_t size, std::vector<Bytes> &out) {
        if (!error.empty()) return false;
        if (size > 4096 || incoming.size() + size > 8192) return fail("USB input exceeds probe bound");
        incoming.insert(incoming.end(), data, data + size);
        while (incoming.size() >= 9) {
            if (incoming[0] != 0xff || incoming[1] != 0x5a || !checksumValid(incoming.data(), 9))
                return fail("Invalid iAP2 header");
            unsigned n = be16(incoming.data() + 2);
            if (n < 9 || n > 4096) return fail("Invalid iAP2 packet size");
            if (incoming.size() < n) return true;
            Bytes frame(incoming.begin(), incoming.begin() + n);
            incoming.erase(incoming.begin(), incoming.begin() + n);
            if (++frames > 64) return fail("Packet limit reached");
            if (frame[4] != 0x40) return fail("Unexpected iAP2 control flags");
            if (n == 9) continue; // Pure link ACK; no data sequence consumed.
            if (n < 11 || frame[7] != 1 || !checksumValid(frame.data() + 9, n - 9))
                return fail("Invalid control-session payload");
            if (frame[5] == peer) {
                if (lastFrame != frame) return fail("Conflicting duplicate sequence");
                out.insert(out.end(), lastReplies.begin(), lastReplies.end());
                continue;
            }
            if (frame[5] != uint8_t(peer + 1)) return fail("Out-of-order data sequence");
            if (control.size() + n - 10 > 4096) return fail("Control message exceeds probe bound");
            peer = frame[5]; lastFrame = frame; lastReplies.clear();
            lastReplies.push_back(packet(uint8_t(nextSeq - 1), peer));
            control.insert(control.end(), frame.begin() + 9, frame.end() - 1);
            while (control.size() >= 6) {
                if (control[0] != 0x40 || control[1] != 0x40) return fail("Invalid control-message marker");
                unsigned count = be16(control.data() + 2), id = be16(control.data() + 4);
                if (count < 6 || count > 4096) return fail("Invalid control-message size");
                if (control.size() < count) break;
                Bytes body(control.begin() + 6, control.begin() + count);
                control.erase(control.begin(), control.begin() + count);
                messages.push_back(id);
                if (!handle(id, body)) return false;
            }
            out.insert(out.end(), lastReplies.begin(), lastReplies.end());
        }
        return true;
    }
private:
    uint8_t peer, nextSeq = 1;
    unsigned frames = 0;
    Bytes cert, incoming, control, lastFrame;
    Sign signer;
    bool identify;
    std::vector<Bytes> lastReplies;
    bool fail(const char *why) { error = why; return false; }
    bool handle(unsigned id, const Bytes &body) {
        if (id == 0xaa00) {
            if (!body.empty() || certificateReplies || cert.size() <= 640 || cert.size() > 2048)
                return fail("Unexpected certificate request or certificate size");
            lastReplies.push_back(packet(nextSeq++, peer, message(0xaa01, cert)));
            ++certificateReplies;
        } else if (id == 0xaa02) {
            if (certificateReplies != 1 || challengeReplies || body.size() != 24 || be16(body.data()) != 24 || be16(body.data() + 2) != 0)
                return fail("Unsupported authentication challenge");
            Bytes signature = signer(Bytes(body.begin() + 4, body.end()));
            if (signature.size() != 256) return fail("RSA-2048 test-key signing failed");
            lastReplies.push_back(packet(nextSeq++, peer, message(0xaa03, signature)));
            ++challengeReplies;
        } else if (id == 0xaa05) {
            if (!body.empty() || challengeReplies != 1) return fail("Out-of-order authentication success");
            authenticated = true;
        } else if (id == 0xaa04) {
            return fail("Dongle rejected the test authentication");
        } else if (id == 0x1d00) {
            if (!body.empty() || !authenticated || identificationRequested) return fail("Out-of-order identification request");
            identificationRequested = true;
            if (identify) lastReplies.push_back(packet(nextSeq++, peer, identification()));
        } else if (id == 0x1d02 && identify) {
            if (!body.empty() || !identificationRequested) return fail("Out-of-order identification acceptance");
            identificationAccepted = true;
        } else if (id == 0x1d03) {
            return fail("Dongle rejected the bench identification");
        } else if (id == 0x4300 && identificationAccepted) {
            size_t pos = 0;
            while (pos < body.size()) {
                if (body.size() - pos < 4) return fail("Truncated availability parameter");
                unsigned n = be16(body.data() + pos);
                if (n < 4 || n > body.size() - pos) return fail("Invalid availability parameter length");
                pos += n;
            }
            availabilityReceived = true;
        } else if ((id == 0x4e09 || id == 0x4e0a || id == 0x4e0c) && identificationAccepted) {
            // Device name/language/UUID metadata. Observe only; no Mac settings change.
            if (body.empty() && id != 0x4e0c) return true;
            if (body.size() < 5 || body.size() > 260 || be16(body.data()) != body.size()
                || be16(body.data() + 2) != 0 || body.back() != 0)
                return fail("Invalid device metadata parameter");
        } else if (id == 0x4e0b && identificationAccepted) {
            // DeviceTimeUpdate: acknowledge delivery, never change the Mac clock.
            size_t pos = 0; unsigned seen = 0;
            while (pos < body.size()) {
                if (body.size() - pos < 4) return fail("Truncated time update parameter");
                unsigned n = be16(body.data() + pos), tag = be16(body.data() + pos + 2);
                if (tag > 2 || (seen & (1u << tag)) || n != (tag == 0 ? 12u : tag == 1 ? 6u : 5u)
                    || n > body.size() - pos) return fail("Invalid time update parameter");
                seen |= 1u << tag; pos += n;
            }
            if (seen != 7) return fail("Incomplete time update");
        } else return fail("Unexpected control message in authentication probe");
        return true;
    }
};
}
