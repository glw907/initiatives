# Content check trials, 2026-11-22

These files are the trial versions behind
[the content check spec](../../specs/2026-11-22-content-check-spec.md). All of them ran on
pavilion with Vale 3.28.1. The trial run before launch passed on 2026-11-22: a Sonnet session
called `content-vale.sh` on a clone at `01c86da` and got `11 errors, 1 warning and 0
suggestions in 1 file.` The built version merged as pull request 26 in `glw907/standards`.

| File | What it is |
| --- | --- |
| `vale/vale.ini` | The Vale config. It reads Markdown only and turns on one style |
| `vale/styles/WebContent/Vocabulary.yml` | The 34 flat-banned words from the method's catalog, with their endings. Errors |
| `vale/styles/WebContent/Qualified.yml` | `navigate`, `journey`, and `nuanced`, banned only in one sense. Warnings |
| `vale/styles/WebContent/Phrases.yml` | The 12 fixed constructions. Errors |
| `content-vale.sh` | The wrapper script that runs Vale with that config on one file, with `--no-global` |
| `content-style-test.sh` | The test for the style and the wrapper |

## What plain Vale does today

Run from the ecxc-ski checkout, which has no Vale config:

| Command | Output | Exit |
| --- | --- | --- |
| `vale src/content/pages/about.md` | `0 errors, 0 warnings and 0 suggestions in 0 files.` | 0 |
| `vale --config <trial>/vale.ini src/content/pages/about.md` | `0 errors, 0 warnings and 0 suggestions in 1 file.` | 0 |
| The same, on a `.txt` copy of a page | `0 errors, 0 warnings and 0 suggestions in 0 files.` | 0 |
| The same, on a path that doesn't exist | `0 errors, 0 warnings and 0 suggestions in stdin.` | 0 |
| The same, with `--output=JSON`, on a clean page and on the `.txt` copy | `{}` both times | 0 |

Vale passes a file it never read. The JSON output can't tell the two cases apart, so the
wrapper reads the summary line.

## The wrapper and its test

The files were copied into a clone of `glw907/standards` at `b6dbe0d`, at the paths the spec
names, and the wording changes the spec lists were applied, with the two frontmatter lines.

| Command | Output | Exit |
| --- | --- | --- |
| `bash tests/content-style-test.sh` | `content-style-test: 37 catalog terms, 12 constructions, 2 samples, and 4 failure cases pass` | 0 |
| The same, with `pivotal` deleted from `Vocabulary.yml` | `content-style-test: the style does not flag the catalog term 'pivotal'` | 1 |
| The same, with `CONTENT_VALE` set to a script that is `exec vale --no-global --config <the shipped vale.ini> --no-wrap "$@"` | `content-style-test: a file type Vale skips: exit 0, want 2` | 1 |
| The same, with `CONTENT_VALE` set to a copy of the wrapper without `--no-global`, beside a copy of the `vale/` folder | `content-style-test: a config in the home folder: exit 0, want 2` | 1 |
| `content-vale.sh src/content/pages/about.md`, from the ecxc-ski checkout | `0 errors, 0 warnings and 0 suggestions in 1 file.` | 0 |
| `content-vale.sh` on the method's sample B | `11 errors, 1 warning and 0 suggestions in 1 file.` | 1 |
| `shellcheck` on both scripts | No output | 0 |

The repo's eight CI commands all exit 0 in that clone: `claude plugin validate plugins/standards`,
`claude plugin validate .`, `node scripts/validate-warnings.mjs`, `scripts/scan.sh`,
`tests/scan-test.sh`, `scripts/check-skill-lines.sh`, `tests/check-skill-lines-test.sh`, and
`node scripts/check-references.mjs`.

## The config in the home folder

Pavilion has a Vale config at `~/.config/vale/.vale.ini`. `vale --config <trial>/vale.ini
ls-config` lists both files under `ConfigFiles`, and the merged config reads `.go`, `.ts`, and
`.py` files as Markdown and accepts the words in the `House` vocabulary. The first wrapper
ran without `--no-global`, so that config could add a file type or drop a banned word. A fresh
reader of the spec found it on 2026-11-22. The wrapper now passes `--no-global`, and the
test's fourth failure case sets `XDG_CONFIG_HOME` to a folder whose config reads `.txt` as
Markdown.

## The style on the four sites

Run over every Markdown file under `src/content/` in each site:

| Site | Files | Places flagged |
| --- | --- | --- |
| ecxc-ski | 7 | 0 |
| 907-life | 8 | 5 |
| aksailingclub-org | 91 | 21 |
| cairn-pub | 5 | 0 |

Six of the 26 are a literal or legal use: a lifting harness, a person whose surname is Foster,
a rule that names the time of day boats are put away, and three in the club's bylaws and lease
text. The other 20 are uses the catalog bans, and `essential` accounts for 7 of them.

## The CI install

Both release files answer HTTP 200:
`https://github.com/errata-ai/vale/releases/download/v3.28.1/vale_3.28.1_Linux_64-bit.tar.gz`
and `vale_3.28.1_checksums.txt` beside it. The checksums file lists the archive as
`068954ad869ebec24b8dec6ebcd1cbb1fd5f5a83e966a35baedfae8b2cdc093a`.
