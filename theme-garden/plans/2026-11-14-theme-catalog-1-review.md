Initiative: theme-garden

# Theme catalog 1: the plan review

One `standards:plan-reviewer` read of `2026-11-14-theme-catalog-1-plan.md` on 2026-11-14, against
cairn-cms at `839232fe9`. The planner checked the two blockers and findings M1, M3, and M5 against
the code before folding. Every finding below is folded into the plan unless it says otherwise.

## Blockers

- `npm test` can't include `test:catalog`: `workflow-yaml.test.ts:182` pins the chain to the two
  Vitest scripts. `test:catalog` is now a script, a lane leg, and a `test.yml` step.
- New `test.yml` steps fail `gate-tier.test.ts:744` unless the gate tier names them. C1.8 now edits
  `scripts/checks/gate-tier.mjs` and both tests.

## Changed what a task builds or checks

- C1.1's gate-table edit needed a row in `gate-tier.test.ts`, and its lane check passed on the
  unchanged table. The check is now a test case that fails today.
- `semver` was installed in C1.6 and needed from C1.1, and two paired tasks edited `package.json`.
  C1.1 now installs all three dev dependencies.
- The showcase's menus link to `/admin`, which a demo answers with 404. The demo build removes
  those entries.
- The index read had no outcome for a 5xx or a bad body, either of which could erase the catalog.
  It is now an S3 read where only a missing key means empty.
- The version-rise check couldn't receive its range as a lane leg. It has a default range, and CI's
  two ranges are written out.
- The pre-flight probe covered one of the run's requests. It now covers each, with the lock's reply,
  and its recorded replies seed C1.6's fake bucket.
- The proving environment's branch rule would have refused pull request runs, and the check couldn't
  show the `main` rule. Both are rewritten.
- Also folded: the workflow's setup steps, its dispatch target, the Dependabot skip, two more
  trigger paths, variables in place of a hard-coded Worker name, a committed archive digest, the
  ustar fields, a `tar -tzf` read, a cross-origin fixture and a viewport check for the reference
  page, the set manifest's name and schema, accepted `engine` cases, the C1.8 reads written out, a
  short cache time on proving, `preview_urls` off, a rule for a shared proving target, a row for a
  proving run that can't go green, and a floor on review rounds.

## Not folded

- Whether Go's `archive/tar` reads the hand-written archive is proven in the installer pass, which
  writes that reader. This pass proves it with system `tar`.
- The reviewer could not verify that an Editor token deploys with a `routes` entry, how an
  account-owned R2 token's S3 key pair is issued, or that actionlint accepts an `environment` set
  by an expression. Pre-flight item 5 proves the first two. The third is the executor's to find,
  and two jobs with fixed environments is the fallback.

## Replies recorded at pre-flight

Pre-flight items 2 to 5 ran on 2026-11-14. Each request below was made with the token the run
uses, never `ws-admin`. Headers that vary per request (`cf-ray`, `date`, `server`) are cut.

### What the replies settle

- A create-only `PutObject` on an existing key answers 412 `PreconditionFailed` where no lock
  applies, and 409 `ObjectLockedByBucketPolicy` under a lock rule. The lock is checked first, so
  the resume rule in C1.6 reads both.
- `DeleteObjects` on a locked key answers 200 with an `<Error>` element in the body. C1.6 reads
  the body, never the status alone.
- A missing key answers 404 `NoSuchKey` over S3. The public address answers 404 as `text/html`.
- The public address sends `access-control-allow-origin: *` on a 200 and on a 404.
- The public read's `cf-cache-status` is `DYNAMIC`, with the object's `Cache-Control` passed through.
- The proving token answers 403 `AccessDenied` on `cairn-catalog`.
- An Editor token deploys only from a Wrangler file with no `routes` entry. With the entry,
  `wrangler deploy` uploads the version and then exits 1 with code 10084. Without it the deploy
  exits 0 and the custom domain stays attached. C1.5 generates the file without `routes`.
- After all four deploys, both Workers still report `{'enabled': False, 'previews_enabled': False}`
  for `workers.dev`.

### R2 replies

