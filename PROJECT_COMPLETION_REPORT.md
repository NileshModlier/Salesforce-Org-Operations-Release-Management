# Project Completion Report

| | |
|---|---|
| **Project** | Salesforce Org Operations & Release Management |
| **Version** | 1.0 |
| **Report date** | 10 November 2026 |
| **Author** | Nilesh P Raghavan |
| **Completion status** | **Complete as a source portfolio.** Milestones M1–M6 delivered. No org connected, nothing deployed |
| **Environment class** | Salesforce Developer Edition (two orgs plus scratch orgs). No sandbox, no Enterprise org, no customer production org |

---

## 1. Executive summary

The project set out to show how a Salesforce operations admin runs a small sales and support process across more than one org, with git as the source of truth, using only what Developer Edition provides.

All six milestones are delivered:

- Four personas and twelve requirements are traced to Salesforce DX metadata, which covers 8 custom fields, 6 validation rules, 4 Draft flows, 7 permission sets, 4 permission set groups, 10 reports, and 2 dashboards.
- A full release-governance process is documented for Lifecycle Center and git.
- A support layer of two guides, two runbooks, and 23 procedure sections is fronted by a retrieval assistant. Its local evaluation scored **20/20 correct answers, 10/10 correct refusals, and 0 hallucinations**.

The work is **implemented in source** and **documented**. It has **not been executed** against any org. The Salesforce CLI wasn't installed in the build workspace, and Org A and Org B were never connected. That boundary is recorded in every milestone and enforced by the validation scripts.

## 2. Objectives and outcome

| # | Objective | Outcome | Evidence label |
| --- | --- | --- | --- |
| O1 | Define who does what, and the access and process contracts | 4 personas, 12 stories with acceptance criteria | Implemented (documents) |
| O2 | Configure the process on standard objects | 4 value sets, 8 fields, 6 rules, 9 layouts, 3 record pages | Implemented (source) |
| O3 | Automate routing, timing, and escalation safely | 4 Draft flows with fault paths, 7 flow tests, 2 queues, 1 notification type | Implemented (source) |
| O4 | Enforce least-privilege persona access | 4 zero-object-permission profiles, 7 permission sets, 4 groups, security matrix | Implemented (source) |
| O5 | Give leadership requirement-driven reporting | 10 reports, 2 dashboards, synthetic dataset, 4 hand-checked metrics | Implemented (source). Values not observed |
| O6 | Define a release path that fits Developer Edition | Path B, 3 stages, 7 gates, 2 manifests, destructive list, tabletop rollback | Documented |
| O7 | Support users without inventing procedures | 2 guides, L1 (7) and L2 (6) runbooks, retrieval assistant, 30-question evaluation | Implemented and evaluated locally |
| O8 | Assess release tooling honestly | Lifecycle Center notes. Flosum access assessment (Not Executed) | Studied |

## 3. Scope delivered by milestone

| Milestone | Deliverables | Key files | Status |
| --- | --- | --- | --- |
| **M1** Foundation | Personas, requirements, environment strategy, Flosum access assessment, Lifecycle Center notes, DX layout, org registry | `docs/personas.md`, `docs/requirements.md`, `docs/environment_strategy.md`, `docs/flosum_access.md`, `docs/lifecycle_center_notes.md`, `org-ops/README.md` | Complete |
| **M2** Configuration | 8 fields, 4 standard value sets, 6 validation rules (36 manual examples), 9 layouts, 3 Lightning record pages, traceability | `force-app/.../objects/`, `layouts/`, `flexipages/`, `standardValueSets/`, `docs/validation_rules.md`, `docs/test-cases.md` | Complete in source |
| **M3** Automation and security | 4 Draft flows, 7 flow tests, 2 queues, 2 public groups, 1 notification type, 4 profiles, 4 persona permission sets, 4 groups, security matrix, persona test plan | `flows/`, `flowtests/`, `queues/`, `profiles/`, `permissionsets/`, `permissionsetgroups/`, `docs/security-matrix.xlsx`, `docs/persona_testing.md` | Complete in source |
| **M4** Reporting | 10 reports, 2 dashboards, 3 reporting permission sets, synthetic data, metric validation | `reports/`, `dashboards/`, `data/synthetic/`, `docs/reports.md`, `docs/dashboards.md`, `docs/metric_validation.md` | Complete in source |
| **M5** Release governance | Release plan, governance rules, checklists, changelog, 2 release manifests, destructive list, rollback drill | `release/`, `docs/release_management.md`, `docs/release_governance.md` | Documented. Not executed |
| **M6** User support | Sales Rep and Support Agent guides, L1 and L2 runbooks, retrieval assistant, evaluation, completion notes | `docs/user-guides/`, `docs/runbook/`, `helper/`, `docs/ai_helper*.md` | Complete. Evaluated locally |

## 4. Requirement acceptance status

