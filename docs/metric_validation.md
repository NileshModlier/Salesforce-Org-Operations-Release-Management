# Metric validation

Each dashboard has two metrics checked by hand against `data/synthetic/`. The dashboard value was not read from a rendered dashboard. No org is connected, and the Salesforce CLI is not installed.

The hand count is the value these components are built to show when the running user can read every row in the dataset and the report runs in November 2026 where a date filter matters. Pipeline By Stage is scoped to the running user, so it is not one of the two checked sales metrics.

## Sales Dashboard

| Metric | Expected Value | Dashboard Value | Verification Method |
| --- | --- | --- | --- |
| Open Opportunity Value | 221000 | Not observed | Sum Amount in `data/synthetic/opportunities.csv` where Stage is not Closed Won and not Closed Lost. Thirteen rows. 221,000. |
| Conversion Rate | 41.67% | Not observed | Count `ConvertedTarget=Yes` in `data/synthetic/leads.csv` and divide by 24. 10 divided by 24 is 41.666..., shown at two decimals as 41.67%. |

The open-amount figure is the full book. It matches an Ops Admin run, because that permission set has view all on Opportunity. A Sales Rep with private sharing sees only the rows that rep owns. In the file, Rep A owns 165,000 of open amount and Rep B owns 56,000.

The conversion rate matches after the ten Qualified leads are converted and no extra leads are added. Before that convert step, a live report shows 0%.

## Support Dashboard

| Metric | Expected Value | Dashboard Value | Verification Method |
| --- | --- | --- | --- |
| Open Cases | 15 | Not observed | Count rows in `data/synthetic/cases.csv` whose Status is not Closed. High 7, Medium 4, Low 4. |
| Escalations | 4 | Not observed | Count rows whose Status is Escalated. High 2, Medium 1, Low 1. |

These two match a Support Lead L2 or Ops Admin run. Both can read all cases. Support Agent L1 cannot run the dashboard.

A third figure, not one of the two required checks: the average of Hours To First Response on the 16 stamped cases is 3.00. The four New cases are blank and stay out of the average.

## What this check does not prove

The report and dashboard XML has not been deployed. A live run can still disagree with these numbers if the formula column id, the case date column, or the custom detail formula is rejected, if the viewer cannot see every row, or if Opportunities Closing This Month is run outside November 2026. That closing-month component is 11 opportunities and 212,000 of amount for a November 2026 run. It was not one of the two formal checks because the filter is relative to the day the dashboard opens.
