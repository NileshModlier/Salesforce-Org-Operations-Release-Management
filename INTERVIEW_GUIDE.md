# Interview Guide

**50 Salesforce functional operations questions, with detailed answers**
Grounded in the *Salesforce Org Operations & Release Management* project.

---

## How to use this guide

Each answer has two parts. **Answer** is the general principle an interviewer is listening for. **In this project** gives the concrete evidence from the repository, so you can move from theory to something you built.

Use the project's evidence labels precisely:

| Say | Meaning |
| --- | --- |
| "I **implemented**…" | It exists as Salesforce DX source or Python in the repository |
| "I **documented**…" | A written process or test plan that hasn't been run |
| "I **studied**…" | Read from Salesforce or vendor documentation and assessed |

Have this sentence ready: *"It's built for Developer Edition and hasn't been deployed yet. The metadata, release process, and runbooks are complete in source, and connecting the two orgs is the next step."* Don't describe a production org, an Enterprise org, a sandbox, Flosum access, or Lifecycle Center usage.

| Section | Questions |
| --- | --- |
| A. Sales Cloud | 1–5 |
| B. Service Cloud | 6–10 |
| C. Permission Sets and Access | 11–15 |
| D. Validation Rules | 16–19 |
| E. Flows | 20–24 |
| F. Reports | 25–28 |
| G. Dashboards | 29–31 |
| H. Release Governance | 32–37 |
| I. Lifecycle Center | 38–40 |
| J. Flosum | 41–42 |
| K. Runbooks | 43–46 |
| L. AI Knowledge Systems | 47–50 |

---

## A. Sales Cloud

### 1. How would you design an opportunity stage path so pipeline reviews mean the same thing for every deal?

**Answer.** Start with a short, agreed list of stages, each with a clear entry condition and a default probability. Make Closed Won and Closed Lost the only terminal stages. Store the list in the Opportunity Stage value set so nobody can invent a private stage. Then protect the transitions that matter most with validation rules, for example requiring an amount on Closed Won. Path guidance and record-page banners help reps understand what each stage expects. The goal is that a forecast meeting talks about deals, not about definitions.

**In this project.** I implemented a six-stage `OpportunityStage` value set: Prospecting 10%, Qualification 20%, Proposal 50%, Negotiation 80%, Closed Won 100%, Closed Lost 0%. `Opportunity_Closed_Won_Requires_Amount` blocks Closed Won with a blank, zero, or negative amount, while Closed Lost and open stages can still be saved with a blank amount. A `Next_Step__c` field makes it visible which deal needs action (REQ-001, REQ-002).

### 2. How do you stop reps from converting unqualified leads?

**Answer.** Define a status that means "qualified," then block conversion from any other status with a validation rule. The trap is that the convert action itself writes the converted status. A rule that checks the *current* status blocks every conversion. The rule must check `IsConverted` and look at the *prior* status with `PRIORVALUE`.

**In this project.** I implemented `Lead_Convert_Requires_Qualified`: `AND(IsConverted, NOT(ISPICKVAL(PRIORVALUE(Status), "Qualified")))`. Unqualified, Open - Not Contacted, and Working - Contacted can't convert. A second rule, `Lead_Requires_Email_Or_Phone`, keeps unreachable leads out of the funnel. Mobile phone doesn't count, and that's a deliberate, documented choice. The documented manual tests include three passing and three failing conversions.

### 3. What happens when a lead converts, and how do you avoid creating duplicates?

**Answer.** Standard conversion creates or links an account, creates a contact, and optionally creates an opportunity, then keeps the converted lead linked to all three. To avoid duplicates, the rep should attach an existing account when one is visible. Matching and duplicate rules can enforce this more strictly. Know when *not* to create the opportunity, for example in a data load where opportunities come from their own file.

**In this project.** REQ-004 says the rep can use an existing account instead of creating a duplicate. I kept the standard convert action with no custom mapping. In the synthetic-data load plan, the ten conversion targets are converted *without* creating opportunities, because the 18-row opportunity file would otherwise be inflated and the pipeline totals would change.

### 4. How would you route new leads to the right owner?

**Answer.** You can use lead assignment rules or a record-triggered flow. A flow is easier to test, can branch on any field, and can handle a missing owner gracefully instead of failing. Route on a business attribute rather than on a person's name. Decide what happens when the target user doesn't exist. Don't leave the record unowned or assign an invalid ID.

**In this project.** I implemented a **Lead Assignment** after-save flow that routes on `Product_Interest__c` (Core Product, Add-on Service, Renewal, or Undecided) to named owner placeholders such as `sales.core@org-ops.invalid`. If that user doesn't exist, the creator stays the owner and the outcome is `OwnerNotFound`, a handled result rather than a fault. The flow is Draft, with two flow tests that assert the route without needing the placeholder users.

