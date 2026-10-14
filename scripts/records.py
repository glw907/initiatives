"""Load, validate, and index the initiative records of an initiatives tree."""

import json
import re
import subprocess
from pathlib import Path

REQUIRED = ("id", "title", "summary", "status", "owner", "created", "repos")
STATUSES = ("proposed", "active", "paused", "done", "withdrawn")
NOT_RECORDS = {"scripts", "tests", "node_modules"}
START = "<!-- index:start -->"
END = "<!-- index:end -->"


def record_dirs(root: Path) -> list[Path]:
    """Return the top-level directories that are meant to hold a record."""
    return sorted(
        p
        for p in root.iterdir()
        if p.is_dir() and not p.name.startswith(".") and p.name not in NOT_RECORDS
    )


def parse_yaml(path: Path):
    """Return the parsed document, or raise ValueError when yq cannot read it."""
    run = subprocess.run(
        ["yq", "-o=json", ".", str(path)], capture_output=True, text=True
    )
    if run.returncode != 0:
        raise ValueError(run.stderr.strip().splitlines()[0] if run.stderr else "unparsable")
    return json.loads(run.stdout)


def load(root: Path):
    """Return (records, errors); a record is (directory name, data)."""
    records = []
    errors = []
    dirs = record_dirs(root)
    if not dirs:
        errors.append((root.name or str(root), "no initiative records"))
    seen = {}
    for d in dirs:
        yaml_path = d / "initiative.yaml"
        rel = f"{d.name}/initiative.yaml"
        if not yaml_path.is_file():
            errors.append((f"{d.name}/", "directory has no initiative.yaml"))
            continue
        try:
            data = parse_yaml(yaml_path)
        except ValueError as exc:
            errors.append((rel, f"does not parse: {exc}"))
            continue
        if not isinstance(data, dict):
            errors.append((rel, "is not a mapping"))
            continue
        problems = validate(d.name, data)
        errors.extend((rel, p) for p in problems)
        ident = data.get("id")
        if isinstance(ident, str):
            if ident in seen:
                errors.append((rel, f"duplicate id {ident}, also in {seen[ident]}"))
            else:
                seen[ident] = rel
        if not problems:
            records.append((d.name, data))
    return records, errors


def validate(dirname: str, data: dict) -> list[str]:
    """Return the problems with one record's fields."""
    out = []
    for field in REQUIRED:
        if field not in data or data[field] in (None, "", []):
            out.append(f"missing required field {field}")
    if "status" in data and data["status"] not in (None, "") and data["status"] not in STATUSES:
        out.append(f"unknown status {data['status']!r}")
    if isinstance(data.get("id"), str) and data["id"] != dirname:
        out.append(f"id {data['id']!r} differs from directory name {dirname!r}")
    repos = data.get("repos")
    if repos not in (None, "", []):
        if not isinstance(repos, list) or not all(
            isinstance(r, str) and re.fullmatch(r"[A-Za-z0-9._-]+", r) for r in repos
        ):
            out.append("repos must be a list of bare GitHub repo names")
    for field in ("id", "title", "summary", "status", "owner", "created"):
        if field in data and data[field] not in (None, "") and not isinstance(data[field], str):
            out.append(f"field {field} must be a string")
    return out


def render_index(records) -> str:
    """Return the index table for the valid records, sorted by id."""
    lines = [
        "| Initiative | Status | Repos | Summary |",
        "|---|---|---|---|",
    ]
    for dirname, data in sorted(records):
        summary = data["summary"].replace("|", "\\|").strip()
        repos = ", ".join(data["repos"])
        lines.append(
            f"| [{data['title']}]({dirname}/README.md) | {data['status']} | {repos} | {summary} |"
        )
    return "\n".join(lines)


def index_block(readme: str):
    """Return the text between the index markers, or None when they are absent."""
    if START not in readme or END not in readme:
        return None
    return readme.split(START, 1)[1].split(END, 1)[0].strip("\n")


def splice_index(readme: str, table: str) -> str:
    """Return readme with the index markers' content replaced by table."""
    head, rest = readme.split(START, 1)
    tail = rest.split(END, 1)[1]
    return f"{head}{START}\n{table}\n{END}{tail}"
