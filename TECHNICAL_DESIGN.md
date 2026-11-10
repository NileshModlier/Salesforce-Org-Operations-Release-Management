# Technical Design

**Salesforce Org Operations & Release Management** · version 1.0 · 10 November 2026

This is the component-level specification. It covers the metadata, the logic, the security grants, the reporting definitions, the release packaging, the retrieval assistant, and the validation suite. Every component described is **Implemented** as Salesforce DX source or Python in the repository unless it's marked **Documented**. **No component has been deployed**, and no org is connected.

---

## 1. Project configuration

| File | Setting | Value |
| --- | --- | --- |
| `sfdx-project.json` | Project name | `org-operations` |
| | Package directory | `force-app` (default) |
| | `sourceApiVersion` | `68.0` |
| | `sfdcLoginUrl` | `https://login.salesforce.com` |
| | Namespace | none |
| `config/project-scratch-def.json` | Edition | `Developer` |
| | Features | none |
| | Sample data | `false` |
| | Language | `en_US` |
| `.forceignore` | Excludes | `jsconfig.json`, `.eslintrc.json`, `__tests__` |
| `.gitignore` | Excludes | `.sf/`, `.sfdx/`, auth files, `*.key`, `*.pem`, `jwt/`, `.env*`, logs, `node_modules/`, `tests/results/` |
| `.gitattributes` | Line endings | LF for everything, CRLF for `*.ps1` |
| `org-ops/README.md` | Org registry | `org-a`, `org-b`, `scratch`: aliases, roles, and login host only. No credentials |

## 2. Process contract (standard value sets)

| Value set | Values (default first) | Closed or converted semantics | Requirements |
| --- | --- | --- | --- |
| `LeadStatus` | Open - Not Contacted, Working - Contacted, Qualified, Unqualified, Closed - Converted | Only Closed - Converted is converted, and the convert action writes it | REQ-003, REQ-004 |
| `OpportunityStage` | Prospecting 10%, Qualification 20%, Proposal 50%, Negotiation 80%, Closed Won 100%, Closed Lost 0% | Closed Won is closed and won. Closed Lost is closed and not won | REQ-001, REQ-002 |
| `CaseStatus` | New, Working, Waiting on Customer, Escalated, Closed | Only Closed is a closed status | REQ-005 to REQ-008 |
| `CaseType` | Question, Problem, Feature Request | Used by Case Assignment routing | REQ-005, REQ-010 |

Case Priority stays Low, Medium, High, and Case Origin stays Phone, Email, Web, both as platform defaults.

> **Deploy risk.** A standard value set deploy replaces the target org's list. Records already on omitted values can make the deploy fail. A fresh scratch org has no such records. Org A and Org B haven't been inspected.

## 3. Custom fields

| API name | Type | Length / values | Required on field | Edited by | Read-only for |
| --- | --- | --- | --- | --- | --- |
| `Lead.Product_Interest__c` | Picklist (restricted) | Core Product, Add-on Service, Renewal, Undecided | No | Sales Rep, Ops Admin | none |
| `Opportunity.Next_Step__c` | Text | 255 | No | Sales Rep, Ops Admin | Support Lead L2 |
| `Case.First_Response_At__c` | Date/Time | none | No | L1, Ops Admin, First Response flow | Support Lead L2 |
| `Case.Escalation_Reason__c` | Long Text Area | 1,000 chars, 4 lines | No (rule-enforced) | L1, L2, Ops Admin, Escalation flow | none |
| `Case.Escalated_By__c` | Lookup (User) | none | No (rule-enforced) | L1, L2, Ops Admin, Escalation flow | none |
| `Case.Return_Guidance__c` | Long Text Area | 1,000 chars, 4 lines | No (rule-enforced) | L2, Ops Admin | Support Agent L1 |
| `Case.Resolution_Notes__c` | Long Text Area | 1,000 chars, 4 lines | No (rule-enforced) | L2, Ops Admin | Support Agent L1 |
| `User.Persona__c` | Picklist (restricted) | Sales Rep, Support Agent L1, Support Lead L2, Ops Admin | No | Ops Admin | All other personas |

