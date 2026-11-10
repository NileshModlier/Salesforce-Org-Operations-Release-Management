# Changelog

Dates are the day the release package was defined in source. No package has been deployed. Rollback status is Not required until a target org changes.

## Release 1

| Field | Entry |
| --- | --- |
| Date | 10 November 2026 |
| Components | Custom fields, Lead Status, Opportunity Stage, Case Status, Case Type, six validation rules, nine layouts, three Lightning record pages, four Draft flows and seven flow tests, L1 and L2 queues, public groups, Escalation Alert, four profiles, seven permission sets, four permission set groups. Manifest: `release/manifests/release-1-package.xml`. |
| Reason | Put the approved sales and support process and the persona access model into Org B and then Org A before any leadership report. |
| Outcome | Not executed. Source is in the repository. No scratch org, Org B, or Org A deploy has been run. |
| Rollback Status | Not required |

The reporting permission sets are in this package because the permission set groups reference them. Reports and dashboards are not in this package.

## Release 2

| Field | Entry |
| --- | --- |
| Date | 10 November 2026 |
| Components | Five Sales Leadership reports, five Support Leadership reports, Sales Dashboard, Support Dashboard, and the two public report and dashboard folders. Manifest: `release/manifests/release-2-package.xml`. |
| Reason | Give Sales and Support leadership the approved operational reports after Release 1 is in the org. |
| Outcome | Not executed. Depends on Release 1. Dashboards have not been rendered. Synthetic data has not been loaded. |
| Rollback Status | Not required |

## Template

Copy this block for the next work item. Replace every bracket. Leave Outcome as Not executed until a deploy id exists.

| Field | Entry |
| --- | --- |
| Date | [YYYY-MM-DD] |
| Components | [Manifest path and the metadata members this work item deploys] |
| Reason | [Requirement id and the change the reviewer can recognize] |
| Outcome | [Not executed, or the deploy id, commit SHA, org alias, and pass or fail] |
| Rollback Status | [Not required, Planned, In progress, or Restored] |
