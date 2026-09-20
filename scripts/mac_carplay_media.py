"""USB-scoped, bounded timing/event sockets for the Mac head-unit bench test."""
import json
import plistlib
import socket
import struct
import threading
import time


def timestamp():
    return (time.monotonic_ns() * (1 << 32) // 1_000_000_000) & ((1 << 64) - 1)


class BenchMedia:
    def __init__(self, host, scope, peer, output, stop, deadline):
        self.host, self.scope, self.peer = host, scope, peer.split('%')[0]
        self.output, self.stop, self.deadline = output, stop, deadline
        self.sockets, self.threads, self.records = [], [], []
        self.key = None
        self.closed = threading.Event()
        self.streams = {}
        self.stream_count = 0
        self.is_stream = False
        self.video_budget = dict(bytes=32*1024*1024, frames=1800)

    def bind(self, kind):
        sock = socket.socket(socket.AF_INET6, kind)
        sock.setsockopt(socket.IPPROTO_IPV6, socket.IPV6_V6ONLY, 1)
        sock.bind((self.host, 0, 0, self.scope))
        sock.settimeout(0.15)
        if kind == socket.SOCK_STREAM:
            sock.listen(1)
        self.sockets.append(sock)
        return sock

    def spawn(self, target, *args):
        def worker():
            try:
                target(*args)
            except (OSError, ValueError) as error:
                if self.active():
                    self.records.append(dict(error=str(error), worker=target.__name__))
        thread = threading.Thread(target=worker, daemon=True)
        self.threads.append(thread)
        thread.start()

    def active(self):
        return not self.stop.is_set() and not self.closed.is_set() and time.monotonic() < self.deadline

    def initial_setup(self, data, auth):
        if self.sockets:
            raise ValueError('Initial setup already performed')
        if data.get('et') != 16 or not isinstance(data.get('ekey'), bytes) or len(data['ekey']) != 16:
            raise ValueError('Expected MFi-SAP session key')
        port = data.get('timingPort')
        if type(port) is not int or not 1 <= port <= 65535 or auth.cipher is None:
            raise ValueError('Invalid timing/auth setup')
        self.key = auth.cipher.update(data['ekey'])
        events = self.bind(socket.SOCK_STREAM)
        timing = self.bind(socket.SOCK_DGRAM)
        self.spawn(self.event_listener, events)
        self.spawn(self.timing, timing, port)
        return dict(eventPort=events.getsockname()[1], timingPort=timing.getsockname()[1])

    def setup_streams(self, data):
        streams = data.get('streams')
        if self.key is None or self.closed.is_set() or not isinstance(streams, list) or len(streams) != 1:
            raise ValueError('Expected one stream after initial setup')
        stream = streams[0]
        if not isinstance(stream, dict) or type(stream.get('type')) is not int:
            raise ValueError('Invalid stream description')
        kind = stream['type']
        if kind in self.streams:
            raise ValueError('Stream already started; TEARDOWN required')
        if self.stream_count >= 16:
            raise ValueError('Session stream setup limit reached')
        if kind in (100, 101):
            if stream.get('audioFormat') not in (2048, 32768):
                raise ValueError('Unsupported audio format')
        elif kind == 110:
            stream_id = stream.get('streamConnectionID')
            if type(stream_id) is not int or not -(1 << 63) <= stream_id < (1 << 64):
                raise ValueError('Invalid stream connection ID')
        else:
            raise ValueError('Unsupported bench stream format')
        self.stream_count += 1
        output = self.output / ('stream-%02d' % self.stream_count)
        output.mkdir(mode=0o700)
        group = BenchMedia(self.host, self.scope, self.peer, output, self.stop, self.deadline)
        group.key, group.records, group.is_stream = self.key, self.records, True
        group.preview_output = getattr(self, 'preview_output', self.output)
        group.video_budget = self.video_budget
        group.description = dict(stream)
        self.streams[kind] = group
        try:
            if kind in (100, 101):
                data_socket, control_socket = group.bind(socket.SOCK_DGRAM), group.bind(socket.SOCK_DGRAM)
                group.spawn(group.discard_audio, data_socket)
                group.spawn(group.discard_audio, control_socket)
                result = dict(type=kind, dataPort=data_socket.getsockname()[1], controlPort=control_socket.getsockname()[1])
            else:
                screen = group.bind(socket.SOCK_STREAM)
                group.spawn(group.video, screen, stream_id & ((1 << 64) - 1))
                result = dict(type=110, dataPort=screen.getsockname()[1])
            self.records.append(dict(event='stream_setup', type=kind, directory=output.name))
            return dict(streams=[result])
        except Exception:
            group.close()
            del self.streams[kind]
            raise

    def teardown(self, data):
        if not isinstance(data, dict):
            raise ValueError('TEARDOWN must be a dictionary')
        if 'streams' not in data:
            self.close()
            return
        streams = data['streams']
        if not isinstance(streams, list) or len(streams) > 3:
            raise ValueError('Invalid teardown stream list')
        selected = []
        for stream in streams:
            if not isinstance(stream, dict) or type(stream.get('type')) is not int or stream['type'] not in (100, 101, 110):
                raise ValueError('Invalid teardown stream description')
            kind = stream['type']
            group = self.streams.get(kind)
            if group:
                for key in ('uuid', 'streamConnectionID'):
                    if key in stream and stream[key] != group.description.get(key):
                        raise ValueError('Teardown stream identity mismatch')
                if kind not in selected:
                    selected.append(kind)
        # Validate the whole request before stopping any stream.
        for kind in selected:
            self.streams[kind].close()
            del self.streams[kind]
            self.records.append(dict(event='stream_teardown', type=kind))

    def discard_audio(self, sock):
        packets, received = 0, 0
        while self.active() and received < 16*1024*1024:
            try:
                data, peer = sock.recvfrom(65536)
            except socket.timeout:
                continue
            if peer[0].split('%')[0] == self.peer and peer[3] == self.scope:
                packets += 1
                received += len(data)
        self.records.append(dict(audio_discarded_packets=packets, audio_discarded_bytes=received))

    def video(self, sock, stream_id):
        from mac_carplay_video import capture
        connection = self.accept(sock)
        if connection:
            self.records.append(dict(event='video_connected'))
            with connection:
                capture(connection, self, stream_id)

    def accept(self, sock):
        while self.active():
            try:
                connection, peer = sock.accept()
            except socket.timeout:
                continue
            if peer[0].split('%')[0] == self.peer and peer[3] == self.scope:
                connection.settimeout(0.15)
                self.sockets.append(connection)
                return connection
            connection.close()
        return None

    def event_listener(self, sock):
        connection = self.accept(sock)
        if connection is None:
            return
        self.records.append(dict(event='event_connected'))
        with connection:
            while self.active():
                try:
                    data = connection.recv(8192)
                except socket.timeout:
                    continue
                if not data:
                    break
                if len(self.records) < 128:
                    self.records.append(dict(event_data_hex=data.hex()))

    def timing(self, sock, port):
        peer = (self.peer, port, 0, self.scope)
        next_send, sent, received = 0, 0, 0
        while self.active():
            now = time.monotonic()
            if now >= next_send:
                sock.sendto(struct.pack('>BBHIQQQ', 0x80, 0xD2, 7, 0, 0, 0, timestamp()), peer)
                sent += 1
                next_send = now + (0.05 if sent < 5 else 1)
            try:
                packet, remote = sock.recvfrom(256)
            except socket.timeout:
                continue
            if remote[0].split('%')[0] != self.peer or remote[3] != self.scope or remote[1] != port:
                continue
            if len(packet) != 32 or packet[0] != 0x80 or packet[2:4] != b'\x00\x07':
                continue
            if packet[1] == 0xD2:
                sock.sendto(struct.pack('>BBHIQQQ', 0x80, 0xD3, 7, 0,
                            int.from_bytes(packet[24:], 'big'), timestamp(), timestamp()), remote)
            elif packet[1] == 0xD3:
                received += 1
        self.records.append(dict(timing_sent=sent, timing_received=received))

    def close(self):
        self.closed.set()
        for group in self.streams.values():
            group.close()
        self.streams.clear()
        for sock in list(self.sockets):
            try:
                sock.shutdown(socket.SHUT_RDWR)
            except OSError:
                pass
            sock.close()
        for thread in self.threads:
            thread.join(timeout=5)
        if any(thread.is_alive() for thread in self.threads):
            raise ValueError('Stream worker did not stop; refusing replacement')
        if not self.is_stream:
            (self.output / 'media-events.json').write_text(json.dumps(self.records, indent=2) + '\n')


def display_info():
    """Minimal H.264 screen-only bench receiver, matching the Corsa pixel size."""
    return dict(deviceID='02:00:00:00:80:48', name='CarPlay', model='SmartBox Mac Bench',
                manufacturer='Local Development', sourceVersion='220.68', protocolVersion='1.0',
                firmwareRevision='0.1', hardwareRevision='1', statusFlags=0,
                features=(1 << 7) | (1 << 26) | (1 << 32) | (1 << 37),
                displays=[dict(uuid='7D2913E6-7BF3-42A9-82AB-AD87C70B0480', features=0,
                               widthPixels=800, heightPixels=480, widthPhysical=154,
                               heightPhysical=86, maxFPS=30)],
                audioFormats=[], audioLatencies=[], hidDevices=[], limitedUIElements=[],
                modes=dict(appStates=[dict(appStateID=1, speechMode=-1),
                                      dict(appStateID=2, state=False), dict(appStateID=3, state=False)],
                           resources=[dict(resourceID=1, transferType=2)],
                           initialPermanentEntity=[dict(resourceID=1, permanentEntity=1)]))
