# Validation rule test cases

Manual examples for the six M2 validation rules. They were not executed. No scratch org has been created in this workspace.

Each example assumes the other required standard fields are filled: lead name and company, opportunity name and close date, case subject.

## Lead_Requires_Email_Or_Phone

| Example | Expected | Data |
| --- | --- | --- |
| PASS 1 | Save succeeds | Status Open - Not Contacted, Email a@example.com, Phone blank |
| PASS 2 | Save succeeds | Status Working - Contacted, Email blank, Phone 415-555-0100 |
| PASS 3 | Save succeeds | Status Qualified, Email a@example.com, Phone 415-555-0100 |
| FAIL 1 | Save blocked on Email | Status Open - Not Contacted, Email blank, Phone blank |
| FAIL 2 | Save blocked on Email | Existing lead updated so Email and Phone are both cleared |
| FAIL 3 | Save blocked on Email | Email blank, Phone blank, Mobile phone 415-555-0199. Mobile does not count. |

## Lead_Convert_Requires_Qualified

| Example | Expected | Data |
| --- | --- | --- |
| PASS 1 | Convert succeeds | Status Qualified, Email a@example.com, then Convert |
| PASS 2 | Convert succeeds | Status Qualified, Phone 415-555-0100, Email blank, then Convert |
| PASS 3 | Convert succeeds | Status Qualified, product interest Core Product, Email a@example.com, then Convert and attach an existing account |
| FAIL 1 | Convert blocked on Status | Status Open - Not Contacted, Email a@example.com, then Convert |
| FAIL 2 | Convert blocked on Status | Status Working - Contacted, Email a@example.com, then Convert |
| FAIL 3 | Convert blocked on Status | Status Unqualified, Email a@example.com, then Convert |

## Opportunity_Closed_Won_Requires_Amount

| Example | Expected | Data |
| --- | --- | --- |
| PASS 1 | Save succeeds | Stage Closed Won, Amount 1000 |
| PASS 2 | Save succeeds | Stage Prospecting, Amount blank |
| PASS 3 | Save succeeds | Stage Closed Lost, Amount blank |
| FAIL 1 | Save blocked on Amount | Stage Closed Won, Amount blank |
| FAIL 2 | Save blocked on Amount | Stage Closed Won, Amount 0 |
| FAIL 3 | Save blocked on Amount | Stage Closed Won, Amount -25 |

## Case_Escalation_Requires_Reason

| Example | Expected | Data |
| --- | --- | --- |
| PASS 1 | Save succeeds | Status New, Escalation Reason blank, Escalated By blank |
| PASS 2 | Save succeeds | Status Working, both escalation fields blank |
| PASS 3 | Save succeeds | Status Escalated, Escalation Reason "Needs a product specialist", Escalated By set to the L1 user |
| FAIL 1 | Save blocked on Escalation Reason | Status Escalated, Escalation Reason blank, Escalated By set |
| FAIL 2 | Save blocked on Escalation Reason | Status Escalated, Escalation Reason "Needs a product specialist", Escalated By blank |
| FAIL 3 | Save blocked on Escalation Reason | Status Escalated, Escalation Reason blank, Escalated By blank |

## Case_Close_Requires_Resolution

| Example | Expected | Data |
| --- | --- | --- |
| PASS 1 | Save succeeds | Status Working, Resolution Notes blank |
| PASS 2 | Save succeeds | Status Escalated, reason and Escalated By filled, Resolution Notes blank |
| PASS 3 | Save succeeds | Status Closed, Resolution Notes "Password reset completed" |
| FAIL 1 | Save blocked on Resolution Notes | Status Closed, Resolution Notes blank |
| FAIL 2 | Save blocked on Resolution Notes | Status changed from Working to Closed with Resolution Notes blank |
| FAIL 3 | Save blocked on Resolution Notes | Status changed from Escalated to Closed with Resolution Notes cleared |

## Case_Return_Requires_Guidance

| Example | Expected | Data |
| --- | --- | --- |
| PASS 1 | Save succeeds | New case inserted as Working, Return Guidance blank |
| PASS 2 | Save succeeds | Status stays Escalated, Return Guidance blank, reason and Escalated By filled |
| PASS 3 | Save succeeds | Status changed from Escalated to Working, Return Guidance "Ask the customer for the account number" |
| FAIL 1 | Save blocked on Return Guidance | Status changed from Escalated to Working, Return Guidance blank |
| FAIL 2 | Save blocked on Return Guidance | Status changed from Escalated to New, Return Guidance blank |
| FAIL 3 | Save blocked on Return Guidance | Status changed from Escalated to Waiting on Customer, Return Guidance blank |
