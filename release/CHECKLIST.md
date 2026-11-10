# Release checklist

Use one copy of this list per work item. The boxes below are the master list. None of them are checked, because no promotion has been run.

Operator steps are the Ops Admin's own list. The other sections are the stage gates.

## Pre-Release

- [ ] Confirm Flosum access is still Not Executed. Do not open a Flosum pipeline.
- [ ] Confirm Org A is the production stand-in, Org B is the UAT stand-in, and the scratch org is development.
- [ ] Confirm no sandbox and no customer production org are in the path.
- [ ] Confirm the work item names WI-001 or WI-002, or a later requirement id.
- [ ] Confirm the branch is `wi/WI-00n-slug`, cut from `uat`, and that `main` has no direct commits.
- [ ] Confirm the manifest is `release/manifests/release-1-package.xml` or `release/manifests/release-2-package.xml`.
- [ ] Confirm Release 2 is not queued ahead of a successful Release 1.
- [ ] Confirm flows in the revision are Draft unless the work item activates them.
- [ ] Run `validate-m1.ps1` through `validate-m5.ps1` on the revision and keep the output with the work item.
- [ ] Confirm the reviewer is not the only author, and that no credential file is in the diff.

## Deployment

- [ ] Deploy the work item manifest to the scratch org and commit from that org.
- [ ] Open the review into `uat` and wait for approval.
- [ ] Deploy that revision to Org B. Record whether Lifecycle Center or the CLI performed the hop.
- [ ] If Lifecycle Center rejects Org B as a stage, deploy the same commit with the CLI and write that limitation on the work item.
- [ ] Run UAT for the requirement set. Sequence personas across the two CRM licenses.
- [ ] Stop if UAT fails. Do not merge to `main`.
- [ ] After written Ops Admin approval, merge `uat` into `main`.
- [ ] Deploy the `main` commit to Org A with the same manifest.

## Post-Release

- [ ] Record the Org A deploy id, the commit SHA, the date, and the outcome in `release/CHANGELOG.md`.
- [ ] Confirm the six validation rules are active after Release 1.
- [ ] Confirm the four flows are still Draft.
- [ ] Confirm a Sales Rep still has no Case object permission.
- [ ] Confirm Support Agent L1 still has no Run Reports permission.
- [ ] After Release 2, open Sales Dashboard and Support Dashboard as the logged-in user.
- [ ] Compare live counts with [docs/metric_validation.md](../docs/metric_validation.md) only if the synthetic load finished. Otherwise leave the dashboard value as not observed.
- [ ] Watch the Developer Edition API limit. Stop a retry loop if calls approach 15,000 in 24 hours.

## Rollback

- [ ] Name the trigger from the rollback criteria in `release/release-plan.md`.
- [ ] Identify the commit. Do not use a force push or a hard reset.
- [ ] Revert that commit on the branch that was promoted.
- [ ] Remember that a normal deploy does not delete metadata the reverted commit had added.
- [ ] For a Release 2 removal, use `release/rollback/destructiveChanges.xml` only after the same removal has been accepted on Org B.
- [ ] Do not destructively remove standard value sets, validation rules, or fields in this drill.
- [ ] Re-run the validation scripts and the story that failed.
- [ ] Set the changelog rollback status to Restored, or to Not required when nothing was deployed.

## Operator

- [ ] Log in as the named Ops Admin. Do not share the password.
- [ ] Confirm Dev Hub on Org A is enabled before creating a scratch org, and confirm the scratch-org limits before a fourth active org.
- [ ] Assign the Lifecycle Center permission sets that the product installs. Do not invent a substitute with Modify All Data.
- [ ] Keep the pipeline to three stages: Development, UAT, Production Stand-In. Remove any stage that assumes a sandbox.
- [ ] Point Development at a scratch org, UAT at Org B, and Production Stand-In at Org A.
- [ ] Connect GitHub.com or Bitbucket Cloud only. Do not connect a provider outside that documented set.
- [ ] Write the Org B attachment result, success or the product limitation, before calling the pipeline complete.
- [ ] Leave Flosum unconnected while its access status is Not Executed.
- [ ] Log in to Org A often enough that a year of inactivity does not deactivate the Dev Hub.