`User.Persona__c` drives Lightning visibility only. It doesn't grant object access, change a profile, or replace a permission set.

## 4. Validation rules

All six are active. The error message and error field are shown to the user exactly as written.

| Rule | Error field | Formula | Message |
| --- | --- | --- | --- |
| `Lead_Requires_Email_Or_Phone` | Email | `AND(ISBLANK(Email), ISBLANK(Phone))` | Enter an email address or a phone number before saving this lead. |
| `Lead_Convert_Requires_Qualified` | Status | `AND(IsConverted, NOT(ISPICKVAL(PRIORVALUE(Status), "Qualified")))` | Convert this lead only when its status is Qualified. |
| `Opportunity_Closed_Won_Requires_Amount` | Amount | `AND(ISPICKVAL(StageName, "Closed Won"), OR(ISBLANK(Amount), Amount <= 0))` | Enter an amount greater than zero before setting the stage to Closed Won. |
| `Case_Escalation_Requires_Reason` | Escalation Reason | `AND(ISPICKVAL(Status, "Escalated"), OR(ISBLANK(Escalation_Reason__c), ISBLANK(Escalated_By__c)))` | Enter the escalation reason and the agent who escalated before saving an escalated case. |
| `Case_Close_Requires_Resolution` | Resolution Notes | `AND(ISPICKVAL(Status, "Closed"), ISBLANK(Resolution_Notes__c))` | Enter resolution notes before closing this case. |
| `Case_Return_Requires_Guidance` | Return Guidance | `AND(ISPICKVAL(PRIORVALUE(Status), "Escalated"), OR(ISPICKVAL(Status, "New"), ISPICKVAL(Status, "Working"), ISPICKVAL(Status, "Waiting on Customer")), ISBLANK(Return_Guidance__c))` | Enter return guidance before sending an escalated case back to L1. |

**Design notes**

- `PRIORVALUE(Status)` on the convert rule is essential. The convert action writes Closed - Converted, so testing the *new* status would block every conversion.
- Mobile phone doesn't satisfy the email-or-phone rule. That's an explicit, documented choice.
- The return rule needs a *prior* status of Escalated, so a new case inserted as Working doesn't fire it. Closing an escalated case uses the resolution rule instead.
- No rule deletes records, changes ownership, or assigns a queue.

**Test design (Documented).** `docs/test-cases.md` lists three PASS and three FAIL examples per rule, 36 in total, each with concrete data. They haven't been executed.

## 5. User experience

### 5.1 Page layouts (9)

| Layout | Persona | Notes |
| --- | --- | --- |
| `Lead-Sales Rep` | Sales Rep | Name, company, status, title, email, phone, product interest, lead source, owner |
| `Lead-Ops Admin` | Ops Admin | The sales fields plus audit fields |
| `Opportunity-Sales Rep` | Sales Rep | Stage, amount, close date, next step, read-only probability |
| `Opportunity-Support Lead L2` | Support Lead L2 | Commercial context. Amount, next step, probability, account, and owner are read-only. Name, stage, and close date stay editable because the platform requires it, and the Lightning page shows them read-only for L2 |
| `Opportunity-Ops Admin` | Ops Admin | Full pipeline fields plus audit fields |
| `Case-Support Agent L1` | Support Agent L1 | Return guidance and resolution notes are read-only |
| `Case-Support Lead L2` | Support Lead L2 | First response is read-only. Guidance and resolution are editable |
| `Case-Ops Admin` | Ops Admin | All case business fields are editable, plus audit fields |
| `User-Ops Admin` | Ops Admin | User maintenance fields plus Persona |

### 5.2 Lightning record pages (3)

