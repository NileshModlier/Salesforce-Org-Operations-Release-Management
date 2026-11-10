# Requirements

Twelve user stories define the operating model for sales pipeline, lead qualification, case management, escalation, reporting, and access control. They are acceptance targets for later milestones. M1 does not build the fields, automation, reports, or security that would satisfy them.

Personas are defined in [personas](personas.md). Environment limits that constrain these stories are in [environment strategy](environment_strategy.md).

## Process contract

Later milestones use these values unless a story is explicitly changed. M2 implements them in standard value sets. See [data model](data_model.md).

Opportunity stage path:

1. Prospecting
2. Qualification
3. Proposal
4. Negotiation
5. Closed Won
6. Closed Lost

Lead status:

- Open - Not Contacted
- Working - Contacted
- Qualified
- Unqualified

A lead is eligible for conversion only when status is Qualified.

Case status:

- New
- Working
- Waiting on Customer
- Escalated
- Closed

Case priority: Low, Medium, High.

Case origin: Phone, Email, Web.

Queues named by this contract, and not created in M1:

- L1 Support Queue
- L2 Escalation Queue

## Stories

### REQ-001

- **Requirement ID:** REQ-001
- **Theme:** Sales Pipeline
- **User Story:** As a Sales Rep, I want a list of the opportunities I own so that I can see which deals need attention.
- **Acceptance Criteria:**
  - The list includes only opportunities owned by the running user.
  - Each row shows stage, amount, and close date.
  - The stages shown are Prospecting, Qualification, Proposal, Negotiation, Closed Won, and Closed Lost.
  - The rep can open the list without access to another rep's opportunities.
- **Priority:** High
- **Persona:** Sales Rep

### REQ-002

- **Requirement ID:** REQ-002
- **Theme:** Sales Pipeline
- **User Story:** As a Sales Rep, I want every opportunity to follow one stage path so that a pipeline review uses the same meanings for every deal.
- **Acceptance Criteria:**
  - The stage path is Prospecting, Qualification, Proposal, Negotiation, Closed Won, and Closed Lost.
  - Closed Won and Closed Lost are the only terminal stages.
  - A stage change is visible on the opportunity.
  - The same path is the target for scratch org development, Org B, and Org A once a later milestone deploys it.
- **Priority:** High
- **Persona:** Sales Rep

### REQ-003

- **Requirement ID:** REQ-003
- **Theme:** Lead Qualification
- **User Story:** As a Sales Rep, I want to mark a lead Qualified or Unqualified before conversion so that the pipeline starts from a real sales conversation.
- **Acceptance Criteria:**
  - Lead status includes Open - Not Contacted, Working - Contacted, Qualified, and Unqualified.
  - Conversion is allowed only when status is Qualified.
  - An Unqualified lead stays unconverted.
  - Qualification uses the lead's name, company, and a phone number or email address.
- **Priority:** High
- **Persona:** Sales Rep

### REQ-004

- **Requirement ID:** REQ-004
- **Theme:** Lead Qualification
- **User Story:** As a Sales Rep, I want conversion of a qualified lead to produce an account, a contact, and an opportunity so that the handoff into the pipeline is traceable.
- **Acceptance Criteria:**
  - Conversion creates an opportunity on the documented stage path.
  - The new contact is related to the account.
  - The converted lead stays linked to the account, contact, and opportunity.
  - When an account for the same company is already visible to the rep, the rep can use that account instead of creating a duplicate.
- **Priority:** High
- **Persona:** Sales Rep

### REQ-005

- **Requirement ID:** REQ-005
- **Theme:** Case Management
- **User Story:** As a Support Agent L1, I want to open a case from a customer request so that the request has an owner, a status, and a priority.
- **Acceptance Criteria:**
  - The case records subject, description, origin, status, and priority.
  - Origin is Phone, Email, or Web.
  - Priority is Low, Medium, or High.
  - Initial status is New.
  - The case is related to a contact when the contact is known, and to an account when the account is known.
- **Priority:** High
- **Persona:** Support Agent L1

### REQ-006

- **Requirement ID:** REQ-006
- **Theme:** Case Management
- **User Story:** As a Support Agent L1, I want to move a case through working statuses and record what I did so that the next person can see the history.
- **Acceptance Criteria:**
  - L1 working statuses are New, Working, and Waiting on Customer.
  - Each customer or internal update is stored on the case.
  - L1 can edit cases they own and cases in the L1 Support Queue.
  - L1 cannot delete a case.
- **Priority:** High
- **Persona:** Support Agent L1

### REQ-007

- **Requirement ID:** REQ-007
- **Theme:** Escalation
- **User Story:** As a Support Agent L1, I want to escalate a case I cannot resolve so that a Support Lead L2 receives the case and the reason.
- **Acceptance Criteria:**
  - Escalation sets status to Escalated.
  - The case is placed on the L2 Escalation Queue.
  - The escalation stores a written reason on the case.
  - The L1 user who escalated remains identifiable.
  - After the handoff, L1 can read the case and cannot overwrite the L2 resolution.
