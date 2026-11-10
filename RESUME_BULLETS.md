# Resume Bullets

Short, medium, and long versions for five target roles. Every number comes from the repository or from its local evaluation.

> **Wording rule.** The metadata is complete as Salesforce DX source but **hasn't been deployed**, and the release process is **documented, not executed**.
>
> **Use:** *designed, built (as Salesforce DX metadata), implemented in source, authored, documented, traced, evaluated locally.*
>
> **Don't write:** *deployed, administered a production org, managed releases for, reduced X%, sandbox, Enterprise org, implemented Flosum,* or *set up a Lifecycle Center pipeline.*
>
> **If asked:** "Built for Developer Edition and complete in source. Connecting the two orgs and promoting the releases is the next step."

## Project header (use once per resume)

**Salesforce Org Operations & Release Management** · Personal project · Salesforce DX (API 68.0), Sales Cloud and Service Cloud administration, Flow, permission sets, reports and dashboards, Python · Developer Edition orgs

## Verified numbers you can use

| Metric | Value |
| --- | --- |
| Personas / requirements | 4 / 12 (traced to metadata, release package, and validation script) |
| Custom fields / standard value sets | 8 / 4 |
| Validation rules | 6 (36 documented pass/fail examples) |
| Record-triggered flows / flow tests | 4 (Draft, each with a fault path) / 7 |
| Profiles / permission sets / permission set groups | 4 (0 object permissions) / 7 / 4 |
| Reports / dashboards | 10 / 2 |
| Synthetic dataset | 66 rows. 4 hand-checked metrics (221,000 · 41.67% · 15 · 4) |
| Release packages | 2 (61 and 16 members) · 3 stages · 7 gates |
| Procedure sections (guides + runbooks) | 23 (L1: 7, L2: 6, guides: 10) |
| Assistant evaluation | 30 questions: 20/20 correct answers, 10/10 correct refusals, 0 hallucinations |
| Milestones | 6 |

---

## 1. Salesforce Administrator

**Short**
- Built a Sales Cloud and Service Cloud operating model in Salesforce DX: 8 custom fields, 6 validation rules, 4 record-triggered flows, 7 permission sets in 4 persona groups, and 10 reports with 2 dashboards, all traced to 12 requirements.

**Medium**
- Designed four personas and implemented least-privilege access in source: 4 minimum-access profiles with no object permissions, 7 permission sets, and 4 permission set groups. No permission set grants Modify All Data.
- Built 6 validation rules that enforce information at the right transition: qualified-only lead conversion (using `PRIORVALUE`), a positive amount on Closed Won, an escalation reason and user, return guidance, and resolution notes.
- Built 4 Draft record-triggered flows for lead routing, case queue routing, first-response stamping (before-save), and one-day scheduled escalation, each with fault paths and handled outcomes.

**Long**
- Translated 4 personas and 12 user stories into Salesforce DX metadata on standard objects: 4 standard value sets, 8 custom fields, 9 persona page layouts, and 3 Lightning record pages with Dynamic Forms visibility.
- Built least-privilege security as metadata: profiles carry only the app and layouts, while business access sits on 7 permission sets grouped into 1 permission set group per persona. A security matrix covers 24 object rows and 8 system permissions.
- Authored 6 validation rules, with 36 documented pass/fail test cases covering edge cases such as mobile-only phone numbers, zero and negative amounts, and returns from Escalated.
- Built 4 record-triggered flows with 7 flow tests. The escalation flow fills the reason and Escalated By before changing status so it satisfies its own validation rule, and notifies the Ops Admin through a custom notification.
- Built 10 reports (summary and matrix, user-scoped and organization-scoped, with summary and row-level formulas) and 2 dashboards running as the logged-in user. Validated expected values by hand against a 66-row synthetic dataset.
- Designed the environment around Developer Edition limits (no sandboxes, scratch-only source tracking, 2 CRM licenses, 0 Service Cloud licenses) and recorded every not-executed item.

