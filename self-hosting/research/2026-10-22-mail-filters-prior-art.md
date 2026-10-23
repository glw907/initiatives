# Prior art for the mail-filters design

V = verified (I read it in the source). I = inferred. Stalwart claims come from a shallow clone of `stalwartlabs/stalwart` at HEAD `aa47d8e` (2026-10-18), whose `crates/main/Cargo.toml` says 0.16.27, and the `sieve-rs` crate it pins (0.7.3, per `Cargo.lock`).

## 1. Personal mail versus automated mail

- **Commercial systems route by sender, not by headers.** HEY sends every first-time sender to the Screener, and a person decides where that sender's mail goes from then on (V, https://www.hey.com/how-it-works/). In Apple Mail, changing a sender's category "applies to all current and future messages from that sender" (V, https://support.apple.com/en-us/guide/icloud/mmafbebd3108/icloud). Proton sorts by metadata and learns from each move (I, from press coverage: https://neowin.net/news/proton-mail-is-finally-now-able-to-sort-your-emails-into-different-categories/). SaneBox sorts on headers such as sender and subject, and retrains when you move a message (V, https://sanebox.com/help/155-how-does-sanebox-work). Its blog says it also weighs your past mail with each sender (I, https://blog.sanebox.com/2018/07/08/how-is-sanebox-is-different-from-google-priority/). Gmail's tabs are machine learning and can't be copied as rules.
- **Transactional mail usually has no List-Unsubscribe.** Google requires one-click unsubscribe only on marketing mail. "Transactional messages are excluded," and Google names password resets and confirmations as examples (V, https://support.google.com/a/answer/14229414). So a receipt, bank alert, or invoice sent straight to geoff@907.life from an address that isn't no-reply passes the design's "not automated" test and lands in the Inbox. This is the design's biggest false-positive path.
- **Stalwart's vacation code already decides what counts as automated.** sieve-rs `action_vacation.rs` lines 70–135 (V) skip a message when any of these holds:
  - the sender starts with `mailer-daemon` or `owner-`, or contains `-request@`;
  - the message carries any `List-*` header (Archive, Help, Id, Owner, Post, Subscribe, Unsubscribe);
  - `Auto-Submitted` is anything but `no`;
  - `X-Auto-Response-Suppress` contains `All` or `OOF`;
  - `Precedence` is `bulk`.

  GitHub's notifications carry `X-Auto-Response-Suppress: All` (V, a header sample quoted at https://pagure.io/pagure/issue/2294).
- **Email service providers stamp their own headers:** `X-SES-Outgoing` (Amazon SES), `X-Mailgun-Sid` (Mailgun), `X-SG-EID` (SendGrid), and `X-PM-Message-Id` (Postmark) (V, https://sendgrid.com/blog/fingerprinting-email-infrastructure-companies/). I didn't verify `Feedback-ID`.
- **notmuch's afew tool tags every message that has a List-Id as a list**, with no separate test for bulk senders (V, https://afew.readthedocs.io/en/latest/filters.html). I found no published Sieve or imapfilter ruleset that does more than test for List-Unsubscribe or a no-reply sender. I couldn't confirm how Fastmail's "mailing list" rule decides.

## 2. Telling a discussion list from a bulk sender

- **List-Post alone does not separate them.** GitHub notifications carry `List-Post: <mailto:reply+…@reply.github.com>`, `Precedence: list`, and `List-Archive`, along with List-Id (V, the 2017 sample at the Pagure link above). GitHub's own header documentation lists only From (`notifications@github.com`), List-Id, and the X-GitHub-* headers (V, https://docs.github.com/en/subscriptions-and-notifications/reference/email-notification-headers).
- **Mailman sets List-Post in specific ways.** Discussion lists get a mailto List-Post. Announce-only lists get `List-Post: NO`. List-generated notices get no List-Post at all (V, https://docs.mailman3.org/projects/mailman/en/latest/src/mailman/handlers/docs/rfc-2369.html). So "has a List-Post" is wrong for announce lists, and the value has to be tested.
- **rspamd treats list-software markers as strong evidence.** These are `X-Mailman-Version`, `X-BeenThere`, `X-Google-Group-Id`, and `X-Google-Loop`. It treats the generic RFC 2369 headers only as a weaker score (V, https://docs.rspamd.com/modules/maillist).
- I found no published headers for groups.io or Substack (unknown). Checking against the corpus remains necessary.

## 3. Account-security mail

- **No published Sieve or imapfilter ruleset turned up.** The practice I found pairs a sender address with a subject phrase, as the design does (I, https://support.rezora.com/articles/27229305115931).
- **Apple Mail is the closest vendor feature.** A time-sensitive message in another category also shows in Primary, and you can remove it per message with "Don't Show In Primary" (V, the Apple link above). That is an overlay, not a move, and it matches the design's "security goes to the Inbox" rule.
- **No vendor publishes its false-positive rate.** The word list carries a risk I inferred: "confirm your" and "verify" also appear in marketing ("confirm your subscription"), and "code" appears in promotions ("promo code").

## 4. Stalwart specifics (all V, from source)

- **`fileinto :create` works.** `crates/email/src/sieve/ingest.rs` lines 310–365 call `mailbox_create_path`, which splits on `/` and creates each missing level (`crates/email/src/mailbox/manage.rs` line 86). A name that is too long, or a mailbox quota that is reached, returns no folder, and the message falls back to the Inbox. `fileinto` without `:create` to a missing folder also goes to the Inbox ("Default to Inbox"). A mailbox id or a `:specialuse` role resolves first.
- **A user script can't look up the address book.** `Event::ListContains` (extlists) is marked "Not allowed" and evaluates false (ingest.rs line 468). The only plugin a user script can call is `llm_prompt` (`crates/common/src/scripts/plugins/mod.rs` line 68).
- **The spam filter leaves no contact header a script can test.** Before Sieve runs, the SMTP stage adds `X-Spam-Result` (tags) and `X-Spam-Score: spam|ham, score=…` (`crates/spam-filter/src/analysis/score.rs`). The address-book check (`card-exists`) and `trusted-reply` run only after Sieve, at ingest, and only for mail already marked spam. `X-Spam-Status` is written there too, after Sieve (`crates/email/src/message/ingest.rs` lines 263–335). So a user script testing `X-Spam-Status` sees nothing.
- **Junk filing with a script active depends on what the script does.** Ingest passes `is_spam = envelope_to.is_spam() && !did_file_into` and moves spam to Junk only when the message's only target is the Inbox. If the script ends in `keep`, spam still goes to Junk. If the script runs any `fileinto`, including to a list folder, spam lands there and skips Junk. The script can test spam with `spamtest :percent` (RFC 5235), which Stalwart feeds from the per-recipient score. A value of 50 or more equals is-spam (`spamfilter.rs` lines 71–105, with tests).
- **User-script limits** (`crates/registry/src/schema/structs_impl.rs` around line 36828): 100 KB script, 4,096-byte strings, 5,000 CPU instructions, 15 nested tests, 128 local variables.
- **There is no server-side way to run a script over stored mail.** JMAP offers only `SieveScript/get|set|query|validate`. The `sieve-rs` crate runs scripts offline, as its `examples/filter.rs` shows, and pinning `=0.7.3` gives the same interpreter that ward runs.
- **Issue #3207 was auto-closed and redirected to the support portal, not fixed** (V, `gh issue view`). In the report, a failed-then-successful activation through JMAP's `#id` reference left a script that dropped mail on its `keep` branch.
- **The envelope recipient Sieve sees is probably the RCPT TO alias, lowercased** (I, `crates/smtp/src/outbound/local.rs`).

## 5. Bulk re-filing tools

- **Pigeonhole's `sieve-filter` is Dovecot-only and experimental.** Its model is still the one to copy (V, https://doc.dovecot.org/main/core/man/sieve-filter.1.html):
  - it simulates by default, and `-e` executes;
  - a message the script keeps stays where it is;
  - redirect and vacation are ignored.

  Its "keep means stay" rule is the same as the design's "Inbox verdict means stay in the Inbox or Archive" rule.
- imapfilter (Lua) and generic JMAP scripts bring a second rule language, which is exactly the drift the design forbids.
- Stored mail has no envelope or spamtest, so a re-filing harness must supply both. A stored `Delivered-To` header can stand in for the envelope recipient (I, ingest adds it when `add_delivered_to` is on).

## Recommended changes to the design

1. **Step 1:** test spam with `spamtest :percent :value "ge" :comparator "i;ascii-numeric" "50"`, then `fileinto :specialuse "\\Junk" "Junk Mail"`, and `stop` (§4 junk filing). Drop "confirm whether Stalwart still files junk": it doesn't once any `fileinto` runs.
2. **Contacts:** take the third fallback, a sender list generated into the script, and drop the first two tries, since both are impossible (§4 address book). Put it in one `address :is "from" [ … ]` test so the 5,000-instruction CPU limit isn't spent per address. Consider adding every address Geoff has written to, taken from Sent Items. That is the signal SaneBox reports using and Stalwart's own trusted-reply check uses (§1, §4).
3. **Widen "automated" in step 5:**
   - include Stalwart's vacation set: any `List-*` header, `X-Auto-Response-Suppress`, and `mailer-daemon`, `owner-`, and `-request@` senders;
   - include the service-provider headers (`X-SES-Outgoing`, `X-Mailgun-Sid`, `X-SG-EID`, `X-PM-Message-Id`).

   Add one more reliability-gate report: To or Cc Geoff, not a contact, never written to, and passed as personal. That is where receipts and bank alerts will hide (§1 transactional mail).
4. **Discussion-list test:** require a `List-Post` whose value is a `mailto:` and not `NO`, and exclude list-software senders' notices and known notifiers (`reply.github.com`, `notifications@github.com`), with category rules first. Prefer list-software markers (`X-Mailman-Version`, `X-BeenThere`, `X-Google-Group-Id`, a groups.io equivalent once seen) as positive evidence (§2).
5. **Folder names:** clean the List-Id-derived name of `/` and cap its length. Otherwise `:create` makes nested folders or falls back to the Inbox (§4 `:create`).
6. **Re-filing:** run the real script offline through `sieve-rs = "=0.7.3"` against exported messages, supplying the envelope from `Delivered-To` and spamtest as unknown. That removes the need for a separate rule-equivalence proof. If that harness conflicts with the workstation's tool-language rule, flag it as a contestable point (§4, §5).
7. **Security rule:** take "confirm your" and "code" out of the word list, or require them alongside a sender on the known list plus no List-Unsubscribe. Real codes and resets are transactional, and transactional mail is exempt from List-Unsubscribe (§1, §3).
8. **Script safety:** activate in a separate JMAP request after the create succeeds, never through a same-request `#id` reference (§4 issue #3207).
9. **Per-sender overrides:** keep two short override lists, always-Inbox and never-Inbox addresses, separate from the domain table. Every commercial system has this escape hatch (§1).
