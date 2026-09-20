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
                self.records.append(dict(error=str(error), worker=target.__name__))
        thread = threading.Thread(target=worker, daemon=True)
        self.threads.append(thread)
        thread.start()

    def active(self):
        return not self.stop.is_set() and time.monotonic() < self.deadline

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
        if self.key is None or not isinstance(streams, list) or len(streams) != 1:
            raise ValueError('Expected one screen stream after initial setup')
        stream = streams[0]
        if not isinstance(stream, dict):
            raise ValueError('Invalid stream description')
        if stream.get('type') in (100, 101) and stream.get('audioFormat') in (2048, 32768):
            if getattr(self, 'audio_streams', 0) >= 2:
                raise ValueError('Audio stream limit reached')
            self.audio_streams = getattr(self, 'audio_streams', 0) + 1
            data_socket, control_socket = self.bind(socket.SOCK_DGRAM), self.bind(socket.SOCK_DGRAM)
            self.spawn(self.discard_audio, data_socket)
            self.spawn(self.discard_audio, control_socket)
            return dict(streams=[dict(type=stream['type'], dataPort=data_socket.getsockname()[1],
                                      controlPort=control_socket.getsockname()[1])])
        if stream.get('type') != 110:
            raise ValueError('Unsupported bench stream format')
        stream_id = stream.get('streamConnectionID')
        if type(stream_id) is not int or not -(1 << 63) <= stream_id < (1 << 64):
            raise ValueError('Invalid stream connection ID')
        if getattr(self, 'screen_started', False):
            raise ValueError('Screen stream already started')
        self.screen_started = True
        screen = self.bind(socket.SOCK_STREAM)
        self.spawn(self.video, screen, stream_id & ((1 << 64) - 1))
        return dict(streams=[dict(type=110, dataPort=screen.getsockname()[1])])

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
        for sock in self.sockets:
            sock.close()
        for thread in self.threads:
            thread.join(timeout=0.5)
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
