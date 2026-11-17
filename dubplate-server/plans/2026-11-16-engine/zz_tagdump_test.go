package tagio

// The engine pass's tag dump. It is a throwaway file: engine-dump.sh
// copies it into internal/engine/tagio, runs it, and removes it, and it
// is never committed.
//
// It prints every answer the tag reader gives for the twelve ledger
// subjects, the golden file, and every truncation of the golden file,
// then hashes the output. It uses only the names the upload gate calls
// and its own loaders, so a refactor of the package's other names and
// test helpers can't break it.

import (
	"crypto/sha256"
	"encoding/json"
	"errors"
	"fmt"
	"os"
	"path/filepath"
	"strconv"
	"strings"
	"testing"
)

const (
	zzLedgerPath   = "../../../corpus/analysis/file_tags.json"
	zzCaseFormat   = "../../../corpus/cases/%s/case.json"
	zzTemplatePath = "../../harness/oracle/testdata/template.flac"
	zzGoldenPath   = "testdata/golden.flac"
)

func TestZZEngineTagDump(t *testing.T) {
	var out strings.Builder
	zzLedgerSubjects(t, &out)
	zzGolden(t, &out)
	zzTruncations(t, &out)

	sum := sha256.Sum256([]byte(out.String()))
	fmt.Printf("tag-dump lines=%d sha256=%x\n", strings.Count(out.String(), "\n"), sum)
	if path := os.Getenv("ENGINE_DUMP_OUT"); path != "" {
		if err := os.WriteFile(path, []byte(out.String()), 0o600); err != nil {
			t.Fatalf("write %s: %v", path, err)
		}
	}
}

// zzLedgerSubjects writes each ledger subject's applied fields to a
// copy of the template, then prints the written file's hash and what
// Read returns for it.
func zzLedgerSubjects(t *testing.T, out *strings.Builder) {
	t.Helper()
	var ledger struct {
		WritableFields []string `json:"writable_fields"`
		Rows           []struct {
			CaseID    string `json:"case_id"`
			ItemIndex int    `json:"item_index"`
		} `json:"rows"`
	}
	zzLoadJSON(t, zzLedgerPath, &ledger)
	fmt.Fprintf(out, "ledger rows=%d writable=%d\n", len(ledger.Rows), len(ledger.WritableFields))

	for _, row := range ledger.Rows {
		var doc struct {
			Expected struct {
				AppliedFields map[string]map[string]json.RawMessage `json:"applied_fields"`
			} `json:"expected"`
		}
		zzLoadJSON(t, fmt.Sprintf(zzCaseFormat, row.CaseID), &doc)
		applied, ok := doc.Expected.AppliedFields[strconv.Itoa(row.ItemIndex)]
		if !ok {
			t.Fatalf("case %s: no applied fields for item %d", row.CaseID, row.ItemIndex)
		}
		filtered := make(map[string]json.RawMessage, len(ledger.WritableFields))
		for _, name := range ledger.WritableFields {
			v, ok := applied[name]
			if !ok {
				t.Fatalf("case %s: applied fields carry no key %q", row.CaseID, name)
			}
			filtered[name] = v
		}
		encoded, err := json.Marshal(filtered)
		if err != nil {
			t.Fatalf("case %s: marshal: %v", row.CaseID, err)
		}
		var ts TagSet
		if err := json.Unmarshal(encoded, &ts); err != nil {
			t.Fatalf("case %s: fill TagSet: %v", row.CaseID, err)
		}

		path := zzCopy(t, zzTemplatePath)
		if err := Write(path, ts, nil, 0o644); err != nil {
			t.Fatalf("case %s: Write: %v", row.CaseID, err)
		}
		fmt.Fprintf(out, "subject %s/%d file=%s\n", row.CaseID, row.ItemIndex, zzFileHash(t, path))
		zzRead(t, out, " ", path)
	}
}

