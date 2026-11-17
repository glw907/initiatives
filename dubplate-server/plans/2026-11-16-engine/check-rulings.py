"""Rerun every search in rulings.md and compare it with the row's record.

Usage: python3 -I check-rulings.py <rulings.md> <repo root>

Each row of the first table names a record as file:line and a search.
The row passes when the search, run from the repo root, prints exactly
one line and that line's number is the record's. The script prints each
failing row, then the totals, and exits 1 when a row fails.
"""

import re
import subprocess
import sys


def main() -> int:
    table, root = sys.argv[1], sys.argv[2]
    rows = bad = 0
    with open(table, encoding="utf-8") as fh:
        for line in fh:
            if not line.startswith("| ") or line.startswith("| Ruling"):
                continue
            cells = [c.strip() for c in line.rstrip("\n").strip("|").split(" | ")]
            if len(cells) < 5:
                continue
            record, search = cells[-2], cells[-1]
            found = re.search(r"``(.+)``", search)
            if not found:
                continue
            rows += 1
            command = found.group(1).replace("\\|", "|")
            out = subprocess.run(
                command, shell=True, cwd=root, capture_output=True, text=True, check=False
            ).stdout.strip().splitlines()
            want = re.match(r"(\S+?):(\d+)", record)
            if want and len(out) == 1 and out[0].split(":")[0] == want.group(2):
                continue
            bad += 1
            print("MISMATCH", cells[0], "|", record, "|", len(out), "lines")
    print("rows", rows, "ok", rows - bad, "bad", bad)
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main())
