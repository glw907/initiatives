# Is Proton Pass the right replacement for 1Password? (research brief, 2026-10-17)

## Verdict

Proton Pass Family is still the best fit, and the margin comes from the criterion Geoff now calls critical: one-step masked email in the browser and on phones. Proton Pass puts "Hide my email" in the email field of a sign-up form, on desktop and in the Android and iOS autofill flows, and the alias can be turned off later with a toggle. No other option here does all of that with an alias on Geoff's own domain. Bitwarden Families with a Stalwart catch-all subdomain is the runner-up. It is cheaper ($47.88 a year), has the deeper audit record, and keeps alias mail off any third party. Its masked-email path is weaker, though: the address comes from the generator in the extension popup, not from the form field, and burning one address means a Stalwart rule, not a toggle. 1Password stays best known for autofill, but its masked email works only with Fastmail, which is being cancelled. The cost of Proton is that every alias message passes through Proton in clear. The exit is cheap because the domain is Geoff's: point the subdomain's MX at Stalwart with a catch-all and every alias keeps receiving mail.

This brief builds on the [Proton Pass brief](2026-10-17-proton-pass.md) and the masked-email sections of the [mail cutover brief](2026-10-17-mail-cutover.md), and does not repeat them. It was read-only research. "Unverified" marks a claim I could not confirm on a primary page. Review-site and forum reports are labelled as anecdote.

## Comparison

Integration is weighted double, per Geoff's instruction. It covers autofill in Firefox and Chromium on Linux, the Safari extension and macOS app, iOS and Android autofill, passkeys, TOTP fill, inline alias creation, and system unlock.

| | Proton Pass Family | Bitwarden Families + Stalwart catch-all | Bitwarden Families + SimpleLogin or addy.io | 1Password Families (stay) | Vaultwarden | KeePassXC |
|---|---|---|---|---|---|---|
| **Integration (x2)** | Strong. Inline alias in the form on desktop, Android, iOS. Passkeys in extension, iOS 17+, Android 14+. No extension biometric on Linux. | Good for passwords. Alias needs a popup step. Linux system unlock likely blocked on Bluefin (see below). | Same as left, plus alias toggle in the alias service, not in Bitwarden. | Strongest password autofill reputation. Masked email ends with Fastmail. | Same clients as Bitwarden. | Weak for phones and family. |
| Price for 4 to 6 people, per year | $59.88, 6 users | $47.88, 6 users | $47.88 plus $36 (addy Pro) or $35.88 (Pass Plus, which carries SimpleLogin Premium) | $71.88 regular, 5 users | $0 plus server time | $0 |
| Security record | 2023 Cure53, 2026 Recurity Labs audit, SOC 2 Type II | Yearly audits by several firms, ETH Zurich malicious-server study, April 2026 npm CLI incident | Same | Not studied here; 6 attacks in the ETH study | Unaudited | Local file |
| Scripts and agents | Vault- or item-scoped agent tokens with an audited reason per read | `bw` is whole-account; Secrets Manager free org gives project-scoped tokens, no event logs | Same | Vault-scoped service accounts, rate limits | Same as Bitwarden, no Secrets Manager | None |
| Alias mail path | Through Proton, then Stalwart | Straight to Stalwart | Through the alias service | Through Fastmail | n/a | n/a |
| Burn one alias | Toggle in any Pass app | Sieve or RCPT rule on Stalwart | Toggle in the alias service | Block in 1Password item | n/a | n/a |
| Reply from alias | Yes, reverse alias | Only with Stalwart send rules | Yes (paid tiers) | Fastmail only | n/a | n/a |

## Proton Pass Family