"Implemented" means the metadata that satisfies the story is in source. Acceptance in an org (UAT) hasn't been run for any story.

| Req | Story (short) | Implemented by | Status |
| --- | --- | --- | --- |
| REQ-001 | Rep sees owned opportunities with stage, amount, close date | Stage value set, `Next_Step__c`, layouts, Pipeline By Stage (user scope) | Implemented in source · UAT not run |
| REQ-002 | One stage path. Closed Won and Lost the only terminal stages | `OpportunityStage`, Closed Won amount rule | Implemented in source · UAT not run |
| REQ-003 | Qualify before conversion | `LeadStatus`, Product Interest, email-or-phone rule, convert rule | Implemented in source · UAT not run |
| REQ-004 | Conversion creates account, contact, opportunity | Standard convert action + convert rule. No custom mapping | Implemented in source · UAT not run |
| REQ-005 | L1 opens a case with owner, status, priority | `CaseStatus` (New default), L1 layout, Case record page, Case Assignment (Draft) | Implemented in source · UAT not run |
| REQ-006 | L1 works statuses and records history | `First_Response_At__c`, First Response Tracking (Draft) | Implemented in source · UAT not run |
| REQ-007 | Escalation with reason, L2 queue, escalating user | Reason and Escalated By fields, escalation rule, Escalation flow (Draft), L2 queue | Implemented in source · UAT not run |
| REQ-008 | L2 takes, resolves, or returns with guidance | Return and close rules, guidance and resolution fields, L2 layout | Implemented in source. **Taking ownership from a queue isn't separately configured** (noted in traceability) · UAT not run |
| REQ-009 | Rep pipeline report by stage | Pipeline By Stage, Sales Dashboard, `Reporting_Sales` | Implemented in source · not rendered |
| REQ-010 | L2 backlog by status, priority, owner. L1 excluded | Cases By Status (matrix), Support Dashboard, `Reporting_Support`. L1 has no reporting set | Implemented in source · not rendered |
| REQ-011 | Persona access limited to the job | 4 profiles (0 object permissions), 4 persona sets, 4 groups | Implemented in source · persona tests not run |
| REQ-012 | Setup and user admin limited to Ops Admin | `Ops_Admin` set (Manage Users, Customize Application, no Modify All Data), Persona field | Implemented in source · persona tests not run |

**Summary:** 12 of 12 requirements implemented in source and traced. 0 of 12 accepted in an org.

## 5. Deliverables inventory

| Category | Count |
| --- | ---: |
| Personas | 4 |
| Requirements | 12 (10 High, 2 Medium) |
| Custom fields | 8 |
| Standard value sets | 4 |
| Validation rules | 6 |
| Validation-rule manual examples | 36 |
| Page layouts | 9 |
| Lightning record pages | 3 |
| Record-triggered flows (Draft) | 4 |
| Flow tests | 7 |
| Queues / public groups | 2 / 2 |
| Custom notification types | 1 |
| Profiles (0 object permissions) | 4 |
| Permission sets | 7 |
| Permission set groups | 4 |
| Reports / dashboards | 10 / 2 |
| Synthetic data rows | 66 (2 accounts, 2 contacts, 24 leads, 18 opportunities, 20 cases) |
| Release packages | 2 (61 and 16 members). Full inventory 77 |
| Procedure sections (guides + runbooks) | 23 |
| Assistant evaluation questions | 30 (20 covered, 10 uncovered) |
| Markdown documents under `docs/` | 25, plus the security matrix workbook |
| Validation scripts | 6 (PowerShell) |

## 6. Quality and validation results

### 6.1 Recorded results (repository, 10 November 2026)

| Check | Result |
| --- | --- |
| `validate-m1.ps1` | PASS · 85 checks |
| `validate-m2.ps1` | PASS · 140 checks |
| `validate-m3.ps1` | PASS · 83 checks |
| `validate-m4.ps1` | PASS · 80 checks |
| `validate-m5.ps1` | PASS · 72 checks |
| `validate-m6.ps1` | Script present. Pass count not recorded in `project_completion.md` |
| `helper.tests.test_helper` | PASS · 5 tests |
| Assistant evaluation | 20/20 correct answers · 20/20 correct citations · 100% citation accuracy · 10/10 correct refusals · 0 hallucinations |

### 6.2 Independent re-check while preparing this report

| Check | Result |
| --- | --- |
| Metadata counts (fields, rules, flows, flow tests, permission sets, groups, profiles, reports, dashboards, layouts, record pages, queues) | Match the figures above |
| Flow status | All 4 `<status>Draft</status>`. Fault connectors present in each |
| Modify All Data | Not present in any permission set |
| Profile object permissions | 0 in each of the 4 profiles |
| Synthetic data metrics | Recomputed: 221,000 open across 13 · 41.67% · 15 open (7/4/4) · 4 escalated (2/1/1) · 11 deals and 212,000 closing November 2026 |
| Assistant unit tests | 5/5 pass (re-run on a copy of the repository) |
| Assistant evaluation | Reproduced exactly: 30 · 20 · 10 · 20 · 20 · 1.0 · 10 · 0 |
| PowerShell validation scripts | **Not re-run.** PowerShell wasn't available in the review environment |

