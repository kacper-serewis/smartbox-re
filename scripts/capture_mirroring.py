#!/usr/bin/env python3
"""Build/run a local AirPlay H.264 capture receiver; never contacts the dongle."""
from __future__ import annotations

import argparse
from datetime import datetime, timezone
import json
import os
from pathlib import Path
import secrets
import shutil
import signal
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
UPSTREAM = ROOT / "firmwares/research/UxPlay"
BUILD = ROOT / "firmwares/research/mirroring-build"
REVISION = "57ea83411d5f7e0b38c5841987439340543f025c"
BINARY = BUILD / "mirror-capture"


def build() -> None:
    for command in ("git", "cmake", "pkg-config"):
        if not shutil.which(command):
            raise RuntimeError("Missing build tools. On macOS: brew install cmake pkgconf libplist openssl@3")
    if not UPSTREAM.exists():
        UPSTREAM.parent.mkdir(parents=True, exist_ok=True)
        subprocess.run(["git", "clone", "https://github.com/FDH2/UxPlay.git", str(UPSTREAM)], check=True)
        subprocess.run(["git", "-C", str(UPSTREAM), "checkout", "--detach", REVISION], check=True)
    actual = subprocess.check_output(["git", "-C", str(UPSTREAM), "rev-parse", "HEAD"], text=True).strip()
    dirty = subprocess.check_output(["git", "-C", str(UPSTREAM), "status", "--porcelain"], text=True).strip()
    if actual != REVISION or dirty:
        raise RuntimeError(f"Expected clean UxPlay checkout at {REVISION}; leaving existing checkout untouched.")
    command = ["cmake", "-S", str(ROOT / "experiments/mirroring"), "-B", str(BUILD),
               f"-DUXPLAY_SOURCE={UPSTREAM}", "-DCMAKE_BUILD_TYPE=Release"]
    if shutil.which("brew"):
        prefix = subprocess.check_output(["brew", "--prefix"], text=True).strip()
        command.append(f"-DCMAKE_PREFIX_PATH={prefix}")
    subprocess.run(command, check=True)
    subprocess.run(["cmake", "--build", str(BUILD), "--parallel", "4"], check=True)


def positive_int(value: str) -> int:
    result = int(value)
    if result <= 0:
        raise argparse.ArgumentTypeError("must be positive")
    return result


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--build", action="store_true", help="build the pinned receiver, then exit")
    parser.add_argument("--seconds", type=positive_int, default=180, help="maximum total runtime (default: 180)")
    parser.add_argument("--capture-seconds", type=positive_int, default=30, help="seconds after first video packet")
    parser.add_argument("--max-mib", type=positive_int, default=64, help="maximum saved video size")
    parser.add_argument("--name", default="SmartBox Mirror Lab", help="Screen Mirroring receiver name")
    args = parser.parse_args()
    if not args.name or len(args.name.encode()) > 50 or any(ord(c) < 32 for c in args.name):
        parser.error("receiver name must contain 1–50 UTF-8 bytes and no control characters")
    if args.build:
        build()
        print(f"Built: {BINARY}")
        return 0
    if not BINARY.is_file():
        raise RuntimeError("Build first: python3 scripts/capture_mirroring.py --build")
    os.umask(0o077)
    stamp = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%S.%fZ")
    output = ROOT / "device-snapshots" / f"mirroring-{stamp}"
    output.mkdir(parents=True, mode=0o700)
    mac = bytearray(secrets.token_bytes(6))
    mac[0] = (mac[0] | 2) & 0xFE
    device_id = ":".join(f"{b:02X}" for b in mac)
    manifest = {"receiver": args.name, "uxplay_revision": REVISION, "requested_size": [800, 480],
                "max_fps": 30, "wall_seconds": args.seconds, "capture_seconds": args.capture_seconds,
                "max_bytes": args.max_mib * 1024 * 1024, "stage": "mac_capture_only"}
    (output / "capture.json").write_text(json.dumps(manifest, indent=2) + "\n")
    print(f"Saving locally to: {output}\nKeep the Mac and iPhone on the same Wi-Fi.\n"
          f"Select {args.name} in Control Center > Screen Mirroring.\n"
          "The PIN will appear here. Audio is discarded; video is recorded, not displayed.\n"
          "Stop with Ctrl-C; capture also stops automatically.\n", flush=True)
    command = [str(BINARY), args.name, device_id, str(args.seconds), str(args.capture_seconds),
               str(manifest["max_bytes"]), "1"]
    # Separate process group: forward Ctrl-C once and allow native worker cleanup.
    with (output / "receiver.log").open("w") as log:
        proc = subprocess.Popen(command, cwd=output, stdout=subprocess.PIPE,
                                stderr=subprocess.STDOUT, text=True, start_new_session=True)
        previous = signal.getsignal(signal.SIGINT)
        signal.signal(signal.SIGINT, lambda *_: proc.send_signal(signal.SIGINT))
        try:
            assert proc.stdout is not None
            for line in proc.stdout:
                print(line, end="", flush=True)
                log.write(line)
                log.flush()
            status = proc.wait()
        finally:
            signal.signal(signal.SIGINT, previous)
            if proc.poll() is None:
                proc.terminate()
                try:
                    proc.wait(timeout=10)
                except subprocess.TimeoutExpired:
                    proc.kill()
                    proc.wait()
    from inspect_h264 import inspect
    video = output / "video.h264"
    if video.exists():
        report = inspect(video.read_bytes())
        (output / "video-analysis.json").write_text(json.dumps(report, indent=2) + "\n")
        print(json.dumps(report, indent=2))
        if not report["sps"]:
            print("No usable H.264 parameter set captured; this does not verify phone mirroring.")
    print(f"Capture saved: {output}")
    return status


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (RuntimeError, subprocess.CalledProcessError) as exc:
        print(f"Error: {exc}", file=sys.stderr)
        raise SystemExit(1)
