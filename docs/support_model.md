# Support model

Support is a reading path. The person with the problem starts on a user-guide page. If the page does not cover the symptom, they use the L1 runbook. If the L1 entry says to escalate, they use the L2 runbook or Ops Admin, as that entry states. The how-to assistant retrieves those pages. It does not perform the steps.

## Tiers

| Tier | Who uses it | What it covers | Where it stops |
| --- | --- | --- | --- |
| Sales Rep guide | Sales Rep | Qualify a lead, update the pipeline, close an opportunity, run the personal pipeline report | Cases, setup, deletes, and any task that is not on the page |
| Support Agent guide | Support Agent L1 | Create a case, record the first response, escalate, and the L1 limits | Team reports, case transfer, resolution notes, setup |
| L1 runbook | The person handling the first support question | Login, MFA, visibility, missing data, report access, dashboard access, case reassignment | Permission changes, flow edits, deploys |
| L2 runbook | Support Lead L2, before Ops Admin | Flow faults, validation rules, permission-set symptoms, release failures, data corrections, reporting discrepancies | Assigning permissions, deploying, activating flows, editing records from the assistant |

Ops Admin remains the only role that assigns groups, manages users, and promotes a release. That work stays in the release plan. It is not a fifth user guide.

## How a question moves

1. Match the task to a guide page and follow the numbered steps.
2. If the symptom is access, a missing row, or ownership, open the matching L1 entry.
3. Follow that entry's escalation criteria. Do not skip them because a workaround seems faster.
4. L2 checks the six second-line entries. When the criteria name Ops Admin, stop there.
5. The assistant may quote the page. The person still performs every click, save, and approval.

Two Salesforce CRM licenses cannot host four personas at once. Support reproduces the problem with the login that holds that persona, then changes the user. Shared passwords are out of bounds.

## What support will not do

- Invent a click path that is not written down.
- Turn off MFA, share a password, or grant Modify All Data to finish a ticket.
- Delete records to make a report match.
- Activate the four Draft flows outside a release work item.
- Treat Flosum as a support tool. Flosum access is Not Executed.
- Treat Org A as a customer production org, or Org B as a sandbox.