### 6.3 What the results prove

They prove internal consistency and completeness of the source:

- The counts haven't drifted.
- The flows are Draft with fault paths.
- No grant is too broad.
- L1 has no reporting set.
- The release packages are correctly scoped.
- The changelog doesn't overclaim.
- The assistant retrieves or refuses as designed.

They **don't** prove deployability or runtime behaviour.

## 7. Not executed

| Item | State |
| --- | --- |
| Org A, Org B connection | Not connected. Salesforce CLI not installed in the workspace |
| Dev Hub | Not enabled |
| Scratch org | Not created |
| Lifecycle Center | Not installed or configured. Org B stage attachment not tested |
| Flosum | Not Executed (trial, demo, access, install) |
| Metadata deploy | Not run for any package |
| Flow activation and flow tests | Flows Draft. Tests not run |
| Validation-rule examples and persona tests | Documented. Not run |
| Synthetic data load | Not loaded |
| Dashboards | Not rendered. Values "Not observed" |
| Release 1 and Release 2 | Outcome *Not executed*. Rollback status *Not required* |
| Rollback drill | Tabletop only |
| Git remote | Not configured |

## 8. Deviations and known issues

| # | Issue | Impact | Recommended action |
| --- | --- | --- | --- |
| K1 | The repository README's roadmap table lists M6 as "Current", while `project_completion.md` records v1.0 as complete | Status reads inconsistently | Use the updated README in this documentation set |
| K2 | No validate-m6 pass count recorded | Incomplete validation record | Run and record it (Roadmap 2.7) |
| K3 | Validation scripts are Windows PowerShell only | Can't run on a Linux CI runner as written | Port them or add a runner (Roadmap 2.5) |
| K4 | The Escalation scheduled path has no flow test | Timing behaviour unverified | UAT procedure before activation (Roadmap 2.2) |
| K5 | Standard value sets replace target values, and the prior values aren't retrieved | A Release 1 rollback can't restore picklists | Retrieve before the first deploy (Roadmap 2.1) |
| K6 | Intended org-wide defaults are documented but not in source | Record visibility depends on the target org's current settings | Deploy through a work item (Roadmap 2.4) |
| K7 | REQ-008 queue take-ownership isn't separately configured | L2 takes ownership through standard behaviour or transfer | Confirm in UAT. Add a work item if needed |
| K8 | Lead Assignment routes to placeholder usernames (`*.invalid`) | Returns `OwnerNotFound` until real users exist | Map to real users when the org is connected |
| K9 | The showcase site's GitHub and LinkedIn links are placeholders in `showcase/src/lib/site.ts` | Broken profile links if published | Replace before sharing |

## 9. Risks carried forward

| Risk | Owner | Mitigation |
| --- | --- | --- |
| Org B can't be a Lifecycle Center stage | Ops Admin | CLI deploy of the same commit, with the limitation recorded |
| License counts differ from the documentation | Ops Admin | Confirm on Company Information before UAT |
| API budget (15,000 per day) spent by retries | Ops Admin | Stop retry loops (checklist item) |
| Org A deactivated after a year of inactivity | Ops Admin | Login cadence on the operator checklist |
| Public report folders open to any future Run Reports holder | Ops Admin | Keep Run Reports as the control. Review before granting it |

## 10. Handover

| For | Start here |
| --- | --- |
| Connecting the orgs and the first promotion | `release/release-plan.md`, `release/CHECKLIST.md`, [ROADMAP.md](ROADMAP.md) Horizon 1 |
| Understanding the design | [ARCHITECTURE.md](ARCHITECTURE.md), [TECHNICAL_DESIGN.md](TECHNICAL_DESIGN.md) |
| Supporting users | `docs/user-guides/`, `docs/runbook/`, `helper/README.md` |
| Re-validating the repository | `tests/validate-m1.ps1` … `validate-m6.ps1`, `py -3 -m unittest helper.tests.test_helper -v`, `py -3 helper/eval/run_eval.py` |

## 11. Completion statement

Version 1.0 of *Salesforce Org Operations & Release Management* is **complete as a source portfolio**. The personas, requirements, configuration, automation, security, reporting, release governance, support content, and retrieval assistant are delivered and internally validated.

Everything that needs a live org (deployment, flow tests, persona tests, dashboard rendering, data loading, promotion, and rollback) is documented with exact steps and remains **not executed**. Lifecycle Center was **studied**. Flosum access is **Not Executed**. No production, Enterprise, or sandbox environment was used or claimed.
