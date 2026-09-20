# Live mirroring through the dongle's wired video output

On 2026-09-20, the corrected bridge ran temporarily in RAM on smartBox-9302
(HW501 app 131 / build 2026081801, density137.5 executable). The iPhone connected
to the dongle's UxPlay receiver. The prepared Mac acted as a wired CarPlay head
unit and decoded the dongle's USB video output.

## Result

- 799 USB frames decoded, zero decoder errors.
- 13 initial welcome-screen packets, followed by 786 phone video packets.
- All 786 phone packets matched the incoming stream byte for byte, including
  the associated SPS/PPS; no unmatched phone packets.
- USB codec dimensions changed from 800×480 welcome screen to 1200×552 phone
  landscape, then 332×720 phone portrait. Both phone orientations decoded.
- The longer input capture decoded 1,604 frames with zero errors. Capture and
  USB receiver windows differ; their total frame counts should not be equal.

Private evidence (ignored by Git):

- `device-snapshots/mirroring-bench-20260920T175424.500221Z/usb-comparison.json`
- The same directory's `video.h264`, `events.jsonl`, and `bench-session.json`.
- `device-snapshots/mac-usb-session-20260920T180513.409728Z/` contains decrypted
  packet records, decoder statistics, final image, protocol records and cleanup.
- `attempt-9933/` preserves an earlier input-only capture: 1,999 decoded frames,
  zero errors, with no USB forwarding because application startup was blocked.

## Restart blocker found during the test

The stock app opens a netlink protocol-26 notification socket on fixed port 53.
Its updater, Bluetooth processes, and hostapd inherit that descriptor. Killing
only the app leaves the socket bound. A restarted app loops in ProxyIAP2
initialization with `EADDRINUSE`, so neither normal output nor the bridge can
start. Restarting the executable alone is not sufficient restoration.

The RAM-only `bench_socket.c` compatibility library recognizes an inherited
socket with exactly that protocol, family, port and groups. If the stock bind
fails with `EADDRINUSE`, it duplicates that socket onto the requested descriptor.
It does not signal background services or alter their descriptors. Disposable
Linux tests verify successful reuse and reception, no-inheritance rejection,
unrelated-port rejection, and ordinary fresh binding.

The independent launcher uses this compatibility library for both the temporary
bridge and the restored original application. Restoration removes the mirroring
library; the small socket library remains in RAM until power cycle. Tests cover
child crash, termination, deadline, an unreaped original process, a second start
with the compatibility library, and wrong-process rejection.

The Mac receiver now allows up to ten seconds for its scoped USB IPv6 address
to appear. The earlier 1.5-second limit could abort while NCM was enumerating.

After stopping the test, `/proc` showed one original application with only the
socket compatibility library loaded, and the updater remained idle/reachable.
A follow-up USB session (`mac-usb-session-20260920T180630.159660Z`) authenticated
and reached RECORD. Its subsequent stream teardown/recreation hit the Mac
receiver's `Screen stream already started` restriction, so this follow-up does
not prove restored normal CarPlay video. Handling stream-scoped TEARDOWN is a
remaining Mac receiver task. The Mac host role and original configuration were
restored after both sessions.

## Limits

This validates the real dongle forwarding path and its codec changes against
the Mac decoder. It does not validate the Corsa's decoder, scaling, or acceptance
of dimensions beyond 800×480. No transcoding or screen-size rewriting is done.
Audio and touch forwarding are not implemented in this bench test. No firmware
was flashed, and the permanent mode selection/recovery latch was unchanged.

See the [RAM test guide](../../experiments/mirroring/BENCH.md).
