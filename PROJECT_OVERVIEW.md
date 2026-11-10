# Project Overview

**Salesforce Org Operations & Release Management**
A Developer Edition portfolio in Salesforce functional operations across Sales Cloud and Service Cloud administration.

| | |
|---|---|
| **Author** | Nilesh P Raghavan |
| **Version** | 1.0 (complete as a source portfolio) |
| **Document date** | 10 November 2026 |
| **Platform** | Salesforce DX, API 68.0, standard objects, no Apex |
| **Environments** | Two Developer Edition orgs (Org A, Org B) and scratch orgs. None connected yet |
| **Deployment status** | Not deployed. The flows are Draft and the dashboards have not been rendered |

---

## 1. Executive summary

Small Salesforce teams rarely fail because a feature is missing. They fail because nobody wrote down who owns what, access drifts from the job, a stage or status means different things to different people, and changes move between orgs without a record. This project tackles those operational problems head-on.

It defines four personas and twelve requirements. It turns them into Salesforce configuration: fields, value sets, validation rules, flows, permission sets, reports, and dashboards. It documents a gated release path that fits what Developer Edition can actually do. Around that it builds a support layer of guides, L1 and L2 runbooks, and a retrieval assistant that answers only from approved pages.

Each claim carries one of three labels:

| Label | Meaning | Examples |
| --- | --- | --- |
| **Implemented** | Exists as Salesforce DX source or as Python code in the repository | Fields, rules, flows, permission sets, reports, dashboards, release manifests, retrieval assistant |
| **Documented** | A written process or test plan that has not been executed | Release plan, gates, checklists, tabletop rollback, persona tests, validation-rule examples |
| **Studied** | Read from public documentation and assessed | Lifecycle Center capabilities, Flosum capability areas, Developer Edition limits |

## 2. Business problem

The project models a small company with one sales process and one support process.

| Pain point | Who feels it | How the project answers it |
| --- | --- | --- |
| Stage names drift and unqualified leads become empty opportunities | Sales Rep, leadership | One six-stage path as a standard value set. Conversion is allowed only from Qualified. Closed Won requires a positive amount |
| Requests arrive with no owner or priority, and escalations happen in side conversations | Support Agent L1, Support Lead L2 | Case status contract, routing flow, required escalation reason and escalating user, L1 and L2 queues |
| A returned case loses its guidance, and a closed case has no resolution | Support Lead L2 | Validation rules require return guidance and resolution notes at the moment they matter |
| Agents cloned from an admin profile can change records the job doesn't need | Ops Admin | Profiles grant no object access. Business access sits on permission sets, assigned through one group per persona |
| Backlog and pipeline are invisible until someone exports a spreadsheet | Leadership | Ten reports and two dashboards, each tied to a requirement |
| Changes move without a record, and rollback is improvised | Ops Admin | Work items, three stages, seven gates, release manifests, and a revert-plus-destructive-list rollback |
| Users ask the same how-to questions repeatedly, and quick answers invent click paths | Everyone | One-task-per-page guides, L1 and L2 runbooks, and an assistant that quotes one approved page or refuses |

## 3. Personas

| Persona | Role summary | Key success criterion |
| --- | --- | --- |
| **Sales Rep** | Qualifies leads, converts qualified ones, and keeps owned opportunities on the stage path | Converts only a Qualified lead and runs a personal pipeline report without an admin |
| **Support Agent L1** | Opens and works cases, and escalates with a reason | Every request is a case with an owner, status, priority, and origin. Escalation stores a reason and the escalating agent |
| **Support Lead L2** | Takes escalations, resolves them or returns them with guidance, and reviews the backlog | Sees every escalated case. Can't close without a resolution or return without guidance |
| **Ops Admin** | Owns configuration, users, persona access, and release approval | Secrets stay out of git. No fifth persona is invented. No Modify All Data |

Developer Edition provides **two Salesforce CRM licenses**, so the four personas are roles that UAT runs one login at a time.

## 4. Requirements

| Theme | Stories | Primary persona | Priority |
| --- | --- | --- | --- |
| Sales Pipeline | REQ-001, REQ-002 | Sales Rep | High |
| Lead Qualification | REQ-003, REQ-004 | Sales Rep | High |
| Case Management | REQ-005, REQ-006 | Support Agent L1 | High |
| Escalation | REQ-007, REQ-008 | Support Agent L1, Support Lead L2 | High |
| Reporting | REQ-009, REQ-010 | Sales Rep, Support Lead L2 | Medium |
| Access Control | REQ-011, REQ-012 | Ops Admin | High |

Every story has acceptance criteria and is traced to metadata, a release package, and a validation script. The tracing is in `docs/requirement_traceability.md` and `docs/release_management.md`.

## 5. Solution at a glance