### 5. A rep says their pipeline report doesn't match the manager's dashboard. How do you explain it?

**Answer.** Check three things first: report scope, sharing, and timing. A "my opportunities" report shows only the running user's records. A dashboard running as the logged-in user shows only what that viewer can see. Under Private org-wide defaults, a rep sees only their own book. Relative date filters such as "this month" change with the day you run them. Most "wrong number" tickets are a viewer, scope, or date question, not a broken report.

**In this project.** Pipeline By Stage is scoped to the running user (REQ-009). In the synthetic data the full open book is 221,000, but Rep A owns 165,000 and Rep B owns 56,000. The L2 runbook's *Reporting Discrepancies* entry tells support to confirm the viewer, the load, and the month before touching a report, and never to edit a formula to force the hand count.

---

## B. Service Cloud

### 6. Walk me through the case lifecycle you'd configure for a two-tier support team.

**Answer.** Keep the statuses minimal and meaningful. Route new cases to a tier-one queue, give tier one a clear escalation path that captures why, let tier two either resolve or send the case back with instructions, and require a resolution before closing. Every handoff should leave a record of who acted and why.

**In this project.** I implemented these Case statuses: New → Working ↔ Waiting on Customer → Escalated → Closed. Case Assignment routes new cases to `L1_Support` or `L2_Escalation`. An escalation requires `Escalation_Reason__c` and `Escalated_By__c`. Returning an escalated case to New, Working, or Waiting requires `Return_Guidance__c`. Closing requires `Resolution_Notes__c`. L1 can't edit the guidance or resolution fields, and L2 writes them.

### 7. How do you route cases to queues without Omni-Channel?

**Answer.** Use a record-triggered flow, or case assignment rules, on create. Decide the routing matrix on stable attributes like priority and type. Look the queue up by DeveloperName instead of hard-coding an ID, so the logic works across orgs. Queue membership is managed separately, through users, roles, or public groups.

**In this project.** Case Assignment is an after-save flow that runs on create only. High priority with type Problem, Feature Request, or blank goes to the L2 Escalation Queue. High priority with type Question, and anything Medium or Low, goes to the L1 Support Queue. The flow queries Group by type and DeveloperName. A missing queue returns `QueueNotFound` and the owner is left unchanged. The queue members are the public groups `Support_L1` and `Support_L2`. Omni-Channel was out of scope because the project's environment documents zero Service Cloud user licenses.

### 8. How would you measure first response time?

**Answer.** Capture the moment of first response in its own Date/Time field, stamped once and never overwritten. Derive the duration in a report formula. Don't rely on Last Modified, because any edit changes it, or on manual entry alone. Define "first response" in terms of the process, such as the first status change away from New.

**In this project.** First Response Tracking is a **before-save** flow that stamps `First_Response_At__c` only when the prior status was New, the new status isn't New, and the field is empty. Any other change is `Skipped`. First Response Performance computes Hours To First Response as `(First Response At − Created Date) × 24`, and the average excludes blank rows. In the synthetic data the expected average is 3.00 hours across 16 stamped cases.

### 9. How do you escalate aged high-priority cases automatically, and what can go wrong?

**Answer.** Use a record-triggered flow with a scheduled path keyed to a date field. Two things go wrong. First, your own automation trips a validation rule, for example a required reason. Second, a dependency such as a queue or a notification recipient doesn't exist. Fill required fields before changing the status, and treat missing dependencies as handled outcomes.

**In this project.** The **Escalation** flow's entry criteria are Priority = High and Status not Escalated or Closed. It has a scheduled path one day after `CreatedDate`, and the immediate path handles cases that are already older than a day. In one update it sets Escalated, moves the case to the L2 queue, fills a standard reason if none exists, and sets Escalated By to the Ops Admin. Then it sends the `Escalation_Alert` custom notification. A missing queue returns `QueueNotFound`, and no Ops Admin persona returns `NoOpsAdmin`. In both cases the record isn't changed. It's Draft, and the flow test covers only the immediate path, which I state openly.

### 10. Which Service Cloud features would you avoid on a Developer Edition org, and why?

**Answer.** Anything that depends on licenses or editions the org doesn't have. Confirm license counts on Company Information before promising a feature. If the org has no Service Cloud user licenses, design on standard Case behaviour: statuses, queues, assignment, validation rules, flows, and reports.

**In this project.** I studied the Developer Edition limits and documented them. The partner comparison the project cites lists 2 Salesforce CRM licenses, 3 Platform licenses, and **0 Service Cloud user licenses**. So Entitlements, milestones, Omni-Channel, and other features that need a Service Cloud license are explicitly out of scope, and case management uses standard Case. The first roadmap step is to confirm these counts on a connected org.

---

## C. Permission Sets and Access

### 11. Why put business access on permission sets rather than profiles?

