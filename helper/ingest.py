"""Split the user guides and runbooks into citable sections.

This module only reads markdown. It does not change Salesforce.
"""

from __future__ import annotations

import json
import re
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[1]
SOURCE_DIRS = (
    REPO_ROOT / "docs" / "user-guides",
    REPO_ROOT / "docs" / "runbook",
)
INDEX_PATH = Path(__file__).resolve().parent / "index.json"
HEADING = re.compile(r"^## ([A-Za-z0-9]+:\S.*)$")
KEYWORDS = re.compile(r"^Keywords:\s*(.+)$", re.IGNORECASE)


def _section_from_lines(source: Path, heading: str, lines: list[str]) -> dict:
    while lines and not lines[0].strip():
        lines = lines[1:]
    if not lines or not KEYWORDS.match(lines[0].strip()):
        raise ValueError(f"{source.name} section '{heading}' is missing a Keywords line")
    keywords = [part.strip().lower() for part in KEYWORDS.match(lines[0].strip()).group(1).split(",")]
    keywords = [item for item in keywords if item]
    if not keywords:
        raise ValueError(f"{source.name} section '{heading}' has no keywords")
    body = "\n".join(lines[1:]).strip()
    if not body:
        raise ValueError(f"{source.name} section '{heading}' has an empty body")
    return {
        "id": heading,
        "source": str(source.relative_to(REPO_ROOT)).replace("\\", "/"),
        "keywords": keywords,
        "body": body,
    }


def parse_document(path: Path) -> list[dict]:
    """Return sections for one markdown file."""
    text = path.read_text(encoding="utf-8")
    sections: list[dict] = []
    current_id: str | None = None
    bucket: list[str] = []

    def flush() -> None:
        nonlocal current_id, bucket
        if current_id is None:
            bucket = []
            return
        sections.append(_section_from_lines(path, current_id, bucket))
        current_id = None
        bucket = []

    for raw in text.splitlines():
        match = HEADING.match(raw.strip())
        if match:
            flush()
            current_id = match.group(1).strip()
            continue
        if current_id is not None:
            bucket.append(raw)
    flush()
    return sections


def build_index() -> dict:
    """Read the procedure documents and return the section index."""
    sections: list[dict] = []
    seen: dict[str, str] = {}
    for folder in SOURCE_DIRS:
        if not folder.is_dir():
            raise FileNotFoundError(folder)
        for path in sorted(folder.glob("*.md")):
            for section in parse_document(path):
                if section["id"] in seen:
                    raise ValueError(
                        f"Duplicate section id {section['id']} in {path.name} and {seen[section['id']]}"
                    )
                seen[section["id"]] = path.name
                sections.append(section)
    sections.sort(key=lambda item: item["id"])
    return {"sections": sections}


def write_index(index: dict | None = None) -> Path:
    """Write helper/index.json and return its path."""
    payload = build_index() if index is None else index
    INDEX_PATH.write_text(json.dumps(payload, indent=2), encoding="utf-8")
    return INDEX_PATH


def main() -> None:
    path = write_index()
    index = json.loads(path.read_text(encoding="utf-8"))
    print(f"Wrote {len(index['sections'])} sections to {path}")


if __name__ == "__main__":
    main()
