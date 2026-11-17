#!/usr/bin/env bash
# engine-dump.sh prints the two bit-identity hashes for the engine pass.
#
# Usage: engine-dump.sh <worktree root> [<output dir>]
#
# It copies the two throwaway dump tests beside this script into the
# worktree, runs them, removes them, and prints one "score-dump" line
# and one "tag-dump" line, each ending in a sha256. With an output dir
# it also writes score.txt and tag.txt there, so two runs can be
# compared with diff when the hashes differ. It exits non-zero when
# either test fails or leaves no hash line.
set -euo pipefail

here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
root=${1:?usage: engine-dump.sh <worktree root> [<output dir>]}
outdir=${2:-}

score_dst="$root/internal/harness/conform/zz_scoredump_test.go"
tag_dst="$root/internal/engine/tagio/zz_tagdump_test.go"
cleanup() { rm -f "$score_dst" "$tag_dst"; }
trap cleanup EXIT

cp "$here/zz_scoredump_test.go" "$score_dst"
cp "$here/zz_tagdump_test.go" "$tag_dst"

run() {
	local name=$1 pkg=$2 test=$3 log
	log=$(mktemp)
	if [ -n "$outdir" ]; then
		mkdir -p "$outdir"
		export ENGINE_DUMP_OUT="$outdir/$name.txt"
	else
		unset ENGINE_DUMP_OUT
	fi
	if ! (cd "$root" && go test -count=1 -v -run "^$test\$" "$pkg") >"$log" 2>&1; then
		cat "$log"
		rm -f "$log"
		echo "engine-dump: $name test failed" >&2
		return 1
	fi
	if ! grep -E "^$name-dump .*sha256=[0-9a-f]{64}\$" "$log"; then
		cat "$log"
		rm -f "$log"
		echo "engine-dump: $name test printed no hash line" >&2
		return 1
	fi
	rm -f "$log"
}

run score ./internal/harness/conform/ TestZZEngineScoreDump
run tag ./internal/engine/tagio/ TestZZEngineTagDump
