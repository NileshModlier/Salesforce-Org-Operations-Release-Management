"""Answer a how-to question from ingested procedure sections only.

The assistant is advisory. It does not change Salesforce data, assign
permissions, modify configuration, deploy releases, or trigger automation.
"""

from __future__ import annotations

import argparse
import json
import sys

import ingest

REFUSAL = (
    "This runbook does not contain\n"
    "an approved answer.\n"
    "\n"
    "Recommend escalation."
)
ADVISORY = (
    "Advisory only. This assistant does not change Salesforce data, "
    "assign permissions, modify configuration, deploy releases, or trigger automation."
)


def _score(question: str, section: dict) -> int:
    folded = " ".join(question.lower().split())
    hits = 0
    for phrase in section["keywords"]:
        if phrase in folded:
            hits += 1
    return hits


def retrieve(question: str, index: dict | None = None) -> dict:
    """Return a refusal or the verbatim body of the single matching section."""
    if not question or not question.strip():
        return _refusal()
    payload = index if index is not None else ingest.build_index()
    scored = [(section, _score(question, section)) for section in payload["sections"]]
    matched = [section for section, score in scored if score > 0]
    if len(matched) != 1:
        return _refusal()
    section = matched[0]
    return {
        "refused": False,
        "answer": section["body"],
        "citations": [section["id"]],
        "advisory": ADVISORY,
    }


def _refusal() -> dict:
    return {
        "refused": True,
        "answer": REFUSAL,
        "citations": [],
        "advisory": ADVISORY,
    }


def format_text(result: dict) -> str:
    """Plain-text reply. The answer text is either the section or the refusal."""
    lines = [result["advisory"], "", result["answer"], ""]
    if result["citations"]:
        lines.append("Citations: " + ", ".join(result["citations"]))
    else:
        lines.append("Citations: none")
    return "\n".join(lines)


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Ask the procedure assistant.")
    parser.add_argument("question", nargs="+", help="Question to match against the runbooks and guides")
    parser.add_argument("--json", action="store_true", help="Print the result as JSON")
    args = parser.parse_args(argv)
    result = retrieve(" ".join(args.question))
    if args.json:
        print(json.dumps(result, indent=2))
    else:
        print(format_text(result))
    return 0


if __name__ == "__main__":
    sys.exit(main())