`Lead_Record_Page`, `Opportunity_Record_Page`, and `Case_Record_Page` all use `flexipage:recordHomeTemplateDesktop`. Each has a highlights panel, Dynamic Forms sections, role guidance, record-state guidance, and related lists. There's one page per object, and the visibility rules carry persona differences. The persona layouts remain the mobile and fallback field sets until Dynamic Forms on Mobile is enabled.

| Visibility rule | Shows when |
| --- | --- |
| Record-state banners | Lead Status = Qualified or Unqualified · Stage = Closed Won or Closed Lost · Case Status = Escalated or Closed |
| Editable pipeline section | Persona ≠ Support Lead L2 |
| Read-only opportunity section | Persona = Support Lead L2 |
| Case handling section | Persona ≠ Sales Rep |
| Editable first response | Persona ∉ {Support Lead L2, Sales Rep} |
| Editable guidance and resolution | Persona ∉ {Support Agent L1, Sales Rep} |
| Ops Admin note | Persona = Ops Admin, or Profile = System Administrator |

Field sections are evaluated on page load, not while the user edits. That's why required notes stay visible to the persona who must type them. Hiding Escalation Reason until status is Escalated would block the save the rule checks. Pages are **not activated**. The documented plan is to activate each one as the org default for desktop.

## 6. Automation

All four flows are record-triggered, **Draft**, and include a `Capture Fault` path that sets `Outcome = Fault` and stores `$Flow.FaultMessage`.

### 6.1 Lead Assignment

| Property | Value |
| --- | --- |
| Trigger | After save · `CreateAndUpdate` · runs on create or when `Product_Interest__c` changes |
| Mapping | Core Product → `sales.core@org-ops.invalid` · Add-on Service → `sales.addon@…` · Renewal → `sales.renewal@…` · Undecided or blank → `sales.default@…` |
| Logic | Set `Route` and `OwnerUsername` → Get active User by username → found: set OwnerId, `Outcome = Assigned` · not found: leave the owner, `Outcome = OwnerNotFound` |
| Fault handling | 2 fault connectors |
| Flow tests | `Lead_Assignment_Core_Product` (Route = Core Product) · `Lead_Assignment_Default` (Route = Default). Neither requires the placeholder users to exist |

The `.invalid` usernames are deliberate placeholders. They aren't real users or mailboxes.

### 6.2 Case Assignment

| Property | Value |
| --- | --- |
| Trigger | After save · `Create` only. A later priority change doesn't reroute the case |
| Matrix | High + Problem, Feature Request, or blank → `L2_Escalation` · High + Question → `L1_Support` · Medium or Low (any type) → `L1_Support` |
| Logic | Set `Route` and `QueueDeveloperName` → Get Group (Type = Queue, DeveloperName) → found: OwnerId = queue, `Assigned` · not found: `QueueNotFound`, owner unchanged |
| Fault handling | 2 fault connectors |
| Flow tests | `Case_Assignment_High_Problem` (Route = L2) · `Case_Assignment_High_Question` (Route = L1) |

Queue members are the public groups `Support_L1` and `Support_L2`. Assigning a permission set group doesn't add queue membership.

### 6.3 First Response Tracking

| Property | Value |
| --- | --- |
| Trigger | **Before save** · `Update` · when Status changes |
| Stamp condition | Prior status (`$Record__Prior`) = New **and** new status ≠ New **and** `First_Response_At__c` is blank |
| Action | `First_Response_At__c = NOW()`, `Outcome = Stamped`. Otherwise `Outcome = Skipped` and the field isn't touched |
| Fault handling | 1 fault connector |
| Flow tests | `First_Response_Tracking_Stamp` (Stamped) · `First_Response_Tracking_Skip` (Skipped) |

A before-save update writes the triggering record without extra DML, which is the cheapest way to stamp a field on the same record.

### 6.4 Escalation