```text
######## cairn-catalog-proving
### PutObject If-None-Match:* (first)
HTTP/1.1 200 OK
Content-Type: text/plain;charset=UTF-8
Content-Length: 0
ETag: "8da843ff65205a61374b09b81ed0fa35"
### HeadObject
HTTP/1.1 200 OK
Content-Type: text/plain; charset=utf-8
Content-Length: 5
Cache-Control: public, max-age=60
ETag: "8da843ff65205a61374b09b81ed0fa35"
Last-Modified: Sat, 14 Nov 2026 22:52:17 GMT
### PutObject If-None-Match:* (second)
HTTP/1.1 412 Precondition Failed
Content-Type: application/xml
Content-Length: 165
<?xml version="1.0" encoding="UTF-8"?><Error><Code>PreconditionFailed</Code><Message>At least one of
the pre-conditions you specified did not hold.</Message></Error>
### GetObject
HTTP/1.1 200 OK
Content-Type: text/plain; charset=utf-8
Content-Length: 5
Cache-Control: public, max-age=60
ETag: "8da843ff65205a61374b09b81ed0fa35"
Last-Modified: Sat, 14 Nov 2026 22:52:17 GMT
probe
### GetObject missing key
HTTP/1.1 404 Not Found
Content-Type: application/xml
Content-Length: 127
<?xml version="1.0" encoding="UTF-8"?><Error><Code>NoSuchKey</Code><Message>The specified key does
not exist.</Message></Error>
### public read with Origin
HTTP/2 200
content-type: text/plain; charset=utf-8
content-length: 5
cache-control: public, max-age=60
etag: "8da843ff65205a61374b09b81ed0fa35"
last-modified: Sat, 14 Nov 2026 22:52:17 GMT
access-control-allow-origin: *
cf-cache-status: DYNAMIC
probe
### public 404 with Origin
HTTP/2 404
content-type: text/html
access-control-allow-origin: *
cf-cache-status: DYNAMIC
### ListObjectsV2 prefix probe/
HTTP/1.1 200 OK
Content-Type: application/xml
Content-Length: 461
<?xml version="1.0" encoding="UTF-8"?><ListBucketResult xmlns="http://s3.amazonaws.com/doc/2006-03-0
1/"><Name>cairn-catalog-proving</Name><Contents><Key>probe/a.txt</Key><Size>5</Size><LastModified>20
26-11-14T22:52:17.701Z</LastModified><ETag>&quot;8da843ff65205a61374b09b81ed0fa35&quot;</ETag><Stora
geClass>STANDARD</StorageClass></Contents><IsTruncated>false</IsTruncated><Prefix>probe/</Prefix><Ma
xKeys>1000</MaxKeys><KeyCount>1</KeyCount></ListBucketResult>
### DeleteObjects
HTTP/1.1 200 OK
Content-Type: application/xml
Content-Length: 156
<?xml version="1.0" encoding="UTF-8"?><DeleteResult xmlns="http://s3.amazonaws.com/doc/2006-03-01/">
<Deleted><Key>probe/a.txt</Key></Deleted></DeleteResult>
### ListObjectsV2 after delete
HTTP/1.1 200 OK
Content-Type: application/xml
Content-Length: 257
<?xml version="1.0" encoding="UTF-8"?><ListBucketResult xmlns="http://s3.amazonaws.com/doc/2006-03-0
1/"><Name>cairn-catalog-proving</Name><IsTruncated>false</IsTruncated><Prefix>probe/</Prefix><MaxKey
s>1000</MaxKeys><KeyCount>0</KeyCount></ListBucketResult>
######## cairn-catalog
### PutObject If-None-Match:* (first)
HTTP/1.1 200 OK
Content-Type: text/plain;charset=UTF-8
Content-Length: 0
ETag: "8da843ff65205a61374b09b81ed0fa35"
### HeadObject
HTTP/1.1 200 OK
Content-Type: text/plain; charset=utf-8
Content-Length: 5
Cache-Control: public, max-age=60
ETag: "8da843ff65205a61374b09b81ed0fa35"
Last-Modified: Sat, 14 Nov 2026 22:52:20 GMT
### PutObject If-None-Match:* (second)
HTTP/1.1 412 Precondition Failed
Content-Type: application/xml
Content-Length: 165
<?xml version="1.0" encoding="UTF-8"?><Error><Code>PreconditionFailed</Code><Message>At least one of
the pre-conditions you specified did not hold.</Message></Error>
### GetObject
HTTP/1.1 200 OK
Content-Type: text/plain; charset=utf-8
Content-Length: 5
Cache-Control: public, max-age=60
ETag: "8da843ff65205a61374b09b81ed0fa35"
Last-Modified: Sat, 14 Nov 2026 22:52:20 GMT
probe
### GetObject missing key
HTTP/1.1 404 Not Found
Content-Type: application/xml
Content-Length: 127
<?xml version="1.0" encoding="UTF-8"?><Error><Code>NoSuchKey</Code><Message>The specified key does
not exist.</Message></Error>
### public read with Origin
HTTP/2 200
content-type: text/plain; charset=utf-8
content-length: 5
cache-control: public, max-age=60
etag: "8da843ff65205a61374b09b81ed0fa35"
last-modified: Sat, 14 Nov 2026 22:52:20 GMT
access-control-allow-origin: *
cf-cache-status: DYNAMIC
probe
### public 404 with Origin
HTTP/2 404
content-type: text/html
access-control-allow-origin: *
cf-cache-status: DYNAMIC
### ListObjectsV2 prefix probe/
HTTP/1.1 200 OK
Content-Type: application/xml
Content-Length: 453
<?xml version="1.0" encoding="UTF-8"?><ListBucketResult xmlns="http://s3.amazonaws.com/doc/2006-03-0
1/"><Name>cairn-catalog</Name><Contents><Key>probe/a.txt</Key><Size>5</Size><LastModified>2026-11-14
T22:52:20.092Z</LastModified><ETag>&quot;8da843ff65205a61374b09b81ed0fa35&quot;</ETag><StorageClass>
STANDARD</StorageClass></Contents><IsTruncated>false</IsTruncated><Prefix>probe/</Prefix><MaxKeys>10
00</MaxKeys><KeyCount>1</KeyCount></ListBucketResult>
### DeleteObjects
HTTP/1.1 200 OK
Content-Type: application/xml
Content-Length: 156
<?xml version="1.0" encoding="UTF-8"?><DeleteResult xmlns="http://s3.amazonaws.com/doc/2006-03-01/">
<Deleted><Key>probe/a.txt</Key></Deleted></DeleteResult>
### ListObjectsV2 after delete
HTTP/1.1 200 OK
Content-Type: application/xml
Content-Length: 249
<?xml version="1.0" encoding="UTF-8"?><ListBucketResult xmlns="http://s3.amazonaws.com/doc/2006-03-0
1/"><Name>cairn-catalog</Name><IsTruncated>false</IsTruncated><Prefix>probe/</Prefix><MaxKeys>1000</
MaxKeys><KeyCount>0</KeyCount></ListBucketResult>
### proving token, ListObjectsV2 on cairn-catalog (must refuse)
HTTP/1.1 403 Forbidden
Content-Type: application/xml
Content-Length: 110
<?xml version="1.0" encoding="UTF-8"?><Error><Code>AccessDenied</Code><Message>Access
Denied</Message></Error>
```

