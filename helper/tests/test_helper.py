"""Section parsing, citation checks, retrieval, refusal, and eval coverage."""

from __future__ import annotations

import sys
import unittest
from pathlib import Path

HELPER_DIR = Path(__file__).resolve().parents[1]
if str(HELPER_DIR) not in sys.path:
    sys.path.insert(0, str(HELPER_DIR))

import ask
import ingest
from eval.run_eval import evaluate, load_questions

REQUIRED_IDS = [
    "SalesRep:Lead Qualification",
    "SalesRep:Update the Pipeline",
    "SalesRep:Close an Opportunity",
    "SalesRep:Run My Pipeline Report",
    "SalesRep:Quick Reference",
    "SupportAgent:Create a Case",
    "SupportAgent:Record the First Response",
    "SupportAgent:Escalate a Case",
    "SupportAgent:Working Limits",
    "SupportAgent:Quick Reference",
    "L1:Login Problems",
    "L1:MFA Problems",
    "L1:Record Visibility",
    "L1:Missing Data",
    "L1:Report Access",
    "L1:Dashboard Access",
    "L1:Case Reassignment",
    "L2:Flow Faults",
    "L2:Validation Rule Issues",
    "L2:Permission Set Problems",
    "L2:Release Failures",
    "L2:Data Corrections",
    "L2:Reporting Discrepancies",
]

RUNBOOK_LABELS = ("### Symptom", "### Checks", "### Resolution", "### Escalation Criteria")
GUIDE_LABELS = ("### Steps", "### Expected outcome", "### Troubleshooting")


class HelperTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.index = ingest.build_index()
        cls.by_id = {section["id"]: section for section in cls.index["sections"]}

    def test_section_parsing(self):
        self.assertEqual(list(self.by_id), sorted(REQUIRED_IDS))
        for section in self.index["sections"]:
            self.assertTrue(section["keywords"])
            self.assertTrue(section["body"])
            self.assertIn(section["source"], (
                "docs/user-guides/sales-rep.md",
                "docs/user-guides/support-agent.md",
                "docs/runbook/L1.md",
                "docs/runbook/L2.md",
            ))
        for section_id, section in self.by_id.items():
            if section_id.startswith("L1:") or section_id.startswith("L2:"):
                for label in RUNBOOK_LABELS:
                    self.assertIn(label, section["body"], section_id)
            elif not section_id.endswith("Quick Reference"):
                for label in GUIDE_LABELS:
                    self.assertIn(label, section["body"], section_id)

    def test_citation_existence_and_retrieval_accuracy(self):
        for item in load_questions():
            if not item["covered"]:
                continue
            result = ask.retrieve(item["question"], self.index)
            self.assertFalse(result["refused"], item["id"])
            self.assertEqual(result["citations"], [item["expected_id"]], item["id"])
            self.assertIn(result["citations"][0], self.by_id)
            self.assertEqual(result["answer"], self.by_id[item["expected_id"]]["body"])

    def test_refusal_logic(self):
        for item in load_questions():
            if item["covered"]:
                continue
            result = ask.retrieve(item["question"], self.index)
            self.assertTrue(result["refused"], item["id"])
            self.assertEqual(result["answer"], ask.REFUSAL)
            self.assertEqual(result["citations"], [])
            self.assertIn("This runbook does not contain\nan approved answer.", result["answer"])
            self.assertIn("Recommend escalation.", result["answer"])
        blank = ask.retrieve("   ", self.index)
        self.assertTrue(blank["refused"])
        ambiguous = ask.retrieve("qualify a lead and a flow fault", self.index)
        self.assertTrue(ambiguous["refused"])

    def test_evaluation_coverage(self):
        questions = load_questions()
        self.assertEqual(len(questions), 30)
        self.assertEqual(sum(1 for item in questions if item["covered"]), 20)
        self.assertEqual(sum(1 for item in questions if not item["covered"]), 10)
        metrics = evaluate()
        self.assertEqual(metrics["question_count"], 30)
        self.assertEqual(metrics["covered"], 20)
        self.assertEqual(metrics["uncovered"], 10)
        self.assertEqual(metrics["correct_answers"], 20)
        self.assertEqual(metrics["correct_citations"], 20)
        self.assertEqual(metrics["citation_accuracy"], 1.0)
        self.assertEqual(metrics["correct_refusals"], 10)
        self.assertEqual(metrics["hallucinations"], 0)

    def test_helper_does_not_call_salesforce(self):
        for name in ("ask.py", "ingest.py"):
            text = (HELPER_DIR / name).read_text(encoding="utf-8").lower()
            for banned in ("subprocess", "simple_salesforce", "sf project deploy", "requests."):
                self.assertNotIn(banned, text, name)


if __name__ == "__main__":
    unittest.main()
