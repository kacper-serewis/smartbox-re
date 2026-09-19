#!/usr/bin/env python3
"""Build, re-extract, and verify the experimental HW501/v131 density image offline."""
from datetime import datetime, timezone
import hashlib
import json
import os
import re
from pathlib import Path
import shutil
import subprocess
import tarfile
import tempfile

from display_patch import patch

ROOT=Path(__file__).resolve().parents[1]
SOURCE=ROOT/'firmwares/hw501/131'
OUTPUT=ROOT/'firmwares/experiments/hw501_131_density125'


def sha(data):return hashlib.sha256(data).hexdigest()


def inventory(root):
    result={}
    for p in sorted(root.rglob('*')):
        rel=p.relative_to(root).as_posix()
        if p.is_symlink():result[rel]=('link',str(p.readlink()))
        elif p.is_file():result[rel]=('file',sha(p.read_bytes()),p.stat().st_mode&0o7777)
        elif p.is_dir():result[rel]=('dir',p.stat().st_mode&0o7777)
    return result


def main():
    for tool in ('mksquashfs','unsquashfs'):
        if not shutil.which(tool):raise SystemExit(f'Missing tool: {tool}')
    original=(SOURCE/'rootfs/bin/CPAAProxyEx').read_bytes()
    modified,details=patch(original)
    OUTPUT.mkdir(parents=True,exist_ok=True)
    with tempfile.TemporaryDirectory(prefix='smartbox-density-') as temporary:
        temp=Path(temporary);tree=temp/'rootfs';baseline=temp/'baseline'
        original_listing=subprocess.check_output(['unsquashfs','-lln',str(SOURCE/'archive/app.img')],text=True)
        owners={line.split()[1] for line in original_listing.splitlines() if re.match(r'^[dl-][rwxstST-]{9} ',line)}
        if len(owners)!=1:raise ValueError('Expected uniform stock filesystem ownership')
        uid,gid=next(iter(owners)).split('/')
        # Fresh extraction with umask zero preserves group-write bits that can
        # be lost when using the earlier research extraction as build input.
        subprocess.run(['unsquashfs','-no-progress','-d',str(baseline),str(SOURCE/'archive/app.img')],capture_output=True,check=True,umask=0)
        shutil.copytree(baseline,tree,symlinks=True)
        executable=tree/'bin/CPAAProxyEx';info=executable.stat()
        executable.write_bytes(modified);os.utime(executable,ns=(info.st_atime_ns,info.st_mtime_ns))
        old=inventory(baseline);new=inventory(tree)
        assert old.keys()==new.keys()
        assert [name for name in old if old[name]!=new[name]]==['bin/CPAAProxyEx']
        source_manifest=json.loads((SOURCE/'manifest.json').read_text())
        timestamp=next(m['mtime'] for m in source_manifest['members'] if m['name']=='app.img')
        image=temp/'app.img'
        result=subprocess.run(['mksquashfs',str(tree),str(image),'-comp','xz','-b','262144','-noappend','-no-progress','-no-xattrs','-force-uid',uid,'-force-gid',gid,'-mkfs-time',str(timestamp)],capture_output=True,text=True)
        (OUTPUT/'build.log').write_text(result.stdout+result.stderr);result.check_returncode()
        if image.stat().st_size>0x500000:raise ValueError('Image exceeds the observed 5 MiB app partition')
        extracted=temp/'verified'
        result=subprocess.run(['unsquashfs','-no-progress','-d',str(extracted),str(image)],capture_output=True,text=True,umask=0)
        (OUTPUT/'verification.log').write_text(result.stdout+result.stderr);result.check_returncode()
        assert inventory(extracted)==new,'Re-extracted filesystem differs from build inputs'
        new_listing=subprocess.check_output(['unsquashfs','-lln',str(image)],text=True)
        assert original_listing==new_listing,'Stock filesystem ownership/modes/timestamps/sizes changed'
        image_data=image.read_bytes();md5=(hashlib.md5(image_data).hexdigest()+'\n').encode()
        archive=OUTPUT/'hw501_131.tar'
        with tarfile.open(SOURCE/'hw501_131.tar','r:') as original_tar,tarfile.open(archive,'w',format=tarfile.GNU_FORMAT) as new_tar:
            import io
            for name,data in [('app.img',image_data),('appmd5sum.txt',md5)]:
                entry=original_tar.getmember(name);entry.size=len(data)
                new_tar.addfile(entry,io.BytesIO(data))
        (OUTPUT/'archive').mkdir(exist_ok=True)
        shutil.copy2(image,OUTPUT/'archive/app.img')
        (OUTPUT/'archive/appmd5sum.txt').write_bytes(md5)
        (OUTPUT/'CPAAProxyEx.patched').write_bytes(modified)
        raw=archive.read_bytes();step=32768
        manifest={'version':131,'hardware':501,'label':'EXPERIMENTAL v131 density125 (physical metadata only)','built_at':datetime.now(timezone.utc).isoformat(),'source':'Local patch of archived stock HW501 v131','size':len(raw),'sha256':sha(raw),'parent_archive_sha256':source_manifest['sha256'],'app_size':len(image_data),'app_partition_limit':0x500000,'app_md5':md5.decode().strip(),'chunk_metadata':{'result':1,'version':131,'pos':0,'itemsize':step,'count':(len(raw)+step-1)//step,'filesize':len(raw),'datasize':step},'changed_files':['bin/CPAAProxyEx'],'patch':details,'verification':'Re-extracted filesystem matches inputs, only CPAAProxyEx content differs from stock. Runtime behavior and iOS zoom eligibility are not yet validated.'}
        (OUTPUT/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
        report=ROOT/'reports/display';report.mkdir(exist_ok=True)
        (report/'patch.json').write_text(json.dumps(manifest,indent=2)+'\n')
        print(f'Built: {archive}\nApp image: {len(image_data):,} / 5,242,880 bytes\nArchive SHA256: {manifest["sha256"]}\nVerified: only CPAAProxyEx changed; original display objects remain unmodified by the tested hook.')


if __name__=='__main__':main()
