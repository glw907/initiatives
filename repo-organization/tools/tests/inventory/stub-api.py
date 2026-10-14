#!/usr/bin/env python3
"""Serve canned Cloudflare API answers: stub-api.py FIXTURE.json PORTFILE EXPECTED_BEARER."""
import http.server
import json
import sys

FIX = json.load(open(sys.argv[1]))
EXPECTED = f"Bearer {sys.argv[3]}"


class H(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        if self.headers.get("Authorization") != EXPECTED:
            return self.reply(401, json.dumps({"success": False, "result": None}))
        e = FIX.get(self.path.split("?")[0])
        if e is None:
            return self.reply(404, "{}")
        self.reply(e.get("status", 200), e["raw"] if "raw" in e else
                   json.dumps({"success": True, "result": e["body"]}))

    def reply(self, code, text):
        self.send_response(code)
        self.send_header("Content-Type", "application/json")
        self.end_headers()
        self.wfile.write(text.encode())

    def log_message(self, *a):
        pass


srv = http.server.HTTPServer(("127.0.0.1", 0), H)
open(sys.argv[2], "w").write(str(srv.server_port))
srv.serve_forever()
