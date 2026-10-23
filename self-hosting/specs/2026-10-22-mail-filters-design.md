# Mail filters and folder reorganization: design

Status: drafted 2026-10-22 from a brainstorm with Geoff; waits on his approval.

This is the self-hosting initiative's deferred goal: "Mail filters can be managed through Stalwart's API." Mail moved to ward on 2026-10-22. Fastmail's filters were not migrated, so ward runs no Sieve script, and new mail lands unsorted. This design covers new filters for Geoff's mailbox and a one-time re-filing of the mail already in it.

## Intent

Geoff wants his Inbox to hold only mail meant for him personally. Everything automated gets sorted into a few categories he can browse when he chooses. Discussion lists each get their own folder. The folders that grew up under Fastmail (about 35, 20 of them empty, several holding one sender each) get replaced by that structure, and the mail already in them moves to match.

## Scope

In scope:

- Geoff's mailbox only, `geoff@907.life` (Geoff, 2026-10-22). The second operator's mailbox is untouched.
- One user Sieve script on ward, managed through Stalwart's JMAP Sieve interface (RFC 9661) and kept in the servers repo.
- A one-time re-filing of the mail already in the mailbox, the Inbox and Archive included.
- Deleting every Remind message (Geoff: "you can just delete all the old Remind messages"). The Anchorage School District replaced Remind with sportsYou, so no rule handles Remind going forward.
- Deleting folders that end up empty.

Out of scope:

- The second operator's mailbox, and any server-wide (system) Sieve script.
- Auto-expiry or retention rules. Deleting old mail is a separate decision.
- Spam-filter tuning beyond keeping today's junk filing working.
- Any tool or UI for Geoff to edit filters himself. Claude edits the script on request.

Anti-goals, which would make this a failure even if it ran:

- Personal mail lost, or filed somewhere Geoff won't see it. A rule that guesses wrong must fail toward the Inbox for the security case, and toward a browsable folder for everything else, never toward deletion.
- A sign-in code or password reset hidden in a folder while Geoff waits for it.
- Machinery out of scale with the job. One script and one re-filing tool, with no generator, database, or daemon unless the builder shows it's needed.

## The folder structure