## 2. Salesforce Functional Operations Analyst (Sales Cloud and Service Cloud)

**Short**
- Defined and built the sales pipeline and two-tier case management process for a Salesforce org: 12 traced requirements, stage and status contracts, L1 and L2 queues, escalation rules, and leadership reporting.

**Medium**
- Wrote 4 personas and 12 user stories with acceptance criteria, then traced each requirement to metadata, a release package, a validation script, and a report or dashboard.
- Designed the case lifecycle (New → Working ↔ Waiting on Customer → Escalated → Closed) with routing by priority and type to L1 or L2 queues, a one-day escalation for high-priority cases, and required reason, guidance, and resolution notes at each handoff.
- Built 10 leadership reports and 2 dashboards answering named questions, including pipeline by stage, conversion by source, backlog by status and priority, hours to first response, and escalations by priority.

**Long**
- Ran a requirements-first design: 4 personas with responsibilities, objects, reports, permissions, pain points, and success criteria, plus 12 user stories (10 High, 2 Medium) across pipeline, qualification, case management, escalation, reporting, and access control.
- Defined the process contract as standard value sets: a 6-stage opportunity path with probabilities, a 5-value lead status, a 5-value case status, and case types for routing.
- Designed lead qualification controls: email or phone required, conversion only from Qualified, and Product Interest-based routing to named owners.
- Designed two-tier support: queue routing on create, first-response time stamped once, automatic escalation after one day for High priority, and mandatory escalation reason, return guidance, and resolution notes.
- Specified leadership metrics with hand-checked expected values (221,000 open pipeline, 41.67% conversion, 15 open cases, 4 escalations, 3.00 hours average first response) and the viewer and date conditions under which they hold.
- Wrote persona test plans, including negative tests and a profile-only control user, sequenced for two CRM licenses.

## 3. Salesforce Release and Technical Operations

**Short**
- Documented a gated Salesforce release process for an environment without sandboxes: scratch org → UAT org → production stand-in, 7 recorded gates, 2 separable release packages, and a revert-plus-destructive rollback.

**Medium**
- Designed the promotion path (`wi/*` → `uat` → `main`) with git as the source of truth, deploying the same commit to each org because change sets can't connect two unrelated Developer Edition orgs.
- Split the release into Release 1 (operating process and access, 61 members) and Release 2 (reporting, 16 members), with a destructive-changes list scoped only to Release 2.
- Authored the release plan, checklists (pre-release, deployment, post-release, rollback, operator), changelog, and a tabletop rollback drill with triggers, steps, validation, risks, and metadata limits.

**Long**
- Designed release governance around Lifecycle Center and git (studied, not installed): one project, one pipeline, three stages, with any sandbox-dependent default stage removed. Documented a CLI fallback if Org B can't be attached as a UAT stage.
- Defined 7 promotion gates, ending with a written Ops Admin approval that records the commit SHA and date. Separated a failed promotion (a skipped gate) from a rollback (defined harm criteria).
- Built release manifests (61 + 16 members against a 77-member inventory) so reports and dashboards can be removed without touching fields, flows, or access.
- Wrote the Release 2 rollback as `git revert` plus `destructiveChanges.xml`, accepted on UAT before the production stand-in. Documented what metadata rollback can't undo: replaced standard value sets, stamped timestamps, and flow-assigned owners.
- Recorded an access assessment for Flosum (Not Executed) and kept it out of the pipeline. Validation scripts fail if the changelog claims an execution that didn't happen.
- Documented operator controls for Developer Edition: Dev Hub quotas (3 active, 6 per day), the 15,000-request API budget, login cadence to avoid deactivation, named users only, and no secrets in git.

## 4. Salesforce Business Analyst

**Short**
- Turned 4 personas and 12 user stories into a traced Salesforce design covering process contracts, validation rules, automation, access, and reporting, with documented test cases and expected metric values.

