# Repo retirement dry run

## Brief

Approving this item lets the pass delete five GitHub repos, tear down 11 Cloudflare resources that nothing else uses, and remove the local copies of 11 repos and folders, after it saves what can't be recovered to one archive. Nothing is removed until you approve, and each step rechecks that its target is unchanged.

The pass can't delete anything safely until you have read the list below, because six of the folders have no remote. You already ruled on those on 2026-10-14. This item shows the exact targets so you can confirm them.

### What changes

- Five GitHub repos are deleted: `cairn-scratch-b`, `displaywidth`, `kit`, `jrnl-md`, and `hugo-blog-template`.
- Three Workers, two D1 databases, one KV namespace, two custom domains, two DNS records, and one Access app are torn down. They are the scratch site, the `pings` service, and the staging copy of the club site.
- Seven local copies are deleted on pavilion: `healthy-diet`, `pings`, `personal-styles`, `cairn-scratch`, `ecxc-ski-agent-memory`, `aksailingclub-sveltekit`, and the `displaywidth` clone. The three folders that are not git repos are saved to one tar archive first. The thinkpad script removes whichever of the 11 it holds.
- Two secrets leave the age store, `PINGS_ADMIN_TOKEN` and `CAIRN_SCRATCH_CF_TOKEN`, together with the shell and bootstrap lines that name the retired repos.
- Seven repos get a one-line GitHub description: `cairn-cms`, `poplar`, `907-life`, `cairn-pub`, `phonebook`, `workstation`, and `approval-queue`.

### If you approve

1. The pass writes the archive and the two D1 exports, then checks them against their sources.
2. It tears down the Cloudflare resources, rechecking each one's ownership just before it deletes.
3. It commits the secret and manifest-line removals to `workstation`, which waits for your read of that PR.
4. It deletes the five GitHub repos and sets the seven descriptions.
5. It removes the local folders, after rechecking each against the facts in the manifest below.

### Decide: Thinkpad store check

Before the store commit, the pass needs `secrets/values.age` to be clean on the thinkpad. On pavilion it is clean and matches `origin/main` (checked just now). Only you can confirm the thinkpad.

Source: `git -C ~/.dotfiles status --porcelain secrets/values.age` on thinkpad-x1, after a pull

- The command prints nothing on the thinkpad (recommended)
- The command prints a change, so the pass waits for you to deal with it first

### Worth knowing

The pass resolved sharing across the scope list and across the Cloudflare account's Worker bindings, so a resource that a Worker outside this pass binds is left in place and not named here.

### Every target and its action

The 11 retiring repos and folders each get one action, listed below with what is lost if you are wrong.

| Target | Kind | Action | Recoverable afterwards |
|---|---|---|---|
| `cairn-scratch-b` | GitHub repo, no local copy on pavilion | Delete the repo | No |
| `displaywidth` | GitHub fork with a local clone, 6 branches ahead of its parent, 0 open PRs | Delete the fork and the clone | Parent repo only |
| `kit` | GitHub fork, 213 branches ahead of its parent, 0 open PRs | Delete the fork | Parent repo only |
| `jrnl-md` | GitHub repo | Delete the repo | No |
| `hugo-blog-template` | GitHub repo | Delete the repo | No |
| `healthy-diet` | Local git repo, no remote, 1 unpushed branch | Delete without a backup (your 2026-10-14 ruling) | The 2026-10-12 handoff bundle on R2 |
| `pings` | Local git repo, no remote, 1 unpushed branch | Delete without a backup (your 2026-10-14 ruling) | The 2026-10-12 handoff bundle on R2 |
| `personal-styles` | Local git repo, no remote, 1 unpushed branch | Delete without a backup (your 2026-10-14 ruling) | The 2026-10-12 handoff bundle on R2 |
| `cairn-scratch` | Plain folder, 158 files | Archive, then delete | From the archive |
| `ecxc-ski-agent-memory` | Plain folder, 17 files | Fold into `ecxc-ski`, archive, then delete | From the archive |
| `aksailingclub-sveltekit` | Orphaned worktree, 1,153 files | Archive, then delete | From the archive |

### Cloudflare resources to tear down

The pass tears down these 11 resources, each of which only a retiring target uses, in this order.

- Custom domains `pings.907.life` and `staging.aksailingclub.org`.
- Workers `pings`, `asc-staging`, and `cairn-scratch-b`, with their cron triggers.
- D1 databases `asc-staging` and `cairn-scratch-b-auth`, exported to the archive first.
- KV namespace `PINGS_KV`.
- DNS records for `pings.907.life` and `staging.aksailingclub.org`.
- Access application "ASC Staging".

