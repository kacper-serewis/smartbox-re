#pragma once
#include <cstddef>
#include <cstdint>

namespace iap2probe {
inline bool checksumValid(const uint8_t *data, size_t size) {
    uint8_t sum = 0;
    for (size_t i = 0; i < size; ++i) sum += data[i];
    return sum == 0;
}

// Deliberately restricted to the single control-session offer used by this
// bench probe. This is not a general stream parser or a link implementation.
inline bool controlSynAck(const uint8_t *data, size_t size) {
    return size == 23 && data[0] == 0xff && data[1] == 0x5a &&
        data[2] == 0 && data[3] == 23 && data[4] == 0xc0 &&
        data[6] == 0 && data[7] == 0 && checksumValid(data, 9) &&
        checksumValid(data + 9, 14) && data[9] == 1 && data[10] > 0 &&
        data[10] <= 127 && ((unsigned(data[11]) << 8) | data[12]) >= 23 &&
        (data[13] || data[14]) && (data[15] || data[16]) &&
        data[17] && data[18] && data[19] == 1 && data[20] == 0 && data[21] == 1;
}
inline void makeAck(uint8_t peerSequence, uint8_t (&ack)[9]) {
    const uint8_t header[9] = {0xff, 0x5a, 0, 9, 0x40, 0, peerSequence, 0, 0};
    uint8_t sum = 0;
    for (size_t i = 0; i < 8; ++i) { ack[i] = header[i]; sum += header[i]; }
    ack[8] = uint8_t(-sum);
}
}
