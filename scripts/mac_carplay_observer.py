"""Bounded AirPlay bench handshake on the prepared Mac USB interface."""
import ipaddress
import json
import plistlib
import re
import socket
import subprocess
import threading
import time


def usb_endpoint():
    tree = plistlib.loads(subprocess.check_output(['ioreg', '-a', '-l', '-p', 'IOService'], timeout=10))
    names = []

    def walk(node, path):
        path += '/' + node.get('IORegistryEntryName', '')
        name = node.get('BSD Name', '')
        if '/usb-drd1/AppleT8142USBXDCI/' in path and re.fullmatch(r'en\d+', name):
            names.append(name)
        for child in node.get('IORegistryEntryChildren', []):
            walk(child, path)

    for node in [tree] if isinstance(tree, dict) else tree:
        walk(node, '')
    if len(set(names)) != 1:
        raise RuntimeError('Expected one Ethernet interface under the prepared USB device controller')
    name = names[0]
    # A fresh app start may need several seconds to enumerate NCM.
    deadline = time.monotonic() + 10
    while time.monotonic() < deadline:
        config = subprocess.check_output(['/sbin/ifconfig', name], text=True, timeout=5)
        match = re.search(r'inet6 (fe80:[0-9a-f:]+)%' + re.escape(name) + r'\s', config, re.I)
        if match:
            host = str(ipaddress.IPv6Address(match[1]))
            return name, host, socket.if_nametoindex(name)
        time.sleep(0.1)
    raise RuntimeError('USB link-local IPv6 address is not ready')


class USBObserver:
    def __init__(self, output, identity=None, seconds=12):
        if not 1 <= seconds <= 42:
            raise ValueError("Receiver duration must be 1..42 seconds")
        self.seconds = seconds
        self.output = output
        self.identity = identity
        self.media = None
        self.media_lock = threading.RLock()
        self.media_count = 0
        self.clients = []
        self.save_lock = threading.Lock()
        self.peer = None
        self.auth = None
        if identity:
            from mac_carplay_auth import BenchAuth
            self.auth = BenchAuth(*identity)
        self.records = []
        self.stop = threading.Event()
        self.name, self.host, self.scope = usb_endpoint()
        self.socket = socket.socket(socket.AF_INET6, socket.SOCK_STREAM)
        self.socket.setsockopt(socket.IPPROTO_IPV6, socket.IPV6_V6ONLY, 1)
        self.socket.bind((self.host, 0, 0, self.scope))
        self.socket.listen(4)
        self.socket.settimeout(0.2)
        self.port = self.socket.getsockname()[1]
        self.thread = threading.Thread(target=self.serve, daemon=True)
        self.thread.start()
        ready = output / 'network-ready.json'
        temporary = output / 'network-ready.tmp'
        temporary.write_text(json.dumps(dict(host=self.host, port=self.port, interface=self.name)))
        temporary.replace(ready)

    def save_records(self):
        with self.save_lock:
            temporary = self.output / 'network-requests.tmp'
            temporary.write_text(json.dumps(self.records, indent=2) + '\n')
            temporary.replace(self.output / 'network-requests.json')

    def serve(self):
        self.deadline = time.monotonic() + self.seconds
        try:
            while not self.stop.is_set() and time.monotonic() < self.deadline:
                try:
                    connection, peer = self.socket.accept()
                except socket.timeout:
                    continue
                if (peer[3] != self.scope or not ipaddress.IPv6Address(peer[0].split('%')[0]).is_link_local
                        or (self.peer and self.peer != peer[0]) or len(self.clients) >= 4):
                    connection.close()
                    continue
                self.peer = peer[0]
                thread = threading.Thread(target=self.handle, args=(connection, peer), daemon=True)
                self.clients.append(thread)
                thread.start()
        except OSError as error:
            if not self.stop.is_set():
                self.records.append(dict(error=str(error)))
        finally:
            for thread in self.clients:
                thread.join(timeout=1)
            self.save_records()

    def handle(self, connection, peer):
        auth, deadline = self.auth, self.deadline
        try:
            with connection:
                connection.settimeout(0.2)
                pending = b''
                for _ in range(256):
                    frame, pending = read_request(connection, pending, deadline, self.stop)
                    if frame is None:
                        break
                    request, lines, headers, body = frame
                    record = dict(peer=peer[0], interface=self.name, request=request,
                                  header=lines, body_hex=body.hex())
                    self.records.append(record)
                    status, response = 501, b''
                    content_type = 'application/octet-stream'
                    if request.split()[:2] == ['POST', '/auth-setup'] and auth:
                        try:
                            response = auth.exchange(body)
                            status = 200
                        except ValueError as error:
                            record['error'] = str(error)
                            status = 400
                    if request.split()[0] == 'SETUP' and auth and auth.cipher:
                        from mac_carplay_media import BenchMedia
                        try:
                            data = plistlib.loads(body)
                            if not isinstance(data, dict):
                                raise ValueError('SETUP must be a dictionary')
                            with self.media_lock:
                                if self.media is None:
                                    self.media_count += 1
                                    if self.media_count > 4:
                                        raise ValueError('Media session limit reached')
                                    media_output = self.output if self.media_count == 1 else self.output / ('media-%02d' % self.media_count)
                                    media_output.mkdir(mode=0o700, exist_ok=True)
                                    self.media = BenchMedia(self.host, self.scope, peer[0], media_output, self.stop, deadline)
                                    self.media.preview_output = self.output
                                result = (self.media.setup_streams(data) if 'streams' in data
                                          else self.media.initial_setup(data, auth))
                            response = plistlib.dumps(result, fmt=plistlib.FMT_BINARY)
                            content_type = 'application/x-apple-binary-plist'
                            status = 200
                        except (ValueError, plistlib.InvalidFileException) as error:
                            record['error'] = str(error)
                            status = 400
                    if request.split()[:2] == ['GET', '/info'] and auth and auth.cipher:
                        from mac_carplay_media import display_info
                        info = display_info()
                        (self.output / 'display-info.json').write_text(json.dumps(info, indent=2))
                        response = plistlib.dumps(info, fmt=plistlib.FMT_BINARY)
                        content_type = 'application/x-apple-binary-plist'
                        status = 200
                    if request.split()[:2] == ['POST', '/command'] and self.media:
                        try:
                            command = plistlib.loads(body)
                            if isinstance(command, dict) and command.get('type') in ('modesChanged', 'disableBluetooth'):
                                response = plistlib.dumps(dict(status=0), fmt=plistlib.FMT_BINARY)
                                content_type = 'application/x-apple-binary-plist'
                                status = 200
                        except (ValueError, plistlib.InvalidFileException):
                            status = 400
                    if request.split()[0] == 'TEARDOWN' and self.media:
                        try:
                            data = plistlib.loads(body) if body else {}
                            with self.media_lock:
                                if self.media is None:
                                    raise ValueError('No media session to tear down')
                                self.media.teardown(data)
                                if 'streams' not in data:
                                    self.media = None
                            status = 200
                        except (OSError, ValueError, plistlib.InvalidFileException) as error:
                            record['error'] = str(error)
                            status = 400
                    if (request.split()[0] in ('RECORD', 'SET_PARAMETER') or request.split()[:2] == ['POST', '/feedback']) and self.media:
                        status = 200
                    version = request.split()[-1]
                    reason = {200: 'OK', 400: 'Bad Request', 501: 'Not Implemented'}[status]
                    text = (f'{version} {status} {reason}\r\nCSeq: {headers["cseq"]}\r\n'
                            f'Content-Length: {len(response)}\r\nContent-Type: {content_type}\r\n\r\n')
                    connection.sendall(text.encode('ascii') + response)
                    record.update(response_status=status, response_bytes=len(response))
                    self.save_records()
                    if status != 200:
                        break
        except (OSError, ValueError) as error:
            if not self.stop.is_set():
                self.records.append(dict(error=str(error)))
        finally:
            self.save_records()

    def close(self):
        self.stop.set()
        self.thread.join(timeout=3)
        self.socket.close()
        with self.media_lock:
            if self.media:
                self.media.close()