**Answer.** Profiles are one per user and hard to change without cloning. Permission sets stack. If profiles carry only the essentials (license, default app, page layouts) and permission sets carry object, field, and system access, you can add a capability to a whole persona without touching profiles or layouts. It also aligns with Salesforce's direction of travel toward permission-set-led access.

**In this project.** I implemented four profiles with **zero `objectPermissions`**. A profile-only user can log in and can't create a lead, opportunity, or case. That user is the control case in persona testing. In M4 I added reporting access by putting `Reporting_Sales`, `Reporting_Support`, and `Reporting_Admin` into three groups. No profile was cloned.

### 12. What is a permission set group, and how did you structure yours?

**Answer.** A permission set group bundles permission sets so you assign one thing per role. When you add a set to the group, everyone with the group gets it. Design one group per persona, keep sets granular (persona access separate from reporting access), and avoid assigning loose sets directly to users.

**In this project.** I implemented four groups:
- Sales Rep = `Sales_Rep` + `Reporting_Sales`
- Support Agent L1 = `Support_L1` only
- Support Lead L2 = `Support_L2` + `Reporting_Support`
- Ops Admin = `Ops_Admin` + `Reporting_Admin`

L1 deliberately gets no reporting set, which enforces REQ-010's rule that L1 isn't a consumer of the all-team backlog. `validate-m4.ps1` fails if a reporting set ever appears in the L1 group.

### 13. A user has the right permission set group but can't see the cases in their queue. What do you check?

**Answer.** Separate the grants. Object permission says whether they can read cases at all. Org-wide defaults and sharing say *which* cases. Queue membership says whether queue-owned records are theirs to work. A permission set group doesn't make someone a queue member. Also check that any "persona" or label field isn't being mistaken for access.

**In this project.** Queue membership is the public group `Support_L1` or `Support_L2`, and the documentation and runbooks repeat that assigning the group doesn't add it. `User.Persona__c` only drives Lightning visibility and grants nothing. The L1 runbook entry *Record Visibility* walks through these exact checks and escalates to Ops Admin when the group or public group is wrong.

### 14. How do you give an operations admin enough power without granting Modify All Data?

**Answer.** Grant exactly what the job needs: create, read, edit, delete, and View All on the business objects they support, plus Manage Users, Customize Application, View Setup, and View All Users. Modify All Data bypasses sharing and validation intent across every object. It's rarely needed for configuration or user administration.

**In this project.** `Ops_Admin` has create, read, edit, delete, and View All on Lead, Account, Contact, Opportunity, and Case, plus User read and edit and View All. Its system permissions are View Setup, Customize Application, Manage Users, and View All Users. **No permission set grants Modify All Data.** The security matrix records `Modify All Data = N`, `validate-m3.ps1` fails if any set includes it, and the governance rules forbid granting it to close a ticket.

### 15. How do you prove a permission model works?

**Answer.** Write persona tests that include *negative* cases: what each user must **not** be able to do. Include a control user with only the profile. Keep a security matrix that a reviewer can read without opening Setup. When licenses are scarce, test one persona at a time by switching the group on a single test user.

**In this project.** I documented persona tests for all four roles. A Sales Rep can't create a case or open Setup. L1 can't edit Resolution Notes, delete a case, or edit an opportunity. L2 can transfer a case but can't edit Next Step. Ops Admin doesn't need Modify All Data for any step. There's also the profile-only control user. `docs/security-matrix.xlsx` covers 24 object rows and 8 system-permission rows. With two CRM licenses, the plan sequences the logins. The tests haven't been executed yet.

---

## D. Validation Rules

### 16. How do you require a field only at a particular status?

**Answer.** Keep the field optional and write a validation rule conditioned on the status, for example `AND(ISPICKVAL(Status, "Closed"), ISBLANK(Notes__c))`. Making the field required on the layout or field would force it at every save, including early ones where the information doesn't exist yet. Put the error on the field the user needs to fill.

**In this project.** All five custom case fields are optional on the field. Rules enforce them at the right moment. `Case_Escalation_Requires_Reason` applies only when Status is Escalated, and `Case_Close_Requires_Resolution` only when Status is Closed. A new case can still be saved with neither field filled.

### 17. Explain `PRIORVALUE` and where you used it.

**Answer.** `PRIORVALUE(field)` returns the field's value before the current save. Use it to validate *transitions* rather than states. Common uses are "you can't leave status X without Y," or a case where another process writes the new value for you, as lead conversion does.

**In this project.** I used it in two rules. `Lead_Convert_Requires_Qualified` checks the prior status, because conversion writes Closed - Converted. `Case_Return_Requires_Guidance` fires only when the prior status was Escalated and the new status is New, Working, or Waiting on Customer. A new case inserted directly as Working doesn't trigger it.

