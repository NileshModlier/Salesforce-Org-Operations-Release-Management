# Flows

Four record-triggered flows. All are Draft. They have not been activated or run. The Salesforce CLI is not installed, and no org is connected.

Each flow has a fault path named Capture Fault. A missing user, queue, or Ops Admin is a handled result, not a platform fault: the flow sets `Outcome` and `FaultMessage` and does not change the record.

## Lead Assignment

Record-triggered, after save, on Lead create and when Product Interest changes.

### Assignment rules

| Product Interest | Named owner placeholder |
| --- | --- |
| Core Product | sales.core@org-ops.invalid |
| Add-on Service | sales.addon@org-ops.invalid |
| Renewal | sales.renewal@org-ops.invalid |
| Undecided, or blank | sales.default@org-ops.invalid |

The usernames are placeholders. They are not real users and they are not mailboxes.

### Decision logic

1. Set `Route` and `OwnerUsername` from the table.
2. Look up an active User with that username.
3. If the user exists, set the lead owner to that user and set `Outcome` to Assigned.
4. If the user does not exist, leave the creator as owner and set `Outcome` to OwnerNotFound.

### Expected Inputs

A Lead with Last Name, Company, a phone or email, and optionally Product Interest.

### Expected Outputs

`Route` is Core Product, Add-on Service, Renewal, or Default. `Outcome` is Assigned only when the placeholder user exists.

### Failure Behavior

Get Records or the owner update uses the Capture Fault path. `Outcome` becomes Fault and `FaultMessage` stores `$Flow.FaultMessage`. The lead is not given a bad owner id.

Flow tests: `Lead_Assignment_Core_Product`, `Lead_Assignment_Default`. They assert `Route`. They do not require the placeholder users to exist.

## Case Assignment

Record-triggered, after save, on Case create only. A later priority change does not reroute the case. The escalation flow handles age.

### Routing matrix

| Priority | Type | Queue |
| --- | --- | --- |
| High | Problem | L2 Escalation Queue (`L2_Escalation`) |
| High | Feature Request | L2 Escalation Queue |
| High | blank | L2 Escalation Queue |
| High | Question | L1 Support Queue (`L1_Support`) |
| Medium or Low | any | L1 Support Queue |

Case Type values added for this matrix: Question (default), Problem, Feature Request.

### Decision logic

1. Set `Route` to L2 or L1 and `QueueDeveloperName` to the queue API name.
2. Look up Group where Type is Queue and DeveloperName matches.
3. If the queue exists, set Case Owner to that queue and `Outcome` to Assigned.
4. If it does not exist, leave the creator as owner and set `Outcome` to QueueNotFound.

Queue members are the public groups Support_L1 and Support_L2. Assigning a permission set group does not add the user to the public group. Ops Admin adds the user to the matching group when the user exists.

### Expected Inputs

A new Case with Subject, Status New, Priority, Origin, and optionally Type.

### Expected Outputs

`Route` is L1 or L2. Owner is the matching queue when the queue exists.

### Failure Behavior

A missing queue is QueueNotFound and does not write an owner. A failed lookup or update takes Capture Fault.

Flow tests: `Case_Assignment_High_Problem` expects Route L2. `Case_Assignment_High_Question` expects Route L1.

## First Response Tracking

Record-triggered, before save, when Case Status changes.

### Decision logic

Stamp `First_Response_At__c` with the current date and time only when all of these are true:

- Prior status is New
- New status is not New
- First Response At is empty

Any other status change sets `Outcome` to Skipped and leaves the field alone.

### Expected Inputs

A Case whose status is changing. The stamp path starts at New with an empty First Response At.

### Expected Outputs

`Outcome` is Stamped or Skipped. On Stamped, First Response At becomes the current date and time.

### Failure Behavior

The before-save field update has a Capture Fault path. `Outcome` becomes Fault. A skipped change does not write the field.

Flow tests: `First_Response_Tracking_Stamp` and `First_Response_Tracking_Skip`.

## Escalation

Record-triggered, after save, on Case create and update. Entry criteria: Priority is High, and Status is not Escalated or Closed.

### Scheduled path

Path name: One day after create. It runs one day after CreatedDate and enters the same age decision as the immediate path.

Threshold: one day. `PastThreshold` is true only when CreatedDate is not blank and is at least one day before now.

The immediate path escalates only a high-priority case that is already older than one day, such as a load of old data. A brand-new high-priority case sets `Outcome` to NotDue and waits for the scheduled path.

### Decision logic

1. If the case is not past the threshold, stop with NotDue.
2. Look up the L2 Escalation Queue. If it is missing, stop with QueueNotFound and do not change the case.
3. Look up an active User whose Persona is Ops Admin. If none exists, stop with NoOpsAdmin and do not change the case.
4. Update the case in one save:
   - Status = Escalated
   - Owner = L2 Escalation Queue
   - Escalation Reason = the existing reason, or "Automatically escalated. High priority case exceeded the one-day threshold."
   - Escalated By = the existing user, or the Ops Admin user
5. Send the Escalation Alert custom notification to that Ops Admin, targeting the case.
6. Set `Outcome` to Escalated.

The reason and Escalated By values are filled so `Case_Escalation_Requires_Reason` does not block the update.

### Expected Inputs

A high-priority case that is not Closed or Escalated. The scheduled path also needs CreatedDate.

### Expected Outputs

Before one day, `Outcome` is NotDue and the status stays unchanged. After one day, status is Escalated, the owner is the L2 queue, the reason and Escalated By are populated, and the Ops Admin receives a bell notification.

### Failure Behavior

Missing queue or missing Ops Admin does not change the case. A failed lookup, update, or notification takes Capture Fault, sets `Outcome` to Fault, and stores `$Flow.FaultMessage`. The notification is not mocked by the flow test. The flow test `Escalation_Not_Yet_Due` covers the immediate path only. The scheduled path is the same decision one day later.

## Flow tests

The tests live in `force-app/main/default/flowtests/`. They were not executed. Run them with `sf flow run test` after the flows are deployed and before they are activated.
