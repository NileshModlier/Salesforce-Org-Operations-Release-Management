# Lessons Learned

**Salesforce Org Operations & Release Management** · version 1.0 · 10 November 2026

These lessons come from designing and documenting the project across six milestones. They're about how decisions held up as the design developed, not about live-org incidents. Nothing has been deployed yet.

---

## Summary

| # | Theme | Lesson in one line |
| --- | --- | --- |
| 1 | Edition constraints | Write the limits down first. They decide the architecture |
| 2 | Process contract | Value sets are the contract. Custom fields only where a story has nowhere to store data |
| 3 | Validation rules | Require information at the transition, not on the field |
| 4 | Validation rules | `PRIORVALUE` is how you validate a transition someone else writes |
| 5 | Flows | A missing dependency is an outcome, not a fault |
| 6 | Flows | Automation must satisfy your own rules, so fill before you flip |
| 7 | Flows | Ship Draft. Activation is a separate decision |
| 8 | Security | Profiles for the page, permission sets for the job |
| 9 | Security | Four grants that people confuse for one |
| 10 | Security | Least privilege is provable only with negative tests |
| 11 | Reporting | Scope, sharing, and date decide the number before the formula does |
| 12 | Reporting | A dashboard needs a known answer before it has a real one |
| 13 | Release governance | Every hop deploys the same commit |
| 14 | Release governance | A skipped gate is a failed promotion, not a rollback |
| 15 | Metadata vs data recovery | A deploy is an upsert, and rollback can't restore what was never retrieved |
| 16 | Tool access | A trial page, a demo, or a screenshot isn't access |
| 17 | Runbooks | One symptom per entry, and escalation criteria that name a person |
| 18 | AI knowledge systems | Refusal is a feature. Measure it |
| 19 | AI knowledge systems | The corpus boundary is a safety boundary |
| 20 | Evidence | "Not executed" is a state worth recording, and worth testing |

---

## Salesforce administration

### 1. Write the edition limits down first

**What happened.** M1 recorded the Developer Edition facts before any metadata existed:
- no sandboxes
- source tracking only in scratch orgs
- 3 active and 6 daily scratch orgs
- 2 CRM licenses, 3 Platform licenses, and 0 Service Cloud user licenses
- 5 MB of data storage and 15,000 API calls a day

**Why it mattered.** Those facts shaped everything that followed:
- Development moved to scratch orgs.
- UAT became a second org that receives deploys.
- Change sets were ruled out.
- Case management stayed on standard Case.
- Persona testing had to be sequential.

**Do next time.** Start every Salesforce engagement with a one-page "claims boundary" table covering edition, orgs, sandboxes, licenses, and tools, and confirm it on Company Information.

### 2. Treat value sets as the process contract

**What happened.** Lead Status, Opportunity Stage, Case Status, and Case Type became standard value sets taken directly from the requirements. Only eight custom fields were added, each answering a story that had nowhere else to store its data.

**Why it mattered.** A single stage list ends arguments about meaning in pipeline reviews, and a small field footprint keeps layouts, reports, and permissions manageable.

**Watch out.** A standard value set deploy *replaces* the target org's values. On an org with live records on other values it can fail. The rollback drill can't restore the old list, because it was never retrieved. Retrieve before you replace.

---

## Validation rules

### 3. Require information at the transition, not on the field

**What happened.** Escalation reason, return guidance, and resolution notes are all optional fields. Rules require them only when the status makes them necessary: Escalated, a return from Escalated, or Closed.

**Why it mattered.** Field-level "required" would block legitimate early saves, such as a new case that hasn't been escalated. Conditional rules keep the normal path open and close only the path that loses information.

### 4. Use `PRIORVALUE` to validate transitions that someone else writes

**What happened.** The first instinct for "only convert Qualified leads" is to check `Status = Qualified`. But the convert action writes Closed - Converted, so that rule would block every conversion. The correct rule checks `IsConverted` and `PRIORVALUE(Status)`.

**Generalisation.** When the platform or automation writes the new value, validate the *before* state. The same pattern makes the return-guidance rule fire only on a genuine return from Escalated.

---

## Flows

### 5. A missing dependency is an outcome, not a fault

