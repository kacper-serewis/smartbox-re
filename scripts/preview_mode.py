#!/usr/bin/env python3
"""Local interactive mode UI with an explicitly simulated device driver."""
import argparse
import os
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[1]
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("--state-dir", type=Path, default=ROOT / "device-snapshots/mode-preview")
parser.add_argument("--port", type=int, default=8081)
args = parser.parse_args()
if not 0 < args.port <= 65535:
    parser.error("--port must be in 1..65535")
os.umask(0o077)
output = args.state_dir.resolve()
output.mkdir(parents=True, exist_ok=True)
driver = output / "lab-driver"
driver.write_text('''#!/bin/sh
set -eu
printf 'simulated %s %s\\n' "$1" "$2" >&2
case "$1:$2" in
  probe:mirroring|probe:carplay|start:mirroring|start:carplay|stop:mirroring|stop:carplay) exit 0;;
  *) exit 1;;
esac
''')
driver.chmod(0o700)
print(f"Development preview only. State: {output}", flush=True)
command = [str(ROOT / "firmwares/research/mode-build/smartbox-mode"), "--state-dir", str(output),
           "--web-dir", str(ROOT / "experiments/mode/web"), "--driver", str(driver), "--port", str(args.port), "--lab"]
child = subprocess.Popen(command)
try:
    child.wait()
except KeyboardInterrupt:
    child.terminate()
    child.wait(timeout=8)