// zzGolden prints what Sniff, Read, and Parse return for the golden
// file, then the hash of three rewrites of it.
func zzGolden(t *testing.T, out *strings.Builder) {
	t.Helper()
	format, err := Sniff(zzGoldenPath)
	fmt.Fprintf(out, "golden sniff=%v err=%s\n", format, zzErr(err, zzGoldenPath))
	fmt.Fprintf(out, "golden formats=%v\n", SupportedFormats())
	zzRead(t, out, "golden ", zzGoldenPath)
	zzContainer(t, out, "golden ", zzGoldenPath)

	ts, err := Read(zzGoldenPath)
	if err != nil {
		t.Fatalf("Read golden: %v", err)
	}
	png := append([]byte{0x89, 'P', 'N', 'G', '\r', '\n', 0x1a, '\n'}, "dump-picture-payload"...)
	pic := Picture{Type: 3, MediaType: "application/octet-stream", Description: "cover", Width: 640, Height: 480, Depth: 24, Colors: 16, Data: png}
	for _, w := range []struct {
		name     string
		ts       TagSet
		pictures []Picture
	}{
		{"same-tags-keep-pictures", ts, nil},
		{"same-tags-strip-pictures", ts, []Picture{}},
		{"same-tags-two-pictures", ts, []Picture{pic, pic}},
		{"empty-tags-keep-pictures", TagSet{}, nil},
	} {
		path := zzCopy(t, zzGoldenPath)
		err := Write(path, w.ts, w.pictures, 0o644)
		fmt.Fprintf(out, "rewrite %s err=%s file=%s\n", w.name, zzErr(err, path), zzFileHash(t, path))
		zzContainer(t, out, " ", path)
	}

	path := zzCopy(t, zzGoldenPath)
	bad := Picture{Type: 3, Data: []byte("no image magic here")}
	err = Write(path, ts, []Picture{bad}, 0o644)
	fmt.Fprintf(out, "rewrite bad-picture err=%s file=%s\n", zzErr(err, path), zzFileHash(t, path))

	for _, b := range []Bounds{
		{TagBytes: 16, PictureBytes: 1 << 20},
		{TagBytes: 1 << 20, PictureBytes: 16},
		{TagBytes: 1 << 20, PictureBytes: 1 << 20},
	} {
		c, err := ParseBounded(zzGoldenPath, b)
		fmt.Fprintf(out, "bounded %d/%d blocks=%d err=%s\n", b.TagBytes, b.PictureBytes, len(c.Blocks), zzErr(err, zzGoldenPath))
	}
}

// zzTruncations prints what Sniff, Parse, Read, and Write return for
// every prefix of the golden file, so each refusal is on the record.
func zzTruncations(t *testing.T, out *strings.Builder) {
	t.Helper()
	golden, err := os.ReadFile(zzGoldenPath)
	if err != nil {
		t.Fatalf("read golden: %v", err)
	}
	dir := t.TempDir()
	path := filepath.Join(dir, "prefix.flac")
	for n := 0; n <= len(golden); n++ {
		if err := os.WriteFile(path, golden[:n], 0o644); err != nil {
			t.Fatalf("write prefix %d: %v", n, err)
		}
		format, sniffErr := Sniff(path)
		c, parseErr := Parse(path)
		_, readErr := Read(path)
		fmt.Fprintf(out, "prefix %d sniff=%v/%s parse=%d/%s read=%s\n", n, format, zzErr(sniffErr, path),
			len(c.Blocks), zzErr(parseErr, path), zzErr(readErr, path))
		if n%64 == 0 {
			writeErr := Write(path, TagSet{}, nil, 0o644)
			fmt.Fprintf(out, "prefix %d write=%s file=%s\n", n, zzErr(writeErr, path), zzFileHash(t, path))
		}
	}

	if err := os.WriteFile(path, []byte("OggS\x00\x02 not a FLAC stream at all"), 0o644); err != nil {
		t.Fatalf("write ogg: %v", err)
	}
	format, sniffErr := Sniff(path)
	_, readErr := Read(path)
	fmt.Fprintf(out, "ogg sniff=%v/%s read=%s\n", format, zzErr(sniffErr, path), zzErr(readErr, path))

	missing := filepath.Join(dir, "missing.flac")
	_, readErr = Read(missing)
	fmt.Fprintf(out, "missing read=%s\n", zzErr(readErr, missing))
}

