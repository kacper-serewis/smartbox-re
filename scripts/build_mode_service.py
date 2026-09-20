#!/usr/bin/env python3
"""Build native/RV32 mode service and a staging bundle (not a flashable image)."""
import argparse
import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import tarfile
import urllib.request

ROOT = Path(__file__).resolve().parents[1]
BUILD = ROOT / "firmwares/research/mode-build"
TOOLCHAIN_NAME = "riscv32-ilp32d--glibc--stable-2024.05-1"
TOOLCHAINS = ROOT / "firmwares/research/toolchains"
TOOLCHAIN_SHA = "00112418e6d4b0733019a673b682a39f1ce6300b9448cd840f1194aa4b064192"


def setup():
    TOOLCHAINS.mkdir(parents=True, exist_ok=True)
    archive = TOOLCHAINS / f"{TOOLCHAIN_NAME}.tar.xz"
    if not archive.exists():
        url = f"https://toolchains.bootlin.com/downloads/releases/toolchains/riscv32-ilp32d/tarballs/{archive.name}"
        temporary = archive.with_suffix(".download")
        print(f"Downloading pinned toolchain: {url}", flush=True)
        urllib.request.urlretrieve(url, temporary)
        temporary.rename(archive)
    if hashlib.sha256(archive.read_bytes()).hexdigest() != TOOLCHAIN_SHA:
        raise RuntimeError("Bootlin archive checksum mismatch")
    if not (TOOLCHAINS / TOOLCHAIN_NAME).exists():
        with tarfile.open(archive) as tf:
            tf.extractall(TOOLCHAINS, filter="data")
    subprocess.run(["docker", "build", "--platform", "linux/amd64", "-t", "smartbox-emulation:local",
                    str(ROOT / "experiments/emulation")], check=True)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--setup", action="store_true", help="download verified compiler and build QEMU container")
    parser.add_argument("--riscv", action="store_true", help="also build the static RV32 Linux binary and staging bundle")
    args = parser.parse_args()
    if args.setup:
        setup()
    BUILD.mkdir(parents=True, exist_ok=True)
    subprocess.run(["cc", "-std=c11", "-O2", "-Wall", "-Wextra", "-Werror",
                    str(ROOT / "experiments/mode/mode_service.c"), "-o", str(BUILD / "smartbox-mode")], check=True)
    if not args.riscv:
        print(f"Native executable: {BUILD / 'smartbox-mode'}")
        return
    subprocess.run(["docker", "run", "--rm", "--platform", "linux/amd64", "--network", "none", "--read-only",
                    "--tmpfs", "/tmp:rw,exec,nosuid,size=128m", "-v", f"{TOOLCHAINS}:/toolchains:ro",
                    "-v", f"{ROOT / 'experiments/mode'}:/src:ro", "-v", f"{BUILD}:/out", "smartbox-emulation:local",
                    f"/toolchains/{TOOLCHAIN_NAME}/bin/riscv32-buildroot-linux-gnu-gcc",
                    "-Os", "-s", "-static", "-std=c11", "-Wall", "-Wextra", "-Werror",
                    "/src/mode_service.c", "-o", "/out/smartbox-mode-riscv32"], check=True)
    output = ROOT / "firmwares/experiments/connection-mode"
    (output / "bin").mkdir(parents=True, exist_ok=True)
    (output / "web").mkdir(exist_ok=True)
    shutil.copy2(BUILD / "smartbox-mode-riscv32", output / "bin/smartbox-mode")
    for name in ("index.html", "mode.js"):
        shutil.copy2(ROOT / "experiments/mode/web" / name, output / "web" / name)
    # Prepare integration into both stock settings pages without editing archives.
    (output / "stock-web").mkdir(exist_ok=True)
    for name, label in (("index_cptowlcp_en.html", "Connection mode"), ("index_cptowlcp.html", "连接模式")):
        raw = (ROOT / "firmwares/hw501/131/rootfs/web" / name).read_bytes()
        marker = b'<div class="weui-cells">'
        if marker not in raw:
            raise RuntimeError(f"Expected settings section missing in {name}")
        row = ('\r\n<a class="weui-cell weui-cell_access" href="#" onclick="event.preventDefault();'
               'var u=new URL(window.location.href);u.port=8081;u.pathname=\'/\';u.search=\'\';u.hash=\'\';window.location.href=u.href;">'
               f'<div class="weui-cell__bd">{label}</div><div class="weui-cell__ft"></div></a>').encode()
        (output / "stock-web" / name).write_bytes(raw.replace(marker, marker + row, 1))
    manifest = {"kind": "staging_bundle", "flashable": False, "hardware_target": "HW501 RV32 ILP32D Linux",
                "toolchain": TOOLCHAIN_NAME, "toolchain_archive_sha256": TOOLCHAIN_SHA,
                "requires": ["verified firmware startup integration", "device mode driver preserving car-facing transport",
                             "dongle mirroring receiver and video bridge"], "files": {}}
    for path in sorted(output.rglob("*")):
        if path.is_file() and path.name != "manifest.json":
            manifest["files"][str(path.relative_to(output))] = {"bytes": path.stat().st_size,
                                                              "sha256": hashlib.sha256(path.read_bytes()).hexdigest()}
    (output / "manifest.json").write_text(json.dumps(manifest, indent=2) + "\n")
    print(f"RV32 executable: {BUILD / 'smartbox-mode-riscv32'}\nStaging bundle: {output}\nNot a flashable firmware image.")


if __name__ == "__main__":
    main()
