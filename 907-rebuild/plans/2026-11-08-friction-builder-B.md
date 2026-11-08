# BACKLOG: cairn instructions that were missing, unclear, or wrong

Kept while rebuilding 907.life on cairn (create-cairn-site 0.99.0-rc.4). This file moves into the
site repo once setup has scaffolded it.

## Setup command

1. **No flag reference for `create-cairn-site`.** The flags are scattered through the docs:
   `--name`, `--repo-name`, and `--app-name` appear only in the rows of the recovery tables, `--owner-email` only under
   "Sign in again", and `--email` only in a passing sentence about `--yes`. No page lists them all or
   says which can be passed on a first run. The npm registry entry has no readme, and the npmjs.com
   page refuses automated fetches, so `--help` is the only source, and that means running the tool.
2. **The "site's name" prompt is unclear.** Create your site says "The site's name" with no format.
   It doesn't say whether that's a display name ("907.life") or a slug, or how the Worker,
   repository, App (`cairn-<name>`), database (`<name>-auth`), and bucket (`<name>-media`) names come
   from it. The derivations show up only in the recovery tables and the transcript excerpt. A
   brief that names a repo and a Worker (`glw907/907-life`, `907-life`) can't be mapped to flags
   or answers without guessing.
3. **No way to name the domain up front is documented.** It's unclear whether a domain can be passed
   as a flag or only typed at the `Connect a domain you own...` prompt.
4. **Builds after a domain, in the same run, is unclear.** Create your site says the command
   "goes on to offer Workers Builds" after the domain question. Own your domain says "If you
   decline the domain, the setup command offers Builds in the same run" and otherwise points at
   `--connect`. It isn't clear whether accepting the domain also offers Builds in the same run.
5. **A domain already on the same Cloudflare account, carrying live mail, gets one sentence**
   ("the zone arrives active and there is nothing to copy"). It should state plainly that the
   command leaves the existing records alone, and repeat the DMARC `p=reject` warning there, because
   that's the case where an owner's mail is most at risk.
6. **No guidance for an agent and a human splitting the work.** The docs assume one person at one
   terminal. When an agent builds the site and the human runs setup, things that aren't written
   down matter: the progress record lives in the human's `~/.config/cairn/sites`, so `--sign-in`
   and `--connect` work only from their machine, and the agent needs to know which folder to work in
   and when it's safe to push.