func zzRead(t *testing.T, out *strings.Builder, label, path string) {
	t.Helper()
	ts, err := Read(path)
	if err != nil {
		t.Fatalf("Read %s: %v", path, err)
	}
	encoded, err := json.Marshal(ts)
	if err != nil {
		t.Fatalf("marshal TagSet: %v", err)
	}
	fmt.Fprintf(out, "%sread %s\n", label, encoded)
}

func zzContainer(t *testing.T, out *strings.Builder, label, path string) {
	t.Helper()
	c, err := Parse(path)
	if err != nil {
		fmt.Fprintf(out, "%sparse err=%s\n", label, zzErr(err, path))
		return
	}
	fmt.Fprintf(out, "%sstreaminfo %+v frames=%d+%d vendor=%q\n", label, c.StreamInfo, c.FrameOffset, c.FrameLength, c.VorbisComment.Vendor)
	for i, b := range c.Blocks {
		fmt.Fprintf(out, "%sblock %d type=%d last=%t length=%d payload=%x\n", label, i, b.Type, b.Last, b.Length, sha256.Sum256(b.Payload))
	}
	for i, cm := range c.VorbisComment.Comments {
		fmt.Fprintf(out, "%scomment %d %q=%q\n", label, i, cm.Name, cm.Value)
	}
	for i, p := range c.Pictures {
		fmt.Fprintf(out, "%spicture %d type=%d media=%q desc=%q %dx%d depth=%d colors=%d data=%x\n", label, i,
			p.Type, p.MediaType, p.Description, p.Width, p.Height, p.Depth, p.Colors, sha256.Sum256(p.Data))
	}
}

// zzErr renders an error as its class and its text, with the scratch
// path replaced so two runs print the same line.
func zzErr(err error, path string) string {
	if err == nil {
		return "ok"
	}
	class := "other"
	switch {
	case errors.Is(err, ErrMalformedContainer):
		class = "malformed"
	case errors.Is(err, ErrUnsupportedContainer):
		class = "unsupported"
	case errors.Is(err, ErrTagsTooLarge):
		class = "tags-too-large"
	case errors.Is(err, ErrPictureTooLarge):
		class = "picture-too-large"
	case errors.Is(err, os.ErrNotExist):
		class = "not-exist"
	}
	return class + "[" + strings.ReplaceAll(err.Error(), path, "<path>") + "]"
}

func zzLoadJSON(t *testing.T, path string, v any) {
	t.Helper()
	data, err := os.ReadFile(path)
	if err != nil {
		t.Fatalf("read %s: %v", path, err)
	}
	if err := json.Unmarshal(data, v); err != nil {
		t.Fatalf("decode %s: %v", path, err)
	}
}

func zzCopy(t *testing.T, src string) string {
	t.Helper()
	data, err := os.ReadFile(src)
	if err != nil {
		t.Fatalf("read %s: %v", src, err)
	}
	path := filepath.Join(t.TempDir(), "scratch.flac")
	if err := os.WriteFile(path, data, 0o644); err != nil {
		t.Fatalf("write %s: %v", path, err)
	}
	return path
}

func zzFileHash(t *testing.T, path string) string {
	t.Helper()
	data, err := os.ReadFile(path)
	if err != nil {
		t.Fatalf("read %s: %v", path, err)
	}
	return fmt.Sprintf("%x", sha256.Sum256(data))
}