### 18. How do you stop validation rules from breaking automation or data loads?

**Answer.** Remember that validation rules run on DML from flows and data loads too. Design your automation to satisfy the rules, by filling required values before the status change. Order your data loads so records arrive in a valid state. Don't add "bypass" checkboxes casually, because they become permanent holes.

**In this project.** The Escalation flow fills Escalation Reason and Escalated By in the same update that sets Escalated, so its own save passes `Case_Escalation_Requires_Reason`. The documented synthetic-data load inserts conversion targets as Qualified, never as already converted, because the convert rule would reject that. Escalated rows need a real User ID, and Closed rows carry resolution notes. No bypass mechanism was added.

### 19. How do you test validation rules before deployment?

**Answer.** For each rule, write both passing and failing examples with concrete data. Include boundary and edge cases: zero and negative numbers, alternative fields that *don't* satisfy the rule, and transitions from different prior states. Run them in a scratch org before UAT, and then let the UAT story checks confirm the business flow.

**In this project.** `docs/test-cases.md` documents three PASS and three FAIL examples per rule, 36 in total. They cover a mobile phone that doesn't satisfy the email-or-phone rule, Closed Won with 0 and −25, Closed Lost with a blank amount, and returns from Escalated to each of the three working statuses. They're documented and haven't been run. No scratch org exists yet.

---

## E. Flows

### 20. When do you use a before-save flow versus an after-save flow?

**Answer.** Use **before-save** for updates to fields on the triggering record. It runs without an extra DML operation, so it's the fastest option. Use **after-save** when you need the record ID, need to work with other records, call actions such as notifications, or use scheduled paths. If you can do it before save, do it before save.

**In this project.** First Response Tracking is before-save, because it only stamps a field on the same case. Escalation is after-save because it uses a scheduled path and sends a custom notification. Lead Assignment and Case Assignment are after-save, record-triggered flows that set the owner after Get Records lookups.

### 21. How do you handle errors in flows?

**Answer.** Add fault connectors to every element that can fail: lookups, updates, and actions. Capture `$Flow.FaultMessage`. Separate expected gaps, like "the queue doesn't exist yet," from genuine faults, and handle the expected ones with a decision rather than letting them throw. Never write a half-valid value just to keep going.

**In this project.** Every flow has a **Capture Fault** path that sets `Outcome = Fault` and stores the fault message. Expected gaps are handled outcomes that leave the record unchanged: `OwnerNotFound`, `QueueNotFound`, `NoOpsAdmin`, `NotDue`, and `Skipped`. `validate-m3.ps1` fails if any flow lacks a Capture Fault path.

### 22. How do scheduled paths work, and what are the gotchas?

**Answer.** A scheduled path runs a set time before or after a date field on the record, once the record meets the entry conditions. Gotchas include records that are already past the time when they're created or loaded, entry conditions that change before the path runs, and test coverage. Not every flow-test tool exercises scheduled paths, so verify them in a UAT org before activation.

**In this project.** Escalation's scheduled path runs one day after `CreatedDate`. The immediate path applies the same age check, so already-old records, such as a data load, escalate at once, while new ones return `NotDue` and wait. The flow test `Escalation_Not_Yet_Due` covers the immediate path only. I documented that the scheduled path needs verification in UAT, and the rollback drill notes that this test can't prove the schedule was removed.

### 23. Why would you deploy flows as Draft?

**Answer.** Activation changes behaviour for every user and every load, so it deserves its own decision. Deploying Draft lets you review the logic in the target org, run flow tests, and load data without automation rewriting it. Then you activate under a specific change with UAT first.

**In this project.** All four flows are Draft and ship Draft in Release 1. The release plan says to activate a flow only through a new work item, with UAT first. The synthetic load must happen with the flows Draft, because Lead and Case Assignment would overwrite the loaded owners and First Response Tracking would re-stamp times. The checklists verify after each release that the flows are still Draft.

### 24. How do you test flows?

**Answer.** Use Flow Tests to assert outcomes for specific input records, covering each branch. Run them after deploy and before activation. Complement them with persona-based UAT for behaviour that tests can't cover, such as notifications, scheduled paths, and real queue membership.

**In this project.** I implemented seven flow tests. Two cover Lead Assignment (Core Product and Default routes), two cover Case Assignment (High Problem → L2 and High Question → L1), two cover First Response Tracking (Stamped and Skipped), and one covers Escalation (NotDue). They're metadata only and haven't been run. The plan is `sf flow run test` after deploy and before activation. Persona testing adds flow checks such as `OwnerNotFound`, `QueueNotFound`, and `NoOpsAdmin`.

---

## F. Reports

### 25. Which report format would you use for a support backlog by status and priority?

