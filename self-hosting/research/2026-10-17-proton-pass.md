# Replace 1Password with Proton Pass on pavilion and thinkpad-x1 (research brief, 2026-10-17)

Scope: the password manager itself on two Bluefin DX (Fedora 44 bootc) workstations. That covers the desktop app, the browser extensions, `pass-cli` for scripts, the 1Password data migration, Proton Pass features, and the Proton account's own security. Alias DNS for mail delivery is in another brief. This was read-only research. Nothing was installed, no `op` or `pass-cli` command ran, and no secret was decrypted. I downloaded the official RPM to the scratchpad to read its metadata, then deleted it.

Claims marked "unverified" came from a search summary or memory, not from a page I read in full or a file I inspected.

## How 1Password is wired in today (measured)

- `secret-receive --op REF` runs `op read REF`. `secret-set.sh` and `sync.sh` run `op item get "Workstation age encryption key" --fields notesPlain --reveal` and cache the key in `/dev/shm/.age-key-$UID` until reboot or until the `claude` wrapper exits.
- `claude-sudo-setup` runs `op read "op://Private/Workstation sudo/password"` into `/dev/shm/claude-sudo-$UID`, which `claude-askpass` feeds to `sudo -A`.
- `claude-block-op` denies a fourth `op` call within 60 seconds in one session. `claude-secret-guard` has no 1Password pattern.
- `check-drift` diffs the 1Password repo file and the Chromium policies. `layered-packages.txt` lists `1password` 8.12.40 and `1password-cli` 2.41.0. Chromium force-lists the 1Password extension (`aeblfdkhhhdcdjpifhhbdiojplfjncoa`). Firefox policy holds only search settings.

The security property that matters: today the gate is the 1Password desktop approval. The first `op` call per session needs Geoff's click. After that, the session can read any vault the account holds, not only the two workstation items.

## 1. Desktop app, extensions, and how they connect

**Official packages are DEB and RPM only.** Proton's Linux guide lists a DEB and an RPM, a SHA512 check against `version.json`, and `sudo rpm -i --force ProtonPass.rpm`. Updates are a fresh download, prompted by an in-app notice ([Proton guide](https://proton.me/support/set-up-proton-pass-linux)). The current stable is 1.42.0, released 2026-10-07 at a 1 percent staged rollout ([version.json](https://proton.me/download/PassDesktop/linux/x64/version.json)).

**I inspected the 1.42.0 RPM.** The SHA512 matched `version.json`. The package has no GPG signature (`Signature: (none)`), no scriptlets, and no repo file. It installs to `/usr/lib/proton-pass` and `/usr/bin/proton-pass`, which suits ostree. So on Bluefin the install would be `rpm-ostree install ./proton-pass-<ver>.rpm`. That is a local, unsigned layer that `ujust update` will never refresh. Each update means a manual download, a checksum, a re-layer, and a reboot. This is my inference from the package metadata and rpm-ostree's local-RPM behaviour. 1Password differs because it ships a signed dnf repo.

