# Decisions, 2026-11-03

Geoff's rulings from the brainstorm on pavilion, and Claude's calls marked as such. The sources are the research brief's: Anthropic's Claude Code security and best-practices pages, OWASP's Secrets Management Cheat Sheet and LLM01 and LLM06, Proton's access-token and pass-cli docs, RFC 2142, and Stalwart's address and permission docs.

## Vaults

A vault is the unit Proton grants access on, so each vault holds one set of readers. Projects get folders, not vaults (Claude's call, from OWASP 4.3 and Proton's token docs).

| Vault | Holds | Readers |
|---|---|---|
| `Private` | accounts only Geoff signs in to | Geoff |
| `Cathy & Geoff` | accounts the two run as a household: bank, utilities, insurance, house, taxes, shared subscriptions | Geoff, Cathy |
| `Family` | accounts the adult kids use or would need: family plans, phones, travel, emergencies | Geoff, the kids |
| `Parents` | the parents' accounts | Geoff, Cathy |
| `Proton recovery` | Proton's recovery material | Geoff; no agent |
| `Infrastructure` | the household's servers, backups, mail, phones, voip.ms, Cloudflare, the registrar, and the age key | Geoff, the second operator, Claude (editor); each `<host>-scripts` agent on the age-key item only |
| `Projects` | cairn, the sites, npm, Anthropic, Resend, Twilio, and the technical identity's vendor accounts, one folder per project | Geoff, Claude (editor) |
| `ASC` | the club's credentials and its age key, so a handover is one share | Geoff, Claude (editor), officers later |
| `Test accounts` | `glw907-test`, the probe mailboxes, test logins | Claude (editor); later a CI token |

Tiebreaker (Geoff approved): an item goes in the narrowest vault that holds everyone who signs in to it, and money or medical accounts lean to `Cathy & Geoff` unless a kid uses them. `Workstation`, `Servers emergency`, and `Household IT` are gone; `Infrastructure` replaced the last two (Geoff, the rename and moves). `pavilion-claude` has temporary editor on `Private`, `Cathy & Geoff`, `Family`, and `Parents` for the triage, revoked when it ends.

## Mail

- A second mailbox on ward takes technical mail. Claude reads it with a separate app password, scoped down (Stalwart credentials can only remove permissions). The scope is Claude's call.
- Alerts go straight to that mailbox (Geoff). Where a provider has a separate notification address, it is set at the provider; otherwise a Sieve rule moves known alert subjects only, so a reset code never follows an alert (Claude's call).
- Technical accounts, the high-value ones included, register on the technical identity, since Claude already holds their passwords (Geoff). The exception is Proton, whose recovery stays on the personal mailbox, because resetting it would open every vault (Geoff agreed).
- The public technical identity is an alias into the technical mailbox. Every message there is untrusted input, per Anthropic's prompt-injection guidance and OWASP LLM01. Its name is still open.

## Emergency access

Geoff and Cathy each name the kids as Proton Emergency Access contacts with a wait of about two weeks, and a letter with the estate documents explains the feature and each vault (Geoff). This opens the whole account, which is intended. Geoff sets it up in Proton's dashboard under Recovery.

## Open

- The public identity's name, and where it appears.
- The naming scheme and the note template, drafted from the triage.
