#!/usr/bin/env python3
"""Measure software bridge geometry limits with real generated H.264 in RV32 QEMU.

Does not measure a physical head unit's decoder, throughput or scaling limits.
"""
import base64
from datetime import datetime, timezone
import json
from pathlib import Path
import subprocess
import sys
from test_mirroring_transport import annexb
from test_native_video import BUILD, ROOT, digest, decode


def guest():
    root = Path('/work')
    sysroot = root / 'firmwares/research/mirror-deps/riscv32-ilp32d--glibc--bleeding-edge-2021.11-1/riscv32-buildroot-linux-gnu/sysroot'
    qemu = ['timeout', '--signal=KILL', '30', str(root / 'firmwares/research/qemu-andes-build/qemu-riscv32'),
            '-cpu', 'andes-a25', '-L', str(sysroot), '-E',
            f'LD_LIBRARY_PATH={root}/firmwares/hw501/131/rootfs/lib:{sysroot}/lib:{sysroot}/usr/lib']
    for case in sorted(Path('/evidence').glob('case-*')):
        result = subprocess.check_output(qemu + [str(root / 'firmwares/research/mirroring-riscv/replay-native'),
                    str(case / 'input.packets'), str(case / 'video.h264'), str(case / 'events.jsonl')],
                    text=True, stderr=subprocess.STDOUT, timeout=35)
        (case / 'bridge.json').write_text(result)


def main():
    manifest = json.loads((BUILD / 'manifest.json').read_text())
    for path, sha in manifest['integration_sources'].items():
        if digest(ROOT / path) != sha:
            raise ValueError(f'Source changed; run build_mirroring_riscv.py: {path}')
    if digest(BUILD / 'replay-native') != manifest['files']['replay-native']['sha256']:
        raise ValueError('Replay binary differs from build manifest')
    output = ROOT / 'device-snapshots' / ('resolution-tests-' + datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%S.%fZ'))
    output.mkdir(mode=0o700)
    print('Evidence:', output, flush=True)
    fixture = output / 'video-fixture'
    subprocess.run(['swiftc', '-O', str(ROOT / 'experiments/mirroring/video_fixture.swift'), '-o', str(fixture)], check=True)
    subprocess.run([str(fixture), 'generate-resolutions', str(output / 'source.json')], check=True)
    frames = json.loads((output / 'source.json').read_text())
    sizes = [(800,480), (480,800), (1024,600), (1280,720), (1600,900), (1920,1080),
             (720,1280), (1080,1920), (1936,1080), (1920,1088), (800,480)]
    if len(frames) != len(sizes)*12:
        raise ValueError('Unexpected fixture count')
    cases = []
    all_packets, all_expected = [], bytearray()
    for index, (w, h) in enumerate(sizes):
        subset = frames[index*12:(index+1)*12]
        if any((f['width'], f['height']) != (w,h) for f in subset):
            raise ValueError('Encoder geometry differs from requested geometry')
        directory = output / ('case-%02d' % index); directory.mkdir()
        previous, packets, forwarded = None, [], []
        for frame in subset:
            sps, pps, avcc = (base64.b64decode(frame[k]) for k in ('sps','pps','avcc'))
            prefix = b''
            if previous != (sps, pps):
                prefix = b'\0\0\0\1' + sps + b'\0\0\0\1' + pps
                previous = (sps, pps)
            raw = annexb(avcc)
            packets.append(prefix + raw)
            # The bridge intentionally forwards SPS/PPS and VCL; encoder SEI is omitted.
            vcl = b''.join(b'\0\0\0\1' + nal for nal in raw.split(b'\0\0\0\1')[1:] if nal and nal[0] & 31 in (1, 5))
            forwarded.append(prefix + vcl)
        (directory / 'input.packets').write_bytes(b''.join(len(p).to_bytes(4,'big') + p for p in packets))
        expected_accept = w <= 1920 and h <= 1080
        expected = b''.join(forwarded) if expected_accept else b''
        cases.append((directory, [w,h], expected, 12 if expected_accept else 0))
        all_packets.extend(packets); all_expected.extend(expected)
    combined = output / 'case-99'; combined.mkdir()
    (combined / 'input.packets').write_bytes(b''.join(len(p).to_bytes(4,'big') + p for p in all_packets))
    cases.append((combined, 'all transitions, including return after rejected sizes', bytes(all_expected),
                  sum(item[3] for item in cases)))
    subprocess.run(['docker','run','--rm','--platform','linux/amd64','--network','none',
                    '-v',f'{ROOT}:/work:ro','-v',f'{output}:/evidence','smartbox-emulation:local',
                    'python3','/work/scripts/test_mirroring_resolutions.py','--guest'], check=True, timeout=180)
    results = []
    for directory, size, expected, count in cases:
        actual = (directory / 'video.h264').read_bytes()
        if actual != expected:
            raise AssertionError(f'{size}: unexpected forwarding or changed bytes')
        decoder = decode(directory) if expected else None
        if decoder and (decoder['frames_decoded'] != count or decoder['decode_errors']):
            raise AssertionError(f'{size}: decoding failed: {decoder}')
        results.append(dict(size=size, forwarded_frames=count, forwarded_vcl_and_config_identical=True, decoder=decoder))
    report = dict(results=results, hardware_tested=False, replay_sha256=digest(BUILD/'replay-native'),
                  limitation='Measures current software guard and bridge under QEMU; not Corsa acceptance or dongle real-time performance.')
    (output/'report.json').write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps(report,indent=2))


if __name__ == '__main__':
    guest() if '--guest' in sys.argv else main()
