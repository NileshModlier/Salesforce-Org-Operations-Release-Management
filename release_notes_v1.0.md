# Release notes v1.0

Date: 10 November 2026.

This note covers the repository at version 1.0. It is not a Salesforce deploy. Org A and Org B were not changed. Release 1 and Release 2 in the changelog remain Not executed.

## Included

- Foundation for two Developer Edition orgs and scratch-org development.
- Lead, opportunity, and case configuration for the twelve requirements, including six active validation rules.
- Draft automation for lead assignment, case assignment, first response, and escalation, each with a fault path.
- Persona security: minimum-access profiles, permission sets, and one permission set group per persona. No permission set grants Modify All Data. Support Agent L1 cannot run the team reports.
- Sales and support dashboards, with a synthetic dataset and hand-counted expected values.
- Release governance on Lifecycle Center and git. Flosum is Not Executed.
- User guides, L1 and L2 runbooks, and an advisory retrieval assistant that refuses questions the documents do not cover.

## Not included

- A connected org, a Dev Hub, a Lifecycle Center project, or a git remote.
- Activated flows, loaded sample rows, or rendered dashboard screenshots.
- Sandboxes, a customer production org, or a Flosum tenant.
- An assistant that can edit, deploy, or assign access.

## Promotion when an org exists

Follow `release/release-plan.md`. Deploy Release 1 before Release 2. Keep the flows Draft unless a new work item says otherwise. Record the commit SHA and the deploy id in the changelog. The assistant is not part of that deploy.