**Price.** $59.88 a year for up to six users, each with Pass Plus. Unlimited aliases, custom domains, the CLI, and Emergency Access are on the plan ([pricing](https://proton.me/pass/pricing)).

**Security.** Cure53 tested the extension, mobile apps, and API in 2023 and found one high-severity issue, a missing public-suffix check ([Cure53 report](https://cure53.de/pentest-report_proton-pass.pdf)). Recurity Labs tested the extensions, mobile and desktop apps, and the CLI between January and April 2026. Proton reports no remote exploits or encryption bypasses, with memory-handling findings in the desktop app fixed on retest ([Proton, May 2026](https://proton.me/business/blog/proton-pass-audit-2026)). That summary is Proton's own; the PDF is linked from the same page. Proton holds a company-wide SOC 2 Type II from July 2025 ([Tom's Guide](https://www.tomsguide.com/computing/online-security/proton-passes-its-first-soc-2-type-ii-audit-verifying-its-business-security-credentials)). Each vault has a random key sealed to the user key, and each item has its own key wrapped by the vault key, with AES-256-GCM ([security model](https://proton.me/blog/proton-pass-security-model)). Proton Pass was not in the 2026 ETH Zurich malicious-server study, so it has had less hostile scrutiny than Bitwarden, not more resistance ([ePrint 2026/058](https://eprint.iacr.org/2026/058)). I found no reported breach of Proton Pass.

**Scripts and agents.** Covered in the Proton Pass brief. In short, `pass-cli` agent tokens can be scoped to one vault or one item, expire, revoke at once, and log a reason for every read. No other option here gives an audited, item-scoped token on a household plan.

**Linux.** The extension works alone with a PIN lock. Extension biometric unlock is documented only for Chromium on macOS ([biometric unlock](https://proton.me/support/biometric-unlock-desktop)), and the roadmap still lists it as coming ([roadmap](https://proton.me/blog/pass-roadmap-spring-summer-2026)). The desktop app is an unsigned RPM with no repo, as the earlier brief found.

**Apple.** There is a macOS app and a separate Safari extension in the Mac App Store ([App Store](https://apps.apple.com/app/id6502835663)). Passkeys work in Safari with the extension as of fall and winter 2025 ([roadmap](https://proton.me/blog/pass-roadmap-spring-summer-2026)). On iOS, Proton Pass is set as the AutoFill provider in Settings ([iOS setup](https://proton.me/support/pass-setup-ios)), and passkeys need iOS 17 or later ([passkeys](https://proton.me/support/pass-use-passkeys)). Face ID unlock on iOS and Touch ID in the Safari extension are unverified.

**Autofill reports (anecdote).** A Firefox reviewer says about one site in ten has trouble ([AMO review](https://smartvless.duckdns.org/en-US/firefox/addon/proton-pass/reviews/?page=29), a mirror of the AMO review pages). Security.org reports 94 percent correct fills on complex forms and a field-detection miss rate of about 8 percent for Bitwarden ([Security.org](https://www.security.org/password-manager/proton-pass-vs-bitwarden/)). Its method is not published. The Safari extension changelog lists fixes for iframe logins and a skipped email field ([App Store](https://apps.apple.com/app/id6502835663)). I found no controlled 2026 benchmark for any product.

**Masked email.** In the extension, click the icon in the email field and choose "Hide my email", which creates and fills the alias. On Android and iOS, the autofill create-login flow has the same choice, with the domain under Advanced options, and then "Create login" or "Create & AutoFill" saves it ([aliases](https://proton.me/support/pass-email-alias)). Disabling an alias stops it receiving mail and can be undone. Replies go out from the alias, and contacts are kept per alias (same page). Pass Plus carries SimpleLogin Premium, whose custom domains support catch-all and regex auto-create ([Proton blog](https://proton.me/blog/pass-plus-simplelogin-premium-feature), [SimpleLogin domains](https://simplelogin.io/docs/custom-domain/manage-domain/)). Whether Family members get the SimpleLogin side too, and whether the desktop inline flow can default to the custom domain, is unverified.

**1Password import.** Logins, TOTP, custom fields, and Documents with their files come through 1PUX. Passkeys do not, because 1Password does not put them in 1PUX (see the earlier brief). Proton Pass import of passkeys by Credential Exchange is unverified.

## Bitwarden Families

**Price.** $47.88 a year for six premium accounts. That covers TOTP, Emergency Access, and 5 GB of attachments each plus 5 GB shared ([pricing](https://bitwarden.com/pricing/)).

**Security.** Bitwarden publishes yearly audits. In 2025 Cure53 covered the extension and autofill overlay, desktop app, and web vault, ETH Zurich reviewed core cryptography, Unit 42 the mobile apps, and Fracture Labs the network. In 2024 the firms were IOActive, Mandiant, Fracture Labs, and Cure53. It holds SOC 2 Type 2 and ISO 27001 ([audits](https://bitwarden.com/help/is-bitwarden-audited/)). The default key derivation is PBKDF2 with 600,000 iterations, with Argon2id available ([KDF](https://bitwarden.com/help/kdf-algorithms/)). The February 2026 ETH Zurich and USI study found 12 attacks under a fully malicious server ([ePrint 2026/058](https://eprint.iacr.org/2026/058)). Bitwarden rated them medium or low and says all have been addressed ([Bitwarden blog](https://bitwarden.com/blog/security-through-transparency-eth-zurich-audits-bitwarden-cryptography/)). On April 22, 2026, a malicious `@bitwarden/cli` 2026.4.0 sat on npm for about 90 minutes, through a compromised CI action. It stole developer secrets from machines that installed it. Bitwarden found no vault exposure, and the other packages were not affected ([BleepingComputer](https://bleepingcomputer.com/news/security/bitwarden-cli-npm-package-compromised-to-steal-developer-credentials), [The Hacker News](https://thehackernews.com/2026/04/bitwarden-cli-compromised-in-ongoing.html)). The lesson for this workstation: never install the CLI from npm.

**Scripts and agents.** The `bw` personal API key has a fixed scope of `api`, reaches the whole account, and still needs the master password to unlock ([API key](https://bitwarden.com/help/personal-api-key/), [CLI](https://bitwarden.com/help/cli/)). That is worse than both 1Password and Proton for an AI agent. The scoped path is Secrets Manager. A Families user must create a separate free organization for it, limited to 2 users, 3 projects, and 3 machine accounts, with no event logs; logs start at Teams, $6 per user per month ([plans](https://bitwarden.com/help/secrets-manager-plans/); the Teams price is from a search summary, unverified). Machine accounts get read or read-write access per project ([machine accounts](https://bitwarden.com/help/machine-accounts/)). Access tokens are shown once, default to never expiring, and revoke at once, though an authenticated machine can keep decrypting for up to an hour ([tokens](https://bitwarden.com/help/access-tokens/)). For the workstation's one age key that would work, but with no audit trail and a second organization to keep.

**Linux.** The desktop app is a verified Flatpak on Flathub ([Flathub](https://flathub.org/api/v2/verification/com.bitwarden.desktop/status)). Bitwarden recommends the Snap or Flatpak, and says the Flatpak supports biometric unlock for both sandboxed and unsandboxed browsers. The Flatpak step copies a polkit policy into `/usr/share/polkit-1/actions/` ([biometrics](https://bitwarden.com/help/biometrics/)). On Bluefin `/usr` is read-only, so that step cannot be done as written. Whether polkit on Fedora 44 also reads actions from `/etc` is unverified. A 2025 report says Linux system-auth unlock broke after 2024.12.1 on both native and Flatpak builds ([issue 13216](https://github.com/bitwarden/clients/issues/13216), anecdote). The SSH agent runs inside the desktop app and asks for authorization per use, with a Flatpak socket path ([SSH agent](https://bitwarden.com/help/ssh-agent/)). The extension works without the desktop app.

**Apple.** The Safari extension ships only inside the Mac App Store desktop app ([Safari](https://bitwarden.com/help/install-safari-app-extension.md)). Touch ID unlock is supported on macOS, and Safari 14+ is listed for browser biometrics ([biometrics](https://bitwarden.com/help/biometrics/)). On iOS, Bitwarden is a system AutoFill provider for passwords and passkeys from iOS 17 ([iOS autofill](https://bitwarden.com/help/auto-fill-ios/)). A January 2026 forum post says it is not yet a macOS system passkey provider on macOS 26.2 ([forum](https://community.bitwarden.com/t/register-as-macos-password-and-passkey-provider/93723), anecdote). Safari autofill had a long 2024 lock-up bug that staff tied to Safari 17.4 ([forum](https://community.bitwarden.com/t/macos-safari-extension-autofill-issue/71582), anecdote).

**Autofill reports (anecdote).** The inline menu showed "No items to show" in 2025 releases, including on Firefox with 2025.12.1 ([forum](https://community.bitwarden.com/t/inline-auto-fill-shows-no-items-to-show-while-extension-icon-detects-login-correctly/93313)). A 2026 report has the menu vanishing in Brave after a Chromium update ([PiunikaWeb](https://piunikaweb.com/2026/06/11/bitwarden-autofill-not-working-brave/)). Passkeys and TOTP fill from the inline menu ([autofill](https://bitwarden.com/help/auto-fill-browser/)).

**Masked email.** The username generator has three types. Plus-addressed. Catch-all, which makes a random address at your domain. Forwarded alias, which calls SimpleLogin, addy.io, Firefox Relay, Fastmail, Forward Email, or DuckDuckGo, and accepts a self-hosted SimpleLogin or addy.io URL ([generator](https://bitwarden.com/help/generator/)). On mobile the forwarder list is shorter and catch-all addresses are random only (same page). The inline menu on a sign-up form offers a generated password and saves the new login. The help page does not say it offers a username or alias ([autofill](https://bitwarden.com/help/auto-fill-browser/)). So an alias takes a trip to the popup's generator or the new-item form. That is two or three clicks, not one.

**1Password import.** Bitwarden imports 1PUX, but attachments must be uploaded again one by one ([import](https://bitwarden.com/help/import-from-1password/)). Proton carries them. On iOS 26 and Android 14, Bitwarden can import passkeys by Credential Exchange when the other app supports it ([passkeys](https://bitwarden.com/help/storing-passkeys/)). 1Password for iOS says it exports that way ([1Password community](https://www.1password.community/discussions/1password/importexport-passkeys/158045), unverified as current). That route could save some passkey re-enrollment.

**Emergency Access** is included in Families. The contact can be any Bitwarden account, free or paid. View and takeover are both offered ([emergency access](https://bitwarden.com/help/emergency-access/)).

## Bitwarden with a self-hosted alias service

**addy.io self-hosted** and **SimpleLogin self-hosted** each bring their own Postfix, database, and web app, and each expects to own MX for the alias domain (addy.io offers self-hosting from its [site](https://addy.io/)). On the mail server that means a second MTA in front of Stalwart, or a second server. Both give a per-alias toggle and reply-from-alias. Neither is worth it for one household that wants a boring mail server.

**Hosted addy.io** costs $1 a month (Lite, one domain, 50 replies a day) or $3 (Pro, 20 domains, sender blocking). Deactivated aliases discard mail silently, and catch-all is per domain ([addy.io](https://addy.io/)). It plugs into Bitwarden's generator. That is Proton's model with a smaller vendor and a second bill.

**Bitwarden plus Proton Pass Plus for the SimpleLogin side** would cost $83.76 a year and run two password managers. It adds nothing that Proton Pass Family lacks.

## 1Password (staying)

Families is $5.99 a month billed yearly after a $4.49 first year, for five people ([pricing](https://1password.com/pricing/password-manager)). Service accounts are vault-scoped and work on Families, at 1,000 reads an hour per token and 1,000 requests a day per account ([rate limits](https://www.1password.dev/service-accounts/rate-limits)). Usage reports exist ([service accounts](https://www.1password.dev/service-accounts/)). Linux works today on these machines through the RPM repo. Flatpak browsers cannot talk to the app, per a January 2026 staff reply ([community summary](https://universal-blue.discourse.group/t/working-1password-with-browser-integration/12535.md)). Masked email is a Fastmail integration only ([1Password support](https://support.1password.com/fastmail)). Once Fastmail is cancelled, 1Password has no alias source, and no way to use a catch-all except typing the address by hand. Staying means paying more for a password manager with no masked email.

## Vaultwarden (note only)

Vaultwarden is an unofficial Rust server for Bitwarden clients, not associated with Bitwarden, with no published audit ([GitHub](https://github.com/dani-garcia/vaultwarden)). The clients would be Bitwarden's, so integration matches Bitwarden. It is not wise here. The password manager holds the restic, LUKS, and server root passwords that the runbook needs to restore the servers. Putting it on those servers makes recovery circular. It would also make Geoff the security team for the household's most sensitive data, next to the mail server he already called the biggest risk.

## KeePassXC (note only)

KeePassXC 2.7.12 (March 2026) is a local file with an official Flatpak, browser integration, and passkeys ([release](https://keepassxc.org/blog/2026-03-10-2.7.12-released/), [OMG Ubuntu](https://www.omgubuntu.co.uk/2025/02/keepassxc-snap-update-adds-native-messaging-support-i-e-browser-integration)). It has no sharing, no emergency access, and no aliases, and phones need third-party apps. It does not fit four people on phones.

## Masked email with Stalwart

**What Stalwart provides.** A Domain object has `catchAllAddress`, which receives mail to unknown local recipients. If it is unset, such mail is rejected ([Domain](https://stalw.art/docs/ref/object/domain), [RCPT stage](https://stalw.art/docs/mta/inbound/rcpt)). Each domain also has `subAddressing`: Enabled, Disabled, or Custom. Domains are managed in the WebUI, by JMAP (`x:Domain/set`), or with `stalwart-cli`. A subdomain such as `m.907.life` is just another Domain. Accounts carry `aliases`, each an `EmailAlias` with `name`, `domainId`, `enabled`, and `description`, set through `x:Account/set` ([Account](https://stalw.art/docs/ref/object/account)). A populated alias payload is not shown on that page. System Sieve scripts can run at SMTP stages, and a forum example rejects one address at RCPT time with `550 5.7.1` ([Sieve examples](https://stalw.art/docs/sieve/examples/), [forum](https://support.stalw.art/t/how-to-block-outbound-email-address/1233)).

**The 0.16 catch: sending from catch-all addresses.** In 0.16 an account cannot send as an address merely because the catch-all delivers it. `mustMatchSender` blocks it. The workarounds are one alias per address, turning the check off, or a custom expression for one account ([forum](https://support.stalw.art/t/v0-16-catch-all-issues/461)). So with a bare catch-all, replying from `service@m.907.life` needs extra setup. The `Delivered-To` header also shows the catch-all mailbox, not the original address (same thread). Sorting on the original recipient must read `To` or the envelope. That is unverified on a live server.

**How burning works in each design.**

- *Proton Pass:* toggle the alias off in any Pass app. Mail stops at Proton. One tap.
- *Stalwart catch-all:* add the address to a reject list read by a RCPT-stage system script. The sender gets a 550, which also tells them the address is dead. Or a user Sieve rule can file it to Trash. Either way it is a server edit, best done by a small script over JMAP or `stalwart-cli`. No phone app can do it. Whether a disabled `EmailAlias` on a catch-all domain rejects mail, or falls through to the catch-all, is unverified.
- *addy.io or SimpleLogin:* toggle in their app or site.

**How much the missing toggle matters.** Little, in volume. Of 168 non-deleted Fastmail masks, one is disabled (measured 2026-10-17). Burning is rare. Creation happens at every sign-up, by every family member, often on a phone. The integration that matters is creation, and there Proton's in-form button beats Bitwarden's generator trip. Bitwarden's catch-all is also random-only on phones. The toggle is a small win for Proton. The in-form creation is the big one.

**Recommended workflow (Proton Pass).**

1. Add `m.907.life` (name is Geoff's call) as a Proton Pass custom domain. MX and SPF point at Proton, per the mail cutover brief. Set the Stalwart address as the default mailbox for each family member.
2. Turn on catch-all for the domain on the SimpleLogin side, if Family carries it. Then an address typed at a service by hand, or one missed in triage, still arrives.
3. Sign up: email field, Proton icon, "Hide my email", confirm the `m.907.life` suffix, submit, save the login. On a phone, the same choice sits in the autofill create-login flow.
4. Burn: disable, never delete. Proton says deletion cannot be undone ([aliases](https://proton.me/support/pass-email-alias)).
5. Reply: reply to the forwarded message. It leaves through the reverse alias. Stalwart's DKIM must be right first, as the mail cutover brief notes.
6. Portability drill, once a year: export aliases with `pass-cli item list --output json` into the age-encrypted backup. Keep a written plan: add `m.907.life` as a Stalwart Domain with `catchAllAddress` set, then move its MX. The brief Fastmail triage window is the only time mail depends on two vendors at once.

**The Fastmail triage.** For each of the 165 live `@fastmail.com` masks, open the service's account page and use the same in-form button on the email-change field. That last step is unverified; the field may not be detected as a sign-up form. Otherwise create the alias in the extension and paste it. Then disable the Fastmail mask, as the mail cutover brief lays out.

## Recommendation

Keep Proton Pass Family as the plan. With integration weighted double, it is the only option with one-step alias creation in the form on Linux browsers, Safari, Android, and iOS. Its CLI also gives the narrowest audited access for scripts and Claude. It costs $12 a year more than Bitwarden, which buys that integration.

Choose Bitwarden Families with a Stalwart catch-all instead only if Geoff ranks "no third party sees alias mail" above one-step creation on phones. In that case, install the verified Flatpak and the extensions, and never the npm CLI. Use the Secrets Manager free organization, with no event logs, for the workstation age key. Add a RCPT-stage reject list on Stalwart for burned addresses. Expect a Stalwart send rule before family members can reply from an alias.

Do not stay on 1Password, self-host Vaultwarden, or move to KeePassXC.

## Risks

- Alias mail transits Proton in clear. This is the cost of the toggle and the in-form button. The mitigation is the catch-all exit plan above.
- Linux is Proton's weakest platform. The extension has no biometric unlock on Linux yet, and the desktop app is a manual, unsigned RPM. Geoff will type a PIN in the extension.
- Thin independent autofill evidence for every product. The review figures above are anecdote. Run a short trial before cancelling 1Password: ten sign-ins and two sign-ups per person, in Firefox, Chromium, Safari, and both phone types.
- Proton has less outside scrutiny than Bitwarden. One firm per audit cycle, and no academic malicious-server study.
- Stalwart 0.16 behaviour changed without changelog notice. Users report this for catch-all and sending ([forum](https://support.stalw.art/t/v0-16-catch-all-issues/461)). Test the fallback catch-all on a staging domain before relying on it.
- Unverified points to check during the trial. That Pass Family carries SimpleLogin catch-all. That the desktop inline flow can default to the custom domain. That the in-form button appears on email-change pages. Face ID and Touch ID behaviour in the Pass apps and the Safari extension.

## Open questions for Geoff

1. Weighing: is "one tap to create an alias on a phone" worth Proton seeing alias mail? This brief assumes yes, from your integration priority.
2. Trial: will each family member spend a week on Proton Pass before 1Password is cancelled?
3. Budget: Pass Family at $59.88 a year, against Bitwarden Families at $47.88 with no hosted aliases. Is the $12 difference acceptable?
4. Does the fourth household member use Apple, Android, or both? That decides how hard to test the Safari and iOS paths.
