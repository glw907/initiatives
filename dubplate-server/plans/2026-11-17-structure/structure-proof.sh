#!/usr/bin/env bash
# Prints a fingerprint of what dubplate-server shows a person, for the
# structure round's proof that behavior is unchanged. Run it on a binary
# built at the pass's base commit and again at its head: the two outputs
# must be identical.
#
# Usage: structure-proof.sh <path to dubplate-server binary> [transcript file]
#
# The transcript is every line the runs printed, with the temp folder, the
# log timestamp, the local user, and the free-space figure masked. When two
# fingerprints differ, diff the two transcripts.
#
# Port 18431 on 127.0.0.1 must have no listener while this runs.
set -uo pipefail

bin=$(realpath "$1")
keep=${2:-}
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
mkdir -p "$work/home" "$work/music/library" "$work/music/staging" "$work/state" "$work/state2"
transcript="$work/transcript.txt"

# Fixture values, built at run time so no credential-shaped literal sits in
# this file. None of them reaches a real service.
fill() { printf "$1%.0s" $(seq 1 "$2"); }
link_key=$(fill a 64)
session_key=$(fill b 64)
mail_word=$(fill x 12)

base=(PATH=/usr/bin:/bin HOME="$work/home")
complete=("${base[@]}"
  DUBPLATE_LIBRARY_ROOT="$work/music/library" DUBPLATE_STATE_DIR="$work/state"
  DUBPLATE_SITE_NAME=Proof DUBPLATE_ADMIN_EMAIL=admin@example.test
  DUBPLATE_IDENTITY_SOURCE=magic-link DUBPLATE_STAGING_DIR="$work/music/staging"
  "DUBPLATE_MAGIC_LINK_SECRET=$link_key" "DUBPLATE_SESSION_SECRET=$session_key"
  DUBPLATE_PUBLIC_URL=https://proof.example.test DUBPLATE_SMTP_HOST=smtp.example.test
  DUBPLATE_SMTP_PORT=587 DUBPLATE_SMTP_USER=proof "DUBPLATE_SMTP_PASSWORD=$mail_word"
  DUBPLATE_SMTP_FROM=dubplate@example.test DUBPLATE_SERVE_PORT=18431)

mask() {
  sed -E -e "s#$work#WORK#g" \
    -e 's/^time=[^ ]+ /time=T /' \
    -e 's/actor=local:[^ ]+/actor=local:USER/' \
    -e 's/^(backup free space +).*/\1N/'
}

# section <title> runs the commands fed to it and adds their masked output
# to the transcript, then prints the section's line count and hash.
section_start() { section_title=$1; : >"$work/section.txt"; }
run() {
  local label=$1 code=0
  shift
  {
    echo "### $label"
    "$@" 2>&1 || code=$?
    echo "exit=$code"
  } | mask >>"$work/section.txt"
}
section_end() {
  printf '%-34s lines=%-4s sha256=%s\n' "$section_title:" \
    "$(wc -l <"$work/section.txt")" "$(sha256sum "$work/section.txt" | cut -c1-64)"
  { echo "## $section_title"; cat "$work/section.txt"; } >>"$transcript"
}

section_start "empty environment"
run "doctor" env -i "${base[@]}" "$bin" doctor
run "check" env -i "${base[@]}" "$bin" check
section_end

section_start "complete environment, no store"
run "check" env -i "${complete[@]}" "$bin" check
run "doctor" env -i "${complete[@]}" "$bin" doctor
run "member list" env -i "${complete[@]}" "$bin" member list
section_end

section_start "a retired setting name"
run "check" env -i "${complete[@]}" DUBPLATE_LIBRARY_DIR="$work/music/library" "$bin" check
run "doctor" env -i "${complete[@]}" DUBPLATE_UPLOADS_DIR="$work/music/staging" "$bin" doctor
section_end

section_start "refused values"
run "check, thresholds" env -i "${complete[@]}" DUBPLATE_SERVE_PORT=80 DUBPLATE_SERVE_PREFIX=nope \
  DUBPLATE_SERVE_BIND_ADDRS=999.1.1.1 DUBPLATE_STORE_BUSY_TIMEOUT=1ns DUBPLATE_STORE_MIGRATION_WAIT=soon \
  DUBPLATE_THEME_MATCH=other DUBPLATE_THEME_PALETTE=UPPER DUBPLATE_BRANDING=red \
  DUBPLATE_OPERATOR_CSS_FILE="$work/none.txt" DUBPLATE_INTAKE_FORMAT_ALLOWLIST=mp3 "$bin" check
