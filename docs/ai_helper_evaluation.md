# AI helper evaluation

The evaluation set has 30 questions in `helper/eval/questions.json`. Twenty are covered by one procedure section. Ten are outside the guides and runbooks. `helper/eval/run_eval.py` scores a fresh retrieval. No org is contacted.

## Measures

| Measure | Meaning |
| --- | --- |
| Correct answers | A covered question returns the expected section and does not refuse |
| Citation accuracy | Every emitted citation id exists in the ingested index |
| Correct refusals | An uncovered question returns the approved refusal and no citation |
| Hallucinations | A reply whose answer text is not the cited section body, or a refusal that adds extra text or a citation |

A correct covered answer is also a correct citation, because the only citation is the expected id and that id was loaded from the documents.

## Result

Ran with `py -3 -m unittest helper.tests.test_helper` and `helper/eval/run_eval.py` on 10 November 2026.

| Measure | Result |
| --- | --- |
| Questions | 30 |
| Covered | 20 |
| Uncovered | 10 |
| Correct answers | 20 of 20 |
| Correct citations | 20 of 20 |
| Citation accuracy | 100 percent |
| Correct refusals | 10 of 10 |
| Hallucinations | 0 |

The ten refusals ask about card data, Flosum, a shared password, mass delete, Einstein scoring, the fiscal year, duplicate merge, a marketing blast, disabling MFA, and a sandbox. None of those procedures exist in the guides or runbooks.

The twenty covered questions use the keyword phrase of the target section. A question that only shares a loose word with a page is supposed to refuse. That keeps the assistant from guessing.

## Limits of this score

The score shows that the retriever returns the written page, or refuses. It does not show that a person completed the click path in an org. Nothing in this evaluation deployed metadata or changed a record.
