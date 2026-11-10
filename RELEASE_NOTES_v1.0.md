# Release Notes · v1.0

**Salesforce Org Operations & Release Management**
**Release date:** 10 November 2026 · **Type:** repository release (source portfolio)

> **This is a repository version, not a Salesforce deployment.** Org A and Org B weren't changed. The Salesforce release packages defined inside this version, *Release 1* and *Release 2*, both remain **Not executed**.

---

## Highlights

- **Process contract on standard objects.** The opportunity stage path, lead statuses, case statuses, and case types are stored as standard value sets, with eight custom fields where the stories needed them.
- **Six validation rules** require information at the transition that would otherwise lose it: qualified-only conversion, email or phone on leads, a positive amount on Closed Won, a reason and user on escalation, guidance on return, and notes on close.
- **Four record-triggered flows (Draft)** for lead routing, case routing, first-response stamping, and one-day escalation. Each has a fault path and handled outcomes.
- **Least-privilege persona access.** Profiles have zero object permissions. Seven permission sets in four groups. No Modify All Data anywhere.
- **Leadership reporting.** Ten reports and two dashboards running as the logged-in user, with hand-checked expected values from a synthetic dataset.
- **Release governance for Developer Edition.** Path B (Lifecycle Center + git), three stages, seven gates, two separable packages, and a revert-plus-destructive rollback.
- **Support and knowledge.** Two persona guides and L1 and L2 runbooks, 23 sections in all, behind a retrieval assistant that answers verbatim or refuses: **20/20** correct answers, **10/10** correct refusals, **0** hallucinations.

## What's new in v1.0

### Configuration (M2)

| Component | Detail |
| --- | --- |
| Standard value sets | `LeadStatus`, `OpportunityStage`, `CaseStatus`, `CaseType` |
| Custom fields | `Lead.Product_Interest__c`, `Opportunity.Next_Step__c`, `Case.First_Response_At__c`, `Case.Escalation_Reason__c`, `Case.Escalated_By__c`, `Case.Return_Guidance__c`, `Case.Resolution_Notes__c`, `User.Persona__c` |
| Validation rules | `Lead_Requires_Email_Or_Phone`, `Lead_Convert_Requires_Qualified`, `Opportunity_Closed_Won_Requires_Amount`, `Case_Escalation_Requires_Reason`, `Case_Close_Requires_Resolution`, `Case_Return_Requires_Guidance` |
| Layouts | 9 persona layouts |
| Lightning record pages | `Lead_Record_Page`, `Opportunity_Record_Page`, `Case_Record_Page` (dynamic visibility, not activated) |

### Automation and security (M3)

| Component | Detail |
| --- | --- |
| Flows (Draft) | `Lead_Assignment`, `Case_Assignment`, `First_Response_Tracking`, `Escalation` |
| Flow tests | 7 (not run) |
| Queues and groups | `L1_Support`, `L2_Escalation`; public groups `Support_L1`, `Support_L2` |
| Notification | `Escalation_Alert` custom notification type |
| Profiles | `Sales_Rep`, `Support_Agent_L1`, `Support_Lead_L2`, `Ops_Admin`, each with 0 object permissions |
| Permission sets | `Sales_Rep`, `Support_L1`, `Support_L2`, `Ops_Admin` |
| Permission set groups | One per persona |
| Security matrix | `docs/security-matrix.xlsx` |

### Reporting (M4)

| Component | Detail |
| --- | --- |
| Sales Leadership reports | Lead Conversion By Source, Pipeline By Stage, Opportunities Closing This Month, Open Opportunity Value, Conversion Rate |
| Support Leadership reports | Open Cases By Priority, Cases By Status (matrix), First Response Performance, Escalations By Priority, Cases Closed By Agent |
| Dashboards | Sales Dashboard, Support Dashboard (`LoggedInUser`) |
| Reporting permission sets | `Reporting_Sales`, `Reporting_Support`, `Reporting_Admin`. L1 receives none |
| Synthetic data | `data/synthetic/`: 2 accounts, 2 contacts, 24 leads, 18 opportunities, 20 cases |
| Expected values | Open Opportunity Value 221,000 · Conversion Rate 41.67% · Open Cases 15 · Escalations 4 |