**Answer.** A **matrix** report, which groups rows by one field and columns by another, so leaders see the intersection: how many High cases are Waiting on Customer, for example. Add owner and opened date for drill-down. Use summary reports for single-dimension groupings, and tabular reports for raw lists.

**In this project.** Cases By Status is the REQ-010 matrix, with Status down and Priority across, plus case owner and opened date. `validate-m4.ps1` fails if it isn't a matrix. The other nine reports are summary reports grouped by stage, source, priority, converted, or owner.

### 26. How do you build a "my pipeline" report, and why does scope matter?

**Answer.** Set the report scope to the running user's records ("My opportunities"), group by stage, and include amount and close date. Scope matters because sharing alone may show a manager or admin more than the user's own book. A "my" report should mean exactly that, whoever runs it.

**In this project.** Pipeline By Stage runs on Opportunity with scope = user, grouped by Stage, and shows amount, close date, and Next Step (REQ-009). Even the Ops Admin, who has View All, sees only opportunities they own in this report. The sales guide tells reps to read the rows as their own book and not to compare them with the 221,000 full-book figure.

### 27. How do you calculate rates and durations in reports?

**Answer.** Use a **summary formula** for aggregate ratios, such as converted ÷ total. Use a **row-level formula** for per-record durations, such as hours between two timestamps, then average it in the summary. Decide how blanks behave, because a blank should usually be excluded rather than counted as zero.

**In this project.** Conversion Rate and Lead Conversion By Source use sum(Converted) ÷ row count as a percentage with two decimals. The expected value is 41.67% (10 ÷ 24). First Response Performance uses a row-level *Hours To First Response* = `(First Response At − Created Date) × 24`. Blank rows stay out of the average, so the expected average is 3.00 hours.

### 28. How do you control who can run reports?

**Answer.** Use the Run Reports permission on a permission set, plus folder access. Public read-only folders keep sharing simple. The permission then decides who can actually run anything. Be explicit about who shouldn't have reporting, and remember that public folders are visible to anyone you later give Run Reports.

**In this project.** Reports live in two public, read-only folders. Run Reports comes from `Reporting_Sales`, `Reporting_Support`, or `Reporting_Admin` in the persona groups, and L1 has none. That avoids putting a user ID in a folder share that a deploy would need. I documented the risk: anyone later given Run Reports could open the support folder, so the control is the permission, not folder privacy.

---

## G. Dashboards

### 29. Logged-in-user dashboards versus a fixed running user: what's the trade-off?

**Answer.** A dashboard that runs as a fixed user shows everyone that user's view, which is convenient but can expose data beyond a viewer's own sharing. A dashboard that runs as the logged-in user respects each viewer's access, but the numbers differ by viewer, and that needs explaining. Choose based on whether the audience should see the same totals.

**In this project.** Both dashboards are `LoggedInUser`. A Sales Rep sees their own sharing, while Support Lead L2 and Ops Admin, who have View All on cases, see the full support book. The runbooks explain why a rep doesn't see 221,000 and why an empty chart can be a sharing issue rather than a broken dashboard.

### 30. How do you design a dashboard leaders will actually use?

**Answer.** Each component should answer a named question. Put a few KPIs on top, charts for grouped questions in the middle, and a table for the row-level "which ones?" question. Add a filter that matches how leaders slice the business, and wire it only to components where it makes sense.

**In this project.**
- **Sales Dashboard:** three KPIs (open value, conversion rate, closing this month), a pipeline bar, a lead-source donut, and a closing-this-month table. The Stage filter is wired to the pipeline bar and the table only, because the other components aren't stage reports.
- **Support Dashboard:** three KPIs (open cases, escalations, hours to first response), three charts, and a closed-by-agent table. The Priority filter is wired to every component.

### 31. How do you validate a dashboard before go-live?

**Answer.** Load a known dataset and compare the components against hand-calculated expected values. State the conditions under which the numbers should match: who's viewing, which month, and whether the load is complete. Record the dashboard value as "not observed" until you've actually seen it.

**In this project.** I counted four metrics by hand from the synthetic files: Open Opportunity Value 221,000 (13 rows), Conversion Rate 41.67%, Open Cases 15, and Escalations 4. They should match only for a viewer who can read every row, after the ten conversions, and, for the closing-month table, in November 2026 (11 deals, 212,000). The dashboard values are recorded as **Not observed**, and `validate-m4.ps1` fails if the data files drift from these counts.

---

## H. Release Governance

### 32. How do you promote changes between orgs without sandboxes or change sets?

**Answer.** Make git the source of truth and deploy the same revision to each environment with the Salesforce CLI or a DevOps tool. Change sets only work between a production org and its sandboxes. Unrelated orgs need metadata deploys. Develop in a source-tracked scratch org, commit, deploy to UAT, then promote the identical commit to the final org.

