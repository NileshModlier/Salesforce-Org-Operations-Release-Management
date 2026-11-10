# Requirement traceability

Each story maps to the metadata that implements it. Reports and dashboards are in M4. The chain from requirement to flow to report to dashboard is below.

| Requirement | Metadata component | M2 coverage |
| --- | --- | --- |
| REQ-001 | Opportunity.Next_Step__c, Opportunity-Sales Rep, Opportunity_Record_Page, OpportunityStage, Pipeline_By_Stage, Open_Opportunity_Value, Opportunities_Closing_This_Month | Stage, amount, close date, and next step are on the sales layout and on the sales reports. |
| REQ-002 | OpportunityStage, Opportunity_Closed_Won_Requires_Amount, Opportunity_Record_Page | The six-stage path is the standard value set. Closed Won and Closed Lost are the only closed stages. Closed Won requires an amount greater than zero. |
| REQ-003 | LeadStatus, Lead.Product_Interest__c, Lead_Requires_Email_Or_Phone, Lead_Convert_Requires_Qualified, Lead-Sales Rep, Lead_Record_Page | Status values, product interest, email or phone, and the convert gate are in metadata. |
| REQ-004 | Lead_Convert_Requires_Qualified, Lead-Sales Rep, Lead_Record_Page | Conversion still uses the standard convert action, which creates an account, contact, and opportunity. No custom conversion mapping was added. |
| REQ-005 | CaseStatus, Case-Support Agent L1, Case_Record_Page | New is the default status. Subject, description, origin, priority, contact, and account are on the L1 layout and record page. |
| REQ-006 | Case.First_Response_At__c, CaseStatus, Case-Support Agent L1, Case_Record_Page, First_Response_Tracking | The before-save flow stamps First Response At once when status leaves New. |
| REQ-007 | Case.Escalation_Reason__c, Case.Escalated_By__c, Case_Escalation_Requires_Reason, CaseStatus, Case-Support Agent L1, Escalation, L2_Escalation | Manual escalation still requires a reason and a user. The scheduled escalation flow fills both when it moves an aged high-priority case to the L2 queue. |
| REQ-008 | Case.Return_Guidance__c, Case.Resolution_Notes__c, Case_Return_Requires_Guidance, Case_Close_Requires_Resolution, Case-Support Lead L2, Case_Record_Page | Return and close rules are active. Taking ownership from a queue is not configured. |
| REQ-009 | Pipeline_By_Stage, Sales_Dashboard, Reporting_Sales | The report runs on Opportunity, groups by stage, and includes amount, close date, and next step. Scope is the running user. |
| REQ-010 | Cases_By_Status, Open_Cases_By_Priority, Support_Dashboard, Reporting_Support | The matrix groups by status and priority and shows owner and opened date. L2 can run it. L1 has no Run Reports permission. |
| REQ-011 | User.Persona__c, Sales_Rep, Support_L1, Support_L2, Ops_Admin, Sales_Rep profile, Support_Agent_L1 profile, Support_Lead_L2 profile, Ops_Admin profile | Permission sets enforce the access contract. Profiles hold page layouts and apps only. |
| REQ-012 | User.Persona__c, User-Ops Admin, Ops_Admin | Persona remains a visibility label. The Ops Admin permission set grants Manage Users and Customize Application. It does not grant Modify All Data. |

## Component index

| Component | Requirements |
| --- | --- |
| Lead.Product_Interest__c | REQ-003 |
| Opportunity.Next_Step__c | REQ-001, REQ-009 |
| Case.First_Response_At__c | REQ-006 |
| Case.Escalation_Reason__c | REQ-007 |
| Case.Escalated_By__c | REQ-007 |
| Case.Return_Guidance__c | REQ-008 |
| Case.Resolution_Notes__c | REQ-008 |
| User.Persona__c | REQ-011, REQ-012 |
| Lead_Requires_Email_Or_Phone | REQ-003 |
| Lead_Convert_Requires_Qualified | REQ-003, REQ-004 |
| Opportunity_Closed_Won_Requires_Amount | REQ-001, REQ-002 |
| Case_Escalation_Requires_Reason | REQ-007 |
| Case_Close_Requires_Resolution | REQ-008 |
| Case_Return_Requires_Guidance | REQ-008 |
| Lead_Record_Page | REQ-003, REQ-004, REQ-011 |
| Opportunity_Record_Page | REQ-001, REQ-002, REQ-009, REQ-011 |
| Case_Record_Page | REQ-005, REQ-006, REQ-008, REQ-010, REQ-011 |

## Release chain

Requirement, metadata, release package, and validation script. Release 1 is the operating process. Release 2 is leadership reporting. Neither package has been deployed. The full table is in [release_management.md](release_management.md).

| Requirement | Metadata | Release | Validation |
| --- | --- | --- | --- |
| REQ-001 | Next_Step__c, OpportunityStage, Pipeline_By_Stage | Release 1 and Release 2 | validate-m2.ps1, validate-m4.ps1 |
| REQ-002 | Opportunity_Closed_Won_Requires_Amount | Release 1 | validate-m2.ps1 |
| REQ-003 | Product_Interest__c, Lead_Assignment | Release 1 | validate-m2.ps1, validate-m3.ps1 |
| REQ-004 | Lead_Convert_Requires_Qualified | Release 1 | validate-m2.ps1 |
| REQ-005 | CaseStatus, Case_Record_Page | Release 1 | validate-m2.ps1 |
| REQ-006 | First_Response_Tracking, First_Response_Performance | Release 1 and Release 2 | validate-m3.ps1, validate-m4.ps1 |
| REQ-007 | Escalation, Escalations_By_Priority | Release 1 and Release 2 | validate-m3.ps1, validate-m4.ps1 |
| REQ-008 | Case_Close_Requires_Resolution, Cases_Closed_By_Agent | Release 1 and Release 2 | validate-m2.ps1, validate-m4.ps1 |
| REQ-009 | Pipeline_By_Stage, Sales_Dashboard | Release 2 | validate-m4.ps1 |
| REQ-010 | Cases_By_Status, Support_Dashboard | Release 2 | validate-m4.ps1 |
| REQ-011 | Sales_Rep, Support_L1, Support_L2, Ops_Admin | Release 1 | validate-m3.ps1 |
| REQ-012 | Ops_Admin, Persona__c | Release 1 | validate-m3.ps1 |

## Reporting chain

A row uses None when no flow feeds that metric. Record visibility still follows the running user.

| Requirement | Flow | Report | Dashboard |
| --- | --- | --- | --- |
| REQ-001 | None | Pipeline_By_Stage, Open_Opportunity_Value, Opportunities_Closing_This_Month | Sales_Dashboard |
| REQ-003 | Lead_Assignment | Lead_Conversion_By_Source, Conversion_Rate | Sales_Dashboard |
| REQ-006 | First_Response_Tracking | First_Response_Performance | Support_Dashboard |
| REQ-007 | Escalation | Escalations_By_Priority | Support_Dashboard |
| REQ-008 | None | Cases_Closed_By_Agent | Support_Dashboard |
| REQ-009 | None | Pipeline_By_Stage | Sales_Dashboard |
| REQ-010 | Case_Assignment | Cases_By_Status, Open_Cases_By_Priority | Support_Dashboard |
