#!/bin/sh
set -eu
TC=/deps/riscv32-ilp32d--glibc--bleeding-edge-2021.11-1/bin/riscv32-buildroot-linux-gnu
UX=/work/firmwares/research/UxPlay
INC="-I$UX/lib -I$UX/lib/playfair -I$UX/lib/llhttp -I/deps -I/build/prefix/include -I/build/openssl/include -I/deps/openssl-1.1.1w/include"
FLAGS='-Os -fPIC -std=gnu11 -DPLIST_210 -DPLIST_230 -DNOHOLD -D_LINUX -D_REENTRANT -D_FILE_OFFSET_BITS=64 -DOPENSSL_API_COMPAT=0x10101000L'
"$TC-gcc" $FLAGS $INC -DSMARTBOX_BENCH -shared /work/experiments/mirroring/device_bridge.c -o /build/libsmartbox-bench.so /build/libmirror.a /build/prefix/lib/libplist-2.0.a -L/work/firmwares/hw501/131/rootfs/lib -Wl,--gc-sections -Wl,-Bsymbolic-functions -Wl,--version-script=/work/experiments/mirroring/device_exports.map -Wl,-rpath,/mnt/app/lib -lcrypto -ldns_sd -lpthread -lm -ldl
"$TC-strip" /build/libsmartbox-bench.so
"$TC-gcc" -Os -Wall -Wextra -Werror /work/experiments/mirroring/bench_launch.c -o /build/smartbox-bench
"$TC-strip" /build/smartbox-bench
"$TC-gcc" -Os -Wall -Wextra -Werror -fPIC -shared /work/experiments/mirroring/bench_socket.c -o /build/libsocket-reuse.so -ldl
"$TC-strip" /build/libsocket-reuse.so