| Property | Value |
| --- | --- |
| Trigger | After save · `CreateAndUpdate` · entry: Priority = High and Status ∉ {Escalated, Closed} |
| Scheduled path | "One day after create": offset 1 day, time source `CreatedDate` |
| Threshold | `PastThreshold` = CreatedDate is not blank and is at least one day before now |
| Logic | Not past threshold → `NotDue` · no `L2_Escalation` queue → `QueueNotFound` · no active user with Persona = Ops Admin → `NoOpsAdmin` · otherwise one update: Status = Escalated, Owner = L2 queue, Reason = existing reason or *"Automatically escalated. High priority case exceeded the one-day threshold."*, Escalated By = existing user or the Ops Admin · send the `Escalation_Alert` notification to that Ops Admin, targeting the case · `Outcome = Escalated` |
| Fault handling | 5 fault connectors (lookups, update, notification) |
| Flow test | `Escalation_Not_Yet_Due` (NotDue, immediate path only) |

The reason and Escalated By are filled **before** the status changes, so the flow's own update satisfies `Case_Escalation_Requires_Reason`. A missing queue or Ops Admin leaves the case unchanged. The flow never tries a save the validation layer would reject.

### 6.5 Supporting metadata

| Component | Detail |
| --- | --- |
| Queues | `L1_Support`, `L2_Escalation`, both Case queues |
| Public groups | `Support_L1`, `Support_L2`, the queue members |
| Custom notification type | `Escalation_Alert`, desktop and mobile |
| Flow tests | 7. Run with `sf flow run test` after deploy and before activation. **Not executed** |

## 7. Security model

### 7.1 Profiles (4)

`Sales_Rep`, `Support_Agent_L1`, `Support_Lead_L2`, and `Ops_Admin` use the Salesforce user license and contain **zero `objectPermissions`**. They set no login IP ranges or login hours. They hold the default app (Lightning Sales, Lightning Service, or All Tabs) and the layout assignments. The Ops Admin profile doesn't include Customize Application or Manage Users. Those are on the permission set.

### 7.2 Permission sets (7)

| Permission set | Object permissions | Field exceptions | System permissions |
| --- | --- | --- | --- |
| `Sales_Rep` | Lead CRE · Opportunity CRE · Account R · Contact R · User R | Product Interest edit, Next Step edit, Persona read | none |
| `Support_L1` | Case CRE · Account R · Contact R · User R | First Response, Escalation Reason, Escalated By edit · Resolution Notes, Return Guidance read · Persona read | none |
| `Support_L2` | Case RE + View All · Opportunity R · Account R · Contact R · User R | First Response read · other case fields edit · Next Step read · Persona read | `TransferAnyCase` (Transfer Cases) |
| `Ops_Admin` | Lead, Account, Contact, Opportunity, Case: CRED + View All · User RE + View All | All project fields edit, including Persona | `ViewSetup`, `CustomizeApplication`, `ManageUsers`, `ViewAllUsers` |
| `Reporting_Sales` | none | none | `RunReports` |
| `Reporting_Support` | none | none | `RunReports` |
| `Reporting_Admin` | none | none | `RunReports`, `CreateCustomizeReports`, `CreateCustomizeDashboards`, `CreateReportFolders`, `CreateDashboardFolders`, `ManageReportsInPubFolders`, `ManageDashbdsInPubFolders` |

*C = create, R = read, E = edit, D = delete.* **No permission set includes `ModifyAllData`**, and no persona set grants delete except Ops Admin.

### 7.3 Permission set groups (4)

| Group | Members |
| --- | --- |
| `Sales_Rep` | `Sales_Rep`, `Reporting_Sales` |
| `Support_Agent_L1` | `Support_L1` |
| `Support_Lead_L2` | `Support_L2`, `Reporting_Support` |
| `Ops_Admin` | `Ops_Admin`, `Reporting_Admin` |

A person receives exactly one group. In M4 the three reporting sets were added to their groups once, and anyone already holding a group picks up the new set automatically.

