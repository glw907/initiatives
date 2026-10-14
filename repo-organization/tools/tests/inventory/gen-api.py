#!/usr/bin/env python3
"""Print the known-ties Cloudflare fixture as {path: {body}} JSON. Every id is invented."""
import json

A = "/accounts/acct-fixture"
kv = lambda n: "%032x" % n
D1 = "00000000-0000-0000-0000-00000000d001"
WORKERS = ["pings", "scratch-a", "scratch-w3", "asc-shell", "asc-handbook", "asc-uptime",
           "asc-legacy-main", "zz-outside-w"]
BIND = {
    "pings": [{"type": "kv_namespace", "namespace_id": kv(1)}],
    "scratch-a": [{"type": "kv_namespace", "namespace_id": kv(11)},
                  {"type": "kv_namespace", "namespace_id": kv(12)}],
    "asc-shell": [{"type": "service", "service": "asc-handbook"}, {"type": "service", "service": "asc-uptime"},
                  {"type": "r2_bucket", "bucket_name": "asc-event-images"}, {"type": "d1", "id": D1},
                  {"type": "kv_namespace", "namespace_id": kv(3)}],
    "asc-handbook": [{"type": "r2_bucket", "bucket_name": "asc-event-images"}],
    "asc-legacy-main": [{"type": "r2_bucket", "bucket_name": "asc-event-images"}],
    "zz-outside-w": [{"type": "kv_namespace", "namespace_id": kv(4)}],
}
api = {f"{A}/workers/scripts": WORKERS}
for w in WORKERS:
    api[f"{A}/workers/scripts/{w}/settings"] = {"bindings": BIND.get(w, [])}
    api[f"{A}/workers/scripts/{w}/schedules"] = {"schedules": [{"cron": "*/5 * * * *"}] if w == "pings" else []}
api[f"{A}/workers/scripts"] = [{"id": w} for w in WORKERS]
api[f"{A}/workers/domains"] = [{"hostname": "pings.example.invalid", "service": "pings"}]
api[f"{A}/d1/database"] = [{"uuid": D1, "name": "asc-shell-db"}]
api[f"{A}/storage/kv/namespaces"] = [{"id": kv(n), "title": f"k{n}"} for n in (1, 2, 3, 4, 11, 12)]
api[f"{A}/r2/buckets"] = {"buckets": [{"name": "asc-event-images"}]}
api[f"{A}/access/apps"] = [
    {"id": "app-sole", "name": "Scratch only", "domain": "scratch.example.invalid"},
    {"id": "app-mixed", "name": "Scratch and survivor", "domain": "scratch.example.invalid",
     "self_hosted_domains": ["scratch.example.invalid", "survivor.example.invalid"]},
]
api["/zones"] = [{"id": "z1", "name": "example.invalid"}]
api["/zones/z1/workers/routes"] = [{"pattern": "scratch.example.invalid/*", "script": "scratch-a"},
                                   {"pattern": "app.wild.example.invalid/*", "script": "scratch-a"}]
api["/zones/z1/dns_records"] = [
    {"id": "dns-scratch", "name": "scratch.example.invalid", "type": "CNAME"},
    {"id": "dns-wild", "name": "app.wild.example.invalid", "type": "CNAME"},
    {"id": "dns-pings", "name": "pings.example.invalid", "type": "CNAME"},
]
api["/zones/z1/email/routing/rules"] = [{"id": "er1", "actions": [{"type": "worker", "value": ["pings"]}]}]
print(json.dumps({p: {"body": b} for p, b in api.items()}))
