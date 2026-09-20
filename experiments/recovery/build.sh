#!/bin/sh
set -eu
TC=/deps/riscv32-ilp32d--glibc--bleeding-edge-2021.11-1
export PATH="$TC/bin:$PATH"
export CC=riscv32-buildroot-linux-gnu-gcc
cd /build/dropbear-2026.94
CFLAGS='-Os -ffunction-sections -fdata-sections' LDFLAGS='-static -Wl,--gc-sections' \
 ./configure --host=riscv32-buildroot-linux-gnu --disable-zlib --disable-syslog \
 --disable-lastlog --disable-utmp --disable-utmpx --disable-wtmp --disable-wtmpx \
 --disable-loginfunc
make -j4 PROGRAMS='dropbear dropbearkey' MULTI=1 STATIC=1
"$TC/bin/riscv32-buildroot-linux-gnu-strip" dropbearmulti
cp dropbearmulti /build/bundle/dropbearmulti
"$CC" -std=c11 -Os -s -static -Wall -Wextra -Werror \
 /work/experiments/recovery/recovery.c -o /build/bundle/recoveryd
"$TC/bin/riscv32-buildroot-linux-gnu-readelf" -h /build/bundle/recoveryd
"$TC/bin/riscv32-buildroot-linux-gnu-readelf" -d /build/bundle/dropbearmulti
