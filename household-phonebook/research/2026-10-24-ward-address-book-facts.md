# Ward address book: source facts

Date: 2026-10-24. Gathered for `specs/2026-10-24-ward-address-book-design.md`. Sources are
stalw.art pages (the unversioned `/docs/...` tree, last updated 2026-10-03, taken as 0.16),
ward's cached stalwart-cli schema (`~/.cache/stalwart-cli/0nOZo9UpoZXYT375r_fM03-cN7dbh2AlhkvWPkpstqs/schema-Pzykh-dZ4p6qVJ7wVulQvyF7-1aRB8fI6GcjdJMWK2Q.json`,
"the schema"), Stalwart source at tag `v0.16.27` (sha `aa47d8ef`), and the private `servers`
repo. Each item marked UNCONFIRMED names the probe that settles it.

## 1. Group principals

- `stalwart-apply` pipes `stalwart-build-plan`'s output to `stalwart-cli apply --stdin` on
  loopback (`roles/stalwart/stalwart-apply:94`, `:146`). `build-plan` writes one `Account`
  upsert per `accounts.json` entry, always `"@type": "User"`, matched on `name` and `domainId`
  (`roles/stalwart/build-plan:27-35`). It never reads `login` or `mailbox`.
- `Account` has two variants, `User` (`x:UserAccount`) and `Group` (`x:GroupAccount`) (the
  schema, `x:Account`). A Group needs `name`, `domainId`, `roles` (`Default` or `Custom`), and
  `permissions`; `emailAddress` is server-set as name@domain
  (<https://stalw.art/docs/ref/object/account/>).
- Membership lives on the User: `x:UserAccount.memberGroupIds`, "List of groups that this
  account is a member of". A plan sets it as `{ "memberGroupIds": { "#grp-sales": true } }`, and
  "a Domain can be upserted in operation 1 and then referenced by an Account in operation 2"
  (<https://stalw.art/docs/management/cli/apply/>).
- "Group accounts cannot log in to the mail server using IMAP, POP3, or JMAP"
  (<https://stalw.art/docs/auth/principals/group/>, a pre-0.16 page). Whether the group's
  address accepts mail is UNCONFIRMED (probe: `rcpt-check.sh` against it).

## 2. Read-only sharing with a group

- DAV privileges map to ACLs in `crates/dav/src/common/acl.rs:325-356`: `Read` gives `Read` and
  `ReadItems`; `Write` gives `Modify`, `Delete`, `AddItems`, `ModifyItems`, `RemoveItems`. Deny,
  inverted, and non-href ACEs get 403 (`acl.rs:296-320`).
- JMAP: `AddressBook.shareWith` maps a principal id to `AddressBookRights {mayRead, mayWrite,
  mayShare, mayDelete}` (the schema). RFC 9610 section 2: mayRead means "The user may fetch the
  ContactCards in this AddressBook".
- A grant to a group reaches its members: `effective_acl` unions every ACE where
  `access_token.is_member(item.account_id)` (`crates/common/src/sharing/mod.rs:26-36`), and
  `is_member` is true for the account itself and each group in `member_of`
  (`crates/common/src/auth/access_token.rs:476-480`), filled from `member_group_ids`
  (`access_token.rs:71-85`).
- **A group-owned book is writable by every member.** The card PUT handler checks ACLs only
  `if !access_token.is_member(account_id)` (`crates/dav/src/card/update.rs:113-116`), and a
  member passes `is_member` for its group. So the owner must be a separate account.
- Writes without the right ACL get 403: update needs `ModifyItems` (`card/update.rs:113-116`),
  create needs `AddItems` (`:224-232`), delete needs `RemoveItems`
  (`card/delete.rs:99-101`, `:164-167`). Not yet run live.
- Discovery: "Stalwart lists every accessible calendar and address book collection in the
  calendar-home-set and addressbook-home-set properties of the authenticated principal, covering
  both personal and shared collections" (<https://stalw.art/docs/collaboration/sharing/>).
  Shared books stay under the owner's path, `/dav/card/<owner>/<book>`.
- JMAP discovery: RFC 9670 section 1.4, "the Session object MUST only include Accounts where
  either the user is subscribed to at least one record ... or the Account belongs to the user."
  `AddressBook.isSubscribed` defaults to `true` (the schema). Whether a member's session lists
  the owner's account is UNCONFIRMED.
- `maxShares` defaults to 10 sharees per item (<https://stalw.art/docs/ref/object/sharing/>).
- How the current Global Address Book share was made is not recorded. `docs/cutover-log.md:108`
  says only "over a WebDAV ACL".

## 3. A contacts-only account

- `mailbox` is a repo-only field, read by `roles/stalwart/stalwart-status:60`,
  `roles/stalwart/stalwart-jmap:39`, `roles/mail-filters/mail-filters:100,531`, and
  `scripts/drill-remote.sh:342`. With `mailbox: false` an account stays out of the status
  counts, the drills, and mail-filters, and is otherwise an ordinary User.
- "Stalwart automatically creates a default address book when an account is accessed and no
  address books currently exist for it" (<https://stalw.art/docs/collaboration/contact/>).

## 4. Auto-ban on ward

- `roles/stalwart/plan.ndjson:6` sets `authBanPeriod` to 86400000 (24 hours). `authBanRate` is
  the default, `{"count":100,"period":"1d"}` (the schema).
- "Authentication failures across every service ... feed into a single counter per source"
  and "Authentication ban tracking keys on both the source IP and the login name"
  (<https://stalw.art/docs/server/auto-ban/>). A ban is a `BlockedIp` entry;
  `roles/stalwart/stalwart-admin` lists and deletes them.
- A banned Cloudflare egress address may be shared with the zone's monitor Worker, which polls
  `https://mail.907.life/healthz/live` (`cloudflare/monitor/src/checks.ts:19`).
- `rateLimitAuthenticated` defaults to 1000 a minute (the schema).

## 5. Cloudflare Workers

- `mail.907.life` is a DNS-only CNAME to `ward.907.life` (`cloudflare/dns/ward:3`, `:5`).
- The monitor Worker on Custom Domain `monitor.907.life` already fetches
  `https://mail.907.life/healthz/live`, and its alert opened and cleared with Stalwart's state
  (`docs/cutover-log.md:95`). So a same-zone fetch to this host works.
- Subrequests to an unproxied host outside the zone use Full (strict) TLS
  (<https://developers.cloudflare.com/support/troubleshooting/http-status-codes/cloudflare-5xx-errors/error-526/>).
  Ward's certificate names `mail.907.life` (`plan.ndjson:9`).
- Cron Triggers take a cron expression with one-minute granularity and run on UTC
  (<https://developers.cloudflare.com/workers/configuration/cron-triggers/>). "The runtime waits
  for the promise returned by the scheduled() handler to resolve (up to the 15-minute duration
  limit)" (<https://developers.cloudflare.com/workers/runtime-apis/handlers/scheduled/>).
- "For HTTP-triggered Workers, ctx.waitUntil() can extend execution for up to 30 seconds after
  the response is sent ... If any Promises have not settled after 30 seconds, they are canceled"
  (<https://developers.cloudflare.com/workers/runtime-apis/context/>).
- Workers Paid allows 10,000 subrequests per invocation (limits page).

## 6. CardDAV

- Stalwart implements RFC 6352, 6578, 3744, 4918, 2426, 6350, 9610, and 9670
  (<https://stalw.art/docs/development/rfcs/>).
- `vCardVersion` defaults to `v4` (<https://stalw.art/docs/ref/object/address-book/>). Input is
  parsed strictly, and bad input gets 412 `SupportedAddressData` (`card/update.rs:91-101`).
  Ward's cards are `VERSION:4.0`.
- An update that changes the UID gets 412 `NoUidConflict` (`card/update.rs:176-186`). A create
  checks UID uniqueness within the book (`:252-258`).
- `If-Match` is checked before a write, and a failed precondition gets 412
  (`card/update.rs:134-166`, `:235-247`). `If-None-Match: *` on create is UNCONFIRMED.
- `maxVCardSize` defaults to 524288 bytes; WebDAV `maxResults` to 2000 per response.

## 7. mail-filters

- `roles/mail-filters/mail-filters:224-229` reads every `ContactCard` in every account the
  login's JMAP session lists with `urn:ietf:params:jmap:contacts`. It does not look books up by
  name. If Geoff's session doesn't list the owner account, the household book drops out
  silently.

## UNCONFIRMED, with the probe for each

1. A group grant reaches a member over CardDAV: on the probe domain, grant `<D:read/>` to a
   probe group on a probe book, then PROPFIND `addressbook-home-set` and multiget as a member.
2. A read-only member gets 403 on PUT and DELETE: try a create, an update with `If-Match`, and a
   delete as that member.
3. The read ACE's effective privileges: PROPFIND `current-user-privilege-set` as the member.
4. The group principal's href, and whether a non-admin owner can grant to it: PROPFIND
   `/dav/pal/`, then send the ACL as the owner.
5. A member's JMAP session lists the owner account: `GET /jmap/session` as the member.
6. Ward's live `enableAssistedDiscovery`: `stalwart-cli get WebDav`.
7. The group's address accepts mail: `rcpt-check.sh`.
8. What the login-name half of auth-ban tracking bans: read the v0.16.27 ban code.
9. The current share's ACE: PROPFIND `DAV:acl` on Geoff's Global book.
10. `If-None-Match: *` on create: PUT a new card twice; expect 201, then 412.
11. A membership change takes effect without a re-login: PROPFIND as the member at once.
