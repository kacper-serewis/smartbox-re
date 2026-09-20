# Running HW501 application code with QEMU

The firmware application's architecture is RV32 ILP32D. The archive is an
application partition only: no bootloader, kernel, base root filesystem, or
hardware model is included. See [QEMU's distinction between supported CPUs and
board models](https://www.qemu.org/docs/master/system/target-riscv.html).

## What worked on 2026-09-19

1. Built the native mode service for RV32 and passed all ten service integration
   tests under standard `qemu-riscv32` in a Debian container.
2. Loaded the unmodified stock `CPAAProxyEx` with a substitute Bootlin glibc
   sysroot. The initial generic QEMU 7.2.22 run stopped at instruction
   `0x0a16e05b` in `libprotobuf-lite.so`, ELF address `0x2c3bc`.
   A later probe with standard QEMU **10.0.13** also stopped with SIGILL before
   worker creation (`probe-20260919T180031.148124Z`).
3. Built [Andes' QEMU fork](https://github.com/andestech/qemu) at commit
   `32902627f26c5d760cd4efab499b989d566822f9` (QEMU 9.2.0 base), with the
   `andes-a25` CPU model. Its `XAndesV5Isa.decode`/translator implements `bnec`,
   which matches the failing instruction. This passes the instruction without
   changing the stock executable or libraries. A25 is an emulation compatibility
   choice, not identification of the exact dongle CPU model.
4. The stock application reached initialization and worker-thread creation. Its
   own log reports `init carplay proxy`; it attempts I2C/MFi and USB/iAP2-related
   initialization. Missing `/dev/i2c-0`, `/dev/by-name/private`, base-system
   scripts, and kernel netlink support prevent a normal device environment.

The bounded Andes run recorded a **SIGSEGV at address 0x8** after hardware-related
failures and continued until the eight-second timeout. We have not established
the exact crash cause. This is partial application execution, **not successful
firmware boot, a stable CarPlay session, or a full dongle emulator**.

The trace's `Unknown syscall 407/413` labels alone do not establish unsupported
system calls: this fork contains handlers for those time64 calls but lacks some
strace names. Kernel/library substitution and hardware failures still limit
behavioral conclusions.

## Reproduce

```sh
python3 scripts/build_mode_service.py --setup --riscv
python3 scripts/emulate_firmware.py --mode-tests
python3 scripts/emulate_firmware.py --stock
python3 scripts/emulate_firmware.py --setup-andes
python3 scripts/emulate_firmware.py --stock --andes
```

Setup is already completed on this Mac. Andes setup builds only the RV32
Linux-user emulator. The recorded patch guards an old `struct sched_attr`
definition against newer host glibc headers and translates RV32 time64 socket
timeouts (`SO_RCVTIMEO_NEW`/`SO_SNDTIMEO_NEW`) to host timeouts. Without the latter,
UxPlay's receive worker exits with `ENOPROTOOPT`. A real 50 ms receive timeout
test verifies expiration; this does not ignore timeout requests or alter guest
instruction behavior. Source, build artifacts, and downloaded compiler stay
under ignored `firmwares/research/`.

The toolchain is [Bootlin riscv32-ilp32d glibc stable 2024.05-1](https://toolchains.bootlin.com/releases_riscv32-ilp32d.html),
archive SHA-256 `00112418e6d4b0733019a673b682a39f1ce6300b9448cd840f1194aa4b064192`.
It supplies a compatible loader, libc, libstdc++, and other libraries missing
from the application archive; these are **not copied from the dongle**.

Runtime containers have no external network, source/firmware mounted read-only,
disposable writable state, and no host hardware devices passed through. Probes
stop after eight seconds and save traces, app logs, and provenance under
`firmwares/research/emulation/probe-*`.

The first reproducible Andes probe is
`probe-20260919T175601.360507Z`: 18 thread/process clone calls, no SIGILL,
SIGSEGV observed, timeout exit 124. Its own app log is `app-app.log`.

## Next emulation work

The mirroring receiver now builds with a glibc 2.34 toolchain, links the stock
crypto/DNS libraries, and passes a 72-frame encrypted transport test under Andes
QEMU. `scripts/test_mirroring_device.py` checks bridge framing/mode control, loads
the integration into the stock executable, and exercises the actual RV32 driver.
See the [experimental image](../mirroring/FLASHING.md).

Full application testing needs the device's base filesystem/configuration and
controlled substitutes for hardware-dependent calls, or models of the relevant
interfaces. QEMU cannot infer those from `app.img`. A generic `virt` board can
run suitable Linux, but does not itself reproduce Allwinner V821 peripherals,
the adapter's USB gadget/iAP2 interface, Wi-Fi/Bluetooth, or MFi hardware.