for one in DUBPLATE_SERVE_PORT=80 DUBPLATE_SERVE_PREFIX=nope DUBPLATE_SERVE_BIND_ADDRS=999.1.1.1 \
  DUBPLATE_STORE_BUSY_TIMEOUT=1ns DUBPLATE_STORE_MIGRATION_WAIT=soon DUBPLATE_THEME_MATCH=other \
  DUBPLATE_THEME_PALETTE=UPPER DUBPLATE_BRANDING=red "DUBPLATE_OPERATOR_CSS_FILE=$work/none.txt" \
  DUBPLATE_INTAKE_FORMAT_ALLOWLIST=mp3 DUBPLATE_BACKUP_ENABLED=true DUBPLATE_TRUSTED_PROXY_ENABLED=true \
  DUBPLATE_SMTP_FROM=nobody DUBPLATE_PUBLIC_URL=ftp://proof.example.test DUBPLATE_ADMIN_EMAIL=nobody \
  DUBPLATE_IDENTITY_SOURCE=other DUBPLATE_MAGIC_LINK_SECRET=short DUBPLATE_JOB_RETENTION=1s \
  DUBPLATE_STORE_LOCAL_SNAPSHOT_KEEP=0 DUBPLATE_REAUTH_WINDOW=100h DUBPLATE_SESSION_LIFETIME=9000h \
  DUBPLATE_NONCE_RETENTION=1m DUBPLATE_INTAKE_MAX_FILES=0 DUBPLATE_BACKUP_GUARD_FRACTION=2 \
  DUBPLATE_UNKNOWN_ADDRESS_ANSWER=maybe; do
  run "check, ${one%%=*}" env -i "${complete[@]}" "$one" "$bin" check
  run "doctor, ${one%%=*}" env -i "${complete[@]}" "$one" "$bin" doctor
done
section_end

# serve creates and migrates the store before it reaches the web check, so a
# short run leaves a current store whether or not the web app is built in.
section_start "a store with one admin"
timeout -s INT 6 env -i "${complete[@]}" "$bin" serve >/dev/null 2>&1
run "member add" env -i "${complete[@]}" "$bin" member add admin@example.test --admin --name Admin --username admin
run "member add, second" env -i "${complete[@]}" "$bin" member add member@example.test --name Member --username member
run "member add, taken" env -i "${complete[@]}" "$bin" member add member@example.test --name Member --username member
run "member list" env -i "${complete[@]}" "$bin" member list
run "member demote, last admin" env -i "${complete[@]}" "$bin" member demote admin@example.test
run "member remove" env -i "${complete[@]}" "$bin" member remove member@example.test
run "check" env -i "${complete[@]}" "$bin" check
run "doctor" env -i "${complete[@]}" "$bin" doctor
run "settings reset, no value" env -i "${complete[@]}" "$bin" settings reset DUBPLATE_JOB_RETENTION
run "settings reset, unknown" env -i "${complete[@]}" "$bin" settings reset DUBPLATE_NO_SUCH_KEY
run "check, seed refused" env -i "${complete[@]}" DUBPLATE_JOB_RETENTION=1s "$bin" check
run "doctor, seed refused" env -i "${complete[@]}" DUBPLATE_STORE_LOCAL_SNAPSHOT_KEEP=0 "$bin" doctor
run "backup, disabled" env -i "${complete[@]}" "$bin" backup
run "version" env -i "${complete[@]}" "$bin" version
section_end

help_of() { env -i "${base[@]}" "$bin" "$@" --help; }
section_start "help text, every command"
run "root" help_of
for verb in backup check completion doctor member restore serve settings unidecode version; do
  run "$verb" help_of "$verb"
done
for sub in "member add" "member list" "member remove" "member demote" "settings reset" "unidecode install"; do
  # shellcheck disable=SC2086
  run "$sub" help_of $sub
done
section_end

printf '%-34s lines=%-4s sha256=%s\n' "everything:" "$(wc -l <"$transcript")" \
  "$(sha256sum "$transcript" | cut -c1-64)"
if [ -n "$keep" ]; then cp "$transcript" "$keep"; fi