**The Flathub build is not Proton's.** `me.proton.Pass` on Flathub names Proton AG as developer, but its verification status is "Not verified". Its manifest builds from Proton's WebClients source with `--device=all` and the X11 and Wayland sockets ([Flathub API](https://flathub.org/api/v2/verification/me.proton.Pass/status), [manifest](https://github.com/flathub/me.proton.Pass)). A Zorin user could not get the Flatpak to reach the clipboard on Wayland and moved to the official DEB ([forum](https://forum.zorin.com/t/proton-pass-flatpak-cannot-access-clipboard/64407)). For a password manager, an unverified third-party build is a supply-chain risk I would not take.

**The desktop app carries a native messaging host.** Proton's docs do not describe one. The 1.42.0 native module contains a host named `me.proton.pass.nm`, described as "Proton Pass host for native messaging with the desktop app". It holds allowed origins for the Chrome Web Store extension (`ghmbeldphafepmbegfdlkpapadhbakde`) and the Firefox add-on (`78272b6fa58f4a1abaac99321d503a20@proton.me`). It also holds manifest paths for `~/.config/chromium/NativeMessagingHosts` and `~/.mozilla/native-messaging-hosts`. I found this with `strings` on the binary, so what the channel carries is unverified. The likely use is extension unlock through the desktop app. Proton's biometric page documents extension biometrics only for macOS Chromium browsers ([biometric unlock](https://proton.me/support/biometric-unlock-desktop)). The April 2026 roadmap promised extension biometric unlock "macOS and Chromium first" ([roadmap](https://proton.me/blog/pass-roadmap-spring-summer-2026)). A Flatpak build would write a host path that a non-sandboxed RPM browser cannot run. That matches the existing "no Flatpak for browser integration" doctrine in `bluefin-admin.md`.

**The extension works without the desktop app.** It signs in on its own and locks with a six-digit PIN and an auto-lock timer. Three wrong PINs force a full sign-in ([PIN lock](https://proton.me/support/proton-pass-pin)). `pass-cli` is also independent of the desktop app; its docs never mention it. So unlike 1Password, the desktop app is optional on this setup. What it adds is offline access (a paid feature, listed as shipped in the [roadmap](https://proton.me/blog/pass-roadmap-spring-summer-2026)), a separate window, and whatever the native host enables. The extension's own offline mode was still "coming soon" in April 2026.

**Extension IDs (checked).** Chrome Web Store `ghmbeldphafepmbegfdlkpapadhbakde` ([store page](https://chromewebstore.google.com/detail/ghmbeldphafepmbegfdlkpapadhbakde)). Firefox add-on slug `proton-pass`, guid `78272b6fa58f4a1abaac99321d503a20@proton.me`, version 1.41.1 of 2026-09-25 ([AMO API](https://addons.mozilla.org/api/v5/addons/addon/proton-pass/)).

**Policy install.** In Chromium, swap the 1Password ID in `ExtensionSettings` for `ghmbeldphafepmbegfdlkpapadhbakde` and keep the same `normal_installed`, `update_url`, and `toolbar_pin` keys ([Chrome policy list](https://chromeenterprise.google/policies/#ExtensionSettings)). Keep `PasswordManagerEnabled: false` and the autofill-off keys, but rename the file so it no longer says 1Password. For Firefox, add an `ExtensionSettings` entry keyed by the guid, with `installation_mode: normal_installed` and `install_url: https://addons.mozilla.org/firefox/downloads/latest/proton-pass/latest.xpi`. Add `PasswordManagerEnabled: false` and `OfferToSaveLogins: false` ([Mozilla policy templates](https://mozilla.github.io/policy-templates/#extensionsettings)). The policy shapes are from those references. The exact Firefox key behaviour on Firefox 14x is unverified.

## 2. `pass-cli`

**Version and install.** Current is 2.4.2 (2026-10-01) ([versions.json](https://proton.me/download/pass-cli/versions.json), [changelog](https://github.com/protonpass/pass-cli/blob/main/CHANGELOG.md)). It is open source (GPL-3.0) since 2.1.2, and its GitHub issue tracker is disabled. Bugs go to the support form. Install routes are the official script (`curl -fsSL https://proton.me/download/pass-cli/install.sh | bash`), a manual binary with a SHA256 from `versions.json`, or the official Homebrew tap `brew install protonpass/tap/pass-cli`. Under Homebrew, `pass-cli update` is disabled and `brew upgrade` takes over ([installation](https://protonpass.github.io/pass-cli/get-started/installation/)). The CLI needs Pass Plus, Pass Family, or a bundle. Free accounts cannot use it ([Proton blog](https://proton.me/blog/proton-pass-cli)).

**Auth modes** ([login](https://protonpass.github.io/pass-cli/commands/login/)):

- Web login, the default. `pass-cli login` prints a URL, and the flow completes in a browser. It is the only flow that supports SSO or a hardware-key 2FA.
- Interactive login (`--interactive`): password, TOTP, second password, and extra password, from prompts or `PROTON_PASS_*` env vars or files. U2F keys are not supported here.
- Personal access token (PAT): `pass-cli pat create --name N --expiration 1h|1d|1w|1m|3m|6m|1y`. The token (`pst_...::KEY`) is shown once. It reaches nothing until `pat access grant` names a vault or a single item, with a role of viewer, editor, or manager. `pat delete` revokes it at once. `pat renew` issues a new string and kills the old one ([pat](https://protonpass.github.io/pass-cli/commands/personal-access-token/)).
- Agent: a PAT flagged for audit. `pass-cli agent create NAME --expiration 1m --vault V`. Since 2.1.0, `item view`, every `item create` variant, `item update`, `trash`, `untrash`, `move`, and `vault update` must carry `PROTON_PASS_AGENT_REASON` (up to 300 characters). The reason is stored end-to-end encrypted in a log that the owner reads with `pass-cli agent monitor NAME` ([agent](https://protonpass.github.io/pass-cli/commands/agent/)). SecretSpec's compatibility table confirms that 2.1.0 rejects reasonless reads. It also warns that "backward incompatible changes can ship in a patch release" ([SecretSpec](https://secretspec.dev/providers/protonpass/)).

**Session lifetime.** User sessions persist until logout. PAT and agent sessions last 2 hours and cannot take a session lock ([session](https://protonpass.github.io/pass-cli/commands/session/)). Session data lives in `~/.local/share/proton-pass-cli/.session/`, or in `PROTON_PASS_SESSION_DIR` if set. The local encryption key goes in the kernel keyring by default. That needs no D-Bus and is cleared on reboot. `PROTON_PASS_LINUX_KEYRING=dbus` uses GNOME Keyring instead, and `PROTON_PASS_KEY_PROVIDER=fs` writes `local.key` beside the data ([configuration](https://protonpass.github.io/pass-cli/get-started/configuration/)). Telemetry is on by default. `PROTON_PASS_DISABLE_TELEMETRY` turns it off ([FAQ](https://protonpass.github.io/pass-cli/help/faq/)).

**References.** The form is `pass://<vault name or share ID>/<item title or ID>/<field>`. Fields include `password`, `username`, `email`, `url`, `note`, `totp`, and custom fields. Since 2.1.4 a section-qualified form `Section.field` also works. TOTP fields resolve to the current code, or to the `otpauth://` URI with `?totp=uri`. If two names match, "one of them will be used". The page calls name resolution case-sensitive in one place and field matching case-insensitive in another. Scripts should use share and item IDs ([secret references](https://protonpass.github.io/pass-cli/commands/contents/secret-references/)).

**Commands.**

- `pass-cli item view "pass://SHARE/ITEM/field"` prints one field to stdout. `--output json` gives the whole item ([view](https://protonpass.github.io/pass-cli/commands/contents/view/)).
- `pass-cli run [--env-file F] -- cmd` resolves `pass://` values in the environment for the child process only. It masks them in output by default ([run](https://protonpass.github.io/pass-cli/commands/contents/run/)).
- `pass-cli inject -i tpl -o out` resolves `{{ pass://... }}` and writes mode 0600 by default ([inject](https://protonpass.github.io/pass-cli/commands/contents/inject/)). A multiple-replacement bug in `inject` was fixed in 2.4.0.

**Read one field into a pipe without touching disk.**

```bash
export PROTON_PASS_SESSION_DIR="$XDG_RUNTIME_DIR/pass-ws"   # tmpfs, per-boot
export PROTON_PASS_DISABLE_TELEMETRY=1
PROTON_PASS_AGENT_REASON="sync.sh: decrypt values.age on $(hostname)" \
  pass-cli item view "pass://$WS_SHARE_ID/$AGE_ITEM_ID/key" | age --decrypt -i - values.age
```

`$XDG_RUNTIME_DIR` is tmpfs on both hosts (checked on pavilion). The agent docs show `pass-cli agent item view` in one example and plain `pass-cli item view` in another. Confirm which one is right with `pass-cli agent --help` on the machine.

**User-presence unlock.** `pass-cli` has no equivalent of 1Password's desktop approval. The closest is a session lock: `pass-cli session create-lock --idle-timeout 30..900` sets a lock code, which the server enforces. Then `session lock` and `session unlock` follow. It works only for full user sessions, never for PATs or agents. The page contradicts itself on what happens when the timeout ends. Whether `unlock` reads the code from stdin, which a zenity dialog would need, is unverified. The other presence mechanism is a fresh web login, which needs a hardware-key touch if the account uses one.

**Rate limits.** None are documented, and I found no reports. Latency is real: one user measured about 5 to 6 seconds for a cold fetch ([dmcc.io, Jan 2026](https://blog.dmcc.io/journal/proton-pass-cli-linux-secrets/)). Fetch once and cache, as today.

**SSH agent: shipped, not a roadmap item.** `pass-cli ssh-agent load` pushes vault SSH keys into an existing agent. `pass-cli ssh-agent start` runs its own agent on `~/.ssh/proton-pass-agent.sock`. 1.9.0 added a daemon mode, and 2.4.0 added `ssh-add -x` locking ([ssh-agent](https://protonpass.github.io/pass-cli/commands/ssh-agent/)). With a session lock, it will not refresh keys. Geoff's SSH keys do not use 1Password's agent today, so nothing has to move.

## 3. Mapping each `op` use, and the safe design

**The key point: Claude runs as Geoff's UID.** Anything a standing `pass-cli` session can read, Claude's Bash tool can read silently. A logged-in user session is also worse than 1Password after approval. It can run `pass-cli agent create --vault Personal` or `pat create` and mint itself new credentials. So no full-account user session should ever sit in the default session directory on these machines.

**Proposed design.**

1. **A vault named `Workstation`** holding one item: the age identity, as a hidden field `key` on a custom item. Nothing else goes in it.
2. **One agent per host** (`pavilion-scripts`, `thinkpad-scripts`) with the viewer role on `Workstation` only, and a 3-month expiry. An agent beats a plain PAT because every read lands in an audit log with a reason. Each host gets its own, so one can be revoked alone.
3. **The agent token lives in GNOME Keyring**, through `secret-tool store` with attributes like `service proton-pass-agent host pavilion`. It unlocks at desktop login (`secret-tool` is present on pavilion). It is never in the age store, which would be circular, and never in a file.
4. **Scripts use an isolated session directory** in `$XDG_RUNTIME_DIR`. They log in with `pass-cli info || pass-cli login` because of the 2-hour lifetime. They set a reason that names the script and host, and they keep the current `/dev/shm` caches and clear-on-exit behaviour.
5. **The sudo password leaves the scripted path.** The age key is low marginal risk, since every value it decrypts already sits in plaintext in `~/.local/secrets`. The sudo password is different. Silent access to it would be silent root, where today it is gated by a click. `claude-sudo-setup` should raise a zenity hidden-entry dialog, the `secret-receive` pattern, and Geoff types or pastes the password once per session. That keeps a human in the loop for root.
6. **Geoff's personal vaults stay unreachable from any script.** Geoff's own interactive CLI use (for example `secret-receive --pass`) should run a web login into a throwaway tmpfs session directory and `pass-cli logout` on exit.

**What Claude can and cannot read.** Claude can read environment values already in `~/.local/secrets`, as today. It can run the reviewed scripts (`sync.sh`, `secret-set.sh`), which read the age key through the agent with an audit line. It should never call `pass-cli` directly. It should never read the agent token (`secret-tool lookup`), the kernel keyring (`keyctl print/pipe/read`), or the session directory. It should never see a personal vault.

**Compared with 1Password's rule.** "Fetch once per session, never loop `op`" protected Geoff's attention from popup storms. With agent tokens there is no popup, so the loop limit becomes pointless. The rule that replaces it: Claude never calls `pass-cli`, and scripts fetch once and cache. The scope is much narrower than today: one item in one vault, audited, instead of a whole account after one click. The cost is that the age-key read becomes silent. I judge that acceptable because the plaintext it unlocks is already on disk.

## 4. Migrating the data

**Export from 1Password on Linux.** The ellipsis menu, then Export, then the account, then 1PUX or CSV ([1Password export](https://support.1password.com/export/)). Use 1PUX, because CSV drops custom fields, security questions, and linked items. Passkeys are never in an export: "You can only export passkeys in 1Password for iOS and Android at this time" (same page). A 1Password staff answer of September 2026 says 1PUX will not carry passkeys, because a 1PUX file is unencrypted ([community](https://www.1password.community/1password-at-home-31/feature-request-add-passkeys-to-the-1pux-export-file-25552)). Whether Proton Pass on a phone can receive passkeys by Credential Exchange is unverified. Plan to re-enroll each passkey.

**Import.** In the extension: Settings, then Import, then "1Password (1pux, 1pif)" ([Proton guide](https://proton.me/support/pass-import-1password)). The guide lists no limits, so I read the importer source ([1pux.reader.ts](https://github.com/ProtonMail/WebClients/blob/main/packages/pass/lib/import/providers/1password/1pux.reader.ts), [1p.utils.ts](https://github.com/ProtonMail/WebClients/blob/main/packages/pass/lib/import/providers/1password/1p.utils.ts)).

- Carried over: logins, with username or email split, URLs, notes, and TOTP (the first TOTP field becomes the login's TOTP, and later ones become extra fields). Also passwords, secure notes, credit cards (number, CVV, expiry, PIN), identities and addresses, SSH keys (private and public), Wi-Fi, and Documents. A Document becomes a custom item with the file attached. Attachments come through, and custom fields come through as text, hidden, or TOTP.
- Lost or changed: passkeys (absent from the export). Tags are parsed but not mapped, and every vault imports with no folders. Archived items arrive as trashed. Field types `SSH_KEY` and `FILE` inside sections are dropped as fields, with files handled separately. Item history and linked items are not read. Anything that fails is listed in an "ignored" list on the import screen. Each 1Password vault becomes a Proton vault.

**Verify the import.**

1. Before the export, take one 1Password JSON listing (`op item list --format json`, parsed locally) and count items per vault and per category.
2. After the import, count the same with `pass-cli item list --vault-name V --output json`.
3. Record the importer's "ignored" list.
4. Spot-check TOTP codes against 1Password for five items, and check two attachments open.
5. List every login that holds a passkey before 1Password is cancelled.

The 1PUX file is plaintext. Write it to `/dev/shm`, age-encrypt a rollback copy onto the LUKS backup drive, and shred the plaintext.

**Masked-email mapping.** 1Password's Fastmail integration put the masked address in each login. The importer passes the username through `getEmailOrUsername`, so an address-shaped username should land in Proton's email field. Confirm that on one known masked login. For triage:

1. Snapshot the 188 Fastmail masked addresses over JMAP (`MaskedEmail/get`: email, forDomain, description, state, lastMessageAt) into an age-encrypted file.
2. After the import, export logins with `pass-cli item list --output json` (Geoff's interactive session) and join on email.
3. For each live address, create a Proton alias on the new domain, change the address at the service, and update the login.

One community report describes aliases deleted while cleaning up Pass entries ([Privacy Guides](https://discuss.privacyguides.net/t/email-aliases-via-proton-or-tuta-paid-using-custom-domain-from-cloudflare-following-bazzell-ebook/37602)). Proton says a deleted alias "cannot be recovered" ([aliases](https://proton.me/support/pass-add-mailbox)). Disable aliases rather than delete them during triage.

## 5. Features to use well

- **Aliases on a custom domain.** Paid plans can add up to 10 domains, with TXT and MX records required and SPF, DKIM, and DMARC recommended. One domain cannot serve Proton Mail and Proton Pass at once ([custom domain](https://proton.me/support/pass-use-custom-domain)). A third-level domain under 907.life fits. The DNS details are in the other brief.
- **Passkeys** are on every plan ([pricing](https://proton.me/pass/pricing)). Keep the standing rule: passkeys go through the browser for Geoff's touch and are never read by scripts.
- **Built-in TOTP versus a separate authenticator.** Storing TOTP beside the password is a modest weakening. It still stops credential stuffing and phishing (autofill matches the domain). It stops nothing if the vault itself is taken ([Privacy Guides thread](https://discuss.privacyguides.net/t/should-i-use-my-password-manager-for-storing-totp-codes/13379)). My recommendation: use built-in TOTP for ordinary sites. Put the root accounts (Proton, Cloudflare, GitHub, Hetzner, the registrar, banking, and Fastmail during the window) on FIDO2 keys where offered. Otherwise use a separate authenticator such as Proton Authenticator, which is free, runs on Linux, and needs no account ([Proton](https://proton.me/support/set-up-proton-authenticator-linux)). The Proton account's own 2FA can never live in Proton Pass.
- **Proton Sentinel** is included from Pass Plus up. It means stricter sign-in challenges and analyst review. Turn it on under Security and privacy ([Sentinel](https://proton.me/support/proton-sentinel)).
- **Sharing with the second operator.** Pass Family covers up to 6 users, each with Pass Plus. Paid plans can share a vault with 10 others ([pricing](https://proton.me/pass/pricing)). Make a `Household` vault for the runbook's backup passwords (restic, LUKS, server root) and share it with the second operator as viewer.
- **Emergency Access** is on every paid plan: up to five contacts, with a wait of 1 to 30 days. Access is granted automatically when the wait ends unless Geoff denies it. "Both you and your contact must have a Proton Mail email address" ([emergency access](https://proton.me/support/emergency-access)). The second operator would need a Proton account.
- **The Emergency Kit equivalent.** Proton has no single kit document. The recovery phrase downloads as a PDF, and Proton warns not to keep it in Proton Pass or Drive ([recovery phrase](https://proton.me/support/recovery-phrase)). Build a printed kit: account address, a note on where the password lives, the recovery phrase, and where the spare FIDO2 key is. Keep it with the runbook's paper copy, and tell the second operator where it is.

## 6. The Proton account's own security

- **2FA:** two FIDO2 keys, with up to four allowed ([security keys](https://proton.me/support/2fa-security-key)). This forces `pass-cli` onto web login, which is fine for interactive use; scripts use agent tokens. Proton's recovery guide says to set up authenticator-app 2FA before choosing recovery methods ([recovery](https://proton.me/support/set-account-recovery-methods)). Whether a key can be added with no TOTP enabled is unclear, so check that in the settings.
- **Recovery:** Proton wants at least one password-reset method and one data-recovery method. The recovery phrase does both, while a recovery email resets access but loses the data ([recovery](https://proton.me/support/set-account-recovery-methods)). Do not use geoff@907.life as the only recovery email. It will sit on the self-hosted mail server, so a mail outage and a Proton lockout could compound. Use the recovery phrase on paper, a recovery file on the LUKS drive, and Emergency Access for the second operator.
- **Extra password:** an optional second, Pass-only password. Setting it logs out every device ([extra password](https://proton.me/support/pass-extra-password)). With FIDO2 2FA it adds friction for little gain. Skip it unless Geoff wants it.
- **If the account is lost:** aliases on Proton's shared domains die with it. Aliases on Geoff's domain survive as addresses, because he controls DNS and can point the subdomain's MX at Stalwart with a catch-all. The alias-to-service mapping would be lost, though. Keep a monthly encrypted export: Proton offers "a ZIP file containing a PGP-encrypted JSON file" ([export](https://proton.me/support/pass-export)). Whether that export includes alias metadata is unverified. A `pass-cli item list --output json` dump of alias items is the fallback.

## 7. Known pitfalls

- The official RPM is unsigned, with no repo. Updates are manual, and each one needs a reboot when layered.
- The Flathub build is unverified and community-built. It has reported Wayland clipboard trouble.
- A KDE user reports the app asking setup questions on every launch and no tray icon ([report](https://scribe.disroot.org/comment/6826980), unverified).
- There is no system-wide autofill on Linux. A roadmap commenter notes Wayland makes it hard ([Privacy Guides](https://discuss.privacyguides.net/t/proton-pass-product-roadmap-for-next-6-months-file-atachments-desktop-wide-autofill-and-more/22452)). The binary carries libei and RemoteDesktop portal code, which suggests auto-type exists (unverified).
- CLI: breaking changes in patch releases. The docs contradict themselves (lock timeout wording, `agent item view`, case rules). There is no public issue tracker. Name lookups are ambiguous, so pin IDs.
- CLI fixes worth having: `run` stream handling (2.3.1), proxy support (2.4.2), the `inject` double replacement (2.4.0), and agent preflight checks (2.4.0).
- The kernel-keyring default clears on reboot. That suits a tmpfs session directory, but scripts must handle "not logged in" after a reboot.

## Recommendation

Use Pass Family, so the second operator gets his own account, Emergency Access, and the shared vault. Install `pass-cli` from the official Homebrew tap, which fits the CLI tier and gets updates through `brew upgrade`. Install the browser extensions by policy in both browsers. Start without the desktop app. That retires both layered 1Password packages and adds none. Add the official RPM, layered, only if a concrete need appears: offline access on the workstation, or a Linux extension unlock that needs the native host. Never use the Flathub build.

| Current | Proposed replacement |
|---|---|
| `secret-receive --op REF`: `op read REF` | `--pass REF`: a web login into `mktemp -d $XDG_RUNTIME_DIR/pass-XXXX`, then `pass-cli item view "$REF"`, then `pass-cli logout`. The dialog path stays the default. |
| `secret-set.sh` `ensure_key`: `op item get "Workstation age encryption key" --fields notesPlain --reveal \| sed` | `ws-pass-key` helper: read the token with `secret-tool lookup`, set `PROTON_PASS_SESSION_DIR=$XDG_RUNTIME_DIR/pass-ws`, run `pass-cli info \|\| pass-cli login`, then `PROTON_PASS_AGENT_REASON="secret-set.sh on $HOST" pass-cli item view "pass://$WS_SHARE/$AGE_ITEM/key" > "$CACHE"` |
| `sync.sh` decrypt block: same `op item get` | Same helper, with reason `sync.sh on $HOST` |
| `secret-session-clear.sh`: shred the age cache | Also run `pass-cli logout` against `pass-ws` |
| `claude-sudo-setup`: `op read "op://Private/Workstation sudo/password"` | A zenity `--entry --hide-text` dialog into the same `/dev/shm` cache. Geoff pastes from Proton Pass. No scripted read. |
| `claude-askpass`, `claude-sudo-clear` | Unchanged |
| `claude-block-op` (rate limit) | `claude-block-pass`: deny any direct `pass-cli` call. Also deny `secret-tool lookup ... proton-pass-agent`, `keyctl print\|pipe\|read`, reads of `proton-pass-cli` session paths, and `PROTON_PASS_PERSONAL_ACCESS_TOKEN=` on a command line. |
| `claude-secret-guard` | Add the pattern `\bpst_[A-Za-z0-9_-]{8,}::[A-Za-z0-9_-]{8,}` for Proton PATs and agent tokens |
| `check-drift`: `1password.repo` pair | Drop it. Add: pass-cli version against `versions.json`, the agent token expiry date from `registry.md`, and the extension policies present |
| `layered-packages.txt`: `1password`, `1password-cli` | Remove both. Add `pass-cli` to the Brewfile. |
| `chromium-policies/extensions.json`: `aeblfdkh...` | `ghmbeldphafepmbegfdlkpapadhbakde`. Rename `1password.json` to `password-manager.json`. |
| `firefox-policies/policies.json` | Add `ExtensionSettings` for `78272b6fa58f4a1abaac99321d503a20@proton.me`, `PasswordManagerEnabled: false`, and `OfferToSaveLogins: false` |
| `registry.md` Architecture, `bluefin-admin.md` 1Password sections | Rewrite for Proton Pass. Retire the GID gotcha section and add the agent-token renewal procedure. |
| `~/.config/chromium/NativeMessagingHosts/com.1password.1password.json`, `~/.mozilla/native-messaging-hosts/com.1password.1password.json` | Remove when 1Password is uninstalled |

## Migration outline

1. Buy the plan. Set up two FIDO2 keys, the recovery phrase on paper, a recovery file on the LUKS drive, and Sentinel. Have the second operator create his account, then set up Emergency Access.
2. Snapshot the Fastmail masked addresses over JMAP into an age-encrypted file. Take the 1Password count listing, and list the logins that hold passkeys.
3. Export 1PUX to `/dev/shm` and import it through the extension. Save the ignored list, run the count and TOTP checks, then age-encrypt the 1PUX onto the backup drive and shred the plaintext.
4. Create the `Workstation` vault and the age-key item, then one agent per host with a 3-month expiry. Store each token with `secret-tool` on its host.
5. In a `workstation` worktree pass, rewrite the scripts and hooks per the table, with tests that use a scratch store (`secret-set.sh` already honours `VALUES`, `CACHE`, and `LOCAL_SECRETS` overrides). Run `sync.sh --verify` and check `pass-cli agent monitor` shows reasoned reads.
6. Swap the browser policies, install from `bluefin/etc/`, and check `chrome://policy` and `about:policies`.
7. Re-enroll the passkeys site by site. Then start the alias triage, one service at a time, keeping 1Password read-only until the triage list is empty.
8. Uninstall 1Password: `rpm-ostree uninstall 1password 1password-cli`, remove the repo file and the native messaging manifests, and update the manifests. Cancel after a 30-day overlap.

## Risks

- **Silent age-key reads.** Accepted on the grounds above. Any change that puts a second item in `Workstation` breaks that argument, so the rule needs to be written in `registry.md`.
- **Token expiry.** A lapsed agent token breaks `sync.sh` quietly. The `check-drift` warning is the mitigation, and renewal needs Geoff's web login.
- **CLI churn.** Breaking changes ship in patch releases. Pin through Homebrew, and read the changelog before `brew upgrade pass-cli`, the same discipline as `dependency-upgrade`.
- **Lost passkeys.** Any passkey not re-enrolled before cancellation is gone.
- **Account loss.** Covered by the paper kit, Emergency Access, and the alias export. Mail recovery must not depend on the self-hosted server.
- **Unverified points to check on the machine.** `pass-cli agent --help` (the `agent item view` form). Whether `session unlock` reads stdin. Whether the extension behaves differently with the desktop app present. The importer's handling of one masked-email login.

## Open questions for Geoff

1. Plan tier: Pass Family at $59.88 a year covers the second operator, Emergency Access, and sharing. Pass Plus at $35.88 a year is you alone. Proton Unlimited at $119.88 a year adds Mail, Drive, and VPN, which this initiative does not need. Prices are annual billing from the [pricing page](https://proton.me/pass/pricing). Recommendation: Family.
2. Sudo: is pasting the sudo password into a dialog once per Claude session acceptable? The alternative is silent scripted access to root.
3. Desktop app: start without it, as recommended, or do you want the layered app with manual updates from day one?
4. TOTP: are you comfortable keeping ordinary-site TOTP in Pass, with root accounts on hardware keys or a separate authenticator?
