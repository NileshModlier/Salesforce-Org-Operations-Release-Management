# Flosum access assessment

Assessment date: 10 November 2026.

Flosum is a commercial Salesforce DevOps product. It is not part of Developer Edition, and this project does not have a tenant.

## Access status

| Check | Status |
| --- | --- |
| Trial request | Not Executed |
| Demo request | Not Executed |
| Product access | Not Executed |
| AppExchange install | Not Executed |
| Connected orgs | None |
| Credentials stored in this repository | None |

**Access status: Not Executed**

## Trial request

Status: Not Executed.

No trial form was submitted. No Flosum workspace was created. No contact, company, or billing detail was invented for a signup.

A trial is optional future work. If the project owner later requests one, the request needs to state the real topology: two independent Developer Edition orgs, scratch orgs from a Developer Edition Dev Hub, and a git repository. That request is not part of M1.

## Demo request

Status: Not Executed.

No demo was booked and no demo tenant was used. Nothing in this repository is evidence of a Flosum walkthrough.

## Capabilities

The rows below are publicly described product areas. None of them were observed, installed, or tested in this project. Treat every row as unvalidated.

| Capability area | What public descriptions say | Validated in this project |
| --- | --- | --- |
| Metadata deployment | Move metadata between Salesforce orgs with comparison and history | No |
| Version control | Connect a release process to git, including providers outside the Lifecycle Center set | No |
| Pipelines | Promote changes through environments under a release workflow | No |
| Data deployment | Move or seed data, separate from metadata | No |
| Backup and recovery | Snapshot and restore org data or metadata under Flosum backup offerings | No |
| Org comparison | Diff two orgs before a deployment | No |

Vendor pages also describe connections to GitHub, GitLab, Bitbucket, and Azure DevOps. That provider list was not verified against a live Flosum tenant.

## Known unknowns

- Whether a trial can be issued against two independent Developer Edition orgs.
- Whether Flosum requires a production org, a sandbox, or a paid edition before the trial is useful.
- Trial length, user count, and which capabilities are withheld until purchase.
- How Flosum behaves when both orgs have 5 MB of data storage.
- Whether installing Flosum beside Lifecycle Center creates overlapping pipelines or connected-app conflicts.
- Which Flosum features need API capacity beyond the Developer Edition allocation of 15,000 requests per 24 hours.
- What a reviewer would accept as evidence of access: a tenant URL and an install record that this project does not have.

## Decision

M1 does not wait on Flosum. The release path documented for M5 is git plus Lifecycle Center, with CLI metadata deploy where a Lifecycle Center stage cannot attach Org B.

Flosum stays Not Executed until a real tenant exists. Later notes must not describe Flosum analysis as complete while this status stands.
