# Old 907.life site retirement

The 907.life rebuild retires the old site before setup, so the new one can take the real names. This is the retirement packet the design promised: the inventory, the dry run, and the dotfiles PR. The archive is done and proven, and copies sit in `~/Documents/retired-projects/` and in R2. A restore means rebuilding from that archive, since the deletes can't be undone.

Approving merges PR 212, which takes the old Worker out of the secrets sync, and authorizes the teardown you run at rc.4's promotion. The script detaches the domain, then deletes the Builds triggers and their registrations, the Worker, the Turnstile widget, the empty bucket, and the database. Then it renames the repo to `907-life-legacy` and archives it. The inventory found three items the spec's table missed, and the session recommends deleting them too. Mail records, the redirects' rules, and everything shared stay untouched.

From the teardown until setup attaches the domain, the site and `/privacy.html` are down with no time limit, by your ruling. The three mail-discovery redirects are down for about an hour of that, while delivery and sending carry on. In your approve note, name the outside mailbox you'll send the two mail-check messages from.

## If you approve
1. [session] Merge glw907/workstation#212 and pull `~/.dotfiles`.
2. [session] Wait for the conductor's rc.4 promotion message, then ping you.
3. [you: send the before-teardown mail check] From the mailbox you named, send one message to `glw@907.life` with the subject `907-rebuild mail check: before teardown`. Check: the session finds it, the three redirects answer 308, and conductor-servers reports `dns.sh --check` clean.
4. [you: run the teardown] In Ptyxis, run `bash ~/Projects/initiatives/907-rebuild/tools/teardown.sh` and compare its 15 steps with this packet. Then run it again with `--apply`. Check: it ends with "Teardown finished".
5. [session] Confirm each target is gone, run the mail check again, and record when the redirect gap opened.

## Not checked
Whether `ws-admin` may delete Builds triggers and registrations is untested, since only a real delete proves it. The script stops at the first refusal. Two Cloudflare tokens wrapped by the unused registrations (`718f0eab…`, `d38592f8…`) couldn't be listed, since no workstation token reads the token list. Your P6 check of the token list covers them. The estate inventory doc still names `cairn-907-auth`, and T13 updates it to setup's names.

## Ask: Delete the old site's resources, three additions included?
Rule: irreversible
Part: step:4
Recommended: 1
Reason: Every item belongs only to the old site, and the archive holds all of its data.
Summary: The teardown deletes 15 targets, and none can be restored. Three of them, a Turnstile widget, two unused Builds registrations, and an Actions secret, weren't in the spec's table.

Background: The spec's table lists the domain detach, the two Builds triggers and their registration, the Worker, the bucket, the database, one Actions secret, and the repo rename and archive. The inventory found three more items that belong only to the old site. The Turnstile widget "907.life Contact Form" served the old contact form, and setup makes its own. Two Builds registrations named "907-life build token" back no trigger on the account. The `CLOUDFLARE_ACCOUNT_ID` Actions secret sits beside the token secret the spec already deletes. The script re-reads every id before it acts and stops if one has changed.

Facts: Each target is sole-owner, and the data is archived.
- The only triggers on the account are the old Worker's two, and they use registration `503cd3fe` (`907-rebuild/plans/2026-11-07-907-rebuild-teardown-dryrun.txt`)
- Registration `503cd3fe` wraps `ws-admin`, so deleting it revokes nothing (`secrets/registry.md`)
- The bucket holds 0 objects and the archive's restore loaded every table (`907-rebuild/plans/2026-11-07-907-rebuild-log.md`)
- The shared `cairn-build` registration, the mail records, and Email Sending are not in the list (`907-rebuild/tools/teardown.sh`)

Choices:
- Delete all 15: you run the script at promotion; the deletes can't be undone [you]
- Delete only the spec's 11: the session drops the three additions first, and they stay on the account [you]
- Don't run it yet: nothing is deleted, and setup can't start [skip]

## Routine
| Part | Verdict | Fact | Why |
|---|---|---|---|
| glw907/workstation#212 | approve | The dotfiles gate passes, and no store key is removed. | It stops a sync from pushing shared keys into the new Worker. |
| step:1 | session | A merge can be reverted. | It must land before setup. |
| step:2 | session | The conductor owns the release timing. | No deadline on either side. |
| step:3 | you | Only you can send from an outside mailbox. | The mail check needs one real message. |
| step:5 | session | Reads only. | It is T5's acceptance. |
