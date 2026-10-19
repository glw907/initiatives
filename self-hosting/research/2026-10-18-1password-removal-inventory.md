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

The import carried no username for many logins, Kagi among them. Kagi's 1Password item had none
either, so the fix derives each address rather than copying one. Geoff asked on 2026-10-18 that
Claude correct them, which authorizes the writes below.

1. With the 1Password beta unlocked, one read-only `op` listing of field labels, types, and
   purposes, never values, finds every login with no username field and any login whose address
   sits in an unlabeled field.
2. Each gap is matched against Geoff's Fastmail masked addresses by their recorded domain (the
   checklist at `~/.local/state/self-hosting/masked-email-checklist.md`, and JMAP for the domain
   field), then against his own addresses. An item with no match goes to Geoff as a question.
3. Proton Pass splits what 1Password keeps in one username field into two: `Email`, the main
   field (`itemEmail` in its export), and `Username`, revealed by the plus beside it. Proton added
   the second so a login can hold both without custom fields
   (<https://yall.theatl.social/post/3213270/5478605>). How its 1Password importer chooses between
   them is undocumented, so the listing reads both fields of each imported item, and the table
   puts an address in `Email` and any other name in `Username`.
4. Geoff reviews the proposed table, kept in `/dev/shm` or the private servers repo, never in a
   public repo.
5. Claude writes each value into its field through a Proton Pass session from `secret-receive --pass` (W2) in an
   attended sitting, then lists the items again to confirm each one.