| Folder | Holds |
|---|---|
| Inbox | Mail a person wrote for Geoff and sent to him (on To or Cc, or from a contact even on Bcc), account-security mail, and postmaster mail |
| Archive | Personal mail Geoff has finished with. Never lists or notifications |
| Light | Texts from Geoff's Light Phone, which arrive as "Light - Message from …" from `no-reply@thelightphone.com` |
| Lists/*name* | One folder per discussion list, created automatically on the first message |
| Notifications/Shopping | Stores and shipping: Amazon, eBay, the clothing and gear stores, UPS, DHL |
| Notifications/Money | Banks and payments: Bank of America, Wealthfront, Stripe, Venmo, PayPal, Intuit, Gusto |
| Notifications/Health | Patient portals, Premera, the eye and vet clinics, Arete Family Care |
| Notifications/News | Newsletters: Economist, Axios, Substack (Figs in Winter among them), ADN, Atlantic, Reuters |
| Notifications/Tech | GitHub, Cloudflare, Hetzner, Anthropic, ClouDNS, VoIP.ms, Callcentric, PikaPods, and a Reports subfolder for DMARC and TLS reports |
| Notifications/Cross Country | Skiing and cross country running: sportsYou, athletic.net, NSAA, RunSignup, ecxc.ski |
| Notifications/Other | Automated mail that matches no category, travel included (Geoff ruled travel needs no folder) |

Geoff named the categories and the Cross Country folder. He folded Travel into Other. The system folders keep their Stalwart roles: Drafts, Sent Items, Deleted Items, Junk Mail, and Scheduled.

Archive works as it does in Gmail and Fastmail (Geoff agreed, 2026-10-22). Geoff reads personal mail in the Inbox, then archives it. Archive gets no yearly or topic sub-folders, because search covers that. Lists and notifications never pass through Archive. Geoff reads them where they land, and their folders serve as their archive.

## How new mail is sorted

The script runs these tests in order, and the first match decides.

1. **Spam.** A message Stalwart's spam filter marks as spam goes to Junk Mail, as it does today. The builder confirms whether Stalwart still files junk on its own once a user script is active, and keeps that behavior either way.
2. **Account security.** Sign-in codes, password resets, verification links, and new-sign-in alerts go to the Inbox, even though they're automated (Geoff: "If you can make the rules reliable to make that happen"). The rule needs two signals together: a sender on a short known list (Google accounts, Microsoft account protection, GitHub, Apple ID, Proton, Cloudflare, Fastmail, Hetzner, and the banks), and an account-access word in the subject. The word list starts from the one the Proton Services filter used: reset, password, code, verify, verification, sign in, sign-in, login, log in, new device, security alert, 2FA, two-factor, recovery, confirm your. The reliability gate below decides whether this rule ships.
3. **Role addresses.** Mail to `dmarc-reports@907.life` or `tls-reports@907.life` goes to Notifications/Tech/Reports, which replaces DMARC Reports. The rule matches on the recipient, since report senders such as google.com are also on the security list. Mail to `postmaster@907.life` goes to the Inbox, because it is rare and may need action (Claude's call).
4. **Light Phone.** Mail from `no-reply@thelightphone.com` goes to Light.
5. **Personal.** Mail a person wrote for Geoff goes to the Inbox, whatever list or category it would otherwise match (Geoff, 2026-10-22: "Stuff this is personally written by another human for me and is sent to me should always end up in my inbox"). A message counts as personal in either of two cases:
   - `geoff@907.life` is on To or Cc and the message isn't automated: no Auto-Submitted other than `no`, no no-reply sender, and, unless it carries a List-Id, no List-Unsubscribe or `Precedence: bulk`. A list post where Geoff is on To or Cc directly counts as personal, since list servers add bulk headers to every post.
   - The sender is in Geoff's contacts, the message carries no List-Id, and it isn't automated by the same test. Geoff ruled (2026-10-22) that a contact reaches the Inbox even when he's only on Bcc. A contact's posts to a list still go to the list folder.
6. **Discussion lists.** A message from a discussion list goes to `Lists/<name>`, with the name taken from its List-Id. The folder is created on the first message, so joining a list needs no script edit. The sailing club's committee groups are lists like any other (Geoff, 2026-10-22).
7. **Notification categories.** A sender domain on a category's list goes to that category's folder. Adding a sender is a one-line edit. A coach writing personally from ecxc.ski reached the Inbox at step 5, so only automated mail gets this far.
8. **Unknown bulk mail.** A message with bulk markers (List-Unsubscribe, `Precedence: bulk` or `list`, Auto-Submitted other than `no`, or a no-reply sender) goes to Notifications/Other. This catches a new store's receipt or a new service's mail addressed to `geoff@907.life`, so the domain table isn't a chore (Claude's call, from Geoff's intent that everything automated gets sorted).
9. **Everything else** goes to Notifications/Other. This is mail from a stranger with Geoff only on Bcc, which Geoff's rule keeps out of the Inbox (Claude's call).

Geoff's account carries these aliases (`roles/stalwart/accounts.json`): `geoff-login`, `postmaster`, `dmarc-reports`, `tls-reports`, and three former Fastmail masks moved to 907.life (`noble.dust8809`, `heavy.egg1627`, `other.lamp7477`). `geoff-login`, those three, and the fastmail.com masks still forwarding are only ever used to sign up for services. They never count as "to Geoff" in step 5, so their mail lands in a category or in Other.

Geoff's contacts are on ward. Hylki and GNOME Contacts have used ward's address books since 2026-10-22, and his Global Address Book is shared with the second operator. Both books count as contacts for step 5 (Claude's call). Proton Pass aliases on `m.907.life` deliver to `geoff@907.life` and need checking: an alias message may show the alias on To, so step 5 could treat it as personal. The builder confirms how Proton rewrites the headers and treats the `m.907.life` aliases like the masks.

### Facts the builder must verify on ward (Stalwart v0.16.27)

- **Header access.** On this server, JMAP returns `null` for `header:List-Id:asText` but answers the raw form `header:List-Id` (seen 2026-10-22). Any JMAP tooling must request raw header forms. Sieve header tests are a separate path and need their own check.
- **Telling discussion lists from bulk mail.** GitHub notifications carry a List-Id (`glw907/aksailingclub-org …`), and so may newsletters. List-Id alone can't separate a discussion list from a notification. The likely separator is the List-Post header (RFC 2369), which discussion lists set and most bulk senders omit. The builder confirms this against the corpus, and the category rules in step 7 come before step 6 where needed so GitHub stays in Tech.
- **The contacts test.** Stalwart's Sieve docs list extlists (RFC 6134) but don't document an address-book lookup. Stalwart's spam filter trusts address-book senders (`trustContacts`, default true), but its docs don't say whether that leaves a header or tag a user script can test. The builder tries, in order: a spam-filter tag visible to Sieve, then extlists against the address book, then a sender list generated from Geoff's contacts into the script and refreshed when the script is applied. The first that works on a probe account wins.
- **Creating list folders.** `fileinto :create` (RFC 5490 mailbox extension) with variables (RFC 5229) is the intended way to create a `Lists/<name>` folder on first use. Stalwart lists both RFCs, but whether it supports `:create` isn't documented. If it doesn't, the fallback is a fixed list of today's lists in the script, with an unknown list going to a single `Lists/New` folder.
- **Script safety.** A Stalwart issue reports mail dropped after a failed Sieve activation (stalwartlabs/stalwart#3207, unverified). Every script change is tested on the `probe` account first, validated before activation, and activated only after a probe delivery succeeds.

## Re-filing existing mail

A one-time run over JMAP applies the same classification to every message already in the mailbox: the Inbox (623), Archive (29,407), and every user folder. Sent Items, Drafts, Deleted Items, and Junk Mail are left as they are. The re-filing must classify with the same rules as the Sieve script, so the two can't drift. Ideally it runs the real script against each message. If that isn't possible, the builder shows the rules are equivalent by comparing both on the corpus.

Old mail needs one difference from new mail: the re-filing never moves anything into the Inbox, and it never moves mail that looks personal out of Archive (Claude's call). Concretely, for each existing message:

- If the script would send it to Light, a Reports folder, a list, a category, or Other by the bulk test (steps 3, 4, 6, 7, and 8), it moves there.
- If the script would send it to the Inbox (steps 2 and 5, plus `postmaster`), it stays in the Inbox or Archive where it is. In any other user folder, it moves to Archive, since Geoff has already read it.
- If it would reach step 9 (a human sender, not a contact, Geoff not on To or Cc), it stays in the Inbox or Archive. In any other user folder, it moves to Archive.

So old sign-in codes stay in Archive rather than flooding the Inbox, and a stranger's old Bcc stays where Geoff filed it. The re-filing tool takes the script's classification and applies this mapping on top, so the classification rules still can't drift. Read and unread state and flags are preserved.

Folder changes:

- Finance Committee, Program Committee, Membership Committee, and Buccaneer 18 become list folders under `Lists`.
- Notifications becomes the parent folder, and its 295 messages are sorted into the categories.
- News, Wealthfront, Spotify, Cloudflare, US Sailing, Figs in Winter, and Arete Family Care fold into their categories. DMARC Reports becomes Notifications/Tech/Reports.
- Duplicate system folders are merged into the role folder: Trash (0) into Deleted Items, Spam (1) into Junk Mail, Sent (0) into Sent Items.
- Every folder left empty is deleted. Today's empty ones include Amazon, Anthropic, Axios, Kagi, Steam, Github, VoIP.ms, Netflix, 1Password, PayPal, Garmin, Economist, NSAA, Sunbeam Wireless, Anchorage Daily News, and the old empty Lists. Folders with a Stalwart role are never deleted.

Remind messages (about 250 in the surveyed sample) move to Deleted Items rather than being destroyed, so a mistake can be undone until Trash expires (Claude's call).

Safeguards:

1. The run starts with a dry run that reports, per destination folder, how many messages would move there and from where, plus the Remind count. Geoff sees those numbers in the approval packet before anything moves.
2. A ward backup snapshot newer than the dry run must exist before the real run.
3. The real run writes a manifest of every move (message id, old folders, new folders). An undo reads the manifest back.
4. The run moves messages and deletes only empty folders. It never destroys a message.

## The reliability gate

Before the script goes live, Claude runs its classification over the whole existing mailbox and reports five things in the packet: the count per folder; every message the security rule would pull into the Inbox; a sample of personal-looking mail (human sender, no list or bulk headers) that would land outside the Inbox; and every message that reaches Other; and every automated-looking message that would still reach the Inbox. Geoff reads the security list and the stray personal mail. If the security rule pulls in marketing mail or misses a real code or reset, it doesn't ship, and security mail falls back to Notifications/Tech with the rest of Geoff's design unchanged.

## Where things live

The script and the re-filing tool live in the servers repo, which already holds ward's Stalwart role (`roles/stalwart/`) and its JMAP helpers. The builder chooses the exact paths and the tool's language under the workstation's tool-language rule. The runbook gets a short section: where the script lives, how to apply it, how to test on `probe`, and how to undo a re-filing from its manifest. The script is applied over JMAP Sieve with Geoff's credential (`907.life mail: geoff` in the Workstation vault, read through `claude-pass`).

## Calls Claude made

- A contact's posts to a list go to the list folder, not the Inbox.
- A stranger's Bcc goes to Notifications/Other, not the Inbox.
- DMARC and TLS reports go to Notifications/Tech/Reports, matched by recipient, and postmaster mail goes to the Inbox.
- Unknown bulk mail goes to Other unless the sender is a contact.
- Re-filing never moves mail into the Inbox or personal-looking mail out of Archive.
- Both of Geoff's address books on ward count as contacts.
- Remind mail goes to Deleted Items instead of being destroyed.
- No auto-expiry, no yearly Archive folders, and no automatic mark-as-read on notifications.

## Left to the builder

- Folder names for each list, taken from its List-Id, kept short and readable (for example, `Lists/Buccaneer 18 Flagship`). Today's lists come from about 16 List-Ids: the sailing club's committee groups, Buccaneer 18's flagship and BNAC, and alaska-sailing.
- The full sender-domain table for each category, built from the survey's roughly 120 notification domains. Geoff reviews it in the packet.
- The script's internal structure and the re-filing tool's form, within the anti-goal on machinery.