| Layer | What was built | Evidence label |
| --- | --- | --- |
| Process contract | Lead Status, Opportunity Stage, Case Status, Case Type value sets | Implemented (source) |
| Data | 8 custom fields on Lead, Opportunity, Case, and User. No custom objects | Implemented (source) |
| Data quality | 6 active validation rules, 36 manual pass/fail examples | Implemented (source) · examples Documented |
| User experience | 9 persona layouts, 3 Lightning record pages with dynamic visibility | Implemented (source) |
| Automation | 4 record-triggered flows (Draft) with fault paths, 7 flow tests, 2 queues, 1 custom notification | Implemented (source) |
| Security | 4 minimum-access profiles, 7 permission sets, 4 permission set groups, security matrix | Implemented (source) |
| Analytics | 10 reports, 2 dashboards running as the logged-in user, synthetic dataset, 4 hand-checked metrics | Implemented (source) · values not observed |
| Release | Path B (Lifecycle Center + git), 3 stages, 7 gates, 2 release manifests, destructive list, tabletop rollback | Documented |
| Support | 2 user guides, L1 runbook (7 entries), L2 runbook (6 entries) | Implemented (documents) |
| Knowledge assistant | Retrieval over 23 sections, refusal on no match or ambiguity, 30-question evaluation | Implemented and evaluated locally |
| Tool assessments | Lifecycle Center notes, Flosum access assessment | Studied · Flosum Not Executed |

## 6. Milestones

| Milestone | Deliverable | Status |
| --- | --- | --- |
| **M1** Foundation | Personas, requirements, environment strategy, Flosum access assessment, Lifecycle Center notes, DX layout, org registry | Complete |
| **M2** Configuration | Fields, value sets, layouts, record pages, validation rules | Complete in source |
| **M3** Automation and security | Flows and tests, queues, profiles, permission sets and groups, security matrix | Complete in source |
| **M4** Reporting | Reports, dashboards, synthetic data, metric validation | Complete in source |
| **M5** Release governance | Plan, gates, checklists, changelog, manifests, rollback drill | Documented. Not executed |
| **M6** User support | Guides, runbooks, retrieval assistant, evaluation | Complete. Evaluated locally |

## 7. Headline metrics

| Metric | Value |
| --- | ---: |
| Personas | 4 |
| Requirements | 12 |
| Custom fields | 8 |
| Validation rules | 6 |
| Flows (all Draft) | 4 |
| Permission sets | 7 |
| Permission set groups | 4 |
| Reports | 10 |
| Dashboards | 2 |
| Procedure sections (guides + runbooks) | 23 |
| Assistant: correct answers | 20 of 20 |
| Assistant: correct refusals | 10 of 10 |
| Assistant: hallucinations | 0 |

The assistant figures come from a fixed 30-question set run locally. They measure retrieval and refusal, not task completion in an org.

## 8. Constraints that shaped the design

- **Developer Edition only.** There are no sandboxes, so Org B is an unrelated second org. Change sets can't connect Org A and Org B.
- **Source tracking exists only in scratch orgs**, so development happens there and the two orgs take explicit deploys from git.
- **Two CRM licenses and zero Service Cloud user licenses.** Case work uses standard Case. Personas are tested one login at a time.
- **Small budgets.** 5 MB of data storage, 15,000 API requests a day, 3 active and 6 daily scratch orgs.
- **Tool access.** Flosum access is Not Executed. Lifecycle Center is available in Developer Edition according to Salesforce Help, but it isn't installed here.

## 9. What has not been executed

- No org is connected, and the Salesforce CLI is not installed in the build workspace.
- No metadata has been deployed. The flows are Draft. Flow tests, persona tests, and validation-rule examples have not been run in an org.
- The dashboards have not been rendered. The synthetic data has not been loaded.
- Release 1 and Release 2 have no deploy ID. The rollback drill is a tabletop.
- Lifecycle Center isn't installed, and whether Org B can be attached as a stage is still an open check.

## 10. Who should read what

| Reader | Start with |
| --- | --- |
| Recruiter | [SUMMARY_FOR_RECRUITERS.md](SUMMARY_FOR_RECRUITERS.md) |
| Hiring manager | [SUMMARY_FOR_HIRING_MANAGERS.md](SUMMARY_FOR_HIRING_MANAGERS.md), then [CASE_STUDY.md](CASE_STUDY.md) |
| Salesforce admin or architect | [ARCHITECTURE.md](ARCHITECTURE.md) and [TECHNICAL_DESIGN.md](TECHNICAL_DESIGN.md) |
| Interviewer | [INTERVIEW_GUIDE.md](INTERVIEW_GUIDE.md) and [DEMO_SCRIPT.md](DEMO_SCRIPT.md) |
| Anyone continuing the work | [ROADMAP.md](ROADMAP.md) and [PROJECT_COMPLETION_REPORT.md](PROJECT_COMPLETION_REPORT.md) |
