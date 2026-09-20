#!/usr/bin/env python3
"""Reproducible QEMU mode-service tests and isolated stock application probes."""
import argparse
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import subprocess

from build_mode_service import ROOT, TOOLCHAINS, setup

RESEARCH = ROOT / "firmwares/research"
ANDES = RESEARCH / "qemu-andes"
ANDES_BUILD = RESEARCH / "qemu-andes-build"
ANDES_REV = "32902627f26c5d760cd4efab499b989d566822f9"
IMAGE = "smartbox-emulation:local"


def setup_andes():
    if not ANDES.exists():
        subprocess.run(["git", "init", str(ANDES)], check=True)
        subprocess.run(["git", "-C", str(ANDES), "remote", "add", "origin", "https://github.com/andestech/qemu.git"], check=True)
        subprocess.run(["git", "-C", str(ANDES), "fetch", "--depth", "1", "origin", ANDES_REV], check=True)
        subprocess.run(["git", "-C", str(ANDES), "checkout", "--detach", "FETCH_HEAD"], check=True)
    actual = subprocess.check_output(["git", "-C", str(ANDES), "rev-parse", "HEAD"], text=True).strip()
    if actual != ANDES_REV:
        raise RuntimeError(f"Expected Andes QEMU revision {ANDES_REV}; existing checkout left unchanged")
    patch = ROOT / "experiments/emulation/andes-glibc-sched-attr.patch"
    current = subprocess.check_output(["git", "-C", str(ANDES), "diff", "--", "linux-user/syscall.c"])
    other = subprocess.check_output(["git", "-C", str(ANDES), "diff", "--name-only"], text=True).splitlines()
    if any(name != "linux-user/syscall.c" for name in other):
        raise RuntimeError("Unexpected Andes checkout modifications")
    if not current:
        subprocess.run(["git", "-C", str(ANDES), "apply", str(patch)], check=True)
    elif current != patch.read_bytes():
        raise RuntimeError("Andes compatibility patch differs from the recorded patch")
    subprocess.run(["docker", "build", "--platform", "linux/amd64", "-f", str(ROOT / "experiments/emulation/Dockerfile.andes"),
                    "-t", "smartbox-andes-builder:local", str(ROOT / "experiments/emulation")], check=True)
    ANDES_BUILD.mkdir(parents=True, exist_ok=True)
    subprocess.run(["docker", "run", "--rm", "--platform", "linux/amd64", "-v", f"{ANDES}:/source",
                    "-v", f"{ANDES_BUILD}:/build", "-w", "/build", "smartbox-andes-builder:local", "sh", "-c",
                    "/source/configure --target-list=riscv32-linux-user --without-default-features --disable-docs --disable-werror --disable-tools --disable-guest-agent && ninja -j6 qemu-riscv32"], check=True)


def base():
    return ["docker", "run", "--rm", "--platform", "linux/amd64", "--network", "none", "--read-only",
            "--cap-drop", "ALL", "--security-opt", "no-new-privileges", "--pids-limit", "128", "--memory", "512m", "--cpus", "2",
            "--tmpfs", "/tmp:rw,exec,nosuid,size=128m", "-v", f"{ROOT}:/work:ro"]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--setup", action="store_true", help="prepare verified RV32 toolchain and regular QEMU container")
    parser.add_argument("--setup-andes", action="store_true", help="build pinned Andes QEMU with host-header compatibility fix")
    parser.add_argument("--mode-tests", action="store_true", help="run actual RV32 service API/persistence tests in QEMU")
    parser.add_argument("--stock", action="store_true", help="probe the archived stock CPAAProxyEx for eight seconds")
    parser.add_argument("--andes", action="store_true", help="use Andes QEMU for the stock probe")
    args = parser.parse_args()
    if args.setup:
        setup()
    if args.setup_andes:
        setup_andes()
    if args.mode_tests:
        command = base() + ["-e", 'SMARTBOX_MODE_COMMAND=["qemu-riscv32","/work/firmwares/research/mode-build/smartbox-mode-riscv32"]',
                            IMAGE, "python3", "scripts/test_mode_service.py"]
        subprocess.run(command, check=True, timeout=90)
    if args.stock:
        output = RESEARCH / "emulation" / ("probe-" + datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%S.%fZ"))
        output.mkdir(parents=True)
        command = base() + ["--tmpfs", "/mnt/UDISK:rw,nosuid,size=32m", "-v", f"{TOOLCHAINS}:/toolchains:ro",
                            "-v", f"{ROOT / 'firmwares/hw501/131/rootfs'}:/mnt/app:ro", "-v", f"{output}:/evidence"]
        if args.andes:
            command += ["-v", f"{ANDES_BUILD}:/qemu:ro"]
        command += [IMAGE, "python3", "scripts/probe_firmware_guest.py"]
        if args.andes:
            command.append("--andes")
        subprocess.run(command, check=True, timeout=30)
        provenance = {"stock_application_sha256": hashlib.sha256((ROOT / "firmwares/hw501/131/rootfs/bin/CPAAProxyEx").read_bytes()).hexdigest(),
                      "andes_revision": ANDES_REV if args.andes else None,
                      "andes_patch_sha256": hashlib.sha256((ROOT / "experiments/emulation/andes-glibc-sched-attr.patch").read_bytes()).hexdigest() if args.andes else None,
                      "device_access": False, "network": "none", "source_mount": "read-only"}
        (output / "provenance.json").write_text(json.dumps(provenance, indent=2) + "\n")
        print(f"Evidence: {output}")


if __name__ == "__main__":
    main()