**In this project.** I documented a three-stage path. A scratch org from Org A's Dev Hub feeds a `wi/WI-00n-slug` branch, which merges into `uat` for Org B, which merges into `main` for Org A. Org B is a separate Developer Edition org, not a sandbox, so it can't be refreshed and change sets can't connect the two. Every hop is an explicit deploy of a known commit. The process is documented and hasn't been executed.

### 33. What gates would you put between UAT and production?

**Answer.** At minimum: a scoped change record, an independent review, proof that UAT ran the *same* commit production will receive, passing story checks, a written approval with the commit identifier, and a post-deploy validation record. Make each gate leave evidence.

**In this project.** I documented seven gates:
1. The work item names the requirement and manifest.
2. The review is by someone other than the sole author.
3. Org B has the same commit Org A will get.
4. The story checks pass on Org B.
5. Ops Admin writes the approval, SHA, and date.
6. Org A receives that commit.
7. Post-deploy validation is recorded on the changelog.

Only Ops Admin approves production promotion, and never as the only reviewer of their own work item.

### 34. How do you decide how to split a release?

**Answer.** Split by dependency and by blast radius. Ship foundations, meaning data, rules, automation, and access, before the things that consume them, such as reports. Keep packages separable so you can roll one back without the other. Watch hidden dependencies, for example a group that references a set.

**In this project.** Release 1 is the operating process and access model, with 61 members and no reports or dashboards. Release 2 is leadership reporting only: 10 reports, 2 dashboards, and their folders, 16 members in all. The reporting *permission sets* ship in Release 1 because the permission set groups reference them, and removing them would break the group deploy. `validate-m5.ps1` enforces both scoping rules.

### 35. How do you roll back a Salesforce metadata release?

**Answer.** Revert the commit in git, which is the record. Then remember that a metadata deploy is an **upsert**: redeploying the old tree doesn't delete what the bad release added. Removal needs `destructiveChanges.xml`. Rehearse it on UAT first. Some things don't roll back with metadata at all, such as standard picklist values you never retrieved, data written by automation, and ownership changes.

**In this project.** The documented tabletop drill for Release 2 goes like this. Stop promotion, then revert the merge on `main` (and on `uat` if Org B got it), with no force push and no hard reset. Deploy `release/rollback/destructiveChanges.xml` with an empty `package.xml` to Org B, accept the result, and then deploy to Org A. The list removes only the reports, dashboards, and folders. The drill lists what it can't undo: standard value sets, stamped First Response values, and owners already set by an activated flow.

### 36. What's the difference between a failed promotion and a rollback?

**Answer.** A failed promotion means a gate wasn't met, such as a skipped test or a missing approval. You stop, fix the gate, and the next stage waits. Nothing harmful necessarily reached the org. A rollback is for a deployed change that's causing harm, and it starts from defined criteria. Mixing the two leads to unnecessary rollbacks or, worse, skipped gates.

**In this project.** The governance doc says it directly: *"Skipping a gate is a failed promotion, not a rollback."* The release plan lists the rollback criteria:
- A rule blocks a story the work item said would pass.
- A flow is Active that should be Draft.
- A Sales Rep can read cases, or L1 can run the support dashboard.
- The dashboards error, or contradict the hand counts after a load.
- Standard picklist values were unintentionally replaced.

### 37. How do you keep release records auditable?

**Answer.** Every release entry should record what was deployed, why, by whom, from which commit, to which org, with which deploy ID, and what happened. The record must never claim more than happened. "Not executed" is a valid and important state.

**In this project.** The changelog template records Date, Components (manifest path), Reason (requirement ID), Outcome (deploy ID, commit SHA, org alias, pass or fail, or *Not executed*), and Rollback Status (Not required, Planned, In progress, or Restored). Release 1 and Release 2 are both recorded as *Not executed* with rollback *Not required*. `validate-m5.ps1` fails if a changelog entry claims an execution that didn't happen.

---

## I. Lifecycle Center

### 38. What is Lifecycle Center, and how did you plan to use it?

**Answer.** It's Salesforce's release-control product. Earlier documentation and some setup screens call it DevOps Center. Its model is a project with **one pipeline**, made of ordered **stages**. Each stage points at a Salesforce org and a git branch, and **work items** collect the metadata for one change. Git holds the metadata, and the orgs are where it's built or verified.

**In this project.** I studied it from Salesforce Help and the DX guides and documented it as the control plane for "Path B." It's not installed. The plan is to put the Lifecycle Center hub on Org A and create one project, `Org Operations`, with one pipeline. Work items map to requirement IDs, with WI-001 for Release 1 and WI-002 for Release 2.

### 39. What limitations did you identify for Lifecycle Center on Developer Edition?

**Answer.** Check edition availability, the development-environment requirements, the supported source-control providers, and the setup permissions. Then check whether your topology fits the product's assumptions.

