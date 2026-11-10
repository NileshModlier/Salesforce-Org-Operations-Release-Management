# Validation rules

Six active rules. Each rule allows the normal working path and blocks the save the requirement forbids. Formulas below match the metadata after whitespace is ignored.

## Lead_Requires_Email_Or_Phone

- **Object:** Lead
- **Requirement:** REQ-003
- **Error field:** Email
- **Error Message:** Enter an email address or a phone number before saving this lead.
- **Rule Formula:**

```
AND(ISBLANK(Email), ISBLANK(Phone))
```

Name and Company remain standard required fields. Mobile phone does not satisfy this rule.

## Lead_Convert_Requires_Qualified

- **Object:** Lead
- **Requirement:** REQ-003
- **Error field:** Status
- **Error Message:** Convert this lead only when its status is Qualified.
- **Rule Formula:**

```
AND(IsConverted, NOT(ISPICKVAL(PRIORVALUE(Status), "Qualified")))
```

The convert action sets status to Closed - Converted. `PRIORVALUE` is the status the rep had saved. Unqualified, Open - Not Contacted, and Working - Contacted cannot convert.

## Opportunity_Closed_Won_Requires_Amount

- **Object:** Opportunity
- **Requirement:** REQ-001, REQ-002
- **Error field:** Amount
- **Error Message:** Enter an amount greater than zero before setting the stage to Closed Won.
- **Rule Formula:**

```
AND(ISPICKVAL(StageName, "Closed Won"), OR(ISBLANK(Amount), Amount <= 0))
```

Closed Lost can be saved with a blank amount. Open stages can be saved with a blank amount.

## Case_Escalation_Requires_Reason

- **Object:** Case
- **Requirement:** REQ-007
- **Error field:** Escalation Reason
- **Error Message:** Enter the escalation reason and the agent who escalated before saving an escalated case.
- **Rule Formula:**

```
AND(ISPICKVAL(Status, "Escalated"), OR(ISBLANK(Escalation_Reason__c), ISBLANK(Escalated_By__c)))
```

The error is shown on Escalation Reason when either that field or Escalated By is blank. Other statuses do not require either field.

## Case_Close_Requires_Resolution

- **Object:** Case
- **Requirement:** REQ-008
- **Error field:** Resolution Notes
- **Error Message:** Enter resolution notes before closing this case.
- **Rule Formula:**

```
AND(ISPICKVAL(Status, "Closed"), ISBLANK(Resolution_Notes__c))
```

Working, Waiting on Customer, and Escalated cases can be saved with resolution notes blank.

## Case_Return_Requires_Guidance

- **Object:** Case
- **Requirement:** REQ-008
- **Error field:** Return Guidance
- **Error Message:** Enter return guidance before sending an escalated case back to L1.
- **Rule Formula:**

```
AND(ISPICKVAL(PRIORVALUE(Status), "Escalated"), OR(ISPICKVAL(Status, "New"), ISPICKVAL(Status, "Working"), ISPICKVAL(Status, "Waiting on Customer")), ISBLANK(Return_Guidance__c))
```

Closing an escalated case uses the resolution rule instead of this one. A new case created as Working does not fire this rule, because the prior status is not Escalated.

## Strategy

- Conditional requirements stay in validation rules. The custom fields themselves are optional so earlier statuses still save.
- No rule deletes records, changes ownership, or assigns a queue.
- These rules were not executed in an org. `docs/test-cases.md` lists the manual examples for a later scratch-org run.