def read_request(connection, pending, deadline, stop):
    """Bounded persistent framing; preserves bytes belonging to the next request."""
    def receive():
        while not stop.is_set() and time.monotonic() < deadline:
            try:
                return connection.recv(4096)
            except socket.timeout:
                pass
        raise OSError('Receiver deadline reached')

    while b'\r\n\r\n' not in pending:
        if len(pending) > 8192:
            raise ValueError('Header exceeds bound')
        block = receive()
        if not block:
            if pending:
                raise ValueError('Truncated header')
            return None, b''
        pending += block
    header, pending = pending.split(b'\r\n\r\n', 1)
    if len(header) > 8192:
        raise ValueError('Header exceeds bound')
    lines = header.decode('ascii').split('\r\n')
    words = lines[0].split()
    if len(words) != 3 or words[2] not in ('RTSP/1.0', 'HTTP/1.1'):
        raise ValueError('Unsupported request line')
    headers = {}
    for line in lines[1:]:
        name, separator, value = line.partition(':')
        name = name.lower().strip()
        if not separator or not name or name in headers:
            raise ValueError('Malformed or duplicate header')
        headers[name] = value.strip()
    if 'transfer-encoding' in headers:
        raise ValueError('Transfer encoding unsupported')
    length = headers.get('content-length', '0')
    sequence = headers.get('cseq', '')
    if not sequence.isdecimal() or len(sequence) > 10:
        raise ValueError('Invalid CSeq')
    if not length.isdecimal() or len(length) > 5 or int(length) > 65536:
        raise ValueError('Request body exceeds bound')
    length = int(length)
    while len(pending) < length:
        block = receive()
        if not block:
            raise ValueError('Truncated body')
        pending += block
    return (lines[0], lines, headers, pending[:length]), pending[length:]