### Lock replies on the proving bucket

A one-day rule on `probe-lock/`, since removed.

```text
### PutObject into locked prefix (new key)
HTTP/1.1 200 OK
Content-Type: text/plain;charset=UTF-8
Content-Length: 0
ETag: "f97c5d29941bfb1b2fdab0874906ab82"
### PutObject overwrite, no precondition
HTTP/1.1 409 Conflict
Content-Type: application/xml
Content-Length: 153
<?xml version="1.0" encoding="UTF-8"?><Error><Code>ObjectLockedByBucketPolicy</Code><Message>The
object is locked by the bucket policy.</Message></Error>
### PutObject overwrite, If-None-Match:*
HTTP/1.1 409 Conflict
Content-Type: application/xml
Content-Length: 153
<?xml version="1.0" encoding="UTF-8"?><Error><Code>ObjectLockedByBucketPolicy</Code><Message>The
object is locked by the bucket policy.</Message></Error>
### DeleteObject
HTTP/1.1 409 Conflict
Content-Type: application/xml
Content-Length: 153
<?xml version="1.0" encoding="UTF-8"?><Error><Code>ObjectLockedByBucketPolicy</Code><Message>The
object is locked by the bucket policy.</Message></Error>
### DeleteObjects
HTTP/1.1 200 OK
Content-Type: application/xml
Content-Length: 257
<?xml version="1.0" encoding="UTF-8"?><DeleteResult xmlns="http://s3.amazonaws.com/doc/2006-03-01/">
<Error><Key>probe-lock/a.txt</Key><Code>ObjectLockedByBucketPolicy</Code><Message>The object is
locked by the bucket policy.</Message></Error></DeleteResult>
### GetObject (content after attempts)
HTTP/1.1 200 OK
Content-Type: text/plain
Content-Length: 3
ETag: "f97c5d29941bfb1b2fdab0874906ab82"
Last-Modified: Sat, 14 Nov 2026 22:52:40 GMT
one
### DeleteObject after rule removed
HTTP/1.1 204 No Content
### ListObjectsV2 whole bucket
HTTP/1.1 200 OK
Content-Type: application/xml
Content-Length: 234
<?xml version="1.0" encoding="UTF-8"?><ListBucketResult xmlns="http://s3.amazonaws.com/doc/2006-03-0
1/"><Name>cairn-catalog-proving</Name><IsTruncated>false</IsTruncated><MaxKeys>1000</MaxKeys><KeyCou
nt>0</KeyCount></ListBucketResult>
```

