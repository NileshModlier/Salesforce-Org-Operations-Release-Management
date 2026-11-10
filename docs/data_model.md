# Data model

M2 field configuration for REQ-001 through REQ-012. No custom objects. Standard fields already required by the stories (opportunity amount, stage, close date, lead name, company, email, phone, case subject, status, priority, origin, contact, account) stay standard. Custom fields exist only where the standard object has no place to store the story. M3 flows write First Response At and, on an automatic escalation, Escalation Reason and Escalated By.

Deploy status: not deployed. The Salesforce CLI is not installed in this workspace, and Org A, Org B, and the scratch org are not connected.

## Standard value sets

These replace the picklist values the process contract names. They are field configuration, not new objects.

| Value set | Values | Closed or converted | Requirement |
| --- | --- | --- | --- |
| Lead Status | Open - Not Contacted (default), Working - Contacted, Qualified, Unqualified, Closed - Converted | Only Closed - Converted is converted | REQ-003, REQ-004 |
| Opportunity Stage | Prospecting (default, 10%), Qualification (20%), Proposal (50%), Negotiation (80%), Closed Won (100%), Closed Lost (0%) | Closed Won is closed and won. Closed Lost is closed and not won. | REQ-001, REQ-002 |
| Case Status | New (default), Working, Waiting on Customer, Escalated, Closed | Only Closed is a closed status | REQ-005, REQ-006, REQ-007, REQ-008 |

Closed - Converted is the platform status the convert action writes. Reps set Qualified first. `Lead_Convert_Requires_Qualified` checks the status from before that write.

Deploying these value sets onto an org that already has leads, opportunities, or cases on omitted values will fail. A new scratch org does not have that data. Org A and Org B have not been checked.

Case priority stays Low, Medium, High. Case origin stays Phone, Email, Web. M3 adds Case Type values Question, Problem, and Feature Request so case assignment can route on type.

## Lead.Product_Interest__c

| Attribute | Value |
| --- | --- |
| Purpose | Records what the lead wants to talk about during qualification. |
| Type | Picklist. Restricted. Core Product, Add-on Service, Renewal, Undecided. Optional. |
| Used By | Sales Rep, Ops Admin |
| Requirement | REQ-003 |

## Opportunity.Next_Step__c

| Attribute | Value |
| --- | --- |
| Purpose | States the next action on an owned deal so a pipeline review can see which opportunity needs attention. |
| Type | Text, 255 characters. Optional. |
| Used By | Sales Rep edits it. Support Lead L2 sees it read-only. Ops Admin edits it. |
| Requirement | REQ-001 |

## Case.First_Response_At__c

| Attribute | Value |
| --- | --- |
| Purpose | Records when the case first left New. First Response Tracking stamps it once and does not overwrite a value that is already there. |
| Type | Date/Time. Optional. |
| Used By | Support Agent L1 edits it. Support Lead L2 sees it read-only. Ops Admin edits it. |
| Requirement | REQ-006 |

## Case.Escalation_Reason__c

| Attribute | Value |
| --- | --- |
| Purpose | Stores why the case left L1. Required by validation only when status is Escalated, so a new case can be saved without it. |
| Type | Long text, 1,000 characters, 4 visible lines. Optional on the field. |
| Used By | Support Agent L1, Support Lead L2, Ops Admin |
| Requirement | REQ-007 |

## Case.Escalated_By__c

| Attribute | Value |
| --- | --- |
| Purpose | Identifies who is recorded on an escalation. L1 sets it for a manual escalation. The Escalation flow supplies the Ops Admin user when the field is blank so the validation rule can pass. |
| Type | Lookup to User. Optional on the field. |
| Used By | Support Agent L1, Support Lead L2, Ops Admin |
| Requirement | REQ-007 |

## Case.Return_Guidance__c

| Attribute | Value |
| --- | --- |
| Purpose | Stores what L1 should do when L2 sends an escalated case back to New, Working, or Waiting on Customer. |
| Type | Long text, 1,000 characters, 4 visible lines. Optional on the field. |
| Used By | Support Lead L2 and Ops Admin edit it. Support Agent L1 sees it read-only. |
| Requirement | REQ-008 |

## Case.Resolution_Notes__c

| Attribute | Value |
| --- | --- |
| Purpose | Stores how the case was resolved. Required by validation only when status is Closed. |
| Type | Long text, 1,000 characters, 4 visible lines. Optional on the field. |
| Used By | Support Lead L2 and Ops Admin edit it. Support Agent L1 sees it read-only. |
| Requirement | REQ-008 |

## User.Persona__c

| Attribute | Value |
| --- | --- |
| Purpose | Labels which operating role a user is demonstrating so Lightning pages can show the matching guidance and field behavior. It does not grant object access, change a profile, or replace a permission set. |
| Type | Picklist. Restricted. Sales Rep, Support Agent L1, Support Lead L2, Ops Admin. Optional. |
| Used By | Ops Admin sets it on the user. Every persona is a value. |
| Requirement | REQ-011, REQ-012 |

## What this model does not add

- No custom objects, record types, or formula fields.
- Reports and dashboards use the fields already on the layouts. No extra report-only fields were added.
- M3 adds the L1 Support Queue, the L2 Escalation Queue, and the flows that stamp First Response At and fill Escalated By on an automatic escalation.
