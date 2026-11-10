# Layout strategy

M2 page strategy for the four personas. Layouts show the business fields for that role. Lightning record pages add dynamic visibility on top of one shared desktop page per object.

Object security is not on these pages. A layout can hide a field from view and still leave it available to the API. Profiles, permission sets, and permission set groups are a later milestone.

## Persona layouts

| Layout | Persona | What it shows |
| --- | --- | --- |
| Lead-Sales Rep | Sales Rep | Name, company, status, title, email, phone, product interest, lead source, owner. No case fields. |
| Lead-Ops Admin | Ops Admin | The sales lead fields plus created and last-modified audit fields. |
| Opportunity-Sales Rep | Sales Rep | Name, account, stage, amount, close date, next step, read-only probability, owner, description. |
| Opportunity-Support Lead L2 | Support Lead L2 | Commercial context only. Amount, next step, probability, account, and owner are read-only. Name, stage, and close date stay editable on the layout because Salesforce requires those fields to be editable on an opportunity layout. The Lightning page shows them read-only for this persona. |
| Opportunity-Ops Admin | Ops Admin | Full pipeline fields, including editable probability, plus audit fields. |
| Case-Support Agent L1 | Support Agent L1 | Subject, status, priority, origin, contact, account, owner, description, first response, escalation reason, escalated by. Return guidance and resolution notes are read-only. |
| Case-Support Lead L2 | Support Lead L2 | The L1 case fields, with first response read-only and return guidance plus resolution notes editable. |
| Case-Ops Admin | Ops Admin | Every case business field editable, plus audit fields. |
| User-Ops Admin | Ops Admin | The fields required to maintain a user, plus Persona. |

Sales Rep has no case layout. Support Agent L1 has no lead or opportunity layout. Support Lead L2 has no lead layout.

Assignment of a layout to a profile is not in this milestone. The files exist so the security milestone can assign them without redesigning the field set.

## Lightning record pages

| Page | Object | Template |
| --- | --- | --- |
| Lead_Record_Page | Lead | flexipage:recordHomeTemplateDesktop |
| Opportunity_Record_Page | Opportunity | flexipage:recordHomeTemplateDesktop |
| Case_Record_Page | Case | flexipage:recordHomeTemplateDesktop |

Each page has a highlights panel, dynamic form sections, role guidance, record-state guidance, and related lists. There is no second detail panel, so fields are not shown twice.

Dynamic forms in this template are desktop behavior. Until Dynamic Forms on Mobile is enabled, a phone uses the assigned page layout. That is why the persona layouts still carry the field set.

## Dynamic visibility

Record state:

| Component | Visible when |
| --- | --- |
| Lead qualified guidance | Lead Status equals Qualified |
| Lead unqualified guidance | Lead Status equals Unqualified |
| Opportunity Closed Won guidance | Stage equals Closed Won |
| Opportunity Closed Lost guidance | Stage equals Closed Lost |
| Case escalated guidance | Case Status equals Escalated |
| Case closed guidance | Case Status equals Closed |

Role-based components use `User.Persona__c`, with one Ops Admin note that also shows for the System Administrator profile:

| Component | Visible when |
| --- | --- |
| Sales Rep guidance on Lead and Opportunity | Persona equals Sales Rep |
| L1 guidance on Case | Persona equals Support Agent L1 |
| L2 guidance on Case and Opportunity | Persona equals Support Lead L2 |
| Editable opportunity pipeline section | Persona is not Support Lead L2 |
| Read-only opportunity section | Persona equals Support Lead L2 |
| Case handling section | Persona is not Sales Rep |
| Editable first response | Persona is not Support Lead L2 and not Sales Rep |
| Read-only first response | Persona equals Support Lead L2 |
| Editable return guidance and resolution notes | Persona is not Support Agent L1 and not Sales Rep |
| Read-only return guidance and resolution notes | Persona equals Support Agent L1 |
| Ops Admin note | Persona equals Ops Admin, or Profile Name equals System Administrator |

A blank Persona is not equal to Sales Rep, Support Agent L1, or Support Lead L2, so an untagged user sees the editable support and pipeline sections. Set Persona before demonstrating a role. Ops Admin should set their own user to Ops Admin.

Field-section visibility is evaluated when the page loads, not while the user is still editing. Required notes therefore stay on the page for the persona who must type them. Status banners appear after save. Hiding Escalation Reason until status is already Escalated would block the save the validation rule is there to check.

## Page activation

Not activated. No org is connected, and this milestone does not edit profiles.

When a scratch org exists, activate:

1. Lead_Record_Page as the org default for Lead.
2. Opportunity_Record_Page as the org default for Opportunity.
3. Case_Record_Page as the org default for Case.

Activate them for the desktop form factor. Leave the persona layouts in place for mobile and for profile assignment in the security milestone.

Do not activate a different record page per persona. One page per object carries the visibility rules. Persona-specific layouts remain the mobile and fallback field sets.
