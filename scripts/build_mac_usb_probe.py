#!/usr/bin/env python3
"""Build and test the experimental Mac USB access kext. Never install or sign it."""
import hashlib
import json
from pathlib import Path
import plistlib
import subprocess

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / 'experiments/macos-usb'
BUILD = ROOT / 'firmwares/research/mac-usb-probe'
BUNDLE = 'local.smartbox.USBProbe'


def main():
    BUILD.mkdir(parents=True, exist_ok=True)
    sdk = Path(subprocess.check_output(['xcrun', '--sdk', 'macosx', '--show-sdk-path'], text=True).strip())
    version = subprocess.check_output(['xcrun', '--sdk', 'macosx', '--show-sdk-version'], text=True).strip()
    kernel = sdk / 'System/Library/Frameworks/Kernel.framework'
    bundle = BUILD / 'SmartBoxUSBProbe.kext'
    executable = bundle / 'Contents/MacOS/SmartBoxUSBProbe'
    executable.parent.mkdir(parents=True, exist_ok=True)
    commands = []
    with (BUILD / 'build.log').open('w') as log:
        def run(args):
            commands.append([str(v) for v in args])
            r = subprocess.run(commands[-1], stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True, timeout=60)
            log.write(r.stdout); log.flush()
            if r.returncode:
                print(r.stdout)
                r.check_returncode()
            return r.stdout

        test = BUILD / 'test-policy'
        run(['xcrun', 'clang++', '-std=c++14', '-Wall', '-Wextra', '-Werror',
             '-fsanitize=address,undefined', SOURCE / 'test_policy.cpp', '-o', test])
        print(run([test]), end='')
        flags = ['-target', f'arm64e-apple-macos{version}', '-isysroot', str(sdk),
                 '-nostdinc', '-mkernel', '-fno-builtin', '-fno-common', '-DKERNEL', '-DKERNEL_PRIVATE',
                 '-DDRIVER_PRIVATE', '-DAPPLE', '-DNeXT', '-Os', '-Wall', '-Wextra', '-Werror',
                 '-I', str(kernel / 'Headers'), '-I', str(kernel / 'PrivateHeaders')]
        run(['xcrun', 'clang++', *flags, '-std=c++14', '-fno-exceptions', '-fno-rtti', '-fapple-kext',
             '-c', SOURCE / 'SmartBoxUSBProbe.cpp', '-o', BUILD / 'probe.o'])
        module = BUILD / 'module.c'
        module.write_text('''#include <mach/mach_types.h>
extern kern_return_t _start(kmod_info_t *, void *);
extern kern_return_t _stop(kmod_info_t *, void *);
__attribute__((visibility("default"))) KMOD_EXPLICIT_DECL(local.smartbox.USBProbe, "0.1.1", _start, _stop)
__private_extern__ kmod_start_func_t *_realmain = 0;
__private_extern__ kmod_stop_func_t *_antimain = 0;
__private_extern__ int _kext_apple_cc = __APPLE_CC__;
''')
        run(['xcrun', 'clang', *flags, '-c', module, '-o', BUILD / 'module.o'])
        run(['xcrun', 'clang++', '-target', f'arm64e-apple-macos{version}', '-isysroot', sdk,
             '-nostdlib', '-Xlinker', '-kext', BUILD / 'probe.o', BUILD / 'module.o',
             '-lkmodc++', '-lkmod', '-lcc_kext', '-o', executable])
        plist = dict(CFBundleIdentifier=BUNDLE, CFBundleExecutable='SmartBoxUSBProbe',
                     CFBundleName='SmartBoxUSBProbe', CFBundlePackageType='KEXT',
                     CFBundleVersion='0.1.1', CFBundleShortVersionString='0.1.1',
                     OSBundleLibraries={'com.apple.kpi.iokit': '9.0.0', 'com.apple.kpi.libkern': '9.0.0',
                                        'com.apple.kpi.mach': '9.0.0'},
                     IOKitPersonalities={'SmartBoxUSBProbe': dict(
                         CFBundleIdentifier=BUNDLE, IOClass='SmartBoxUSBProbe',
                         IOProviderClass='AppleT8142USBXDCI', IOMatchCategory='SmartBoxUSBProbe',
                         IOPathMatch='IOService:/AppleARMPE/arm-io@10F00000/AppleSoCIO/usb-drd1@AA280000/AppleT8142USBXDCI@1')})
        info = bundle / 'Contents/Info.plist'
        info.write_bytes(plistlib.dumps(plist))
        print(run(['plutil', '-lint', info]), end='')
        print(run(['file', executable]), end='')
        # Ensure no development certificate or ad-hoc signature is implied.
        signing = subprocess.run(['codesign', '-dv', bundle], capture_output=True, text=True, timeout=10)
        log.write(signing.stdout + signing.stderr)
        if signing.returncode == 0:
            raise RuntimeError('Unexpected signed build; inspect the existing output directory')
    sources = [SOURCE / v for v in ('SmartBoxUSBProbe.cpp', 'ProbePolicy.h', 'test_policy.cpp')]
    sources.append(Path(__file__).resolve())
    report = dict(sdk=str(sdk), sdk_version=version, architecture='arm64e', policy_tests='passed',
                  installed=False, loaded=False, hardware_tested=False, signed=False,
                  sources={str(p.relative_to(ROOT)): hashlib.sha256(p.read_bytes()).hexdigest() for p in sources},
                  artifacts={str(p.relative_to(BUILD)): hashlib.sha256(p.read_bytes()).hexdigest() for p in (executable, info)},
                  commands=commands)
    (BUILD / 'manifest.json').write_text(json.dumps(report, indent=2) + '\n')
    print('Built only; not signed, installed, or loaded:', bundle)


if __name__ == '__main__':
    main()
