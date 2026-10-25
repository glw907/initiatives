# Mechanics and feasibility review: ward address book design

Target: `household-phonebook/specs/2026-10-24-ward-address-book-design.md` at `c3d4579`.
Reviewer: `plan-reviewer`, 2026-10-24. Checked against Stalwart v0.16.27 source through
`gh api`, ward's cached stalwart-cli schema, and the `servers` repo, read-only. Saved by the
planning session from the agent's reply.

## Blocker

**1. The group design yields a writable shared book every member can edit, breaking ruling 1**
(correctness; spec:59-64, :78-84). Stalwart creates a default address book whenever it builds
address-book resources for an account that has none (`crates/groupware/src/cache/calcard.rs:112-124`;
schema `defaultHrefName: "default"`, display "Stalwart Address Book"; `cutover-log.md:107`
shows it on Geoff's account). A member's token lists the group's account in `member_of` and
`secondary_ids` (`crates/common/src/auth/access_token.rs:71-75`, `:443-447`). mail-filters runs
`ContactCard/get` on every session account (`mail-filters:224-229`), which goes through
`fetch_dav_resources` (`crates/jmap/src/contact/get.rs:48-54`), and client discovery walks
`all_ids_by_collection`, which includes `member_of`, in both discovery modes
(`crates/dav/src/principal/propfind.rs:413-427`, `crates/dav/src/common/propfind.rs:1433-1448`).
Either creates a `household`-owned book that every member passes `is_member` on
(`card/update.rs:113`), so all can write it, and it appears in their clients. The Group also
adds an unprobed deliverable address (facts UNCONFIRMED 7). **Fold:** make probe 1's fallback
the design: `stalwart-apply` writes one `mayRead` grant per `role: "User"` entry in
`accounts.json`, skipping `"household": false` (`maxShares` 10; `acl_validate` accepts any
Account id in any domain, `crates/jmap/src/api/acl.rs:242-262`). Drop the Group upsert,
`memberGroupIds`, and the group's address. Ruling 4 holds at a new user's first apply;
removing a user revokes at the next apply. Probe 1 becomes "a per-user grant reaches the
member over CardDAV".

## Major

**2. The reconcile can't repair a lost push** (correctness; spec:119-126). Stalwart stores the
parsed card and re-serializes on read (`card/update.rs:197-201`, `:157-162`), so a multiget body
won't match rendered bytes. D1 keeps only the ETag, so a push cancelled after commit leaves
ETags equal. **Fold:** store `rendered_sha256` beside `etag`; PUT with `If-Match` when ward's
ETag differs from the recorded one or the render hash differs from the last pushed hash. Drop
the multiget. The PUT response carries the new ETag (`update.rs:218`, `:300`).

**3. Nothing keeps production from writing the live book before cutover** (correctness;
spec:21-23, :116-124, :175-176). **Fold:** `WARD_PASSWORD`, the ward URL, and the book href
are unset in production until the cutover step; unset gives a "not configured" `ward_sync`
state and no requests. Name the configuration that points the live probe test at a probe book
and where that test runs (`workers_dev` and `preview_urls` are false).

**4. Worker-first rotation deadlocks the 401 stop** (correctness; spec:137-139). **Fold:** the
order is `secret-set.sh`, `render.sh ward`, `stalwart-apply`, then `wrangler secret put
WARD_PASSWORD` last. Optionally a Phones-page retry clears the stop.

**5. The book's creation, name, and href are unspecified** (correctness; spec:52-55, :65-68).
First access auto-creates `/dav/card/phonebook/default/`, "Stalwart Address Book (phonebook)"
(`crates/groupware/src/cache/mod.rs:328-375`). **Fold:** `stalwart-apply`, as the phonebook
login, reads the default book with JMAP `AddressBook/get` (creating it), sets `name` to "Global
Address Book", and sets `shareWith`. The Worker's config holds the href. Pick JMAP over the
WebDAV ACE, since `shareWith` reads back directly.

**6. `d-907` gives the phonebook account a live 907.life inbox** (correctness; spec:52-55).
Contradicts `servers/docs/addresses.md:38` ("Eleven addresses ... There is no catch-all").
**Fold:** put `phonebook` on `d-ward`, like `admin`; login `phonebook@ward.907.life`; record it in
`addresses.md`.

**7. The Worker's credential can send mail from ward** (correctness; spec:52-55, :137). A default
User role keeps submission and IMAP; ward's IP reputation is new (`cutover-log.md:100`).
**Fold:** scope the credential to contacts DAV and JMAP, through `disabledPermissions` on the
account or a Credential permissions list (schema `x:PermissionsList`,
`x:CredentialPermissionsList`). The plan names the exact `Permission` values from the schema
and proves a submission login fails.

## Minor

8. The share step has no place in `stalwart-apply`'s flow (bootstrap exits at `:141-151`, normal
   restarts at `:155`). Fold: a function called on both branches after the final restart, like
   `ensure_certificate`; `--dry-run` prints the grant and writes nothing; probe that
   `stalwart-cli query Account` ids are the ids `shareWith` takes.