### 7.4 Security matrix

`docs/security-matrix.xlsx` has two sheets. **Security Matrix** has 24 object rows (6 objects × 4 personas) with Create/Read/Edit/Delete flags, field exceptions, and persona mapping. **System Permissions** has 8 rows, including an explicit `Modify All Data = N` for Ops Admin.

### 7.5 Record visibility (Documented)

Intended org-wide defaults are Private for Lead, Opportunity, and Case, and Public Read Only for Account and Contact. These aren't in the deployed source. View All on L2 cases and on Ops Admin objects is explicit.

### 7.6 Persona test plan (Documented)

`docs/persona_testing.md` defines step-by-step tests for each persona plus a profile-only control user, who can log in and can't create a lead, along with five flow outcome checks. They aren't executed. Two CRM licenses mean the tests run one persona at a time.

## 8. Analytics

### 8.1 Reports (10)

| Report | Type | Format | Scope | Filter | Grouping | Calculation |
| --- | --- | --- | --- | --- | --- | --- |
| Lead Conversion By Source | LeadList | Summary | Organization | none | Lead Source | Conversion Rate = sum(Converted) ÷ row count, %, 2 dp |
| Conversion Rate | LeadList | Summary | Organization | none | Converted | Same formula. The KPI reads the grand total |
| Pipeline By Stage | Opportunity | Summary | **User** | none | Stage | Sum of Amount, plus close date and Next Step columns |
| Opportunities Closing This Month | Opportunity | Summary | Organization | Close date = this month | Stage | none |
| Open Opportunity Value | Opportunity | Summary | Organization | Stage ∉ {Closed Won, Closed Lost} | Stage | Sum of Amount |
| Open Cases By Priority | CaseList | Summary | Organization | Status ≠ Closed | Priority | none |
| Cases By Status | CaseList | **Matrix** | Organization | none | Status × Priority | Shows owner and opened date |
| First Response Performance | CaseList | Summary | Organization | none | Priority | Row-level `Hours To First Response` = (First Response At − Created Date) × 24. Average skips blanks |
| Escalations By Priority | CaseList | Summary | Organization | Status = Escalated | Priority | none |
| Cases Closed By Agent | CaseList | Summary | Organization | Status = Closed | Case Owner | none |

Folders are `Sales_Leadership` and `Support_Leadership`, both public and read-only.

### 8.2 Dashboards (2)

| Dashboard | Type | Components | Filter |
| --- | --- | --- | --- |
| `Sales_Dashboard` | `LoggedInUser` | KPI Open Opportunity Value · KPI Conversion Rate · KPI Closing This Month · bar Pipeline By Stage · donut Lead Conversion By Source · table Opportunities Closing This Month | Stage (Prospecting, Qualification, Proposal, Negotiation) → pipeline bar and closing table |
| `Support_Dashboard` | `LoggedInUser` | KPI Open Cases · KPI Escalations · KPI First Response · bar Open Cases By Priority · column Cases By Status · bar Escalations By Priority · table Cases Closed By Agent | Priority (High, Medium, Low) → every component |

### 8.3 Synthetic data and expected values

| File | Rows | Columns |
| --- | ---: | --- |
| `accounts.csv` | 2 | Name |
| `contacts.csv` | 2 | LastName, AccountName, Email |
| `leads.csv` | 24 | LastName, Company, Email, Status, LeadSource, Product_Interest__c, ConvertedTarget |
| `opportunities.csv` | 18 | Name, StageName, Amount, CloseDate, Next_Step__c, LogicalOwner, AccountName |
| `cases.csv` | 20 | Subject, Status, Priority, Origin, Type, CreatedDate, First_Response_At__c, Escalation_Reason__c, Resolution_Notes__c, LogicalOwner, LogicalEscalatedBy, AccountName |