**In this project.** From the documentation I studied:
- Salesforce Help lists Developer Edition as an available edition.
- Development environments should be source-tracked, which means scratch orgs here, because Developer Edition orgs don't support source tracking.
- The documented providers are GitHub.com, including Enterprise Cloud, and Bitbucket Cloud. GitLab and Azure DevOps are outside that set.
- The setup permissions include broad data visibility.
- The key **open check** is whether an unrelated Developer Edition org (Org B) can be attached as a UAT stage, since sandboxes are the usual non-scratch stage. If it can't, the fallback is a CLI deploy of the same commit, recorded as a limitation.

### 40. How would you configure the Lifecycle Center pipeline for this topology?

**Answer.** Match the stages to the environments you really have. Remove default stages that assume environments you don't have, and keep one source of truth for each stage's branch.

**In this project.** The documented pipeline has three stages:
1. **Development**: `wi/WI-00n-slug` branches, scratch org.
2. **UAT**: `uat` branch, Org B.
3. **Production Stand-In**: `main` branch, Org A.

Any default stage pointing at a sandbox is dropped. Org A isn't a development environment. The operator checklist adds assigning only the product's own permission sets to the named Ops Admin, connecting only GitHub.com or Bitbucket Cloud, writing down the Org B attachment result before calling the pipeline complete, and logging in often enough that Org A isn't deactivated after a year of inactivity.

---

## J. Flosum

### 41. How does Flosum compare with Lifecycle Center, and why isn't it in your pipeline?

**Answer.** Flosum is a commercial Salesforce DevOps product. Public descriptions cover metadata deployment with comparison and history, version control integration, pipelines, data deployment, backup and recovery, and org comparison. Lifecycle Center is Salesforce's own release-control product. A tool belongs in a release path only when you actually have access to it.

**In this project.** I recorded Flosum in an access assessment. The trial request, demo request, product access, and AppExchange install are all **Not Executed**. There are no connected orgs and no credentials. The capability table is explicitly "unvalidated." The governance decision is Path B (Lifecycle Center and git), and the rule is that no document may describe a Flosum pipeline or a completed Flosum analysis while access is Not Executed. `validate-m5.ps1` fails if the Flosum status changes. In an interview I say I *studied* Flosum's published capabilities. I don't say I used it.

### 42. What would you need to evaluate Flosum properly?

**Answer.** A real tenant, plus answers to the questions that decide fit: environment requirements, limits, coexistence with other tools, and what counts as evidence.

**In this project.** I documented the known unknowns:
- Can a trial be issued against two independent Developer Edition orgs?
- Does it need a production org, a sandbox, or a paid edition first?
- What are the trial length and restricted features?
- How does it behave with 5 MB of data storage and 15,000 API calls a day?
- Does it conflict with Lifecycle Center, through overlapping pipelines or connected apps?

The evidence a reviewer should accept is a tenant URL and an install record. A demo, a trial page, or a screenshot isn't access.

---

## K. Runbooks

### 43. How do you structure an operational runbook entry?

**Answer.** Use one symptom per entry. Give checks in a fixed order, a resolution with explicit "don't do this" lines, and clear escalation criteria naming who is next. Consistent structure lets a stressed responder scan it, and lets an assistant or test check completeness.

**In this project.** Every L1 and L2 entry has **Symptom → Checks → Resolution → Escalation Criteria**. User-guide tasks have **Steps → Expected outcome → Troubleshooting**. The assistant's unit test fails if any section is missing those headings. The L1 runbook has seven entries: login, MFA, record visibility, missing data, report access, dashboard access, and case reassignment. The L2 runbook has six: flow faults, validation rules, permission sets, release failures, data corrections, and reporting discrepancies.

### 44. Walk me through troubleshooting "a user can't run reports."

**Answer.** Identify the user's role and whether they *should* run reports. Check the permission that grants Run Reports, then folder access. Confirm whether the request is really a request for data the role shouldn't have. Escalate to the admin only when the correct grant is in place and it still fails.

**In this project.** *L1:Report Access* starts by confirming the permission set group. Sales Rep gets Run Reports through `Reporting_Sales`, L2 through `Reporting_Support`, Ops Admin through `Reporting_Admin`, and L1 gets none. If an L1 agent wants the team backlog, the answer is that L2 runs it. Don't add Run Reports to L1, and don't clone the Ops Admin set. Escalate to Ops Admin only when a Sales Rep or L2 user has the correct group and still can't run a report in their folder.

### 45. Where do you draw the line between L1 and L2 support?

**Answer.** L1 handles symptoms they can check and explain without changing configuration: access, visibility, missing data, and ownership. L2 handles problems that need deeper diagnosis of automation, rules, permissions, releases, data, and reporting. Only the admin changes users, permissions, or releases. Write the boundary into each entry's escalation criteria.

