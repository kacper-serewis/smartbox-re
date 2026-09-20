#!/usr/bin/env python3
"""Internal bounded probe; run only in the disposable emulation container."""
import argparse
from collections import Counter
import json
from pathlib import Path
import re
import shutil
import subprocess

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("--andes", action="store_true")
args = parser.parse_args()
output = Path("/evidence")
sysroot = Path("/toolchains/riscv32-ilp32d--glibc--stable-2024.05-1/riscv32-buildroot-linux-gnu/sysroot")
emulator = "/qemu/qemu-riscv32" if args.andes else "qemu-riscv32"
command = [emulator] + (["-cpu", "andes-a25"] if args.andes else [])
command += ["-strace", "-L", str(sysroot), "-E", f"LD_LIBRARY_PATH=/mnt/app/lib:{sysroot}/lib:{sysroot}/usr/lib",
            "/mnt/app/bin/CPAAProxyEx"]
version = subprocess.check_output([emulator, "--version"], text=True).splitlines()[0]
with (output / "startup.log").open("w") as log:
    result = subprocess.run(["timeout", "--kill-after=2", "8"] + command, stdout=log, stderr=subprocess.STDOUT)
text = (output / "startup.log").read_text(errors="replace")
app_logs = Path("/mnt/UDISK/logs")
if app_logs.is_dir():
    for file in app_logs.iterdir():
        if file.is_file() and file.stat().st_size < 16 * 1024 * 1024:
            shutil.copy2(file, output / ("app-" + file.name))
report = {"emulator": version, "cpu": "andes-a25" if args.andes else "default",
          "exit_code": result.returncode, "time_limited": result.returncode in (124, 137),
          "illegal_instruction_signal": bool(re.search(r"--- SIGILL", text)),
          "segmentation_fault_signal": bool(re.search(r"--- SIGSEGV", text)),
          "thread_clone_calls": text.count("clone("),
          "missing_device_paths": sorted(set(re.findall(r'"(/dev/[^"\n]+)"[^\n]*errno=2', text))),
          "strace_unknown_labels": dict(Counter(re.findall(r"Unknown syscall (\d+)", text))),
          "note": "Unknown syscall text can mean an absent strace label, not missing emulation. This is an app probe with substitute libc, not a firmware boot."}
(output / "report.json").write_text(json.dumps(report, indent=2) + "\n")
print(json.dumps(report, indent=2))