| Metric | Expected | Derivation |
| --- | ---: | --- |
| Open Opportunity Value | 221,000 | 13 open rows (Rep A 165,000, Rep B 56,000) |
| Conversion Rate | 41.67% | 10 ÷ 24 (Web 4/10, Phone Inquiry 3/6, Partner Referral 2/4, Other 1/4) |
| Closing This Month (Nov 2026 run) | 11 deals, 212,000 | Close date in November 2026 |
| Open Cases | 15 | High 7, Medium 4, Low 4 |
| Escalations | 4 | High 2, Medium 1, Low 1 |
| Avg hours to first response | 3.00 | 8 cases at 2 h and 8 at 4 h. 4 New cases blank |

These figures were recomputed from the CSVs for this document and match the repository's metric notes. Dashboard values are **Not observed**.

**Load order (Documented):** accounts → contacts → leads (conversion targets inserted as Qualified) → convert the 10 targets *without* creating opportunities → 18 opportunities → 20 cases (escalated rows need a real User ID in Escalated By). All four flows stay Draft during the load.

## 9. Release packaging

| Artifact | Content | Members |
| --- | --- | ---: |
| `manifest/package.xml` | Full inventory, API 68.0 | 77 |
| `release/manifests/release-1-package.xml` | CustomField, StandardValueSet, ValidationRule, Layout, FlexiPage, Flow, FlowTest, Queue, Group, CustomNotificationType, Profile, PermissionSet, PermissionSetGroup | 61 |
| `release/manifests/release-2-package.xml` | Report (10 + 2 folders), Dashboard (2 + 2 folders) | 16 |
| `release/rollback/destructiveChanges.xml` | Release 2 reports, dashboards, and folders only | 16 |
| `release/rollback/package.xml` | Empty package used with the destructive list | 0 |

**Branching (Documented):** `wi/WI-00n-slug` is cut from `uat`, merged into `uat`, and `uat` is merged into `main`. No force push, no direct commit to `main`. The remote must be GitHub.com or Bitbucket Cloud, the providers Lifecycle Center documents.

**Changelog contract:** Date, Components, Reason, Outcome (`Not executed` until a deploy ID exists), and Rollback Status (`Not required`, `Planned`, `In progress`, or `Restored`).

## 10. Retrieval assistant

### 10.1 Components

| File | Responsibility |
| --- | --- |
| `helper/ingest.py` | Reads `docs/user-guides/*.md` and `docs/runbook/*.md`. Splits on `^## <Prefix>:<Title>`, requires a `Keywords:` line as the first non-blank line, requires a non-empty body, and rejects duplicate IDs. Writes `helper/index.json` (23 sections) |
| `helper/ask.py` | `retrieve(question)`: folds whitespace and case, counts keyword-phrase substring hits per section, and returns the body only if exactly one section matches. Otherwise it returns `REFUSAL`. Every reply includes an advisory banner. CLI supports `--json` |
| `helper/eval/questions.json` | 30 items: `id`, `covered`, `expected_id`, `question` |
| `helper/eval/run_eval.py` | Scores correct answers, citations, citation accuracy, refusals, and hallucinations |
| `helper/tests/test_helper.py` | 5 unit tests |

### 10.2 Retrieval algorithm

```
score(section) = number of section.keywords that appear as substrings in lower(question)
matched = [s for s in sections if score(s) > 0]
if blank question or len(matched) != 1:
    return { refused: true, answer: REFUSAL, citations: [] }
return { refused: false, answer: matched[0].body, citations: [matched[0].id] }
```

Section IDs: `SalesRep:` ×5, `SupportAgent:` ×5, `L1:` ×7, `L2:` ×6.

### 10.3 Evaluation definitions

| Measure | Definition | Result |
| --- | --- | --- |
| Correct answer | Covered question, not refused, citation equals `expected_id` | 20 / 20 |
| Citation accuracy | Emitted citation IDs that exist in the index | 100% |
| Correct refusal | Uncovered question returns exactly `REFUSAL` with no citation | 10 / 10 |
| Hallucination | An answer that isn't the cited body verbatim, or a refusal with extra text or a citation | 0 |

