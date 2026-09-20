#!/bin/sh
set -eu
TC=/deps/riscv32-ilp32d--glibc--bleeding-edge-2021.11-1
export PATH="$TC/bin:$PATH"
export CC=riscv32-buildroot-linux-gnu-gcc
export AR=riscv32-buildroot-linux-gnu-ar
export RANLIB=riscv32-buildroot-linux-gnu-ranlib
export STRIP=riscv32-buildroot-linux-gnu-strip
export CFLAGS='-Os -fPIC -ffunction-sections -fdata-sections'
mkdir -p /build/plist /build/openssl /build/prefix/include /build/prefix/lib
if [ ! -f /build/prefix/lib/libplist-2.0.a ]; then
    cd /build/plist
    /deps/libplist-2.7.0/configure --host=riscv32-buildroot-linux-gnu --prefix=/build/prefix --disable-shared --enable-static --without-cython --without-tests --without-tools --without-cxx
    make -j4
    make install
fi
cd /build/openssl
if [ ! -f include/openssl/opensslconf.h ]; then
    /deps/openssl-1.1.1w/Configure linux-generic32 no-asm --cross-compile-prefix=riscv32-buildroot-linux-gnu-
    make build_generated
fi
cd /build
UX=/work/firmwares/research/UxPlay
INC="-I$UX/lib -I$UX/lib/playfair -I$UX/lib/llhttp -I/deps -I/build/prefix/include -I/build/openssl/include -I/deps/openssl-1.1.1w/include"
FLAGS='-std=gnu11 -DPLIST_210 -DPLIST_230 -DNOHOLD -D_LINUX -D_REENTRANT -D_FILE_OFFSET_BITS=64 -DOPENSSL_API_COMPAT=0x10101000L'
mkdir -p objects
for src in "$UX"/lib/*.c "$UX"/lib/playfair/*.c "$UX"/lib/llhttp/*.c "$UX"/lib/dns_sd/*.c; do
    obj="objects/$(basename "$(dirname "$src")")_$(basename "$src" .c).o"
    "$CC" $CFLAGS $FLAGS $INC -c "$src" -o "$obj"
done
"$AR" rcs libmirror.a objects/*.o
for pair in 'receiver mirror-capture' 'test_capture test-capture' 'test_transport test-transport'; do
    set -- $pair
    "$CC" $CFLAGS $FLAGS $INC "/work/experiments/mirroring/$1.c" -o "$2" libmirror.a /build/prefix/lib/libplist-2.0.a -L/work/firmwares/hw501/131/rootfs/lib -Wl,--gc-sections -Wl,-rpath,/mnt/app/lib -lcrypto -ldns_sd -lpthread -lm -ldl
    "$STRIP" "$2"
done
"$CC" $CFLAGS $FLAGS $INC -shared /work/experiments/mirroring/device_bridge.c -o libsmartbox-mirror.so libmirror.a /build/prefix/lib/libplist-2.0.a -L/work/firmwares/hw501/131/rootfs/lib -Wl,--gc-sections -Wl,-Bsymbolic-functions -Wl,--version-script=/work/experiments/mirroring/device_exports.map -Wl,-rpath,/mnt/app/lib -lcrypto -ldns_sd -lpthread -lm -ldl
"$STRIP" libsmartbox-mirror.so
"$CC" $CFLAGS -std=gnu11 -Wall -Wextra -Werror /work/experiments/mirroring/device_launch.c -o smartbox-launch
"$STRIP" smartbox-launch
"$CC" $CFLAGS /work/experiments/mirroring/test_timeouts.c -o test-timeouts
"$CC" $CFLAGS $FLAGS $INC -rdynamic /work/experiments/mirroring/test_device_bridge.c -o test-device-bridge libmirror.a /build/prefix/lib/libplist-2.0.a -L/work/firmwares/hw501/131/rootfs/lib -Wl,--gc-sections -lcrypto -ldns_sd -lpthread -lm -ldl
"$CC" $CFLAGS $FLAGS $INC /work/experiments/mirroring/replay_bridge.c -o replay-bridge libmirror.a /build/prefix/lib/libplist-2.0.a -L/work/firmwares/hw501/131/rootfs/lib -Wl,--gc-sections -lcrypto -ldns_sd -lpthread -lm -ldl
riscv32-buildroot-linux-gnu-readelf --version-info mirror-capture

"$CC" -O2 -fPIC -mno-relax -msmall-data-limit=0 -Wall -Wextra -Werror /work/experiments/mirroring/test_native_video.c -o test-native-video

"$CC" $CFLAGS $FLAGS $INC -DSMARTBOX_NATIVE_TEST /work/experiments/mirroring/replay_bridge.c -o replay-native libmirror.a /build/prefix/lib/libplist-2.0.a -L/work/firmwares/hw501/131/rootfs/lib -Wl,--gc-sections -lcrypto -ldns_sd -lpthread -lm -ldl