None of these is an R2 bucket, so there are no object counts to check. Two scratch D1 databases and an R2 bucket that `cairn-scratch` names are no longer in the account, so nothing is torn down for them.

### Shared resources left in place

The `aksailingclub-legacy` repo still serves the live club site, so the pass leaves what it shares with the retiring `aksailingclub-sveltekit`.

- Workers `asc-handbook` and `asc-uptime`, with their cron triggers.
- The `STATUS` KV namespace.
- The `asc-event-images` R2 bucket.
- The `handbook.aksailingclub.org` route and its DNS record.
- Two Access applications that cover shared hostnames.

### Manifest lines to remove

The `workstation` PR removes or edits these lines, so no file names a retired repo.

- `bash/.bashrc`, line 134 (a comment naming `jrnl-md`) and line 152 (a `hugo-blog-template` path pattern).
- `bluefin/bootstrap.sh`, line 786 (the restore loop for the three archived folders).
- `bluefin/SECOND-WORKSTATION.md`, lines 79 to 81 and 253.
- `secrets/registry.md`, the table rows and sections for `PINGS_ADMIN_TOKEN` and `CAIRN_SCRATCH_CF_TOKEN`.

### Worktree calls

No worktree is removable today, because each one is either unmerged or was touched in the last day.

- The merged drafter `agent-*` worktrees pass every rule except age, so the drafter follow-up removes them once a day has passed (the conductor holds this call).
- The `top-bar-tidy` worktree in `workstation` is unmerged, so it stays for your call.
- Worktrees of the live pass are left alone.

### Archive and D1 exports

The pass writes one tar archive of the three plain folders, plus a SQL export of each of the two D1 databases, outside `~/Projects` and outside the state directory.

- Archive path: `/var/home/glw907/Documents/retired-repos-2026-10-14.tar`. It's under `/var/home`, so it survives a reboot.
- The archive holds `cairn-scratch`, `ecxc-ski-agent-memory`, and `aksailingclub-sveltekit`.
- The D1 exports are `asc-staging` and `cairn-scratch-b-auth`, written with `wrangler d1 export`. A failed or empty export stops the pass before any teardown.

### GitHub descriptions

The pass sets these one-line descriptions after you approve.

- `cairn-cms`: An embedded, magic-link, GitHub-committing CMS for SvelteKit sites on Cloudflare.
- `poplar`: A terminal email client built with bubbletea, shipped as one Go binary.
- `907-life`: Source for 907.life, a personal blog on SvelteKit and Cloudflare Workers.
- `cairn-pub`: Source for cairn.pub, the cairn documentation site, on SvelteKit and Cloudflare Workers.
- `phonebook`: A household phonebook for Yealink phones, served from a Cloudflare Worker.
- `workstation`: Dotfiles and provisioning for two Bluefin DX workstations, managed with GNU Stow.
- `approval-queue`: A local app and command that put PRs, designs, and triage lists in front of a reviewer for a decision.

### Geoff does by hand

Two steps need your account, and the pass's token can't do them.

1. Revoke the account-owned token `CAIRN_SCRATCH_CF_TOKEN` in the Cloudflare dashboard.
2. Run `gh auth refresh -s delete_repo`, so the pass can delete the five repos.

### Facts checked before this brief

The pass checked two facts at the head of the pass branch.

- `workstation`#69 merged on 2026-10-14. 
- `secrets/values.age` on pavilion is clean and matches `origin/main` at `8172e2f`.

### Manifest

The manifest below is what the later steps read. The retire, archive, and `workstation` sessions extract it from this approved document, check the document's hash, and act on these rows only. Its columns are `stage`, `kind`, `id`, `action`, and `expect`, separated by tabs.

