# Rollback drill

This is a tabletop drill for Release 2. It was not run in an org. There is no deploy to reverse, and the CLI is not installed. The steps are the ones an operator would follow after a real promotion.

## Rollback Scenario

Release 2 has been deployed to Org B and then to Org A. Sales Dashboard or Support Dashboard fails post-deployment validation. The failure is in the reporting package. Fields, validation rules, flows, profiles, and permission sets from Release 1 are still the accepted revision.

The drill removes Release 2 from the org and leaves Release 1 in place.

## Rollback Trigger

Any one of these, after the Release 2 deploy:

- A dashboard does not open, or a component reports an unknown column.
- A user who should not run reports can open the support dashboard.
- After a completed synthetic load, Open Opportunity Value is not 221000 for a user who can read every opportunity, or Open Cases is not 15 for a user who can read every case.
- The Release 2 deploy also changed a Release 1 component that the manifest does not list.

A trigger that is only a missed check is not a rollback. Fix the check and stop the next stage.

## Rollback Steps

1. Stop further promotion. Do not open WI-003 on top of a bad Release 2.
2. Record the trigger, the Org A deploy id, and the `main` commit SHA in the changelog. Set Rollback Status to In progress.
3. On `main`, revert the Release 2 merge commit. Do not force push. Do not hard reset.
4. Revert the same change on `uat` if Org B received that commit, so the two branches do not diverge.
5. Treat the revert as the git record only. A later metadata deploy of the reverted tree updates components that still exist. It does not delete reports that the commit added.
6. On Org B, deploy `release/rollback/destructiveChanges.xml` with the empty `release/rollback/package.xml`. Accept that UAT result before touching Org A.
7. Deploy the same destructive package to Org A.
8. Do not include standard value sets, fields, flows, profiles, or permission sets in that destructive package.
9. Set Rollback Status to Restored only after the validation steps pass. This drill has not reached that state.

The destructive member list removes the ten reports, two dashboards, and the Sales Leadership and Support Leadership folders. It has not been deployed.

## Validation Steps

1. Run `tests/validate-m4.ps1` on the reverted source. It fails if the reports were removed from git. That failure is expected for this drill. The source of truth after a real rollback is the reverted commit, and the test is updated only when the work item says the reports stay deleted.
2. In Org A, confirm Sales Dashboard and Support Dashboard are gone.
3. In Org A, confirm a Lead still requires email or phone, a Closed Won opportunity still requires a positive amount, and an Escalated case still requires a reason and a user.
4. Confirm the four flows are still present and Draft.
5. Confirm the Sales Rep permission set still has no Case access, and Support Agent L1 still has no Run Reports permission.
6. Write the four results on the changelog outcome.

## Observed Risks

These risks were identified from the metadata and the Developer Edition limits. They were not observed in a live rollback.

- Org A and Org B are not connected, so the drill cannot show a real deploy id.
- A Developer Edition org has 15,000 API requests a day. A repeated failed deploy can consume that budget.
- Org B may not be a legal Lifecycle Center stage. A CLI rollback and a Lifecycle Center promotion can then point at different revisions.
- Two CRM users cannot run the four persona checks at the same time during validation.
- Standard value sets in Release 1 replace the target org's values on first deploy. This drill does not roll those back, because the previous values were never retrieved.
- Permission set groups reference the reporting permission sets. Removing those sets as part of a report rollback would break the group deploy. The drill leaves the sets in place.
- Public report folders mean a user who later receives Run Reports can see the support reports. The drill's access check is the L1 permission set, not folder privacy.

## Metadata Limitations

- Metadata deploy is an upsert. Omitting a component from the next package does not delete it.
- Git revert updates the repository. It does not change an org until a deploy runs.
- Deleting a component needs `destructiveChanges.xml`. Destructive deploy of a standard value set, a standard field, or an active flow is out of scope for this drill.
- Flow tests do not run the Escalation scheduled path. A rollback cannot use that test as proof the schedule was removed.
- Dashboard values depend on the running user and on data. Reverting metadata does not revert the synthetic rows if they were loaded.
- Case assignment and lead assignment, if a later work item activates them, will have written owners. Reverting the flow does not put the old owner back.
- First Response At, once stamped, stays on the case. Removing the flow does not clear the field.
- Scratch orgs expire. A rollback that depends on a deleted scratch org has to be repeated from git, not from the org.
