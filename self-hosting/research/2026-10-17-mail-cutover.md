# Mail cutover research: 907.life from Fastmail to Stalwart on Hetzner Cloud (2026-10-17)

Scope: deliverability, DNS, data migration, cutover and rollback, masked-email triage, Proton Pass alias domain, and ongoing mail health. Stalwart's own installation is covered in a separate brief. Claims carry inline sources; "unverified" marks anything I could not confirm from a primary source.

## Measured starting state (read-only checks, 2026-10-17)

Public DNS for 907.life, checked against Cloudflare's authoritative servers:

- MX: `in1-smtp` and `in2-smtp.messagingengine.com`, both priority 10, TTL 300 (Cloudflare "Auto").
- SPF: `v=spf1 include:spf.messagingengine.com ?all`. The `?all` is neutral, so SPF gives no protection today.
- DMARC: `v=DMARC1; p=none; rua=mailto:geoff@907.life`.
- DKIM: `fm1`, `fm2`, `fm3._domainkey` are CNAMEs to `fmhosted.com`. Only `fm3` carries a live key; `fm1` and `fm2` are empty rotation slots.
- No MTA-STS, TLS-RPT, SRV autodiscovery, CAA, or wildcard MX records. No DNSSEC: RDAP shows `delegationSigned: false`. The registrar is Cloudflare (RDAP, `rdap.identitydigital.services`), so DS publication can be automatic.

Fastmail JMAP session (read-only GET with the stored API token): the token sees `mail`, `contacts`, `submission`, and the `maskedemail` extension. It does not expose calendars, Sieve, or the `principals` capability. A second account on the token is contacts-only (likely a shared address book). Calendars must therefore move over CalDAV, and the second operator's mailbox needs his own credential.

## 1. Deliverability from Hetzner Cloud IPs

