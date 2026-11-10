# Support Agent guide

This guide is for Support Agent L1. Each task below is one page. The assistant does not change Salesforce. A person follows the steps.

## SupportAgent:Create a Case

Keywords: create a case

Page: Support Agent, task 1 of 4

### Steps

1. Create a case. You can create, read, and edit cases you own or that sit in the L1 Support Queue. You cannot delete a case.
2. Leave status at New until you start work. New is the default.
3. Set Priority to Low, Medium, or High, and Origin to Phone, Email, or Web.
4. Set Type to Question, Problem, or Feature Request when you know it.
5. Link the contact and account when you know them. You can read accounts and contacts. You cannot edit leads or opportunities.
6. Add the working notes on the case. Do not keep the only copy in a side chat.

### Expected outcome

The request is a case with owner, status, priority, and origin. A brand-new case stays on New until the first working change.

### Troubleshooting

- Case Assignment is Draft. Creating a case does not yet route it to the L1 or L2 queue. The owner stays the creator until Ops Admin activates that flow under a release.
- If you cannot see a case you do not own and it is not in the L1 Support Queue, that is the access contract. Use the L1 record-visibility page in the runbook. Do not ask for View All Cases.

## SupportAgent:Record the First Response

Keywords: first response at

Page: Support Agent, task 2 of 4

### Steps

1. Open a case whose status is New and whose First Response At is empty.
2. Change the status from New to Working, Waiting on Customer, or another status that is not New. Do this when you first work the case.
3. Leave First Response At empty if it is empty. First Response Tracking stamps it once, when the status leaves New, and only if the field is still empty.
4. Save. Do not clear a time that is already stored. The flow does not overwrite it, and you should not try to.

### Expected outcome

The first time the case leaves New, First Response At receives the current date and time. A later status change does not replace that value.

### Troubleshooting

- The flow is Draft until a release activates it. While it is Draft, the field stays empty unless a person is allowed to set it. L1 can edit the field. Set it only when you are recording the real first response, and set it once.
- If the status was never New, the stamp does not apply. The skip path is for a case that was already past New.

## SupportAgent:Escalate a Case

Keywords: escalation reason

Page: Support Agent, task 3 of 4

### Steps

1. Open the case you own or that is in the L1 Support Queue.
2. Write the escalation reason in Escalation Reason.
3. Set Escalated By to yourself, the agent who is escalating.
4. Set status to Escalated.
5. If either the reason or Escalated By is blank, the save stops with: Enter the escalation reason and the agent who escalated before saving an escalated case.
6. Stop. You do not write Return Guidance or the final Resolution Notes. Those fields are read-only for L1. L2 writes them.

### Expected outcome

The case is Escalated, with a reason and the escalating agent stored on the record. L2 can see it.

### Troubleshooting

- Other statuses do not require the reason or Escalated By.
- The Escalation flow is Draft. It does not move the case to the L2 queue on a timer until Ops Admin activates it under a release. Your manual escalation is still valid.
- You cannot transfer a case you do not own. Transfer Cases is an L2 permission. Use the case-reassignment runbook page.

## SupportAgent:Working Limits

Keywords: what l1 cannot change

Page: Support Agent, task 4 of 4

### Steps

1. Work only cases you own or cases in the L1 Support Queue.
2. Do not delete a case. The L1 permission set does not allow delete.
3. Do not edit a lead or an opportunity.
4. Do not run the Sales Leadership or Support Leadership reports. The L1 permission set group does not include Run Reports. The all-team backlog is an L2 report.
5. Do not assign permission sets, change profiles, or deploy a release. Those are Ops Admin actions.
6. When a limit blocks the task, stop and use the L1 runbook. If the runbook says to escalate, escalate to Support Lead L2 or Ops Admin as that page states.

### Expected outcome

L1 work stays on owned and queue cases. Setup, releases, and the all-team dashboard stay with the roles that have those permissions.

### Troubleshooting

- User.Persona__c does not grant access. A blank or wrong persona changes Lightning guidance. It does not give you cases, reports, or setup.
- Membership of the L1 Support Queue is the public group Support_L1. Assigning the permission set group does not add you to that public group. Ops Admin adds the user to the group.

## SupportAgent:Quick Reference

Keywords: support agent quick reference

Page: Support Agent quick reference

| Task | Do this | Stop when |
| --- | --- | --- |
| New request | Create a case on New, with priority and origin | You need to delete the case |
| First work | Leave New, once | First Response At already has a value |
| Escalate | Reason, Escalated By, then status Escalated | You are about to type resolution notes or return guidance |
| Someone else's case | Only if it is in the L1 Support Queue | It is owned by another person and not in your queue |

### Expected outcome

You can pick the page that matches the task without opening setup.

### Troubleshooting

- If the task is not in the table, do not invent a click path. Open the L1 runbook or escalate.
- You cannot run the team reports, transfer any case, or change users.