### Wrangler replies with the Editor tokens

```text
== cairn-demo-waymark with routes ==
🌀 Building list of assets...
🌀 Starting asset upload...
No updated asset files to upload. Proceeding with deployment...
Total Upload: 0.36 KiB / gzip: 0.25 KiB
Uploaded cairn-demo-waymark (1.86 sec)
No targets deployed for cairn-demo-waymark (0.95 sec)
✘ [ERROR] Trigger configuration for "cairn-demo-waymark" was only partially updated:
    Custom domains:
      - A request to the Cloudflare API
(/accounts/120c269ad6d3dfbe6d63a0bb53758ca0/workers/scripts/cairn-demo-waymark/domains/records)
failed.
        - The zone "demo-waymark.cairn.pub" does not exist on your account. [code: 10084]
  Successful trigger changes were not rolled back.
exit 1
== cairn-demo-waymark without routes ==
🌀 Building list of assets...
🌀 Starting asset upload...
No updated asset files to upload. Proceeding with deployment...
Total Upload: 0.36 KiB / gzip: 0.25 KiB
Uploaded cairn-demo-waymark (2.10 sec)
No targets deployed for cairn-demo-waymark (0.40 sec)
Current Version ID: 9dd6b173-62d0-4df0-b8d0-3b5223329572
exit 0
== cairn-demo-proving with routes ==
🌀 Building list of assets...
🌀 Starting asset upload...
No updated asset files to upload. Proceeding with deployment...
Total Upload: 0.36 KiB / gzip: 0.25 KiB
Uploaded cairn-demo-proving (1.81 sec)
No targets deployed for cairn-demo-proving (0.79 sec)
✘ [ERROR] Trigger configuration for "cairn-demo-proving" was only partially updated:
    Custom domains:
      - A request to the Cloudflare API
(/accounts/120c269ad6d3dfbe6d63a0bb53758ca0/workers/scripts/cairn-demo-proving/domains/records)
failed.
        - The zone "demo-proving.cairn.pub" does not exist on your account. [code: 10084]
  Successful trigger changes were not rolled back.
exit 1
== cairn-demo-proving without routes ==
🌀 Building list of assets...
🌀 Starting asset upload...
No updated asset files to upload. Proceeding with deployment...
Total Upload: 0.36 KiB / gzip: 0.25 KiB
Uploaded cairn-demo-proving (1.96 sec)
No targets deployed for cairn-demo-proving (0.50 sec)
Current Version ID: ab523e12-5db4-4dc2-8790-ca63c6ff3bc2
exit 0
```