```tsv
stage	kind	id	action	expect
archive	tar	/var/home/glw907/Documents/retired-repos-2026-10-14.tar	create	members=cairn-scratch:158,ecxc-ski-agent-memory:17,aksailingclub-sveltekit:1153
archive	d1-export	cbd3fdba-fc6b-47d7-b2a0-537543e880e9	export	name=asc-staging
archive	d1-export	1fe11784-f64e-408f-8bc2-029e997c11a9	export	name=cairn-scratch-b-auth
cloudflare	route	pings.907.life	delete	sole-owner
cloudflare	route	staging.aksailingclub.org	delete	sole-owner
cloudflare	worker	pings	delete	sole-owner
cloudflare	worker	asc-staging	delete	sole-owner
cloudflare	worker	cairn-scratch-b	delete	sole-owner
cloudflare	d1	cbd3fdba-fc6b-47d7-b2a0-537543e880e9	delete	sole-owner
cloudflare	d1	1fe11784-f64e-408f-8bc2-029e997c11a9	delete	sole-owner
cloudflare	kv	5c126cfe4a984f74bd37e67bae3e9512	delete	sole-owner
cloudflare	dns	a7c2b9103ec7d835d72f356489072e5b/6d431fecfc01ca963db1bf6c25c43664	delete	sole-owner
cloudflare	dns	20c8739759428149d47508f0632bb1ff/19ce9467e40893f1d0e8215ddc934f52	delete	sole-owner
cloudflare	access-app	f18fa6b9-79b4-4bd7-88ce-37eac144ece7	delete	sole-owner
store	secret	PINGS_ADMIN_TOKEN	delete	used-by-target-only
store	secret	CAIRN_SCRATCH_CF_TOKEN	delete	used-by-target-only
manifest	line	bash/.bashrc:134	edit	# (poplar, jrnl-md) stays lean.
manifest	line	bash/.bashrc:152	remove	"$HOME"/Projects/hugo-blog-template/*)
manifest	line	bluefin/bootstrap.sh:786	remove	for item in aksailingclub-sveltekit cairn-scratch ecxc-ski-agent-memory; do
manifest	line	bluefin/SECOND-WORKSTATION.md:79	edit	three repos with no remote (`healthy-diet`, `personal-styles`, `pings`), the
manifest	line	bluefin/SECOND-WORKSTATION.md:80	edit	local folders `cairn-scratch`, `ecxc-ski-agent-memory`, and
manifest	line	bluefin/SECOND-WORKSTATION.md:81	edit	`aksailingclub-sveltekit`, the ASC age key, the `jrnl-md` config, and
manifest	line	bluefin/SECOND-WORKSTATION.md:253	edit	cairn-themes displaywidth drafter dubplate ecxc-ski phonebook poplar \
github	repo	cairn-scratch-b	delete	main=5ed23f8bdbe745de02472ea99a86f6cf08510d37
github	repo	displaywidth	delete	main=a9edf624090707441305e510a63d168832ffcbf2
github	repo	kit	delete	main=f6910fe60764b4d1e4688c3386c42ca3680af891
github	repo	jrnl-md	delete	main=8365de9e70713b7081bcbc75d496ae56c421964d
github	repo	hugo-blog-template	delete	main=db7c035f7746dac6e4a5c78109f1762f91ad18bb
github	description	cairn-cms	An embedded, magic-link, GitHub-committing CMS for SvelteKit sites on Cloudflare.	
github	description	poplar	A terminal email client built with bubbletea, shipped as one Go binary.	
github	description	907-life	Source for 907.life, a personal blog on SvelteKit and Cloudflare Workers.	
github	description	cairn-pub	Source for cairn.pub, the cairn documentation site, on SvelteKit and Cloudflare Workers.	
github	description	phonebook	A household phonebook for Yealink phones, served from a Cloudflare Worker.	
github	description	workstation	Dotfiles and provisioning for two Bluefin DX workstations, managed with GNU Stow.	
github	description	approval-queue	A local app and command that put PRs, designs, and triage lists in front of a reviewer for a decision.	
local	local-dir	healthy-diet	remove	HEAD=37a8dac8014b81aea30b7615b2dc9ddfffc8b4f6 refs/heads/main=37a8dac8014b81aea30b7615b2dc9ddfffc8b4f6
local	local-dir	pings	remove	HEAD=c79320a1032e2382ea48c26dbe22f2efc1f6972f refs/heads/master=c79320a1032e2382ea48c26dbe22f2efc1f6972f
local	local-dir	personal-styles	remove	HEAD=c8359559cefdd029997723d37ba2aca7108fe79c refs/heads/master=c8359559cefdd029997723d37ba2aca7108fe79c
local	local-tar	cairn-scratch	remove	mtime=1789226811 files=158
local	local-tar	ecxc-ski-agent-memory	remove	mtime=1787266519 files=17
local	local-tar	aksailingclub-sveltekit	remove	mtime=1788119492 files=1153
local	local-dir	displaywidth	remove	remote HEAD=a9edf624090707441305e510a63d168832ffcbf2 refs/heads/main=a9edf624090707441305e510a63d168832ffcbf2
local	local-dir	cairn-scratch-b	remove	remote
local	local-dir	kit	remove	remote
local	local-dir	jrnl-md	remove	remote
local	local-dir	hugo-blog-template	remove	remote
```
