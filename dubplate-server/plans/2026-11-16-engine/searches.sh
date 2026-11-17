#!/usr/bin/env bash
# Recorded searches for the engine pass plan. Run from the repo root.
set -uo pipefail
n() { printf '%s\t%s\n' "$1" "$2"; }
here=$(cd "$(dirname "$0")" && pwd)
n S1-narrow "$(bash "$here/citation-count.sh" narrow | wc -l)"
n S2-wide "$(bash "$here/citation-count.sh" wide | wc -l)"
n S2-wide-pass "$(bash "$here/citation-count.sh" wide | grep -Ec '^(internal/engine/(matcher|musicbrainz|tagio|tag)/|internal/harness/|cmd/harness/|internal/config/)')"
n S2-gate "$(bash "$here/citation-count.sh" gate | wc -l)"
n S2-gate-pass "$(bash "$here/citation-count.sh" gate | grep -Ec '^(internal/engine/(matcher|musicbrainz|tagio|tag)/|internal/harness/|cmd/harness/|internal/config/)')"
bash "$here/citation-count.sh" gate | grep -Ev '^(internal/engine/(matcher|musicbrainz|tagio|tag)/|internal/harness/|cmd/harness/|internal/config/)' | cut -d/ -f1-2 | sort | uniq -c
bash "$here/citation-count.sh" wide | grep -Ev '^(internal/engine/(matcher|musicbrainz|tagio|tag)/|internal/harness/|cmd/harness/|internal/config/)' | cut -d/ -f1-2 | sort | uniq -c
bash "$here/citation-count.sh" wide | grep -E '^(internal/engine/(matcher|musicbrainz|tagio|tag)/|internal/harness/|cmd/harness/|internal/config/)' | awk -F/ '{ if ($2=="engine") print $1"/"$2"/"$3; else print $1"/"$2 }' | sort | uniq -c
lim='\b(Limiter|NewLimiter|Class|ClassUserPresent|ClassBatch|ClassBackground|Budget|Unmetered|ErrBudgetExhausted|ErrLimiterClosed|DefaultInterval)\b'
n S3-limiter "$(grep -rnE "$lim" --include='*.go' internal/engine internal/harness cmd/harness | wc -l)"
n S3-limiter-outside-files "$(grep -rnE "$lim" --include='*.go' internal/engine internal/harness cmd/harness | grep -v 'musicbrainz/limiter' | wc -l)"
grep -rnE "$lim" --include='*.go' internal/engine internal/harness cmd/harness | grep -v 'musicbrainz/limiter' | cut -d: -f1 | sort | uniq -c
n S3-limiter-lines "$(cat internal/engine/musicbrainz/limiter.go internal/engine/musicbrainz/limiter_test.go | wc -l)"
n S4-component-files "$(ls internal/engine/matcher/album_*.go internal/engine/matcher/track_*.go | grep -vc '_test\.go$')"
n S4-matcher-src "$(ls internal/engine/matcher/*.go | grep -vc '_test\.go$')"
n S5-recover "$(grep -n 'recover()' internal/engine/matcher/*.go | grep -vc '_test\.go:')"
n S5-mutex "$(grep -n 'sync\.\(RW\)\?Mutex' internal/engine/matcher/*.go | grep -vc '_test\.go:')"
n S6-case-field-encode "$(grep -c 'case Field' internal/engine/tagio/encode.go)"
n S6-case-field-reader "$(grep -c 'case Field' internal/engine/tagio/re[a]d.go)"
n S7-registry "$(grep -nE '\b(formatEntry|registry|resolveEntry)\b' internal/engine/tagio/*.go | wc -l)"
n S7-registry-nontest "$(grep -nE '\b(formatEntry|registry|resolveEntry)\b' internal/engine/tagio/*.go | grep -vc '_test\.go:')"
n S8-os-open "$(grep -n 'os\.Open(' internal/engine/tagio/*.go | grep -vc '_test\.go:')"
grep -n 'os\.Open(' internal/engine/tagio/*.go | grep -v '_test\.go:'
n S9-GradeRequests "$(grep -rn 'GradeRequests' --include='*.go' cmd internal | wc -l)"
n S9-ties "$(grep -rn 'tiesAwaitingRuling' --include='*.go' cmd internal | wc -l)"
n S9-extra "$(grep -rnE '\.Extra\b|\bExtra +\[|\bExtra:' --include='*.go' internal/harness cmd/harness | wc -l)"
grep -rnE '\.Extra\b|\bExtra +\[|\bExtra:' --include='*.go' internal/harness cmd/harness | cut -c1-110
n S9-extra-corpus "$(grep -rl '"extra"' corpus --include=case.json | wc -l)"
n S10-fieldNullability "$(grep -rn 'fieldNullability' --include='*.go' cmd internal | wc -l)"
grep -rn 'fieldNullability' --include='*.go' cmd internal | cut -d: -f1,2
n S11-mbrequest-files "$(ls internal/harness/mbrequest | wc -l)"
grep -rn 'harness/mbrequest"' --include='*.go' cmd internal | cut -d: -f1,2
n S12-writeorder "$(grep -rn 'func TestWriteOrderDeterministic' --include='*.go' internal | wc -l)"
n S12-defaulttunables "$(grep -rn 'func TestDefaultTunables_' --include='*.go' internal | wc -l)"
n S13-patterntable-conform "$(grep -n 'PatternTable' internal/harness/conform/*.go | grep -vc '_test\.go:')"
n S14-unmetered-calls "$(grep -rn 'Unmetered()' --include='*.go' cmd internal | grep -v 'musicbrainz/limiter' | wc -l)"
grep -rn 'Unmetered()' --include='*.go' cmd internal | grep -v 'musicbrainz/limiter' | cut -d: -f1,2
n S15-check-citations "$(grep -rn 'CHECK_CITATIONS' scripts .github Makefile .claude docs/standing-rules.md CLAUDE.md 2>/dev/null | wc -l)"
grep -rn 'CHECK_CITATIONS' scripts .github Makefile .claude docs/standing-rules.md CLAUDE.md 2>/dev/null | cut -d: -f1,2
n S16-intake-tagio "$(grep -rnoE 'tagio\.[A-Za-z]+' --include='*.go' internal/intake cmd/dubplate-server | grep -v _test | cut -d: -f3 | sort -u | tr '\n' ' ')"
n S17-unidecode-server "$(grep -rnoE 'unidecode\.[A-Za-z]+' --include='*.go' internal cmd | grep -v _test | grep -v 'internal/engine\|internal/harness\|cmd/harness' | cut -d: -f3 | sort -u | tr '\n' ' ')"
n S18-compilePanic "$(grep -rn 'compilePanicAsError' --include='*.go' internal | wc -l)"
n S19-time-now-fixture "$(bash "$here/citation-count.sh" wide | grep -c 'testdata')"
bash "$here/citation-count.sh" wide | grep 'testdata' | cut -c1-140
