# 1Password removal inventory

Geoff ruled on 2026-10-18 that both workstations drop 1Password once the Proton wiring works, and
that the cutover covers Claude's own access and command-line tools. He keeps 1Password on his
phone and other devices until P4. This file lists what the uninstall pass removes or rewrites, found
by a search of `~/.dotfiles` and `~/Projects` on 2026-10-18.

## Sequencing

1. Pass W (W0 to W4) replaces the live `op` reads with `ws-pass-key` and the zenity sudo dialog,
   keeping an `op` fallback on a host with no agent token. Its PR merges first.
2. W5 passes on pavilion.
3. The uninstall pass opens one workstation PR that removes everything below on both hosts. It
   needs a reboot and goes to Geoff in a packet.
4. thinkpad-x1 runs its W5 before it pulls that PR, so it never loses its age key.
5. 0.11's paper copies (the workstation age key and the ASC age key) exist before the PR merges.

## What reads or names 1Password

Workstation scripts and guards:

- `scripts/secrets/secret-set.sh` and `scripts/secrets/sync.sh`: the age key read (W1 replaces it;
  the uninstall drops the `op` fallback).
- `bin/.local/bin/claude-sudo-setup`: the sudo password read (W2 replaces it).
- `bin/.local/bin/secret-receive`: the `--op` mode.
- `bin/.local/bin/claude-block-op` and its hook registration in `claude/.claude/settings.json`.
- `bin/.local/bin/claude-secret-guard`: its `op` patterns.
- `bin/.local/bin/check-drift`: its 1Password lines.
- `scripts/secrets/secret-session-clear.sh`.
- `tests/secret-set-overrides.test.sh` and `tests/secret-store-flags.test.sh`.
- `scripts/migrate/op_to_1pux.py`, once the username repair below is done.

Install pieces:

- `bluefin/layered-packages.txt` (`1password`, `1password-cli`, its only layered packages), and
  `bluefin/etc/yum.repos.d/1password.repo`.
- `bluefin/bootstrap.sh`, `bluefin/gnome-settings.txt`, `bluefin/SECOND-WORKSTATION.md`,
  `bluefin/README.md`.
- The 1Password beta tarball at `~/.local/opt/1password-beta-dl`.

Rules Claude reads:

- The global `claude/.claude/CLAUDE.md` "Secrets" section ("1Password has sudo semantics").
- `claude/.claude/docs/bluefin-admin.md`, `cloudflare-estate-inventory.md`, `oom-defense.md`, and
  `claude/.claude/instructions/fastmail-api.md`.
- The environment text in `claude/.claude/settings.json` that names 1Password as a secrets
  location.
- `README.md`, `docs/MIGRATION-BRIEF.md`, `secrets/registry.md`.

Other repos:

- `aksailingclub-legacy` reads its own age key, item "ASC age encryption key", in
  `scripts/secrets/sync.sh` and `scripts/secrets/verify-keys.sh`. The key moves to the Proton
  `Workstation` vault in Geoff's FIDO2 session, gets a paper copy with 0.11, and both scripts move
  to `ws-pass-key` or the cached key file.
- The `op` matches in drafter, poplar, and dubplate are test strings and comments, not reads.

Records left as history: `docs/HISTORY.md`, `docs/STATUS.md`, past plans, and the 2026-09-28
infrastructure audit.

## Username repair

The import carried no username for some logins, Kagi among them. Geoff asked on 2026-10-18 that
Claude correct them, which authorizes the writes below.

How the import placed each login name, read from Proton's open-source importer
(`ProtonMail/WebClients`, `packages/pass/lib/import/`, branch `main`, 2026-10-18):

- Proton Pass keeps two fields where 1Password keeps one: `Email`, the main field, and `Username`,
  behind the plus beside it.
- `providers/1password/1pux.reader.ts` reads the login field with the `username` designation and
  passes it to `getEmailOrUsername` (`helpers/transformers.ts:36`). A value that passes
  `is_email_valid` goes to `Email`, and any other value goes to `Username`.
- Every other field becomes a custom field: `extract1PasswordExtraFields`
  (`providers/1password/1p.utils.ts:192`) turns a string, date, or URL into a text field and a
  concealed value into a hidden one, and drops only SSH keys, files, and Wi-Fi keys.
- `op_to_1pux.py` writes the `USERNAME`-purpose field with the `username` designation and every
  other field as a section field, an `EMAIL` field as a string.

So no login name 1Password held was lost. An address that sat in 1Password's username field shows
in Proton's `Email` with `Username` empty. A login name in an unlabeled field shows as a custom
field. A login with neither had no login name in 1Password, which is Kagi's case, since its item
shows no custom field.

The repair:

1. With the 1Password beta unlocked, one read-only `op` listing of field labels, types, and
   purposes, never values, finds every login with an empty or missing `USERNAME`-purpose field.
   Any such login with an address in another field is a custom-field case and gets that value.
2. Each remaining gap is matched against Geoff's Fastmail masked addresses by their recorded
   domain (the checklist at `~/.local/state/self-hosting/masked-email-checklist.md`, and JMAP for
   the domain field), then against his own addresses. An item with no match goes to Geoff as a
   question.
3. Geoff reviews the proposed table, kept in `/dev/shm` or the private servers repo, never in a
   public repo.
4. Claude writes each address into `Email`, and any other name into `Username`, through a Proton
   Pass session from `secret-receive --pass` (W2) in an attended sitting, then lists the items
   again to confirm each one.