The 10 uncovered questions ask about storing card numbers, installing Flosum and refreshing a sandbox, a shared admin password, mass delete, Einstein scoring, fiscal year, duplicate merge, a marketing blast, disabling MFA, and creating a full-copy sandbox.

### 10.4 Unit tests

| Test | Asserts |
| --- | --- |
| `test_section_parsing` | Exactly the 23 required IDs. Runbook sections have Symptom, Checks, Resolution, and Escalation Criteria. Guide task sections have Steps, Expected outcome, and Troubleshooting |
| `test_citation_existence_and_retrieval_accuracy` | Every covered question returns the expected ID and the verbatim body |
| `test_refusal_logic` | Every uncovered, blank, and ambiguous question refuses with no citation |
| `test_evaluation_coverage` | 30 / 20 / 10 split and the published metrics |
| `test_helper_does_not_call_salesforce` | `ask.py` and `ingest.py` contain no `subprocess`, `simple_salesforce`, `sf project deploy`, or `requests.` |

All 5 tests and the evaluation were re-run on a copy of the repository while preparing this document, and the results matched the repository's record.

## 11. Validation suite

Six Windows PowerShell scripts check the repository's source and documents. They never contact an org. Each prints PASS and FAIL lines and exits 1 on any failure.

| Script | Main assertions | Recorded result |
| --- | --- | --- |
| `validate-m1.ps1` | 4 personas with required sections. 10–15 requirements with required fields. Foundation docs present. Mermaid diagrams in the environment strategy. README headings | PASS, 85 checks |
| `validate-m2.ps1` | Fields, value sets, 6 rules, traceability, layouts, record pages. No `ApexClass` in the manifest. README headings | PASS, 140 checks |
| `validate-m3.ps1` | Each flow is Draft, has a Capture Fault path and a flow test. No permission set grants Modify All Data. Sales Rep has no Case access. L1 resolution notes are read-only. Groups contain the right sets. Profiles have no object permissions. Queues are Case queues. Security matrix tokens | PASS, 83 checks |
| `validate-m4.ps1` | Groupings, matrix format, Pipeline By Stage scope and columns, both formulas, dashboard charts. **Synthetic data counts haven't drifted** (rows, open amount, conversions, open cases, escalations). L1 group has no reporting set. No Apex | PASS, 80 checks |
| `validate-m5.ps1` | Checklist sections with at least 5 items each. Path B recorded. Changelog doesn't claim an execution that didn't happen. Flosum status unchanged. Release 1 has no reports. Release 2 has only reports and dashboards. Destructive list limited to Release 2 | PASS, 72 checks |
| `validate-m6.ps1` | Guides and runbooks contain every required section ID and label. Summary files present. README headings. Runs `helper.tests.test_helper` | Present. No pass count recorded in `project_completion.md` |

*Recorded results are from `project_completion.md`, dated 10 November 2026. PowerShell wasn't available in the environment used to prepare this document, so the scripts weren't re-run. The Python tests and evaluation were re-run.*

## 12. Non-functional characteristics

| Concern | Design response |
| --- | --- |
| Storage (5 MB data) | 66 synthetic rows in total. No files |
| API budget (15,000 per 24 hours) | Checklist stops retry loops. Validation scripts and the assistant make no API calls |
| Licenses (2 CRM, 0 Service Cloud) | Personas as roles. Sequenced UAT. Standard Case only |
| Auditability | Changelog fields, a commit SHA on every approval, a deploy ID on every outcome |
| Reversibility | Release packages are separable. The destructive list is scoped. Flows ship Draft |
| Secrets | None in the repository. Ignore rules for every CLI auth artifact |
| Portability | Standard objects only, no Apex, no managed package dependency |
