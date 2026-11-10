# Release governance

Governance is the set of rules that decide who may move a change, and when the move stops. The procedure those people follow is in [docs/release_management.md](release_management.md).

## Path

Path B is selected. Lifecycle Center, once configured on Org A, is the control plane. Git is the source of truth. Flosum is Not Executed and is not an approved tool for this project. A demo, a trial, or a screenshot is not access.

Org A is the production stand-in and the Dev Hub. Org B is the UAT stand-in. Development is a scratch org. There is no sandbox and no customer production org. Change sets are not a substitute, because change sets need a production org and its sandboxes.

## Roles

| Role | May do | May not do |
| --- | --- | --- |
| Ops Admin | Open the Lifecycle Center project, approve production promotion, deploy to Org A, assign persona groups | Approve their own work item as the only reviewer. Grant Modify All Data. |
| Sales Rep | Build on a work item branch in a scratch org. Accept the sales story in UAT. | Merge to `main`. Change profiles or permission sets. |
| Support Lead L2 | Accept the support story in UAT, including the team backlog report after Release 2. | Approve the Org A deploy. |
| Support Agent L1 | Execute assigned UAT cases for their own queue. | Run the all-team support dashboard. Promote a release. |

Two Salesforce CRM licenses cannot hold four simultaneous persona logins. UAT sequences the users. Shared passwords are out of bounds.

## Gates

A change moves only when the previous gate is recorded.

1. Work item names the requirement and the manifest.
2. Review approves the diff. The reviewer is not the only author.
3. Org B has the same commit Org A will receive.
4. The story checks for that requirement pass on Org B.
5. Ops Admin writes the approval, the commit SHA, and the date.
6. Org A receives that commit.
7. Post-deployment validation is written on the changelog. A failure blocks the next work item.

Skipping a gate is a failed promotion, not a rollback. Rollback starts only from the criteria in the release plan.

## Change control

- One pipeline. Three stages. No extra stage for an org this project does not have.
- Release 1 before Release 2. Release 2 does not carry fields or flows.
- Flows stay Draft unless the work item says otherwise.
- Profiles do not gain object permissions in a release.
- `main` changes by merge from `uat`. No force push.
- A year of inactivity can deactivate Org A and its scratch orgs. The operator login cadence is part of the operator checklist.
- The first attach of Org B is an experiment with a written result. Calling it a Lifecycle Center stage before that result is recorded is not allowed.

## What this governance does not claim

Lifecycle Center is available in Developer Edition and is not configured. No promotion has a deploy id. Release 1 and Release 2 outcomes are Not executed, and their rollback status is Not required. The rollback drill is a tabletop. Its risks were read from the metadata and the edition limits, not from a live failure.
