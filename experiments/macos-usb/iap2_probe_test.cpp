#include "IAP2Probe.h"
#include <cassert>
#include <cstring>

int main() {
    // Real HW501 response to our sequence-zero control-only SYN.
    const uint8_t offer[] = {0xff,0x5a,0,23,0xc0,0x27,0,0,0xa9,
                            1,0x7f,0xff,0xff,7,0xd0,0,0xc8,3,3,1,0,1,0xdb};
    assert(iap2probe::controlSynAck(offer, sizeof(offer)));
    for (size_t n = 0; n < sizeof(offer); ++n)
        assert(!iap2probe::controlSynAck(offer, n));
    for (size_t n = 0; n < sizeof(offer); ++n) {
        uint8_t corrupt[sizeof(offer)]; memcpy(corrupt, offer, sizeof(offer));
        corrupt[n] ^= 1;
        assert(!iap2probe::controlSynAck(corrupt, sizeof(corrupt)));
    }
    uint8_t wrongSession[sizeof(offer)]; memcpy(wrongSession, offer, sizeof(offer));
    wrongSession[19] = 2; wrongSession[22]--;
    assert(!iap2probe::controlSynAck(wrongSession, sizeof(wrongSession)));
    uint8_t ack[9]; iap2probe::makeAck(0x27, ack);
    const uint8_t expected[] = {0xff,0x5a,0,9,0x40,0,0x27,0,0x37};
    assert(!memcmp(ack, expected, sizeof(ack)));
    assert(iap2probe::checksumValid(ack, sizeof(ack)));
}
