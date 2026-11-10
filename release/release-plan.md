# Release plan

Path B. Flosum access is Not Executed, so this plan uses Lifecycle Center on Org A and git. Nothing in this plan has been executed. Org A, Org B, and the scratch org are not connected. The Salesforce CLI is not installed. No git remote exists.

Release 1 and Release 2 are the two packages in [manifests/](manifests/). Release 2 depends on Release 1. Later changes use one work item per requirement. These two releases bundle the milestones that are already approved.

## Work Item

A work item is the unit Lifecycle Center promotes. It names one requirement id, except for these two milestone packages, which name the requirement set in the changelog.

| Work item | Release | Branch to open | Requirement set | State |
| --- | --- | --- | --- | --- |
| WI-001 | Release 1 | `wi/WI-001-operating-process` | REQ-001 through REQ-008, REQ-011, REQ-012 | Not opened |
| WI-002 | Release 2 | `wi/WI-002-leadership-reporting` | REQ-009, REQ-010, plus the report half of REQ-001, REQ-006, REQ-007, and REQ-008 | Not opened |

Each later work item records: requirement id, manifest or member list, author, reviewer, and the commit that UAT accepted. Lifecycle Center stores that record once the project exists. Until then the changelog is the record.

## Branch

Branches are names for the remote. They have not been created.

| Branch | Stage | Org |
| --- | --- | --- |
| `wi/WI-00n-slug` | Development | Scratch org from Org A |
| `uat` | UAT | Org B, if Lifecycle Center can attach it |
| `main` | Production stand-in | Org A |

A work item branch is cut from `uat`. Promotion into UAT merges that branch into `uat`. Production promotion merges `uat` into `main`. No force push. No direct commit to `main`.

The remote, when it exists, is GitHub.com or Bitbucket Cloud. Those are the providers Lifecycle Center documents. GitLab and Azure DevOps are outside that set.

## Review

Review is a pull request from the work item branch into `uat`, or the Lifecycle Center promotion diff when the project exists. The reviewer is not the only author of the change.

The review checks:

- The manifest matches the work item. Release 1 has no Report or Dashboard members. Release 2 has only those members.
- Flows stay Draft unless the work item says to activate them.
- Profiles still have no object permissions.
- No Apex, no secret, and no credential file.
- `tests/validate-m1.ps1` through `tests/validate-m5.ps1` pass on the revision.

Review approval is required before the UAT deploy.

## UAT

UAT is Org B. It is a second Developer Edition org, not a sandbox of Org A.

1. Deploy the `uat` revision with the work item manifest.
2. If Lifecycle Center accepts Org B as a stage, the promotion performs that deploy.
3. If Lifecycle Center rejects Org B, deploy the same commit with the CLI and record that Lifecycle Center did not perform the hop. That attachment check has not been run.
4. Run the validation script named on the work item, then the persona checks that match the requirement.
5. Two CRM licenses cannot host four personas at once. Sequence the logins.

UAT data stays inside 5 MB. Use `data/synthetic/` only when the work item is Release 2 or later and the load notes in [docs/reports.md](../docs/reports.md) are followed. Keep the four flows Draft during that load.

## Approval

Ops Admin is the only role that approves production promotion. A Sales Rep or Support Lead L2 can accept the UAT story for their own work. They do not approve the Org A deploy.

Approval is a written outcome on the changelog row: who approved, the commit SHA, and the date. A missing SHA blocks promotion. Shared passwords are out of bounds. The approver uses a named user.

## Production Promotion

Production promotion deploys the approved `main` commit to Org A, the production stand-in. Org A is not a customer production org.

Order for the first two releases:

1. WI-001 merges to `uat`, deploys Release 1 to Org B, and passes UAT.
2. WI-001 merges `uat` to `main` and deploys [manifests/release-1-package.xml](manifests/release-1-package.xml) to Org A.
3. WI-002 repeats that path with [manifests/release-2-package.xml](manifests/release-2-package.xml).

Release 1 includes the reporting permission sets because the permission set groups already reference them. It does not include reports or dashboards. Release 2 does not repeat the fields, flows, or profiles.

Do not activate flows as part of either promotion unless a later work item says so. Draft flows deploy as Draft.

## Post-Deployment Validation

On the org that just received the revision:

- Release 1: run `tests/validate-m2.ps1` and `tests/validate-m3.ps1` against source, then confirm in the org that the six validation rules are active and the four flows are Draft.
- Release 2: run `tests/validate-m4.ps1` against source, then open both dashboards as a user who can run reports. Compare the two hand-checked metrics in [docs/metric_validation.md](../docs/metric_validation.md) only after the synthetic load. Until that load, the expected dashboard value remains not observed.
- Record pass or fail on the changelog outcome. A fail stops the next stage.

## Rollback Criteria

Start the rollback drill when any of these are true after a promotion:

- A validation rule blocks a story that the work item said would pass.
- A flow is Active and was supposed to stay Draft.
- A Sales Rep can read cases, or Support Agent L1 can run the support dashboard.
- Release 2 dashboards error, or their counts contradict the synthetic hand count after a completed load.
- The deploy replaced standard picklist values the work item did not intend to replace.

Rollback does not start because a test was skipped. Skipped validation is a failed promotion, and the next stage waits. The steps and the metadata limits are in [rollback-drill.md](rollback-drill.md).