### Release governance (M5)

| Component | Detail |
| --- | --- |
| Release plan | Work item, branch, review, UAT, approval, promotion, post-deploy validation, rollback criteria |
| Governance | Roles, seven gates, change-control rules |
| Checklists | Pre-release, deployment, post-release, rollback, operator |
| Changelog | Release 1 and Release 2 (*Not executed*), plus a template |
| Manifests | `release-1-package.xml` (61 members) · `release-2-package.xml` (16 members) |
| Rollback | `rollback/destructiveChanges.xml` (Release 2 only) · tabletop drill |

### User support (M6)

| Component | Detail |
| --- | --- |
| Guides | Sales Rep (4 tasks + quick reference) · Support Agent (4 tasks + quick reference) |
| Runbooks | L1 (7 entries) · L2 (6 entries) |
| Assistant | `helper/ingest.py`, `helper/ask.py`, `helper/index.json` (23 sections) |
| Evaluation | `helper/eval/questions.json` (30), `run_eval.py`, 5 unit tests |

## Salesforce release packages defined in this version

| Package | Work item | Contents | Depends on | Outcome | Rollback status |
| --- | --- | --- | --- | --- | --- |
| **Release 1** | WI-001 | Operating process and access model (fields, value sets, rules, layouts, record pages, Draft flows and tests, queues, groups, notification, profiles, 7 permission sets, 4 groups) | none | Not executed | Not required |
| **Release 2** | WI-002 | 10 reports, 2 dashboards, 2 report folders, 2 dashboard folders | Release 1 | Not executed | Not required |

## Verification

| Check | Result |
| --- | --- |
| `validate-m1.ps1` to `validate-m5.ps1` | PASS (85 / 140 / 83 / 80 / 72 checks), recorded 10 November 2026 |
| `helper.tests.test_helper` | PASS, 5 tests |
| Assistant evaluation (30 questions) | 20/20 correct answers · 100% citation accuracy · 10/10 correct refusals · 0 hallucinations |

## Not included

- A connected org, an enabled Dev Hub, a Lifecycle Center project, or a git remote.
- Activated flows, run flow tests, loaded sample rows, or rendered dashboards.
- Sandboxes, an Enterprise org, a customer production org, or a Flosum tenant.
- Any Apex.
- An assistant that can edit records, deploy, or assign access.

## Known issues

| Issue | Workaround or plan |
| --- | --- |
| The Escalation scheduled path isn't covered by a flow test | Verify in UAT before activation |
| Standard value set deploys replace target values, and the prior values aren't retrieved | Retrieve from the target org before the first Release 1 deploy |
| Intended org-wide defaults (Private for Lead, Opportunity, Case) aren't in source | Deploy through a later work item |
| Lead Assignment uses `*.invalid` placeholder usernames | Returns `OwnerNotFound` until real users are mapped |
| Validation scripts require Windows PowerShell | Run on Windows, or port them (roadmap) |
| Personas exceed the two CRM licenses | Run UAT one persona at a time |

## Promotion instructions (once an org exists)

1. Follow `release/release-plan.md` and use one copy of `release/CHECKLIST.md` per work item.
2. Promote **Release 1 before Release 2**: scratch org → Org B (`uat`) → Org A (`main`).
3. Keep the four flows **Draft** unless a new work item activates them.
4. Record the commit SHA, deploy ID, approver, and date on the changelog row. A missing SHA blocks promotion.
5. The retrieval assistant isn't part of any Salesforce deploy.

## Upgrade notes

There's no previous version. v1.0 is the first release of this repository.
