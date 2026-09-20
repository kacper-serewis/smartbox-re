#!/usr/bin/env python3
"""Serve only a head-unit preview image and status on Mac loopback, for five minutes."""
import argparse
from http.server import BaseHTTPRequestHandler, HTTPServer
import json
from pathlib import Path
import time

PAGE = b'''<!doctype html><meta charset="utf-8"><title>SmartBox head-unit display</title>
<style>body{background:#15181c;color:#eee;font:17px system-ui;margin:28px}img{width:800px;max-width:95vw;background:#000}p{max-width:800px}</style>
<h1>SmartBox head-unit display</h1><p>Dongle USB output to Mac. This is the screen the dongle sends to the car.</p>
<p id="state">Waiting for the USB session...</p><img id="screen" alt="Waiting for dongle video">
<p>Audio is discarded. The USB test is temporary; the last received frame remains visible afterward.</p>
<script>setInterval(async()=>{try{let s=await(await fetch('/status')).json();document.querySelector('#state').textContent=s.message+(s.frames_decoded?' | '+s.width+'x'+s.height+' | '+s.frames_decoded+' frames | '+s.decode_errors+' decoder errors':'');if(s.frames_decoded)document.querySelector('#screen').src='/frame?t='+Date.now()}catch(e){}},400)</script>'''


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('output', type=Path)
    args = parser.parse_args()
    output = args.output.resolve()
    class Handler(BaseHTTPRequestHandler):
        def do_GET(self):
            route = self.path.split('?', 1)[0]
            if route == '/':
                data, mime = PAGE, 'text/html; charset=utf-8'
            elif route == '/frame':
                try:
                    data = (output / 'frame.jpg').read_bytes()
                except FileNotFoundError:
                    self.send_error(404); return
                mime = 'image/jpeg'
            elif route == '/status':
                status = dict(message='Waiting for video', frames_decoded=0)
                for filename in ('decoder.json', 'preview-state.json'):
                    try:
                        status.update(json.loads((output / filename).read_text()))
                    except (FileNotFoundError, json.JSONDecodeError):
                        pass
                if status.get('frames_decoded') and status['message'] == 'Waiting for video':
                    status['message'] = 'Receiving dongle USB display'
                data, mime = json.dumps(status).encode(), 'application/json'
            else:
                self.send_error(404); return
            self.send_response(200)
            self.send_header('Content-Type', mime)
            self.send_header('Content-Length', str(len(data)))
            self.send_header('Cache-Control', 'no-store')
            self.send_header('Connection', 'close')
            self.end_headers()
            try:
                self.wfile.write(data)
            except (BrokenPipeError, ConnectionResetError):
                pass
        def log_message(self, *_):
            pass
    server = HTTPServer(('127.0.0.1', 0), Handler)
    server.timeout = 0.5
    (output / 'preview-url.txt').write_text(f'http://127.0.0.1:{server.server_port}/\n')
    deadline = time.monotonic() + 300
    try:
        while time.monotonic() < deadline:
            server.handle_request()
    finally:
        server.server_close()


if __name__ == '__main__':
    main()
