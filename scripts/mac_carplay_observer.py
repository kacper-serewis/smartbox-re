"""Observe one bounded HTTP/RTSP request on the prepared Mac USB interface."""
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
    for _ in range(15):
        config = subprocess.check_output(['/sbin/ifconfig', name], text=True, timeout=5)
        match = re.search(r'inet6 (fe80:[0-9a-f:]+)%' + re.escape(name) + r'\s', config, re.I)
        if match:
            host = str(ipaddress.IPv6Address(match[1]))
            return name, host, socket.if_nametoindex(name)
        time.sleep(0.1)
    raise RuntimeError('USB link-local IPv6 address is not ready')


class USBObserver:
    def __init__(self, output):
        self.output = output
        self.records = []
        self.stop = threading.Event()
        self.name, self.host, self.scope = usb_endpoint()
        self.socket = socket.socket(socket.AF_INET6, socket.SOCK_STREAM)
        self.socket.setsockopt(socket.IPPROTO_IPV6, socket.IPV6_V6ONLY, 1)
        self.socket.bind((self.host, 0, 0, self.scope))
        self.socket.listen(1)
        self.socket.settimeout(0.2)
        self.port = self.socket.getsockname()[1]
        self.thread = threading.Thread(target=self.serve, daemon=True)
        self.thread.start()
        ready = output / 'network-ready.json'
        temporary = output / 'network-ready.tmp'
        temporary.write_text(json.dumps(dict(host=self.host, port=self.port, interface=self.name)))
        temporary.replace(ready)

    def serve(self):
        deadline = time.monotonic() + 12
        try:
            while not self.stop.is_set() and time.monotonic() < deadline:
                try:
                    connection, peer = self.socket.accept()
                except socket.timeout:
                    continue
                with connection:
                    if peer[3] != self.scope or not ipaddress.IPv6Address(peer[0].split('%')[0]).is_link_local:
                        continue
                    connection.settimeout(1)
                    data = b''
                    while b'\r\n\r\n' not in data and len(data) < 8192:
                        if self.stop.is_set() or time.monotonic() >= deadline:
                            raise OSError('Observer deadline reached')
                        block = connection.recv(min(1024, 8192 - len(data)))
                        if not block:
                            break
                        data += block
                    header = data.split(b'\r\n\r\n', 1)[0]
                    lines = header.decode('ascii', errors='replace').split('\r\n')
                    request = lines[0] if lines else ''
                    length = next((line.split(':', 1)[1].strip() for line in lines if line.lower().startswith('content-length:')), '0')
                    body = data.split(b'\r\n\r\n', 1)[1] if b'\r\n\r\n' in data else b''
                    if not length.isdecimal() or len(length) > 5 or int(length) > 65536:
                        raise OSError('Request body exceeds observer bound')
                    while len(body) < int(length):
                        if self.stop.is_set() or time.monotonic() >= deadline:
                            raise OSError('Observer deadline reached')
                        block = connection.recv(min(4096, int(length) - len(body)))
                        if not block:
                            raise OSError('Request body ended early')
                        body += block
                    self.records.append(dict(peer=peer[0], interface=self.name, request=request,
                                             header=lines, body_hex=body[:int(length)].hex(), captured_bytes=len(header) + 4 + int(length)))
                    # Explicitly an observer, not a working AirPlay/video receiver.
                    version = 'RTSP/1.0' if request.endswith('RTSP/1.0') else 'HTTP/1.1'
                    sequence = next((line.split(':', 1)[1].strip() for line in lines if line.lower().startswith('cseq:')), '')
                    extra = ('CSeq: ' + sequence + '\r\n') if sequence.isdecimal() and len(sequence) < 12 else ''
                    connection.sendall((version + ' 501 Not Implemented\r\n' + extra + 'Content-Length: 0\r\nConnection: close\r\n\r\n').encode())
                    break
        except OSError as error:
            self.records.append(dict(error=str(error)))
        finally:
            (self.output / 'network-requests.json').write_text(json.dumps(self.records, indent=2) + '\n')

    def close(self):
        self.stop.set()
        self.thread.join(timeout=2)
        self.socket.close()
