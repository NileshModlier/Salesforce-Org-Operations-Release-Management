# Summary for Hiring Managers

**Salesforce Org Operations & Release Management**: a functional operations and release-governance portfolio built for Developer Edition.

---

## The short version

I designed and built, as Salesforce DX source, the operating model for a small sales and support org. It has four personas and twelve traced requirements, implemented as 8 fields, 6 validation rules, 4 Draft flows, 7 permission sets in 4 groups, and 10 reports with 2 dashboards. Around that I documented a gated release process that works without sandboxes, and wrote L1 and L2 runbooks behind a retrieval assistant that answers verbatim or refuses.

**Nothing is deployed yet.** Org A and Org B aren't connected, the flows are Draft, and the dashboards haven't been rendered. Every document labels each item as Implemented, Documented, or Studied, and the validation scripts fail if the release log claims an execution that didn't happen.

## What it shows about how I work

| Signal | Evidence in the repository |
| --- | --- |
| **Requirements before configuration** | 12 stories with acceptance criteria, each traced to metadata → release package → validation script → report and dashboard |
| **Least privilege by construction** | Profiles have 0 object permissions. Access lives on permission sets in one group per persona. No permission set grants Modify All Data. A script fails if any does |
| **Data quality at the right moment** | Fields stay optional. Rules fire on the transition. `PRIORVALUE` is used where the platform writes the new value (lead conversion, return from Escalated) |
| **Defensive automation** | Every flow has a fault path. Missing owners, queues, or admins are handled outcomes that leave the record unchanged. Flows ship Draft, and activation is its own work item |
| **Operational realism** | Designed around Developer Edition facts: no sandboxes, scratch-only source tracking, 2 CRM licenses, 0 Service Cloud licenses, 15,000 API calls a day |
| **Release discipline** | Three stages, seven gates, written approval with the commit SHA, two separable packages, and rollback as `git revert` plus a destructive list accepted on UAT first |
| **Support empathy** | One task per page. Exact validation messages quoted. Runbook entries with explicit "don't" lines and named escalation targets |
| **Safe AI** | Retrieval-only assistant with a hard refusal and no write path. Measured on refusals as well as answers |
| **Honesty about evidence** | Not-executed lists in every milestone. Flosum recorded as Not Executed. Lifecycle Center studied, not used |

## Technical highlights

1. **Escalation flow that respects its own rules.** It escalates aged high-priority cases on a one-day scheduled path, but fills the escalation reason and Escalated By *before* setting Escalated, so `Case_Escalation_Requires_Reason` doesn't block its own update. A missing queue or Ops Admin returns `QueueNotFound` or `NoOpsAdmin` and changes nothing.
2. **Four separate grants, explained separately.** Profile (app and layouts), permission set group (access), public group (queue membership), and `User.Persona__c` (Lightning visibility only). Tickets usually mix these up, and the runbooks separate them.
3. **Reports tied to questions.** Pipeline By Stage is scoped to the running user (REQ-009). Cases By Status is a status × priority matrix (REQ-010). Run Reports comes from reporting sets that L1 deliberately doesn't get.
4. **Dashboards with known answers.** Hand-counted from a 66-row synthetic set: 221,000 open pipeline, 41.67% conversion, 15 open cases, 4 escalations. Recorded as *Not observed* until rendered. A script fails if the data drifts.
5. **Rollback that admits its limits.** Metadata deploy is an upsert. Removal needs `destructiveChanges.xml`, Org B first. The drill states what can't be undone: standard value sets never retrieved, stamped timestamps, and flow-set owners.
6. **Measured knowledge assistant.** 23 sections, 30-question evaluation, 20/20 correct answers, 10/10 correct refusals, 0 hallucinations. A unit test asserts there's no deploy, HTTP, or subprocess call in the code.

## Trade-offs I made deliberately

| Decision | Trade-off accepted |
| --- | --- |
| Org A is the production stand-in *and* Dev Hub *and* Lifecycle Center hub | Two orgs suffice. Release and scratch administration share one org |
| Org B as UAT through explicit deploys | No refresh. Lifecycle Center stage attachment is an open check, with a CLI fallback documented |
| Flows ship Draft | Safe loads and reviewable activation. No routing until a release activates it |
| Public, read-only report folders | No user IDs in folder shares. Any future Run Reports holder can see them |
| Retrieval with hard refusal | No invented procedures. Paraphrased questions can miss |
| Standard Case only | Stays inside 0 Service Cloud licenses. No Entitlements or Omni-Channel |

## Gaps I know about

- **No live execution.** No deploy IDs, no flow-test runs, no persona tests, no rendered dashboards, no loaded data.
- **Escalation scheduled path** isn't covered by a flow test. It needs UAT verification before activation.
- **Standard value sets** replace target values, and the earlier values aren't retrieved, so a Release 1 rollback can't restore them.
- **Intended org-wide defaults** are documented but not in source.
- **Validation scripts are Windows PowerShell.** The repository records PASS for m1–m5 (85, 140, 83, 80, and 72 checks). The m6 count isn't recorded.

## How to evaluate it in 15 minutes

```powershell
# 1. Assistant: run, refuse, score (≈2 min)
py -3 helper/ask.py "How do I qualify a lead?"
py -3 helper/ask.py "How do I create a full-copy sandbox from Org A?"
py -3 helper/eval/run_eval.py
py -3 -m unittest helper.tests.test_helper -v

# 2. Repository validation (≈2 min, Windows PowerShell)
powershell -NoProfile -ExecutionPolicy Bypass -File tests/validate-m3.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tests/validate-m5.ps1
```

Then read, in order:

1. `docs/requirements.md` (Coverage)
2. `force-app/main/default/flows/Escalation.flow-meta.xml` with `docs/flows.md`
3. `docs/security-matrix.xlsx`
4. `release/release-plan.md`
5. `release/rollback-drill.md`

Interview prompts are in [INTERVIEW_GUIDE.md](INTERVIEW_GUIDE.md), and a 5-minute walkthrough is in [DEMO_SCRIPT.md](DEMO_SCRIPT.md).

## Suitable for

Salesforce Administrator · Salesforce Functional Operations · Salesforce Business Analyst · Salesforce Release or Technical Operations · CRM Support Operations and Knowledge Management
