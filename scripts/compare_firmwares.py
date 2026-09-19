#!/usr/bin/env python3
"""Extract downloaded app images and compare every file by SHA-256."""
import argparse
import difflib
from datetime import datetime, timezone
import hashlib
import itertools
import json
from pathlib import Path
import re
import shutil
import stat
import subprocess


def digest(data):
    return hashlib.sha256(data).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--root', type=Path, default=Path('firmwares/hw501'))
    parser.add_argument('--report', type=Path, default=Path('reports'))
    args = parser.parse_args()
    if not shutil.which('unsquashfs'):
        parser.error('unsquashfs is required (macOS: brew install squashfs)')
    manifest = json.loads((args.root / 'manifest.json').read_text())
    args.report.mkdir(parents=True, exist_ok=True)
    inventories = {}
    for release in manifest['releases']:
        version = release['version']
        folder = args.root / str(version)
        image = folder / 'archive/app.img'
        expected_md5 = (folder / 'archive/appmd5sum.txt').read_text().split()[0]
        if hashlib.md5(image.read_bytes()).hexdigest() != expected_md5.lower():
            raise ValueError(f'Bundled app.img MD5 mismatch for {version}')
        dest = folder / 'rootfs'
        if dest.exists():
            # Reuse extraction only when it was made from exactly this app.img.
            stamp = folder / 'extracted.sha256'
            if not stamp.exists() or stamp.read_text().strip() != digest(image.read_bytes()):
                raise RuntimeError(f'Remove stale extraction before retrying: {dest}')
        else:
            result = subprocess.run(['unsquashfs', '-no-progress', '-d', str(dest), str(image)], capture_output=True, text=True)
            (folder / 'extraction.log').write_text(result.stdout + result.stderr)
            result.check_returncode()
            (folder / 'extracted.sha256').write_text(digest(image.read_bytes()) + '\n')
        inventory = {}
        strings_dir = folder / 'strings'
        strings_dir.mkdir(exist_ok=True)
        for path in sorted(dest.rglob('*')):
            info = path.lstat()
            rel = path.relative_to(dest).as_posix()
            if path.is_symlink():
                inventory[rel] = {'type': 'symlink', 'target': str(path.readlink())}
            elif stat.S_ISREG(info.st_mode):
                data = path.read_bytes()
                record = {'type': 'file', 'size': len(data), 'sha256': digest(data), 'mode': oct(stat.S_IMODE(info.st_mode))}
                if data.startswith(b'\x7fELF'):
                    record['elf_bits'] = {1:32, 2:64}.get(data[4])
                    record['elf_machine'] = int.from_bytes(data[18:20], 'little' if data[5] == 1 else 'big')
                    strings = sorted({s.decode('ascii') for s in re.findall(rb'[\x20-\x7e]{6,}', data)})
                    (strings_dir / (rel.replace('/', '__') + '.txt')).write_text('\n'.join(strings) + '\n')
                inventory[rel] = record
        inventories[str(version)] = inventory
        (folder / 'inventory.json').write_text(json.dumps(inventory, indent=2) + '\n')
        print(f'v{version}: {len(inventory)} files/symlinks extracted', flush=True)
    comparisons = []
    for a, b in itertools.combinations(inventories, 2):
        left, right = inventories[a], inventories[b]
        shared = set(left) & set(right)
        comparisons.append({'from':int(a), 'to':int(b), 'added':sorted(set(right)-set(left)), 'removed':sorted(set(left)-set(right)), 'changed':sorted(p for p in shared if left[p] != right[p]), 'identical':sorted(p for p in shared if left[p] == right[p])})
        diff_dir = args.report / 'diffs' / f'{a}-{b}'
        diff_dir.mkdir(parents=True, exist_ok=True)
        for rel in comparisons[-1]['changed']:
            if rel.startswith('web/'):
                before = (args.root / a / 'rootfs' / rel).read_text().splitlines(keepends=True)
                after = (args.root / b / 'rootfs' / rel).read_text().splitlines(keepends=True)
                delta = difflib.unified_diff(before, after, fromfile=f'{a}/{rel}', tofile=f'{b}/{rel}')
                (diff_dir / (rel.replace('/', '__') + '.diff')).write_text(''.join(delta))
            if 'elf_machine' in left[rel] and 'elf_machine' in right[rel]:
                filename = rel.replace('/', '__') + '.txt'
                old = set((args.root / a / 'strings' / filename).read_text().splitlines())
                new = set((args.root / b / 'strings' / filename).read_text().splitlines())
                (diff_dir / (filename + '.added')).write_text('\n'.join(sorted(new-old)) + '\n')
                (diff_dir / (filename + '.removed')).write_text('\n'.join(sorted(old-new)) + '\n')
    report = {'hardware': manifest['hardware'], 'retrieved_at':manifest['retrieved_at'], 'unavailable':manifest.get('unavailable', []), 'inventories': inventories, 'comparisons':comparisons}
    (args.report / 'comparison.json').write_text(json.dumps(report, indent=2) + '\n')
    lines = [f'# HW{manifest["hardware"]} firmware comparison', '', f'Retrieved: {manifest["retrieved_at"]}', '', '| Version | Tar bytes | app.img bytes | Files/symlinks | app.img archive timestamp (UTC) |', '|---|---:|---:|---:|---|']
    for release in manifest['releases']:
        app = next(m for m in release['members'] if m['name'] == 'app.img')
        timestamp = datetime.fromtimestamp(app['mtime'], timezone.utc).isoformat()
        lines.append(f'| {release["version"]} | {release["size"]:,} | {app["size"]:,} | {len(inventories[str(release["version"])])} | {timestamp} |')
    lines += ['', '## Pairwise file comparison', '', 'Files are compared by content, permission bits, and symlink targets; timestamps are excluded.', '', '| From | To | Identical | Changed | Added | Removed |', '|---:|---:|---:|---:|---:|---:|']
    for c in comparisons:
        lines.append(f'| {c["from"]} | {c["to"]} | {len(c["identical"])} | {len(c["changed"])} | {len(c["added"])} | {len(c["removed"])} |')
    for c in comparisons:
        lines += ['', f'### {c["from"]} → {c["to"]}', '']
        for kind in ('changed', 'added', 'removed'):
            if c[kind]:
                lines.append(f'{kind.capitalize()}: ' + ', '.join(f'`{p}`' for p in c[kind]) + '.')
                lines.append('')
    lines += ['## Advertised but unavailable', '']
    for missing in manifest.get('unavailable', []):
        lines.append(f'- v{missing["version"]}: {missing["reason"]}')
    lines += ['', '## Archive SHA-256', '']
    for r in manifest['releases']:
        lines.append(f'- v{r["version"]}: `{r["sha256"]}`')
    lines += ['', '## Scope and verification', '', f'Source: {manifest["history_source"]}', '', 'Each downloaded tar matches the byte count and the first and final chunks from the appdatas endpoint. The bundled app.img MD5 matches in every release. Every tar and extracted file has a locally calculated SHA-256. These hashes establish local identity, not publisher authenticity. No firmware code was executed.', '', f'Unlisted archive discovery range: {manifest["probe_range"]}. See firmwares/hw501/discovery.json for exact HTTP and API outcomes. Unlisted files with different naming conventions and versions outside this range are outside this comparison.', '']
    (args.report / 'comparison.md').write_text('\n'.join(lines))


if __name__ == '__main__':
    main()