- **Priority:** High
- **Persona:** Support Agent L1

### REQ-008

- **Requirement ID:** REQ-008
- **Theme:** Escalation
- **User Story:** As a Support Lead L2, I want to take an escalated case, resolve it, or return it to L1 with guidance so that escalations do not sit unowned.
- **Acceptance Criteria:**
  - L2 can see every case in Escalated status before taking ownership.
  - L2 can take ownership from the L2 Escalation Queue.
  - Returning a case sets a working status, assigns an L1 owner or the L1 Support Queue, and stores written guidance on the case.
  - Closing a case sets status to Closed and stores a resolution on the case.
  - L2 cannot delete a case.
- **Priority:** High
- **Persona:** Support Lead L2

### REQ-009

- **Requirement ID:** REQ-009
- **Theme:** Reporting
- **User Story:** As a Sales Rep, I want a pipeline report of my opportunities by stage so that I can explain my book in a forecast conversation.
- **Acceptance Criteria:**
  - The report runs on Opportunity.
  - Rows are grouped by stage.
  - The report includes amount and close date.
  - The report is filtered to opportunities owned by the running user.
  - A Sales Rep can run it. Creating the report is a later milestone.
- **Priority:** Medium
- **Persona:** Sales Rep

### REQ-010

- **Requirement ID:** REQ-010
- **Theme:** Reporting
- **User Story:** As a Support Lead L2, I want a case backlog report by status, priority, and owner so that I can see workload and escalation load.
- **Acceptance Criteria:**
  - The report runs on Case.
  - The report groups by status and priority.
  - The report shows case owner and opened date.
  - Support Lead L2 can run it across support cases.
  - Support Agent L1 is not a consumer of the all-team version of this report.
- **Priority:** Medium
- **Persona:** Support Lead L2

### REQ-011

- **Requirement ID:** REQ-011
- **Theme:** Access Control
- **User Story:** As an Ops Admin, I want each persona limited to the records their job requires so that sales work and support work stay separated.
- **Acceptance Criteria:**
  - Sales Rep target access is create, read, and edit on own leads; read on accounts and contacts; create, read, and edit on own opportunities; no case access; no setup access.
  - Support Agent L1 target access is create, read, and edit on cases they own or that are in the L1 Support Queue; read on accounts and contacts; no lead or opportunity edit; no case delete; no setup access.
  - Support Lead L2 target access is read and edit on support cases, including cases they do not yet own; transfer of those cases; read on accounts, contacts, and opportunities; no case delete; no setup access.
  - Ops Admin target access is customize application, manage users, and manage the reports this project defines, inside Developer Edition license limits.
  - This story is the access contract. Profiles, permission sets, and permission set groups are not created in M1.
- **Priority:** High
- **Persona:** Ops Admin

### REQ-012

- **Requirement ID:** REQ-012
- **Theme:** Access Control
- **User Story:** As an Ops Admin, I want setup and user administration limited to the Ops Admin role so that reps and agents cannot change the security model.
- **Acceptance Criteria:**
  - Sales Rep, Support Agent L1, and Support Lead L2 cannot manage users, profiles, permission sets, permission set groups, or sharing.
  - Only the Ops Admin authors those controls, and only in the milestone that implements the security model.
  - Any future login uses a named user. Shared passwords are out of bounds.
  - The access contract fits Developer Edition license limits: two Salesforce CRM users, so the four personas are roles rather than four simultaneous CRM logins.
- **Priority:** High
- **Persona:** Ops Admin

## Coverage

| Theme | Stories | Primary persona |
| --- | --- | --- |
| Sales Pipeline | REQ-001, REQ-002 | Sales Rep |
| Lead Qualification | REQ-003, REQ-004 | Sales Rep |
| Case Management | REQ-005, REQ-006 | Support Agent L1 |
| Escalation | REQ-007, REQ-008 | Support Agent L1, Support Lead L2 |
| Reporting | REQ-009, REQ-010 | Sales Rep, Support Lead L2 |
| Access Control | REQ-011, REQ-012 | Ops Admin |

| Priority | Count | Stories |
| --- | --- | --- |
| High | 10 | REQ-001 through REQ-008, REQ-011, REQ-012 |
| Medium | 2 | REQ-009, REQ-010 |
| Low | 0 | None in M1 |

## Inputs the next milestone still needs

- Authenticate Org A and Org B, then read Company Information. Expected Salesforce CRM licenses: 2. Expected Service Cloud user licenses: 0. Confirm both before assigning logins.
- Keep demo data small. Developer Edition data storage is 5 MB.
- Choose how two CRM logins will demonstrate four roles. Permission sets can switch one licensed user between Sales Rep and a support role. That choice belongs to the security milestone.
- M2 stores escalation reason, return guidance, and resolution notes on Case. Field definitions are in [data model](data_model.md).