9. Servers secret plumbing is missing (`build-plan:16-18` needs the variable in
   `/etc/servers/stalwart.env`). Fold: rows in `secrets/templates/ward/stalwart.env` and
   `secrets/registry.md`; `secrets/render.sh ward` before `stalwart-apply`.
10. The seed loads as `seed.sql` outside the Worker (plan `:1049-1051`), so no push fires. Fold:
    drop "seed" from the push sentence; the cutover waits for the next tick or a named manual
    trigger, then compares counts.
11. Ward-card import mapping is unspecified (TEL types, 7-part `ADR`, more than five emails, more
    than one `ADR`; `+1 907-555-0123` vs the voip.ms form). Fold: name the TEL mapping, send
    overflow to the review, normalize numbers before the same-name compare.
12. Push status handling: DELETE of a missing card is 404 (`card/delete.rs:70-72`), count it as
    success; moving into Blacklist needs a DELETE, out needs a PUT; give each ward fetch an
    `AbortSignal.timeout`; line :173 should say "leave the contacts untouched".
13. The Workers tier is assumed (10,000 subrequests is Paid). Fold: record the tier with its
    source, or batch the first fill.
14. The migration inventory is unchecked live ("18 cards" is from `cutover-log.md:107`;
    `:108`'s operator copy is due for deletion today). Fold: a read-only PROPFIND count before
    approval; name what happens to the operator's copy.
15. The probe table omits `enableAssistedDiscovery` (facts UNCONFIRMED 6). Fold: add
    `stalwart-cli get WebDav`.
16. **OWNER FORK:** the probe accounts (`probe`, `probe2`, `accounts.json:40-58`) get the book
    under ruling 4. Options: (a) `"household": false` on both; (b) accept. Recommendation: (a).
17. Probe accounts' setup and teardown are unnamed. Fold: name the `stalwart-cli` create and
    destroy commands and a nothing-left check.
18. vCard details: `EMAIL;TYPE=other` isn't a registered RFC 6350 value, render no TYPE; name
    escaping for `ADR`, `ORG`, `CATEGORIES`; with `N` absent some clients may show a blank name,
    so add "names show" to each client check.
19. The cutover export can ban Geoff's login (ban tracking keys on login). Fold: stop at the first
    401.
20. Hosts unnamed: pavilion's GOA (`cutover-log.md:106`), and whether thinkpad-x1 has a ward
    contacts account.
21. (optional, over-ceremony) The mail-filters fallback isn't needed: a sharee's token adds every
    account that granted it `Read` to `access_to` (`access_token.rs:76-120`), and the session
    lists those accounts with every capability (`crates/jmap/src/api/session.rs:59-88`); also
    `setup()` refuses `mailbox: false` accounts (`mail-filters:66`). Fold: drop it, keep the
    check.
22. (optional) The unit round trip needs a parser the Worker lacks. Fold: reuse the seed tool's
    ward parser, or test render-only against golden strings.

## Confirmed as stated

PUT returns an ETag on 201 and 204 (`update.rs:218`, `:300`). `If-Match` is checked on update
and create (`:134-174`, `:236-249`), UID conflicts give 412 (`:176-186`). A read-only sharee
gets 403 on create, update, delete (`:113-116`, `:225-232`; `delete.rs:93-101`). `mayRead` maps
to `Read` and `ReadItems` (`crates/jmap-proto/src/object/addressbook.rs:299`).
`github:glw907/survey#v1.3.0`, its `Survey.zip`, and the `DESIGN.md` "Plain app" recipe exist.
