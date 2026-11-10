# Persona testing

Manual tests for the four personas. They were not executed. No user is logged into an org. Run them after the metadata is deployed to a scratch org, the permission set group is assigned, `User.Persona__c` is set, and the L1 or L2 user is added to the matching public group.

A profile-only user is the control. That user has the page layout and app, and cannot create a lead, opportunity, or case.

Two Salesforce CRM licenses cannot host four simultaneous users. Run the sales persona on one license, then the support persona on the other, or change the permission set group and Persona on a single extra user between passes. The Ops Admin license stays on the system administrator.

## Sales Rep

Setup: profile Sales Rep, permission set group Sales Rep, Persona = Sales Rep.

| Step | Action | Expected result |
| --- | --- | --- |
| 1 | Create a lead with email and Product Interest Core Product | Save succeeds. Lead Assignment selects route Core Product. Owner changes only if sales.core@org-ops.invalid exists. |
| 2 | Create an opportunity and set Next Step | Save succeeds. |
| 3 | Open a case tab or create a case | Create is denied. The Sales Rep permission set has no Case access. |
| 4 | Edit User.Persona__c | Edit is denied. The field is readable and not editable. |
| 5 | Open Setup | Setup is not available. |

## Support Agent L1

Setup: profile Support Agent L1, permission set group Support Agent L1, Persona = Support Agent L1, member of public group Support L1.

| Step | Action | Expected result |
| --- | --- | --- |
| 1 | Create a case, Priority Medium, Type Question | Case Assignment sets route L1. Owner becomes the L1 Support Queue when the queue is deployed. |
| 2 | Change status from New to Working | First Response At is stamped once. |
| 3 | Change status to Waiting on Customer | First Response At does not change. |
| 4 | Set status to Escalated with a reason and Escalated By | Save succeeds. |
| 5 | Edit Resolution Notes or Return Guidance | Edit is denied by field permissions. |
| 6 | Delete the case | Delete is denied. |
| 7 | Create a lead or edit an opportunity | Create and edit are denied. |

## Support Lead L2

Setup: profile Support Lead L2, permission set group Support Lead L2, Persona = Support Lead L2, member of public group Support L2.

| Step | Action | Expected result |
| --- | --- | --- |
| 1 | Open a case owned by the L1 queue | The case is visible because View All Cases is on. |
| 2 | Move an escalated case to Working and enter Return Guidance | Save succeeds. |
| 3 | Close a case with Resolution Notes | Save succeeds. |
| 4 | Close a case with Resolution Notes blank | `Case_Close_Requires_Resolution` blocks the save. |
| 5 | Edit Opportunity Next Step | Edit is denied. Stage, amount, and close date are visible. |
| 6 | Delete a case | Delete is denied. |
| 7 | Transfer a case to the L1 Support Queue | Transfer succeeds. Transfer Cases is enabled. |

## Ops Admin

Setup: profile Ops Admin, permission set group Ops Admin, Persona = Ops Admin.

| Step | Action | Expected result |
| --- | --- | --- |
| 1 | Set Persona on the other licensed user | Save succeeds. |
| 2 | Edit Product Interest, Next Step, and the case custom fields | Save succeeds. |
| 3 | Open Setup | Setup is available. View Setup and Customize Application are on the permission set. |
| 4 | Confirm Modify All Data is not required for these steps | The permission set does not grant Modify All Data. |

## Profile-only control

| Step | Action | Expected result |
| --- | --- | --- |
| 1 | Assign the Sales Rep profile and no permission set group | The user can log in and open the Sales app. |
| 2 | Create a lead | Create is denied. |

## Flow checks that sit beside the persona tests

| Check | Expected result |
| --- | --- |
| Placeholder owner user does not exist | Lead `Outcome` is OwnerNotFound. The creator remains owner. |
| Queue metadata failed to deploy | Case `Outcome` is QueueNotFound. The creator remains owner. |
| High-priority case is under one day old | Escalation `Outcome` is NotDue. |
| High-priority case is older than one day and an Ops Admin persona user exists | Status becomes Escalated, owner is the L2 queue, and that user gets the Escalation Alert. |
| No user has Persona Ops Admin | Escalation `Outcome` is NoOpsAdmin. The case is not changed. |