**Medium**
- Elicited and documented 4 personas (responsibilities, objects, reports, permissions, pain points, success criteria) and 12 user stories with acceptance criteria and priorities.
- Produced a traceability matrix linking every requirement to metadata, release package, validation script, flow, report, and dashboard.
- Wrote 36 validation-rule test cases, persona test plans with negative cases, and hand-counted dashboard expectations from a synthetic dataset.

**Long**
- Defined the business problem in operational terms (stage drift, unqualified conversions, reasonless escalations, lost return guidance, over-broad access, spreadsheet reporting) and mapped each one to a requirement.
- Wrote acceptance criteria that encode both the positive path and the restriction, such as "L1 cannot delete a case" and "Support Agent L1 is not a consumer of the all-team report."
- Built bi-directional traceability: requirement → metadata → release → validation script, and requirement → flow → report → dashboard.
- Designed test evidence ahead of the build: 3 pass and 3 fail cases per validation rule, per-persona test steps plus a profile-only control user, and flow outcome checks.
- Specified a 66-row synthetic dataset and its load order (qualified inserts, conversions without opportunity creation, flows kept Draft) so the dashboards have known expected values.
- Documented constraints and assumptions explicitly: Developer Edition license counts, storage, API limits, and an open question about the release tooling.

## 5. CRM Support Operations and Knowledge Management

**Short**
- Wrote Salesforce user guides and L1 and L2 runbooks (23 procedure sections) and built a retrieval assistant that answers only from approved pages. It scored 20/20 correct answers, 10/10 correct refusals, and 0 hallucinations.

**Medium**
- Authored persona guides (one task per page with steps, expected outcome, and troubleshooting) and runbooks (symptom, checks, resolution, escalation criteria) covering login, MFA, visibility, missing data, reports, dashboards, flows, validation rules, permissions, releases, data corrections, and reporting discrepancies.
- Built a standard-library Python assistant that returns a section verbatim with a citation only when exactly one section matches, and otherwise returns an approved refusal recommending escalation.
- Designed a 30-question evaluation (20 covered, 10 that must be refused) and 5 unit tests, including a check that the code can't call Salesforce.

**Long**
- Designed a tiered support model: persona guide → L1 runbook → L2 runbook → Ops Admin, with escalation criteria naming the next role and explicit prohibitions (no MFA bypass, no shared passwords, no Modify All Data, no deleting records to match a report).
- Wrote 23 procedure sections: 2 guides with 4 tasks and a quick reference each, 7 L1 entries, and 6 L2 entries. Each quotes the exact validation messages users see.
- Built a retrieval assistant (`ingest.py`, `ask.py`) that indexes only the approved guides and runbooks, enforces a `Keywords:` line per section, rejects duplicate IDs, and returns verbatim text or a refusal.
- Defined precise evaluation metrics (correct answers, citation accuracy, correct refusals, hallucinations). Achieved 20/20, 100%, 10/10, and 0 on a 30-question set, reproducible with a single command.
- Kept the assistant advisory: no write path, no Salesforce client, no HTTP or subprocess calls, verified by unit test, with an advisory banner on every reply.
- Documented a knowledge-maintenance process: each new answer is a new reviewed section plus an evaluation question, and the retriever itself never changes.

---

## Skills line (ATS)

Salesforce Administration, Sales Cloud, Service Cloud, Salesforce DX, SFDX, scratch orgs, Dev Hub, Lead Management, Opportunity Management, Case Management, Queues, Validation Rules, `PRIORVALUE`, Flow Builder, Record-Triggered Flows, Before-Save Flows, Scheduled Paths, Flow Tests, Custom Notifications, Profiles, Permission Sets, Permission Set Groups, Least Privilege, Lightning Record Pages, Dynamic Forms, Page Layouts, Reports (Summary, Matrix, Formulas), Dashboards, Standard Value Sets, Metadata API, `package.xml`, `destructiveChanges.xml`, Release Management, UAT, Rollback, Lifecycle Center (studied), Git, Runbooks, Knowledge Management, Requirements Traceability, User Stories, Python, Retrieval-Based AI Assistant