**In this project.** The support model defines four tiers: the Sales Rep guide, the Support Agent guide, the L1 runbook, and the L2 runbook. Ops Admin is the stop for assigning groups, managing users, and promoting releases. L2 doesn't approve production promotion or deploy. Support never invents a click path, turns off MFA, shares a password, grants Modify All Data, deletes records to make a report match, or activates Draft flows outside a work item.

### 46. A user asks you to disable MFA so they can get in quickly. What do you do?

**Answer.** Decline politely and troubleshoot. The usual causes are device clock skew or a missing or changed verification method. Never accept a code relayed by someone else, never create a shared login, and escalate method resets to the admin.

**In this project.** *L1:MFA Problems* first checks that the device clock is set automatically, because a skewed clock rejects time-based codes. It checks that the user is enrolling their own method, and that nobody is asking to disable MFA. The runbook explicitly has **no approved bypass**. It escalates to Ops Admin when a time check doesn't fix it, or whenever anyone asks to disable MFA. "How do I disable multi-factor authentication for every user?" is also one of the ten questions the assistant must refuse.

---

## L. AI Knowledge Systems

### 47. How did you design an AI helper that can't give wrong procedures?

**Answer.** Constrain it to retrieval from an approved corpus, return the approved text verbatim with a citation, and refuse whenever the match isn't unambiguous. Give it no tools that change systems. The human still performs every action.

**In this project.** The retrieval assistant indexes only the 23 sections in the user guides and runbooks. It returns a section **only when exactly one** section's keyword phrases match. The answer is that section's body, copied verbatim, with its ID as the citation. Zero matches or several matches give the approved refusal: *"This runbook does not contain an approved answer. Recommend escalation."* Every reply carries an advisory banner, and a unit test asserts the code contains no `subprocess`, Salesforce client, deploy command, or HTTP call.

### 48. How do you evaluate a knowledge assistant?

**Answer.** Build a fixed question set with both **covered** questions, which have a known correct source, and **uncovered** ones, which must be refused. Measure correct answers, citation accuracy, correct refusals, and hallucinations, each with a precise definition. Re-run the set on every content change.

**In this project.** The set has 30 questions: 20 covered and 10 uncovered. The uncovered ones are things the support pages deliberately don't cover, such as card storage, Flosum installation, a shared admin password, mass delete, disabling MFA, and creating a sandbox. A *hallucination* is any answer that isn't the cited body verbatim, or a refusal with extra text or a citation. Results: **20/20 correct answers, 100% citation accuracy, 10/10 correct refusals, 0 hallucinations**. I reproduced them with `run_eval.py`. The limit is stated too: the score shows retrieval and refusal, not that anyone completed a task in an org.

### 49. What are the trade-offs between retrieval-only and generative assistants for support knowledge?

**Answer.** Generative assistants handle paraphrase and synthesis well, but they can invent steps that sound right. That's dangerous in admin work, where a wrong click path can change security or data. Retrieval-only assistants are precise and auditable, but miss paraphrased questions. The right choice depends on the cost of a wrong answer.

**In this project.** I chose precision. Keyword-phrase matching with a hard refusal means a question that only shares a loose word with a page is refused, and that's intentional. The cost is lower recall on paraphrased questions. The mitigation is content work, not a looser retriever: add keyword phrases or new sections, and extend the evaluation set. The roadmap explicitly forbids extending the assistant to deploy, assign permissions, or answer from outside the guides and runbooks.

### 50. How do you keep a knowledge base maintainable and safe as it grows?

**Answer.** Treat each answer as a reviewed unit with a stable ID, fixed structure, and an owner. Validate structure automatically. Keep the corpus deliberately scoped. Grow the evaluation set with the content, including topics you deliberately leave uncovered.

**In this project.** A new answer is a new `##` section with a stable ID like `L2:Release Failures` and a mandatory `Keywords:` line. `ingest.py` fails on a missing keywords line, an empty body, or a duplicate ID. Sections are reviewed like support macros: one symptom, one resolution, one escalation line. Each new topic gets a covered question in `questions.json`, or is deliberately left uncovered with a refusal expected. The corpus excludes design notes on purpose, so a fact that lives only in a design document can never become an answer.

---

## Closing: the 30-second project summary

> "I built a Salesforce functional operations portfolio on Developer Edition. Four personas and twelve requirements drive eight custom fields, six validation rules, four Draft flows, seven permission sets in four groups, and ten reports with two dashboards. The release path is documented: scratch org to Org B to Org A, with seven gates, two separable packages, and a tabletop rollback, because there are no sandboxes. Support is two guides and L1 and L2 runbooks, 23 sections in all, behind a retrieval assistant that scored 20 of 20 correct answers, 10 of 10 correct refusals, and zero hallucinations. Nothing is deployed yet. Connecting the two orgs is the next step."
