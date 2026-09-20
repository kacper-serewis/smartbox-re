# Temporary dongle mirroring test

This workflow runs the corrected video bridge in RAM on the owned smartBox-9302
with the restored HW501 v131 density137.5 application. It does not flash firmware.
The Mac and iPhone must join the dongle Wi-Fi; leave the dongle connected to the
prepared Mac USB port to inspect its car-facing video output.

Build the test payload using the existing pinned dependencies:

```sh
docker run --rm --platform linux/amd64 --network none \
  -v "$PWD:/work:ro" \
  -v "$PWD/firmwares/research/mirror-deps:/deps:ro" \
  -v "$PWD/firmwares/research/mirroring-riscv:/build" \
  smartbox-mirror-builder:local sh /work/experiments/mirroring/build-bench.sh
python3 scripts/test_mirroring_bench.py
python3 scripts/test_bench_socket.py
python3 scripts/bench_mirroring.py prepare
```

Save the printed evidence directory as `BENCH_SESSION`. If the RAM directory
already exists from an earlier test, use that test's saved directory and run
`refresh` instead of `prepare`. Refresh refuses a running experimental app.
It removes the previous RAM capture, so collect evidence first.

```sh
python3 scripts/bench_mirroring.py start --session "$BENCH_SESSION" --seconds 300
python3 scripts/bench_mirroring.py status --session "$BENCH_SESSION"
```

Choose **SmartBox Mirror** in iPhone Screen Mirroring and use the PIN in status.
Run the already-prepared Mac head-unit receiver:

```sh
.venv/bin/python scripts/mac_usb_session_probe.py --run --stage network --preview --seconds 45
```

The browser shows video received over USB from the dongle. Compare landscape,
portrait, and return to landscape. A waiting screen or zero decoded frames is
not a successful mirroring test. The Mac accepting a stream does not prove the
Corsa accepts its codec settings and dimensions.

Collect the incoming phone stream and restore the original application:

```sh
python3 scripts/bench_mirroring.py collect --session "$BENCH_SESSION"
python3 scripts/bench_mirroring.py stop --session "$BENCH_SESSION"
```

An independent launcher also restarts the original application after at most
300 seconds, or after experimental child exit, startup failure, or a termination
signal. It checks process identity, preserves the original arguments/environment,
and signals only the application PID. It does not signal the updater's process
group. The restarted application retains a small RAM-only socket compatibility
library: vendor background processes inherit a fixed USB notification socket
(netlink protocol 26, port 53), preventing a normal second bind. The library
reuses only that exact inherited socket after `EADDRINUSE`. Without this
compatibility step the original executable restarts but its USB initialization
loops. A power cycle removes the compatibility library. This mechanism cannot
recover a kernel hang, power loss, or failure to execute the original application.

The incoming capture is limited to 8 MiB / 120 seconds of video. USB evidence is
saved separately by the Mac receiver. Captures include whatever the phone shows;
keep the ignored evidence directories private. Audio is discarded in this test.
The permanent mode selection and recovery latch are not changed.

For another run, collect first, stop, then `refresh` and `start` using the same
session directory. A partial refresh blocks startup until a successful refresh.
Changing the socket library while it is active requires replugging first.
Replugging the dongle removes all RAM payloads; use `prepare` again afterwards.
