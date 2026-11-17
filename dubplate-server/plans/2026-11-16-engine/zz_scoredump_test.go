package conform

// The engine pass's score dump. It is a throwaway file: engine-dump.sh
// copies it into internal/harness/conform, runs it, and removes it, and
// it is never committed.
//
// It replays every corpus case twice and prints every float the engine
// computed as its exact bit pattern, then hashes the output. The
// conformance suite compares distances at a tolerance, so only this
// dump can show that a refactor moved no bit.

import (
	"context"
	"crypto/sha256"
	"errors"
	"fmt"
	"math"
	"os"
	"path/filepath"
	"strings"
	"testing"

	"github.com/glw907/dubplate/internal/engine/matcher"
	"github.com/glw907/dubplate/internal/engine/tag"
	"github.com/glw907/dubplate/internal/harness/cassette"
	"github.com/glw907/dubplate/internal/harness/stub"
)

func TestZZEngineScoreDump(t *testing.T) {
	root := repoRoot(t)
	casesRoot := filepath.Join(root, "corpus", "cases")
	entries, err := os.ReadDir(casesRoot)
	if err != nil {
		t.Fatalf("read corpus/cases: %v", err)
	}

	var out strings.Builder
	cases := 0
	for _, e := range entries {
		if !e.IsDir() {
			continue
		}
		cases++
		dumpCase(t, &out, filepath.Join(casesRoot, e.Name()))
	}

	sum := sha256.Sum256([]byte(out.String()))
	fmt.Printf("score-dump cases=%d lines=%d sha256=%x\n", cases, strings.Count(out.String(), "\n"), sum)
	if path := os.Getenv("ENGINE_DUMP_OUT"); path != "" {
		if err := os.WriteFile(path, []byte(out.String()), 0o600); err != nil {
			t.Fatalf("write %s: %v", path, err)
		}
	}
}

// dumpCase prints one case under both compat selections. The full
// selection drives tag.Album over the case's stub, the flow the request
// log covers. The default selection re-scores the candidates that run
// returned, because its flow may issue a request the log never held.
func dumpCase(t *testing.T, out *strings.Builder, dir string) {
	t.Helper()
	c, err := cassette.LoadCase(dir)
	if err != nil {
		t.Fatalf("load %s: %v", dir, err)
	}
	fmt.Fprintf(out, "case %s\n", c.ID)

	evalDate, tun, items, err := caseInputs(c)
	if err != nil {
		t.Fatalf("case %s: inputs: %v", c.ID, err)
	}
	srv, err := stub.New(c, dir)
	if err != nil {
		t.Fatalf("case %s: stub: %v", c.ID, err)
	}
	defer func() {
		if err := srv.Close(); err != nil {
			t.Errorf("case %s: close stub: %v", c.ID, err)
		}
	}()
	client, err := gradeClient(srv.Addr())
	if err != nil {
		t.Fatalf("case %s: client: %v", c.ID, err)
	}

	full := matcher.FullCompat()
	prop, err := tag.Album(context.Background(), client, items, tun, full, evalDate, tag.Options{})
	switch {
	case errors.Is(err, tag.ErrNoCandidates):
		fmt.Fprintln(out, " full: no candidates")
	case err != nil:
		t.Fatalf("case %s: tag.Album: %v", c.ID, err)
	}
	fmt.Fprintf(out, " requests misses=%d unused=%d\n", len(srv.Misses()), len(srv.Unused()))

	var got []matcher.Candidate
	if prop != nil {
		got = prop.Candidates
		fmt.Fprintf(out, " full cur=%q/%q rec=%s action=%s\n", prop.CurArtist, prop.CurAlbum, prop.Recommendation, prop.Action)
	}
	dumpCandidates(out, " full", got)

	tunDefault := matcher.DefaultCompat().Apply(tun)
	if err := tunDefault.Validate(); err != nil {
		t.Fatalf("case %s: default tunables: %v", c.ID, err)
	}
	cands := matcher.NewCandidates()
	for _, cand := range got {
		admitted, err := cands.Add(tunDefault, items, cand.Info, evalDate)
		if err != nil {
			t.Fatalf("case %s: default re-score of %s: %v", c.ID, cand.Info.AlbumID, err)
		}
		fmt.Fprintf(out, " default admit %s %t\n", cand.Info.AlbumID, admitted)
	}
	sorted := cands.Sorted()
	rec, err := matcher.Recommend(tunDefault, sorted)
	if err != nil {
		t.Fatalf("case %s: default recommend: %v", c.ID, err)
	}
	action, err := matcher.ActionFor(tunDefault, rec)
	if err != nil {
		t.Fatalf("case %s: default action: %v", c.ID, err)
	}
	fmt.Fprintf(out, " default rec=%s action=%s\n", rec, action)
	dumpCandidates(out, " default", sorted)
}

func dumpCandidates(out *strings.Builder, label string, cands []matcher.Candidate) {
	for i, cand := range cands {
		fmt.Fprintf(out, "%s cand %d %s/%s dist=%016x raw=%016x max=%016x\n", label, i,
			cand.Info.DataSource, cand.Info.AlbumID,
			math.Float64bits(cand.Dist.Distance()),
			math.Float64bits(cand.Dist.RawDistance()),
			math.Float64bits(cand.Dist.MaxDistance()))
		dumpKeys(out, label+"  key", cand.Dist)
		for j, td := range cand.Dist.Tracks {
			fmt.Fprintf(out, "%s  track %d dist=%016x\n", label, j, math.Float64bits(td.Dist.Distance()))
			dumpKeys(out, label+"   key", td.Dist)
		}
		fmt.Fprintf(out, "%s  pairs", label)
		for _, p := range cand.Assignment.Pairs {
			fmt.Fprintf(out, " %d:%d", p.Item, p.Track)
		}
		fmt.Fprintf(out, " extra-items=%v extra-tracks=%v\n", cand.Assignment.ExtraItems, cand.Assignment.ExtraTracks)
	}
}

// dumpKeys prints each penalty key in the order it was first added,
// with its weighted distance.
func dumpKeys(out *strings.Builder, label string, d *matcher.Distance) {
	perKey := d.PerKey()
	for _, k := range d.AddedKeys() {
		fmt.Fprintf(out, "%s %s=%016x\n", label, k, math.Float64bits(perKey[k]))
	}
}