**Mailbox provider rules.** Google requires every sender to use SPF or DKIM, valid forward-confirmed PTR records for each sending IP (A for IPv4, AAAA for IPv6), TLS, RFC 5322 formatting, and a spam rate under 0.3%. Bulk senders (about 5,000 a day) also need SPF, DKIM, and an aligned DMARC record ([Google sender guidelines](https://support.google.com/mail/answer/81126?hl=en)). Google's FAQ says enforcement ramped up from November 2025, with temporary and permanent rejections for non-compliant traffic ([Google sender FAQ](https://support.google.com/a/answer/14229414?hl=en)). Google also warns that an IPv6 rejection (550-5.7.1) often means a missing IPv6 PTR. Yahoo requires SPF or DKIM and valid forward and reverse DNS for all senders ([Yahoo sender best practices](https://senders.yahooinc.com/best-practices/)). Microsoft's Outlook.com rules require valid rDNS for all senders, recommend SPF, DKIM, and DMARC for everyone, and enforce them for senders over 5,000 a day since 5 May 2025 (error `550; 5.7.515`) ([Outlook.com postmaster policies](https://substrate.office.com/ip-domain-management-snds/postmaster/Policies)). A household is far below every bulk threshold, but meeting the bulk rules costs nothing and removes one class of failure.

**Hetzner port policy.** Hetzner's FAQ says ports 25 and 465 are blocked outbound on all cloud servers. After a month as a customer and a paid first invoice, you can file a limit request in the console, decided case by case. Port 587 is open without a request. The block follows the account that owns the project ([Hetzner Cloud server FAQ](https://docs.hetzner.com/cloud/servers/faq/)). The account dates from at least 2026-08-31, so it should already qualify. Inbound port 25 is not affected, so receiving works from day one.

**Hetzner IP reputation.** This is the main risk. Microsoft is the problem receiver:

- Hetzner's own troubleshooting page documents Outlook.com blocks S3140 (manual delisting) and S3150 (a throttle that clears after a few days). It describes a delisting flow through `olcsupport.office.com` that usually needs a reply to the first automated refusal. It also says that if delisting fails, "the only solution is to change the IP" ([Hetzner: Microsoft blacklist](https://docs.hetzner.com/robot/dedicated-server/troubleshooting/microsoft-blacklist/)).
- In October 2025, operators reported Outlook.com rejecting or silently dropping mail from European cloud ranges, Hetzner included. Hetzner's press office told the reporter that Microsoft runs an aggressive internal blocklist that includes subnets that never sent spam. Reader reports are mixed: some were fixed by the delist form, and others traced the problem to their own DMARC ([Born City, 2025-10-16](https://www.borncity.com/blog/2025/10/16/blockt-microsoft-mails-von-europaeischen-cloud-providern-in-outlook-com-hotmail-com/)). This source is a secondary report, but Hetzner's quoted statement matches its own doc.
- Microsoft's monitoring tools will not help at household volume. Hetzner says SNDS only shows data for IPs sending over 100 mails a day to Outlook.com, and neither SNDS nor JMRP can delist ([Hetzner doc above](https://docs.hetzner.com/robot/dedicated-server/troubleshooting/microsoft-blacklist/)). SNDS relaunched in June 2026 with new access controls, and early users report enrollment trouble ([Spam Resource](https://www.spamresource.com/2026/06/snds-and-jmrp-in-transition.html)). A secondary source says the new portal authorizes only the WHOIS contact of a range, which for a cloud IP is Hetzner ([Suped](https://www.suped.com/learn/email-deliverability/why-does-the-new-microsoft-snds-portal-only-offer-whois-authorization), unverified).
- UCEPROTECT lists many individual Hetzner IPs at level 1 ([CESNET NERD example](https://nerd.cesnet.cz/nerd/ip/188.245.222.46)). The level 3 lookup for AS24940 was mid-update when I checked, so its status is unverified. Major mailbox providers are not known to use UCEPROTECT level 3; treat a level 1 hit on your own IP as a reason to swap it.
- Spamhaus: Microsoft treats any Spamhaus-listed IP as blocked ([Hetzner doc above](https://docs.hetzner.com/robot/dedicated-server/troubleshooting/microsoft-blacklist/)). Check with the [Spamhaus IP checker](https://check.spamhaus.org/) rather than by DNS, because Spamhaus answers queries from Hetzner's resolvers and other public resolvers with an error code (127.255.255.254) since February 2025 ([Spamhaus notice](https://submit.spamhaus.org/resources/query-the-legacy-dnsbls-via-hetzner/)). The same notice matters for Stalwart's inbound DNSBL checks: it needs a free DQS key or its own recursive resolver.

**Checking and "warming" an IP.** A household sends too little to build reputation in the usual sense. The useful steps are: check the new IP on Spamhaus, MXToolbox, and multirbl before any DNS points at it; send test mail to Outlook.com, Gmail, and Yahoo test accounts and read the headers; and if the IP is listed, allocate a new primary IP rather than fight the listing (Hetzner's own advice). Set PTR for the server's IPv4 and its chosen IPv6 address in the console or API, forward-confirmed ([Hetzner rDNS docs](https://docs.hetzner.com/cloud/servers/cloud-server-rdns)).

**IPv6.** Gmail checks IPv6 PTR the same way. If Stalwart sends directly, either set PTR and AAAA for one fixed IPv6 address and bind outbound to it, or restrict outbound to IPv4. Stalwart's connection strategy takes explicit source IPs and an EHLO name, and its IP strategy has an `ipv4_only` option ([Stalwart outbound connection](https://stalw.art/docs/mta/outbound/connection/), [IP strategy constants](https://stalw.art/docs/ref/expression/constant/mta-ip-strategy-constant/)). Through a relay, IPv6 on the server stops mattering for reputation.

**Direct send or relay.** I recommend a relay on port 587 from day one, with direct send as a tested fallback. The reasons: Microsoft is the documented failure point for Hetzner cloud ranges; the Microsoft tools that would show a problem do not work at household volume; and a relay removes the port 25 request from the critical path. Privacy cost: the relay sees outbound content, which Fastmail sees today, so this is not a regression. DKIM stays aligned because Stalwart signs with a 907.life key before the relay hands mail on. Stalwart supports a relay route with SMTP AUTH, though one 0.16.12 user reported a route being ignored, so verify it in the rehearsal ([Stalwart routing](https://stalw.art/docs/smtp/outbound/routing), [forum thread](https://support.stalw.art/t/how-to-configure-a-global-authenticated-outbound-relay-smarthost-in-stalwart-0-16-12/1009)).

Relay options for a few hundred messages a month:

| Relay | Cost at household volume | Ports usable from Hetzner | Limits | Notes |
|---|---|---|---|---|
| Amazon SES | $0.10 per 1,000 ([pricing](https://aws.amazon.com/ses/pricing/)) | 587, 2587 ([SES SMTP](https://docs.aws.amazon.com/ses/latest/dg/smtp-connect.html)) | 40 MB messages; sandbox until production access ([quotas](https://docs.aws.amazon.com/ses/latest/dg/quotas.html)) | Custom-domain DKIM; US company. Approval for personal mail is unverified. |
| SMTP2GO | Free to 1,000 a month and 200 a day ([free plan](https://support.smtp2go.com/hc/en-gb/articles/223087947-Free-Plan)); $10/month Starter ([pricing](https://www.smtp2go.com/pricing/)) | 587 and alternates (unverified) | Free plan keeps 5 days of reports | Simple; Australian company. |
| Cloudflare Email Service | 3,000 a month on Workers Paid ([pricing](https://developers.cloudflare.com/email-service/platform/pricing/)) | 465 only, which Hetzner blocks ([SMTP docs](https://developers.cloudflare.com/email-service/api/send-emails/smtp/)) | 5 MiB messages ([limits](https://developers.cloudflare.com/email-service/platform/limits/)); beta; built for transactional mail | Not suitable. |

SES is the cheapest with the largest message size; SMTP2GO is the least setup. Either works; this is a budget and privacy choice for Geoff.

## 2. DNS records and order of operations on Cloudflare

All mail hostnames must be DNS-only (grey cloud). Cloudflare's minimum TTL for DNS-only records is 60 seconds and "Auto" is 300 ([Cloudflare TTL](https://developers.cloudflare.com/dns/manage-dns-records/reference/ttl/)). The MX is already at 300.

- **Host records**: `mail.907.life` A (and AAAA if used), matching the PTR and Stalwart's EHLO name.
- **MX**: one record, `10 mail.907.life`, set at cutover. Do not mix Fastmail and Stalwart MX priorities, which would split mail between two stores.
- **SPF**: before cutover, `v=spf1 include:spf.messagingengine.com ip4:<server> [ip6:<server>] [relay include] ~all`. After the rollback window, drop the Fastmail include and move to `-all`. Fastmail-hosted masked addresses send as fastmail.com and are unaffected.
- **DKIM**: publish a new Stalwart selector (for example `s2026._domainkey`, RSA 2048, plus an Ed25519 selector if Stalwart dual-signs) days before cutover. Google wants at least 1024 bits and recommends 2048 ([Google](https://support.google.com/mail/answer/81126?hl=en)). Keep `fm1`-`fm3` until Fastmail is cancelled; they do no harm.
- **DMARC**: keep `p=none` through cutover and two to four weeks after, with `rua=mailto:dmarc-reports@907.life`. Then `p=quarantine`, then `p=reject` once reports show only Stalwart (and the relay) passing. DMARC is now RFC 9989 (May 2026), which drops `pct` in favor of a binary `t=y` test flag ([RFC 9989](https://www.rfc-editor.org/rfc/rfc9989.txt)). Ramp with `t=y` rather than `pct`. Keeping `rua` inside 907.life avoids the external-reporting authorization record.
- **TLS-RPT**: `_smtp._tls` TXT `v=TLSRPTv1; rua=mailto:tls-reports@907.life` ([RFC 8460](https://www.rfc-editor.org/rfc/rfc8460)).
- **MTA-STS**: `_mta-sts` TXT plus a policy at `https://mta-sts.907.life/.well-known/mta-sts.txt` ([RFC 8461](https://www.rfc-editor.org/rfc/rfc8461)). Stalwart can serve the policy itself on 443 and generate the records; its default mode is `testing` ([Stalwart MTA-STS](https://stalw.art/docs/mta/transport-security/mta-sts)). Publish in `testing` with a short `max_age` (one day) listing both Fastmail and Stalwart MX hosts during overlap, then switch to `enforce` with a long `max_age` after Fastmail's MX is gone. A Cloudflare Worker serving a static file is an alternative that does not depend on the mail host's web listener.
- **DNSSEC**: Cloudflare is both DNS host and registrar, so enabling DNSSEC publishes the DS record automatically ([Cloudflare DNSSEC](https://developers.cloudflare.com/registrar/get-started/enable-dnssec/)). Do it as a separate change after cutover settles, never on cutover day.
- **DANE**: TLSA at `_25._tcp.mail.907.life` needs DNSSEC ([RFC 7672](https://www.rfc-editor.org/rfc/rfc7672)), and Cloudflare DNS accepts TLSA records ([Cloudflare record types](https://blog.cloudflare.com/additional-record-types-available-with-cloudflare-dns/)). With ACME certificates that rotate every few months, a stale TLSA record makes DANE senders refuse your mail. Defer DANE until DNSSEC has run cleanly and certificate key rotation is handled. MTA-STS covers most of the benefit.
- **Client discovery**: SRV `_submissions._tcp` (465), `_imaps._tcp` (993) per [RFC 6186](https://www.rfc-editor.org/rfc/rfc6186) and [RFC 8314](https://www.rfc-editor.org/rfc/rfc8314); `_caldavs._tcp` and `_carddavs._tcp` per [RFC 6764](https://www.rfc-editor.org/rfc/rfc6764); `_jmap._tcp` per [RFC 8620](https://www.rfc-editor.org/rfc/rfc8620). An `autoconfig.907.life` host serves Thunderbird-style clients. Which of these Hylki reads is unverified; test it.
- **PTR**: set in Hetzner for IPv4 and the chosen IPv6 address, before the first test send.

## 3. Data migration

**Mail.** Stalwart's documented path is Vandelay, a one-shot migration tool that reads JMAP, IMAP, CalDAV, CardDAV, and more into a per-account SQLite archive, then reconciles the archive onto a JMAP target ([Stalwart migration](https://stalw.art/docs/migration/)). Its JMAP import page names Fastmail as a use case and uses `https://api.fastmail.com/jmap/session` in its bearer-token example ([Vandelay JMAP import](https://stalw.art/docs/migration/import-export/import/jmap/)). The old `stalwart-cli import` is gone in 0.16, per community answers ([forum](https://support.stalw.art/t/v0-16-fast-bulk-export-import-of-individual-mailboxes-for-backup-and-gdpr-reasons/319)). Useful properties:

- `--dry-run` on every command, and `inspect` prints per-type counts from the archive ([usage](https://stalw.art/docs/migration/import-export/usage/)).
- Re-runs are convergent and do not duplicate. Role mailboxes (Inbox, Sent, Trash) bind to the target's own folders ([export](https://stalw.art/docs/migration/import-export/export/)).
- It is young. The first release blog post is dated 29 May 2026 ([blog](https://stalw.art/blog/jmap-account-migration/)); current release v1.0.12 (2026-10-11). Closed issues include an out-of-memory bug on large JMAP pages and a wrong-date bug on Maildir import ([issues](https://github.com/stalwartlabs/vandelay/issues)). One JMAP import bug involved the `principals` capability, which Fastmail does not advertise, so pass `--account-id` rather than `--account-name` ([issue 21](https://github.com/stalwartlabs/vandelay/issues/21)). The docs do not say explicitly that keywords and `receivedAt` survive; the rehearsal must check.

**Fallback: imapsync.** Mature, keeps flags and internal dates, and can sync a date range for delta runs. It needs a Fastmail app password with mail scope ([Fastmail app passwords](https://www.fastmail.help/hc/en-us/articles/360058752854-App-passwords)). One forum report of imapsync losing bodies into Stalwart is unresolved ([forum](https://support.stalw.art/t/import-documentation-missing/219)), so verify bodies in the rehearsal whichever tool is used.

**Fastmail's own export** is per-folder ZIP, one folder at a time, capped at 4 GB ([Fastmail: download all your data](https://www.fastmail.help/hc/en-us/articles/360060590573-Download-all-your-data)). Take one full set as a cold archive on the backup drive before cutover, independent of either tool.

**Verifying counts.** Both ends speak JMAP. A read-only script compares, per mailbox, `totalEmails` and `unreadEmails`, plus counts of `$flagged` and `$answered` (Email/query with `hasKeyword`), and checks `receivedAt` on a sample of old messages. Targets: 35,571 messages across 36 mailboxes for Geoff, plus the second operator's totals.

**Contacts.** 188 contacts. Fastmail exposes JMAP Contacts, so Vandelay's JMAP import should carry them; CardDAV and a vCard 3.0 file are fallbacks ([Fastmail contacts export](https://www.fastmail.help/hc/en-us/articles/1500000280061-Import-or-export-contacts)). Include the shared contacts-only account.

**Calendars.** Not on Fastmail's JMAP, so use `vandelay import caldav` with the DAV app password, and download each calendar's `.ics` as a fallback ([Fastmail calendar export](https://www.fastmail.help/hc/en-us/articles/360060590773-Import-export-your-calendars)). Recurring events and time zones need a spot check.

**Not migrated.** Rules (a later session), masked addresses, and Fastmail-specific features. Inventory every 907.life address Fastmail accepts (aliases, `postmaster@`, any catch-all, the three @907.life masked addresses) and create each in Stalwart before the MX switch.

## 4. Cutover plan, rollback, and the Fastmail plan

**Rehearsal.** Import full copies of both mailboxes into Stalwart while MX still points at Fastmail. Verify counts, flags, dates, and bodies. Connect Hylki, poplar, and phones. Send from Stalwart through the relay to Gmail, Outlook.com, Yahoo, and [mail-tester](https://www.mail-tester.com/) and read the authentication results. Deliver test mail inbound with a direct SMTP connection. Run a Stalwart restore drill.

**MX switch and propagation.** With TTL 300, most senders follow within minutes, but queued retries can land at Fastmail for days.

**Delta sweeps.** Vandelay's export is upsert by default: matched items are updated from the archive ([README](https://github.com/stalwartlabs/vandelay)). Re-exporting a full Fastmail archive over a Stalwart account in active use could revert moves and resurrect deletions (my inference from the documented semantics; test it in the rehearsal). Safer: a final full Vandelay pass right before the switch, then date-scoped imapsync sweeps of Fastmail's Inbox at T+1 day, T+3, and T+7.

**Local delivery gotcha (unverified for Fastmail).** Hosted mail systems often deliver to a domain they host without looking up MX ([general pattern, iRedMail forum](https://forum.iredmail.org/post50807.html)). While 907.life stays configured at Fastmail, mail sent from inside Fastmail to @907.life (a forwarding rule, a masked-address forward, another Fastmail customer) may stay at Fastmail. Test this right after the switch. Forwarding targets must sit on a domain Fastmail does not host until 907.life is removed there.

**Rollback.** Flip MX (and SPF) back to Fastmail; TTL 300 makes this quick. Mail received at Stalwart in the meantime must be copied back to Fastmail (imapsync reverse, or Vandelay export to Fastmail's JMAP, untested). Keep Fastmail fully configured, domain included, for 30 days.

**Fastmail plan.** Current US prices: Individual $6/month ($5 billed yearly), Duo $10 ($8 yearly), Basic $4 ($3 yearly) ([Fastmail pricing](https://www.fastmail.com/pricing/us/)). Basic is not usable for the triage window. It has no custom domains, IMAP, CalDAV, CardDAV, or app passwords ([app passwords](https://www.fastmail.help/hc/en-us/articles/360058752854-App-passwords)). It has no API tokens either ([Fastmail API tokens](https://www.fastmail.help/hc/en-us/articles/5254602856719-API-tokens)). The triage script and the 1Password integration need API access. Whether Basic keeps Masked Email is unclear. The cheapest workable plan is Individual: after the 30-day rollback window, remove the second operator's user and downgrade, then cancel when triage ends.

**Masked addresses after downgrade or closure.** Fastmail's help covers states (enabled, blocked to Trash, deleted and bouncing) and says custom-domain masked addresses die with the domain ([Masked Email help](https://www.fastmail.help/hc/en-us/articles/4406536368911-Masked-Email)). I found no statement on what happens to @fastmail.com masked addresses when an account closes. Assume they bounce from the day of closure, and ask Fastmail support to confirm. Account data is purged 37 days to a year after closure ([Fastmail DPA annex 2](https://www.fastmail.com/policies/dpa/annex2/)).

## 5. Masked email triage

1. **Export.** `MaskedEmail/get` returns `id`, `email`, `state`, `forDomain`, `description`, `url`, `createdBy`, `createdAt`, and `lastMessageAt` ([Fastmail API docs](https://www.fastmail.com/dev/)). Write it to a JSON file outside git; the list is sensitive.
2. **Enrich.** For each address, query Fastmail mail (read-only) for message count and sender domains over the last year. This identifies services where `forDomain` is blank. Join with password-manager logins by username, which covers the 162 addresses 1Password created.
3. **Classify.** *Critical*: banks, government, health, utilities, domain and hosting, anything used for account recovery. Move first, by hand, and confirm with a password reset. *Active*: mail in the last 12 months (about 91). *Dormant*: older mail; move if the account still matters, otherwise close the account at the service. *Never used*: 24 addresses; close or ignore. *Delete*.
4. **Forward during the window.** A Fastmail rule on the `X-FM-Masked-Email` header can send a copy of masked mail elsewhere ([Masked Email help](https://www.fastmail.help/hc/en-us/articles/4406536368911-Masked-Email)). SRS can be turned on for forwards ([Fastmail forwarding](https://www.fastmail.help/hc/en-us/articles/360058753434-Set-up-mail-forwarding)). Point it at a Stalwart address on a domain Fastmail does not host (see the gotcha above). A Sieve rule in Stalwart tags these, so the tag is the to-do list.
5. **Replace.** For each service: create a Proton Pass alias, change the address at the service, confirm the verification mail arrives in Stalwart, update the login's username, then set the Fastmail mask to `disabled` (blocked to Trash, reversible). Mail arriving later at a disabled mask shows a missed service; mail at an enabled one is a service not yet moved.
6. **Track.** Add a `status` column to the exported file (todo, moved, closed, abandoned) with the date, and recompute counts from the API each week.
7. **Exit criterion.** Cancel Fastmail when no enabled mask and no forwarded masked mail has appeared for 30 days.

**Bulk tooling.** There is no bulk way to change an address at third-party services; each one is manual. Third-party pages document `pass-cli item alias create --prefix` (unverified against Proton's docs, and choosing a custom-domain suffix is undocumented) ([third-party summary](https://aiskill.market/skills/proton-pass-cli)). A catch-all on the alias subdomain removes the need to pre-create aliases: type `service@<sub>.907.life` at the service, and the alias appears on first mail.

## 6. Proton Pass alias domain

- **Plan.** Custom domains need a paid Pass, Workspace, or Visionary plan, up to 10 domains ([Proton custom domain](https://proton.me/support/pass-use-custom-domain)). Pass Plus is $35.88 a year; Pass Family is $59.88 a year for six users ([Proton Pass pricing](https://proton.me/pass/pricing)). Family covers Geoff and the second operator.
- **DNS.** Proton requires TXT ownership and MX records; SPF, DKIM, and DMARC are optional but recommended. Exact values appear only in the Pass "Info" tab ([Proton custom domain](https://proton.me/support/pass-use-custom-domain)). The SimpleLogin backend documents MX `10 mx1.simplelogin.co` and `20 mx2.simplelogin.co` ([SimpleLogin Cloudflare guide](https://simplelogin.io/docs/custom-domain/registrars/cloudflare/cloudflare)), SPF including `simplelogin.co`, and DKIM CNAMEs ([Namecheap guide](https://simplelogin.io/docs/custom-domain/registrars/namecheap/namecheap/)). Copy values from the Pass screen, not from these guides. A subdomain keeps its own MX separate from 907.life's.
- **DMARC.** Give the subdomain its own `_dmarc` record so the 907.life ramp does not decide its policy by inheritance.
- **Forwarding to Stalwart.** Paid plans can add external forwarding mailboxes, verified by a code ([Proton aliases](https://proton.me/support/pass-email-alias)). Make the Stalwart address the default mailbox. Do not use a forwarding address as the mailbox, or replies break ([SimpleLogin anti-phishing](https://simplelogin.io/docs/getting-started/anti-phishing/)).
- **Replies.** Forwarded mail arrives from a per-sender reverse alias; replying to it sends from the alias and hides the mailbox ([reverse alias](https://simplelogin.io/docs/getting-started/reverse-alias/)). SimpleLogin enforces strict DMARC on mail from the mailbox ([SimpleLogin security](https://simplelogin.io/security/)), so Stalwart's outbound DKIM must be right before replies work.
- **SRS, ARC, and spam filtering.** SimpleLogin checks the original sender's DMARC before forwarding. It quarantines on a sender's reject or quarantine policy, and otherwise forwards with a warning ([anti-phishing](https://simplelogin.io/docs/getting-started/anti-phishing/)). How it rewrites envelope and headers is not documented on the pages I found. Stalwart verifies ARC on every message ([Stalwart DMARC/ARC](https://stalw.art/docs/spamfilter/dmarc/)). In the later filters session, treat mail arriving from SimpleLogin's servers as a trusted forwarder so it is not scored down for the original sender's SPF; Stalwart has a trusted-senders feature, which I did not review.
- **Exposure.** All alias mail transits Proton, and Proton sees it in clear. A Proton account problem stops delivery to every alias. Mail to 907.life itself does not depend on Proton.

## 7. Ongoing mail health

- **Reports.** Stalwart parses DMARC aggregate, TLS-RPT, and ARF reports and shows them in its web UI. Interception uses `inboundReportAddresses` (default `postmaster@*`) ([Stalwart report analysis](https://www.stalw.art/docs/mta/reports/analysis)). Add `dmarc-reports@` and `tls-reports@` to that list; a user reported TLS reports reaching the inbox because the address did not match ([forum](https://support.stalw.art/t/tls-reports-not-handled-by-stalwart-and-sent-to-inbox/47)).
- **Blocklists.** A weekly timer checks the server IP and relay results on the DQS-backed Spamhaus zones and a few other lists, and alerts on a hit.
- **Post-cutover test**, repeated after any config change: send to mail-tester and to a Gmail and an Outlook.com test account; confirm `spf=pass`, `dkim=pass` (d=907.life), `dmarc=pass`, TLS, and inbox placement in "Show original". Check [learndmarc.com](https://www.learndmarc.com/) for a visual trace.

## Recommendation: step-ordered cutover

1. **Now.** File the Hetzner port 25 limit request (fallback only). Choose the relay and verify the 907.life domain there. Confirm the Fastmail plan type and the second operator's credentials.
2. **Build week.** Stalwart up (separate brief). Check the IP on blocklists; swap it if listed. Set PTR. Publish `mail` A/AAAA, the new DKIM selector, an SPF that includes both Fastmail and the new sender, TLS-RPT, and MTA-STS in `testing`. Move `rua` to `dmarc-reports@907.life`. None of this changes delivery.
3. **Rehearsal.** Full Vandelay import for both accounts, contacts, and calendars. Verify with the count script, then client and send tests, and a restore drill. Fix and repeat until clean. Take the Fastmail ZIP export to the backup drive.
4. **Masked-email prep.** Export and classify the masks. Set up the Proton Pass subdomain and its DNS, with Stalwart as the mailbox. Move the critical services first; this can start before cutover.
5. **Cutover day** (a quiet weekday morning, both people available). Final Vandelay pass. Create every Fastmail-accepted 907.life address in Stalwart. Switch MX to `mail.907.life`. Test inbound from outside, and from inside Fastmail for the local-delivery gotcha. Point clients at Stalwart.
6. **T+1, T+3, T+7.** Date-scoped imapsync sweeps from Fastmail. Read DMARC reports.
7. **T+30.** If clean: remove Fastmail's SPF include, set SPF to `-all`, and remove 907.life from Fastmail. Remove the second operator and downgrade to Individual. Set the masked-email forward. Set MTA-STS to `enforce`. Start DMARC `p=quarantine`.
8. **T+45 or later.** Enable DNSSEC; later, `p=reject`.
9. **Triage end.** Cancel Fastmail once the exit criterion holds. Remove the `fm*` DKIM CNAMEs.

## Risks

- Microsoft silently drops or blocks Hetzner-origin mail. Mitigation: relay, test accounts, and the delist path.
- Vandelay is five months old. A silent loss of flags, dates, or bodies would be found only if the rehearsal checks for it.
- Delta re-export reverting changes on the live account. Mitigation: date-scoped sweeps after cutover.
- Fastmail local delivery hiding mail during overlap.
- A masked address missed in triage bounces after cancellation. If it was a recovery address, that account is lost. Mitigation: the critical tier first, and the 30-day quiet exit criterion.
- Proton becomes a second dependency for every alias.
- A single USB backup copy for the household's account-recovery root. A Fastmail ZIP export and Vandelay archives add cheap extra copies during the transition.

## Open questions for Geoff

1. Relay: SES (cheapest, AWS account, US) or SMTP2GO (free tier, least setup), or direct send once port 25 opens, accepting the Microsoft risk?
2. Proton plan: Pass Family ($59.88 a year, covers the second operator) or Pass Plus for Geoff only?
3. Alias subdomain name (for example `id.907.life`), and catch-all on or off. Catch-all is faster to triage but accepts mail to any guessed address.
4. Rollback window: 30 days at the current Fastmail plan, then Individual until triage ends. Is a three-month total budget acceptable?
5. Does the second operator have any masked addresses, or any services registered to Fastmail-only addresses, that join the triage?
