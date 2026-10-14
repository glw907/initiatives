#!/usr/bin/env python3
"""Stub Cloudflare API: argv[1] is a directory; the port goes to port; gone lists the 404 ids; code is the default status."""
import http.server
import os
import sys

D = sys.argv[1]


def read(name, default):
    try:
        return open(os.path.join(D, name)).read().strip() or default
    except OSError:
        return default


class H(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path.endswith("/workers/domains"):
            hosts = [h for h in read("domains", "keep.example").split(",") if h]
            self.send_response(200)
            self.end_headers()
            self.wfile.write(('{"result": [%s]}' % ",".join('{"hostname": "%s"}' % h for h in hosts)).encode())
            return
        rid = self.path.rsplit("/", 1)[-1]
        code = 404 if rid in read("gone", "").split(",") else int(read("code", "200"))
        self.send_response(code)
        self.end_headers()
        self.wfile.write(b"{}")

    def log_message(self, *a):
        pass


srv = http.server.HTTPServer(("127.0.0.1", 0), H)
with open(os.path.join(D, "port"), "w") as f:
    f.write(str(srv.server_port))
srv.serve_forever()
