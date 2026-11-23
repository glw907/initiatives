"""Run security-guidance's layer-1 rules over a repo's tracked files at HEAD."""
import collections, re, subprocess, sys
sys.path.insert(0, sys.argv[1])
import patterns as p
repo = sys.argv[2]
files = subprocess.run(["git", "-C", repo, "ls-files"], capture_output=True, text=True).stdout.split()
hits = collections.defaultdict(list)
for f in files:
    if "/testdata/" in f or f.endswith((".png", ".flac", ".mp3", ".wav", ".woff2", ".ico", ".jpg")):
        continue
    try:
        text = open(f"{repo}/{f}", encoding="utf-8").read()
    except (UnicodeDecodeError, FileNotFoundError, IsADirectoryError):
        continue
    for r in p.SECURITY_PATTERNS:
        if "path_check" in r and not r["path_check"](f):
            continue
        if "path_filter" in r and not r["path_filter"](f):
            continue
        if "path_check" in r and "regex" not in r and "substrings" not in r:
            hits[r["ruleName"]].append(f); continue
        ok = any(s in text for s in r.get("substrings", [])) or ("regex" in r and re.search(r["regex"], text))
        if ok:
            hits[r["ruleName"]].append(f)
for k, v in sorted(hits.items()):
    print(f"{k}: {len(v)} file(s): {', '.join(v[:6])}{' ...' if len(v) > 6 else ''}")
print("files scanned:", len(files))
