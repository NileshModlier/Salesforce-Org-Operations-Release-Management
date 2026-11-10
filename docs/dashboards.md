# Dashboards

Two dashboards sit on the leadership reports. Both run as the logged-in user, so the numbers follow that person's sharing and, for Pipeline By Stage, that person's ownership. They have not been rendered in an org.

## Sales Dashboard

Folder: Sales Leadership. Source: `Sales_Dashboard`.

| Component | Type | Report | What it shows |
| --- | --- | --- | --- |
| Open Opportunity Value | KPI | Open Opportunity Value | Sum of open amount |
| Conversion Rate | KPI | Conversion Rate | Grand total of the conversion formula |
| Closing This Month | KPI | Opportunities Closing This Month | Count of opportunities closing this month |
| Pipeline By Stage | Bar chart | Pipeline By Stage | Sum of amount by stage |
| Lead Conversion By Source | Donut chart | Lead Conversion By Source | Lead count by source |
| Opportunities Closing This Month | Table | Opportunities Closing This Month | Stage, name, amount, close date, owner, next step |

Filter: Stage, with options Prospecting, Qualification, Proposal, and Negotiation. It is wired to the pipeline bar and the closing-this-month table. The lead KPI, the lead donut, and the open-amount KPI do not use that filter, because those components are not stage reports. The open-amount report already drops Closed Won and Closed Lost.

## Support Dashboard

Folder: Support Leadership. Source: `Support_Dashboard`.

| Component | Type | Report | What it shows |
| --- | --- | --- | --- |
| Open Cases | KPI | Open Cases By Priority | Count of cases that are not Closed |
| Escalations | KPI | Escalations By Priority | Count of cases in Escalated |
| First Response | KPI | First Response Performance | Average hours to first response |
| Open Cases By Priority | Bar chart | Open Cases By Priority | Open case count by priority |
| Cases By Status | Column chart | Cases By Status | Case count by status |
| Escalations By Priority | Bar chart | Escalations By Priority | Escalated case count by priority |
| Cases Closed By Agent | Table | Cases Closed By Agent | Closed cases by owner |

Filter: Priority, with options High, Medium, and Low. It is wired to every support component.

## Who opens them

Sales Rep can run reports and can open the public folders. The useful sales view for that persona is Pipeline By Stage, because its scope is the running user. Support Lead L2 can run the support dashboard across cases that user can read, which is all cases under the L2 permission set. Ops Admin can run and manage both. Support Agent L1 has no Run Reports permission.

The folders are public read-only so a deploy does not need a user id in the folder share. L1 is kept out by the missing permission, not by a private folder. A person who is later given Run Reports could open the support folder.
