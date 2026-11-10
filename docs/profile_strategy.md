# Profile strategy

Profiles are minimum-access shells. They do not grant business object permissions. Create, read, edit, delete, field access, and system permissions live on permission sets. A user receives one permission set group for their persona.

Four custom profiles use the Salesforce user license. None of them contains `objectPermissions`. None of them sets login IP ranges or login hours, so they do not add a network or time restriction beyond the org password and MFA policy. Login host for these Developer Edition users remains `https://login.salesforce.com`.

## What each profile contains

| Profile | Default app | Also visible | Page assignments |
| --- | --- | --- | --- |
| Sales Rep | Lightning Sales | Sales only | Lead-Sales Rep, Opportunity-Sales Rep |
| Support Agent L1 | Lightning Service | Service only | Case-Support Agent L1 |
| Support Lead L2 | Lightning Service | Service only | Case-Support Lead L2, Opportunity-Support Lead L2 |
| Ops Admin | All Tabs | Sales and Service | Lead-Ops Admin, Opportunity-Ops Admin, Case-Ops Admin, User-Ops Admin |

A user with only the profile, and no permission set group, cannot create or edit leads, opportunities, or cases. That is the minimum-access check in persona testing.

## Why the business permissions are not on the profile

Page layout and app choice follow the job. Access changes more often than the page. A permission set group can gain a later permission set, such as a reporting set, without cloning a profile or rebuilding layout assignments.

The Ops Admin profile still does not include Customize Application or Manage Users. Those system permissions are on the Ops Admin permission set.

## Permission sets

| Permission set | Persona | Object access | Field exceptions | System permissions |
| --- | --- | --- | --- | --- |
| Sales_Rep | Sales Rep | Lead create, read, edit. Opportunity create, read, edit. Account and Contact read. User read. No Case. No delete. | Product Interest edit. Next Step edit. Persona read. | None |
| Support_L1 | Support Agent L1 | Case create, read, edit. Account and Contact read. User read. No Lead or Opportunity. No delete. | First Response, Escalation Reason, and Escalated By edit. Resolution Notes and Return Guidance read-only. Persona read. | None |
| Support_L2 | Support Lead L2 | Case read and edit, view all cases. Opportunity, Account, and Contact read. User read. No delete. | First Response read-only. Other case custom fields edit. Next Step read-only. Persona read. | Transfer Cases |
| Ops_Admin | Ops Admin | Create, read, edit, and delete on Lead, Account, Contact, Opportunity, and Case, with view all. User read and edit, view all users. | All project custom fields edit, including Persona. | View Setup, Customize Application, Manage Users, View All Users |

No permission set includes Modify All Data. Ops Admin is still a Developer Edition project admin, not a customer production administrator.

Record visibility also depends on org-wide defaults and queue membership. Those defaults are not deployed in this milestone. Intended defaults when an org is connected: Private for Lead, Opportunity, and Case; Public Read Only for Account and Contact. Queue membership is the public group Support_L1 or Support_L2.

## Permission set groups

| Group | Contains | Persona |
| --- | --- | --- |
| Sales Rep | Sales_Rep, Reporting_Sales | Sales Rep |
| Support Agent L1 | Support_L1 | Support Agent L1 |
| Support Lead L2 | Support_L2, Reporting_Support | Support Lead L2 |
| Ops Admin | Ops_Admin, Reporting_Admin | Ops Admin |

Grouping is the assignment point. A person gets one group. When a later milestone adds a permission set, it is added to the group once. Users who already have the group pick it up without a second assignment. M4 adds `Reporting_Sales`, `Reporting_Support`, and `Reporting_Admin` this way. Support Agent L1 does not receive a reporting set. The group does not itself create the user or set `User.Persona__c`. Ops Admin sets Persona on the user record so Lightning visibility matches the group.
