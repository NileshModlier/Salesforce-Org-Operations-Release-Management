"""Score the procedure assistant against the fixed 30-question set."""

from __future__ import annotations

import json
import sys
from pathlib import Path

HELPER_DIR = Path(__file__).resolve().parents[1]
if str(HELPER_DIR) not in sys.path:
    sys.path.insert(0, str(HELPER_DIR))

import ask
import ingest

QUESTIONS_PATH = Path(__file__).resolve().parent / "questions.json"


def load_questions() -> list[dict]:
    payload = json.loads(QUESTIONS_PATH.read_text(encoding="utf-8"))
    return payload["questions"]


def evaluate() -> dict:
    index = ingest.build_index()
    by_id = {section["id"]: section for section in index["sections"]}
    questions = load_questions()
    covered = [item for item in questions if item["covered"]]
    uncovered = [item for item in questions if not item["covered"]]

    correct_answers = 0
    correct_citations = 0
    citations_checked = 0
    citations_found = 0
    correct_refusals = 0
    hallucinations = 0
    rows = []

    for item in questions:
        result = ask.retrieve(item["question"], index)
        cited = result["citations"]
        citations_checked += len(cited)
        citations_found += sum(1 for citation in cited if citation in by_id)
        hallucinated = False
        if result["refused"]:
            if result["answer"] != ask.REFUSAL or cited:
                hallucinated = True
        else:
            if len(cited) != 1 or cited[0] not in by_id or result["answer"] != by_id[cited[0]]["body"]:
                hallucinated = True
        if hallucinated:
            hallucinations += 1
        if item["covered"]:
            expected = item["expected_id"]
            answer_ok = (not result["refused"]) and cited == [expected]
            if answer_ok:
                correct_answers += 1
                correct_citations += 1
        else:
            if result["refused"] and result["answer"] == ask.REFUSAL and not cited:
                correct_refusals += 1
        rows.append(
            {
                "id": item["id"],
                "covered": item["covered"],
                "refused": result["refused"],
                "citations": cited,
                "hallucination": hallucinated,
            }
        )

    citation_accuracy = 1.0 if citations_checked == 0 else citations_found / citations_checked
    return {
        "question_count": len(questions),
        "covered": len(covered),
        "uncovered": len(uncovered),
        "correct_answers": correct_answers,
        "correct_citations": correct_citations,
        "citation_accuracy": citation_accuracy,
        "correct_refusals": correct_refusals,
        "hallucinations": hallucinations,
        "rows": rows,
    }


def main() -> int:
    metrics = evaluate()
    summary = {key: metrics[key] for key in metrics if key != "rows"}
    print(json.dumps(summary, indent=2))
    return 0


if __name__ == "__main__":
    sys.exit(main())
