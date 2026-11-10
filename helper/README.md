# Helper

Advisory how-to assistant for the sales guide, the support guide, and the L1 and L2 runbooks.

It retrieves one approved section or it refuses. It does not log into Salesforce, change data, assign permissions, edit configuration, deploy a release, or run a flow.

```
py -3 helper/ingest.py
py -3 helper/ask.py "How do I qualify a lead?"
py -3 -m unittest helper.tests.test_helper -v
```

The procedure text lives in `docs/user-guides/` and `docs/runbook/`. Design and evaluation notes are in `docs/ai_helper.md` and `docs/ai_helper_evaluation.md`.
