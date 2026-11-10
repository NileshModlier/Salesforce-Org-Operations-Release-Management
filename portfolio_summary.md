# Portfolio summary

Salesforce Org Operations & Release Management is a Developer Edition portfolio for a sales and support process with a release path and a support assistant. The source is complete through M6. The orgs were not connected, and the metadata was not deployed.

## What the project shows

- An environment model that does not pretend to have sandboxes: Org A is the production stand-in and Dev Hub, Org B is UAT, and development is a scratch org.
- Twelve requirements traced from the story to metadata, and then to Release 1 or Release 2 and a validation script.
- Persona access on permission sets and groups, with profiles limited to apps and page layouts. Support Agent L1 has no team-report access. No set grants Modify All Data.
- Four Draft record-triggered flows, each with a fault path and a flow test.
- Ten reports and two dashboards, with expected values counted from a 24-lead, 18-opportunity, 20-case synthetic file.
- A release process that refuses Flosum until access exists, and a rollback that uses git revert plus an explicit destructive list because a normal deploy does not delete metadata.
- A how-to assistant that quotes one approved section or refuses. On the 30-question set it scored 20 correct answers, 10 correct refusals, and 0 hallucinations.

## Resume-ready figures

| Item | Count |
| --- | --- |
| Personas | 4 |
| Requirements | 12 |
| Custom fields | 8 |
| Validation rules | 6 |
| Flows, all Draft | 4 |
| Flow tests | 7 |
| Permission sets | 7 |
| Permission set groups | 4 |
| Profiles with no object permissions | 4 |
| Reports | 10 |
| Dashboards | 2 |
| Release packages defined, not deployed | 2 |
| Procedure sections | 23 |
| Assistant questions | 30, of which 20 are covered and 10 must be refused |
| Hallucinations on that set | 0 |

## Constraints to say out loud

Developer Edition, two CRM user licenses, no sandboxes, no customer production org, Flosum Not Executed, Lifecycle Center documented and not installed, dashboard numbers not observed in a live org.
