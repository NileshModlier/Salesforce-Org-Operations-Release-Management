# Reports

Ten reports answer the sales and support leadership questions. They are in source and have not been deployed. No org is connected, and the Salesforce CLI is not installed.

Folders are public and read-only. Run Reports is granted by a reporting permission set on the Sales Rep, Support Lead L2, and Ops Admin groups. Support Agent L1 does not receive that permission, so L1 is not a consumer of the all-team support reports.

| Report | Folder | Format | Question |
| --- | --- | --- | --- |
| Lead Conversion By Source | Sales Leadership | Summary, with a rate formula | How many leads arrive from each source, and what share converts? |
| Pipeline By Stage | Sales Leadership | Summary | What does the running user's pipeline look like by stage? |
| Opportunities Closing This Month | Sales Leadership | Summary | Which opportunities close in the current calendar month? |
| Open Opportunity Value | Sales Leadership | Summary | What amount is still open? |
| Conversion Rate | Sales Leadership | Summary formula | What share of all leads is converted? |
| Open Cases By Priority | Support Leadership | Summary | How many open cases sit at each priority? |
| Cases By Status | Support Leadership | Matrix | How do status and priority intersect, and who owns the case? |
| First Response Performance | Support Leadership | Summary formula | How many hours pass before the first response? |
| Escalations By Priority | Support Leadership | Summary | How many escalated cases sit at each priority? |
| Cases Closed By Agent | Support Leadership | Summary | How many cases has each owner closed? |

## Filters

| Report | Filter |
| --- | --- |
| Lead Conversion By Source | No field filter. Created date is all time. Scope is organization, limited to leads the running user can read. |
| Pipeline By Stage | No stage filter. Close date is all time. Scope is the running user, which is the REQ-009 owner filter. |
| Opportunities Closing This Month | Close date is this calendar month. Scope is organization. |
| Open Opportunity Value | Stage is not Closed Won and not Closed Lost. Close date is all time. Scope is organization. |
| Conversion Rate | No field filter. Created date is all time. Scope is organization. |
| Open Cases By Priority | Status is not Closed. Opened date is all time. Scope is organization. |
| Cases By Status | No field filter. Opened date is all time. Scope is organization. |
| First Response Performance | No field filter. Hours are blank when First Response At is empty, and the average skips those rows. |
| Escalations By Priority | Status equals Escalated. |
| Cases Closed By Agent | Status equals Closed. Closed date is all time. |

## Groupings

| Report | Grouping |
| --- | --- |
| Lead Conversion By Source | Down: Lead Source |
| Pipeline By Stage | Down: Stage |
| Opportunities Closing This Month | Down: Stage |
| Open Opportunity Value | Down: Stage |
| Conversion Rate | Down: Converted |
| Open Cases By Priority | Down: Priority |
| Cases By Status | Down: Status. Across: Priority. |
| First Response Performance | Down: Priority |
| Escalations By Priority | Down: Priority |
| Cases Closed By Agent | Down: Case Owner |

## Calculated Fields

| Report | Calculation |
| --- | --- |
| Lead Conversion By Source | Conversion Rate = sum of Converted divided by the row count, percent, two decimals. |
| Conversion Rate | The same formula. The dashboard KPI reads the grand total. |
| Open Opportunity Value | Sum of Amount. This is a standard aggregate, not a custom formula. |
| First Response Performance | Hours To First Response = (First Response At minus Created Date) times 24. The column average is the performance number. Blank first-response rows stay out of the average. |
| Pipeline By Stage | Sum of Amount, plus the close date and Next Step columns. No custom formula. |

Pipeline By Stage is the REQ-009 report: Opportunity, grouped by stage, with amount, close date, and next step, scoped to the running user. Cases By Status is the REQ-010 matrix: status, priority, owner, and opened date.

## Synthetic data strategy

The dataset is `data/synthetic/`. It is not loaded. Developer Edition data storage is 5 MB. This set is 2 accounts, 2 contacts, 24 leads, 18 opportunities, and 20 cases. That is well inside the limit. File storage is not used.

| Count | Value |
| --- | --- |
| Accounts | 2 |
| Contacts | 2 |
| Leads | 24 |
| Opportunities | 18 |
| Cases | 20 |
| Escalations | 4 cases with status Escalated |

Lead source split: Web 10 (4 converted), Phone Inquiry 6 (3 converted), Partner Referral 4 (2 converted), Other 4 (1 converted). Ten leads are the conversion target. Fourteen are not.

Open opportunity amount, excluding Closed Won and Closed Lost, is 221,000 across 13 opportunities. Eleven opportunities have a November 2026 close date. Their amount is 212,000. That month count is what Opportunities Closing This Month returns when it runs during November 2026.

Sixteen cases have a first response. Eight are two hours after open and eight are four hours after open. The average is 3.00 hours. Four New cases have no first response. Five cases are Closed. Open cases are 15: High 7, Medium 4, Low 4.

Logical owners are labels, not six live users. A Developer Edition org has two Salesforce CRM licenses. On a load, map Rep A and Rep B, L1 Agent A and L1 Agent B, and L2 Lead onto the users that exist, and map the L2 Escalation Queue label to the `L2_Escalation` queue. Closed-by-agent groupings follow the real owner, so a live chart will not show five names unless those owners exist.

Load order, with the four flows still Draft:

1. Insert accounts, then contacts.
2. Insert leads. Every row has an email, so the email-or-phone rule passes. Converted targets are inserted as Qualified, not Closed - Converted. `Lead_Convert_Requires_Qualified` rejects an insert that is already converted.
3. Convert the ten `ConvertedTarget=Yes` leads with the standard convert action and without creating an opportunity. Creating those opportunities would add rows on top of the 18 in the opportunity file and change the pipeline totals.
4. Insert the 18 opportunities. Closed Won amounts are greater than zero.
5. Insert the 20 cases. Escalated rows include a reason and need a real User Id in Escalated By. Closed rows include resolution notes.

Do not activate Lead Assignment or Case Assignment before the load. Those flows would replace the owner on create. First Response Tracking would also stamp First Response At on a status change. Load the stamped value directly, or leave the flow Draft.

Record visibility: organization scope still hides records the running user cannot read. Ops Admin has view all on leads, opportunities, and cases, so the full-book totals above are the Ops Admin figures. A Sales Rep sees only the leads and opportunities that user can read. Pipeline By Stage is stricter: scope is the running user, so even Ops Admin sees only opportunities that user owns.