**What happened.** Each flow distinguishes **handled outcomes** (`OwnerNotFound`, `QueueNotFound`, `NoOpsAdmin`, `NotDue`, `Skipped`) from **faults**, and every element has a Capture Fault path.

**Why it mattered.** Placeholder owners, queues, and an Ops Admin persona won't all exist on day one in a new org. A flow that leaves the record unchanged and reports why is far easier to support than one that throws an error or writes an invalid owner ID. The L2 runbook entry *Flow Faults* builds on exactly this distinction.

### 6. Make automation satisfy your own validation rules

**What happened.** The Escalation flow would trip `Case_Escalation_Requires_Reason` if it set the status to Escalated without a reason and a user. The fix was to fill both in the same update: the existing values, or a standard reason plus the Ops Admin.

**Generalisation.** Validation rules apply to flow updates and data loads too. Design automation and load order to arrive in a valid state, rather than adding bypass flags that become permanent holes.

### 7. Ship flows as Draft and activate through a work item

**What happened.** All four flows deploy as Draft. The synthetic load plan depends on that: active assignment flows would overwrite loaded owners, and First Response Tracking would re-stamp times.

**Why it mattered.** Activation is a behavioural change for every user and every load. Keeping it separate from deployment makes both reversible and reviewable.

**Gap acknowledged.** The flow test for Escalation covers only the immediate path, not the scheduled path. That has to be verified in UAT before activation, and the rollback drill notes it.

---

## Security

### 8. Profiles for the page, permission sets for the job

**What happened.** The four profiles have zero object permissions and carry only the app and layouts. Access lives on permission sets, assigned through one group per persona.

**Proof point.** In M4, adding reporting access meant adding a reporting set to three groups. No profile clones, no layout reassignment, and no second assignment for users who already held the group.

### 9. Four different grants get mistaken for one

**What happened.** Four separate mechanisms ended up governing what someone sees and does:

| Grant | Decides |
| --- | --- |
| Profile | App and page layout |
| Permission set group | Object, field, and system access |
| Public group (`Support_L1`, `Support_L2`) | Queue membership |
| `User.Persona__c` | Which Lightning guidance shows. Grants nothing |

**Why it mattered.** "I can't see my queue" is usually the public group, not the permission set. "I set my persona, why can't I edit?" is because a label isn't access. The runbooks repeat this distinction because support tickets confuse the four.

### 10. Least privilege is provable only with negative tests

**What happened.** The persona tests specify what each persona must *not* be able to do, and include a profile-only control user. The validation scripts fail if any permission set grants Modify All Data, if Sales Rep gains Case access, or if L1 gets a reporting set.

**Generalisation.** A permission model is a set of refusals. Test the refusals.

---

## Reporting

### 11. Scope, sharing, and date decide the number before the formula does

**What happened.** The same synthetic data produces different "correct" numbers:
- Ops Admin's full-book view shows 221,000 of open pipeline.
- Rep A sees 165,000 and Rep B sees 56,000.
- Pipeline By Stage is scoped to the running user, so even Ops Admin sees only their own rows.
- Closing This Month only returns 11 deals worth 212,000 when it runs in November 2026.

**Why it mattered.** Most "the dashboard is wrong" tickets are about the viewer, the load, or the month. The L2 runbook checks those three before anyone touches a formula.

### 12. A dashboard needs a known answer before it has a real one

**What happened.** Without a rendered org, the two dashboards were validated against hand counts from a 66-row synthetic file: 221,000, 41.67%, 15, and 4. The dashboard value is recorded as **Not observed**. A validation script fails if the data files drift from those counts.

**Do next time.** Ship every dashboard with its expected values and the exact conditions for them: viewer access, completed load, and date.

---

## Release governance

### 13. Every hop deploys the same commit

**What happened.** Without sandboxes or change sets, the only trustworthy promotion is deploying one git revision to Org B and then to Org A. Gate 3 states it outright: Org B has the same commit Org A will receive.

**Why it mattered.** Promotion that copies org to org loses the audit trail. Git plus a commit SHA in the approval keeps it.

### 14. A skipped gate is a failed promotion, not a rollback

**What happened.** The governance rules separate the two. A missed check stops the next stage and gets fixed. A rollback starts only from defined criteria: a wrongly blocking rule, an active flow that should be Draft, an access leak, dashboard errors, or unintended picklist replacement.

