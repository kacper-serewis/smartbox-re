#!/usr/bin/env python3
"""Test native video handover offline; optionally replay local phone captures.

Requires scripts/build_mirroring_riscv.py. No adapter access or firmware writes.
"""
import argparse
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
BUILD = ROOT / 'firmwares/research/mirroring-riscv'
STOCK_SHA = 'a147d1b4fd2f73ed5a70b76c45cc5e5ca1aeaa8b1544d4aabc99b7a6618ecc84'


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def guest():
    root = Path('/work')
    binary = root / 'firmwares/hw501/131/rootfs/bin/CPAAProxyEx'
    if digest(binary) != STOCK_SHA:
        raise ValueError('Native address tests require the exact stock v131 executable')
    sysroot = root / 'firmwares/research/mirror-deps/riscv32-ilp32d--glibc--bleeding-edge-2021.11-1/riscv32-buildroot-linux-gnu/sysroot'
    qemu = ['timeout', '--signal=KILL', '30', str(root / 'firmwares/research/qemu-andes-build/qemu-riscv32'),
            '-cpu', 'andes-a25', '-L', str(sysroot), '-E',
            f'LD_LIBRARY_PATH={root}/firmwares/hw501/131/rootfs/lib:{sysroot}/lib:{sysroot}/usr/lib']
    build = root / 'firmwares/research/mirroring-riscv'
    for name, args in [('native-state', [str(binary)]), ('native-wire', [str(binary), '--wire'])]:
        output = subprocess.check_output(qemu + [str(build / 'test-native-video')] + args, text=True, stderr=subprocess.STDOUT, timeout=40)
        Path('/evidence', name + '.log').write_text(output)
        print(output, end='')
    for directory in sorted(Path('/evidence').glob('replay-*')):
        result = subprocess.check_output(qemu + [str(build / 'replay-native'), str(directory / 'input.packets'),
                                                str(directory / 'video.h264'), str(directory / 'events.jsonl')],
                                         text=True, stderr=subprocess.STDOUT, timeout=40)
        (directory / 'bridge.json').write_text(result)


def replay_input(source, destination):
    video = (source / 'video.h264').read_bytes()
    if len(video) > 16 * 1024 * 1024:
        raise ValueError('Capture exceeds test size limit')
    end = 0
    with (destination / 'input.packets').open('wb') as stream:
        for line in (source / 'events.jsonl').read_text().splitlines():
            event = json.loads(line)
            if event.get('event') != 'packet':
                continue
            offset, length = event['offset'], event['length']
            if offset != end or not 5 <= length <= 1024 * 1024 or offset + length > len(video):
                raise ValueError('Capture event offsets are incomplete or invalid')
            stream.write(length.to_bytes(4, 'big'))
            stream.write(video[offset:offset + length])
            end = offset + length
    if end != len(video):
        raise ValueError('Capture contains unindexed video bytes')


def decode(directory):
    from preview_dongle import Packets
    packets = Packets()
    video = (directory / 'video.h264').read_bytes()
    data = []
    for line in (directory / 'events.jsonl').read_text().splitlines():
        event = json.loads(line)
        if event['event'] != 'packet':
            continue
        raw = video[event['offset']:event['offset'] + event['length']]
        converted = packets.convert(raw)
        if converted:
            data.append(json.dumps(converted))
    result = subprocess.run([str(ROOT / 'firmwares/research/mirroring-build/mirror-preview'), str(directory)],
                            input='\n'.join(data) + '\n', text=True, capture_output=True, timeout=120, check=True)
    (directory / 'decoder.log').write_text(result.stdout + result.stderr)
    return json.loads((directory / 'decoder.json').read_text())


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--capture', action='append', default=[], type=Path)
    args = parser.parse_args()
    manifest = json.loads((BUILD / 'manifest.json').read_text())
    for path, sha in manifest['integration_sources'].items():
        if digest(ROOT / path) != sha:
            raise ValueError(f'Source changed; rebuild first: {path}')
    for name in ('test-native-video', 'replay-native', 'libsmartbox-mirror.so'):
        if digest(BUILD / name) != manifest['files'][name]['sha256']:
            raise ValueError(f'Build hash mismatch: {name}')
    output = ROOT / 'device-snapshots' / ('native-video-tests-' + datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%S.%fZ'))
    output.mkdir(mode=0o700)
    captures = []
    for i, source in enumerate(args.capture):
        directory = output / f'replay-{i}'
        directory.mkdir(mode=0o700)
        replay_input(source, directory)
        captures.append((source, directory))
    subprocess.run(['docker', 'run', '--rm', '--platform', 'linux/amd64', '--network', 'none', '--read-only',
                    '--cap-drop', 'ALL', '--security-opt', 'no-new-privileges', '--memory', '512m', '--pids-limit', '64',
                    '--tmpfs', '/tmp:rw,exec,nosuid,size=32m', '-v', f'{ROOT}:/work:ro', '-v', f'{output}:/evidence',
                    'smartbox-emulation:local', 'python3', '/work/scripts/test_native_video.py', '--guest'], check=True, timeout=150)
    report = {'stock_sha256': STOCK_SHA, 'build': manifest['files'], 'native_state': 'passed', 'native_wire': 'passed',
              'hardware_tested': False, 'replays': [],
              'limitations': 'QEMU executes extracted native routines with modeled lifecycle/network/AES dependencies; replay uses the production bridge and native adapter with recording transport callbacks. No head unit is emulated.'}
    for source, directory in captures:
        decoder = decode(directory)
        bridge = json.loads((directory / 'bridge.json').read_text())
        identical = digest(source / 'video.h264') == digest(directory / 'video.h264')
        if not identical or decoder['decode_errors'] or decoder['frames_decoded'] != bridge['frames']:
            raise AssertionError('Replay changed captured stream or did not decode all frames')
        sizes = sorted({(event['width'], event['height']) for line in (directory / 'events.jsonl').read_text().splitlines()
                        if (event := json.loads(line))['event'] == 'geometry'})
        report['replays'].append({'source': str(source), 'bridge': bridge, 'decoder': decoder,
                                  'byte_identical': identical, 'sha256': digest(directory / 'video.h264'), 'geometry': sizes})
    (output / 'report.json').write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps(report, indent=2))
    print('Evidence:', output)


if __name__ == '__main__':
    guest() if '--guest' in sys.argv else main()