**Why it mattered.** Treating every miss as a rollback creates churn. Treating rollbacks as "just re-run it" hides real damage.

---

## Metadata vs data recovery

### 15. A metadata deploy is an upsert, and rollback has hard limits

**What happened.** The Release 2 rollback drill made the limits explicit:
- Reverting git changes the repository, not the org. The org changes only when a deploy runs.
- Redeploying the old tree doesn't delete the components a bad release added. Removal needs `destructiveChanges.xml`, rehearsed on Org B first.
- Metadata rollback doesn't restore data. Stamped First Response values stay, owners set by an activated flow stay, and loaded synthetic rows stay.
- Standard value sets replaced in Release 1 can't be rolled back, because the earlier values were never retrieved.
- Scratch orgs expire. A rollback that depends on a deleted scratch org has to be rebuilt from git.

**Generalisation.** Plan metadata rollback and data recovery as two different procedures, and state in the runbook which one you're doing.

---

## Tool access

### 16. A trial page, a demo, or a screenshot isn't access

**What happened.** Flosum was assessed and recorded as **Not Executed** across trial, demo, product access, and install. Lifecycle Center was **studied** and the process was documented for it, but it wasn't installed. The governance doc forbids describing a Flosum pipeline while access is Not Executed, and a validation script fails if that status changes.

**Why it mattered.** Credibility in a portfolio depends on the line between *studied* and *used*. Keeping the label in the source, and testing it, stops gradual overclaiming.

---

## Runbooks

### 17. One symptom per entry, and escalation criteria that name a person

**What happened.** Every runbook entry follows Symptom → Checks → Resolution → Escalation Criteria. Every guide task follows Steps → Expected outcome → Troubleshooting. Each entry's escalation criteria name the next role: Support Lead L2 or Ops Admin. Each resolution includes explicit "don't" lines: don't disable MFA, don't share a password, don't grant Modify All Data, don't delete rows to match a report.

**Why it mattered.** Responders under pressure take the fastest workaround unless the page rules it out. A consistent structure also let the assistant's tests check every section for completeness.

---

## AI knowledge systems

### 18. Refusal is a feature, so measure it

**What happened.** The assistant answers only when exactly one approved section matches, and returns that text verbatim. The evaluation counts **correct refusals** as a primary metric, with 10 deliberately uncovered questions alongside 20 covered ones. Results: 20/20 correct answers, 10/10 correct refusals, 0 hallucinations.

**Trade-off accepted.** Paraphrased questions that miss a keyword phrase are refused. The remedy is content work: add a phrase or a section and extend the evaluation. It is never a looser matcher.

### 19. The corpus boundary is a safety boundary

**What happened.** The assistant reads only the user guides and runbooks, not design notes, release plans, or the rest of the repository. A fact that lives only in a design note is deliberately not an answer.

**Why it mattered.** Approved procedures are written for users. Design notes are written for builders. Mixing them would let the assistant quote internal reasoning as instructions. The assistant also has no tools to act. It's advisory, and a unit test asserts there's no deploy, HTTP, or subprocess call.

---

## Evidence discipline

### 20. "Not executed" is a state worth recording, and worth testing

**What happened.** Every milestone ends with a not-executed list:
- no org connected
- flows Draft
- dashboards not rendered
- data not loaded
- no deploy IDs
- rollback was a tabletop

The changelog records Release 1 and Release 2 as *Not executed*, with rollback *Not required*. `validate-m5.ps1` fails if a changelog entry claims an execution that didn't happen.

**Why it mattered.** Reviewers trust the rest of the work because the gaps are explicit, specific, and checked by a script.

---

## What I'd change next time

1. **Retrieve before replacing.** Pull the target org's standard value sets before the first deploy, so a rollback can restore them.
2. **Test the scheduled path.** Add a UAT procedure for the Escalation scheduled path before activation, since flow tests cover only the immediate path.
3. **Add a cross-platform validator.** The validation scripts are Windows PowerShell. A small Python or PowerShell 7 runner would let them run in CI on Linux.
4. **Keep the README status in sync.** The repository README listed M6 as "Current" while the completion report recorded v1.0 as complete. A single status table referenced from both would avoid that drift.
5. **Track a fifth metric.** Record the average first-response figure (3.00 hours) as a formal dashboard check alongside the other four.
