# Demo Script: 5-Minute Interview Demonstration

**Salesforce Org Operations & Release Management**

This demo walks an interviewer through the project in five minutes. Because nothing is deployed to an org, the demo is a **guided walkthrough of the repository** plus a **live run of the retrieval assistant**, which is the one component that runs locally.

---

## Before the call (10 minutes of setup)

| # | Prepare | Why |
| --- | --- | --- |
| 1 | Open the repository in VS Code with the explorer expanded to `docs/`, `force-app/main/default/`, `release/`, `helper/` | Fast navigation without searching |
| 2 | Pin these tabs in order: `README.md`, `docs/requirements.md`, `force-app/.../validationRules/Lead_Convert_Requires_Qualified.validationRule-meta.xml`, `docs/flows.md` (Escalation section), `docs/security-matrix.xlsx` (open in Excel), `docs/metric_validation.md`, `release/release-plan.md`, `release/rollback-drill.md` | One tab per segment |
| 3 | Open a terminal at the repository root and run `py -3 helper/ingest.py` once | Confirms Python works. Prints "Wrote 23 sections" |
| 4 | Pre-type the three assistant commands below in a scratch file | No typing mistakes on screen |
| 5 | Optional: `cd showcase && npm run dev` and open http://localhost:3000 | A visual backup if screen sharing an IDE goes badly |
| 6 | Increase the editor font to 16 or more and close notifications | Readability on a shared screen |

---

## Timing at a glance

| Time | Segment | Show |
| --- | --- | --- |
| 0:00–0:30 | Opening and honest scope | README header |
| 0:30–1:10 | Personas, requirements, environments | `requirements.md`, architecture diagram |
| 1:10–1:55 | Configuration and automation | Validation rule XML, Escalation flow design |
| 1:55–2:35 | Security model | Security matrix, permission set groups |
| 2:35–3:10 | Reporting | Metric validation table |
| 3:10–4:00 | Release governance and rollback | Release plan, rollback drill |
| 4:00–4:45 | **Live:** retrieval assistant | Terminal |
| 4:45–5:00 | Close and next step | README metrics |

---

## Script

### 0:00–0:30 · Opening

**Show:** the `README.md` header and metric grid.

> "This is a Salesforce functional operations project across Sales Cloud and Service Cloud administration. It covers personas, access, case and pipeline processes, leadership reporting, release governance, and support runbooks.
>
> One thing up front: it's built for **two Developer Edition orgs**, so there's no sandbox and no customer production org. The metadata is complete as Salesforce DX source but **not deployed yet**. I'll show you the design and run the one piece that runs locally, the support assistant."

### 0:30–1:10 · Personas, requirements, environments

**Show:** `docs/requirements.md` (the Coverage table), then the README architecture diagram.

> "I started with four personas (Sales Rep, Support Agent L1, Support Lead L2, and Ops Admin) and twelve user stories with acceptance criteria. Everything later traces back to a REQ ID.
>
> The environment shape follows the edition. Developer Edition can't create sandboxes or do org-level source tracking. So **development is a scratch org** from Org A's Dev Hub, **Org B is a UAT stand-in**, and **Org A is a production stand-in**. Change sets can't connect two unrelated orgs, so every hop is a deploy of the same git commit."

### 1:10–1:55 · Configuration and automation

**Show:** `Lead_Convert_Requires_Qualified.validationRule-meta.xml`, then the Escalation section of `docs/flows.md`.

> "Eight custom fields and six validation rules hold the process contract. Here's a detail I like: the convert rule uses **PRIORVALUE**. The convert action itself writes Closed - Converted, so checking the current status would block every conversion.
>
> There are four record-triggered flows, all shipped as **Draft**. Take Escalation. A high-priority case still open after a day moves to the L2 queue. The flow fills the escalation reason and Escalated By *before* setting Escalated, so it doesn't trip its own validation rule. A missing queue or a missing Ops Admin is a handled outcome. The record isn't touched, and every flow has a fault path."

### 1:55–2:35 · Security model

**Show:** `docs/security-matrix.xlsx`, both sheets. Then scroll the `permissionsetgroups/` folder.

> "Profiles are minimum-access shells with **zero object permissions**. A profile-only user can log in but can't create anything. Access lives on seven permission sets, bundled into **one group per persona**.
>
> The payoff came in M4: adding reporting access was one permission set added to three groups. No profile was cloned. L1 deliberately gets no reporting set, because the requirement says L1 isn't the audience for the all-team backlog. And **no permission set grants Modify All Data**, not even Ops Admin's. A validation script fails if that ever changes."

### 2:35–3:10 · Reporting

**Show:** `docs/metric_validation.md`.

> "Ten reports and two dashboards, each tied to a requirement question. Both dashboards run as the logged-in user, so the numbers follow the viewer's access.
>
> Since I couldn't render them, I built a 66-row synthetic dataset and counted the expected values by hand: **221,000** open pipeline, **41.67%** conversion, **15** open cases, **4** escalations. The dashboard value is recorded honestly as *not observed*. The first live render gets checked against a known answer."

### 3:10–4:00 · Release governance and rollback

**Show:** the Pipeline and Approval sections of `release/release-plan.md`, then the Rollback Steps and Metadata Limitations sections of `release/rollback-drill.md`.

> "The release path is documented around Lifecycle Center and git. I studied Lifecycle Center, but it isn't installed. Flosum access is recorded as Not Executed, so it's kept out of the pipeline entirely.
>
> There are three stages, from work-item branch to `uat` to `main`, and **seven gates**, ending with a written Ops Admin approval and the commit SHA. Content ships as two packages: **Release 1**, the operating process and access with 61 members, then **Release 2**, the reporting with 16 members.
>
> For rollback, a metadata deploy is an **upsert**, so reverting the commit doesn't delete what Release 2 added. The drill uses `git revert` plus a **destructive list**, accepted on Org B before Org A. It also lists what metadata rollback *can't* undo, like standard picklist values that were never retrieved."

### 4:00–4:45 · Live: the retrieval assistant

**Run** these three commands:

```powershell
py -3 helper/ask.py "How do I qualify a lead?"
py -3 helper/ask.py "How do I create a full-copy sandbox from Org A?"
py -3 helper/eval/run_eval.py
```

> "Support is two persona guides plus L1 and L2 runbooks, **23 sections** in all. The assistant only retrieves from those sections.
>
> A covered question returns the approved page **verbatim**, with its citation. Here it's `SalesRep:Lead Qualification`.
>
> An uncovered question, like creating a sandbox we don't have, gets the approved refusal: *'This runbook does not contain an approved answer. Recommend escalation.'* It answers only when exactly one section matches. No match, or more than one, means it refuses.
>
> On the 30-question evaluation it scores **20 out of 20** correct answers, **10 out of 10** correct refusals, and **zero hallucinations**. And it can't touch Salesforce. A unit test checks that there's no deploy command, HTTP call, or subprocess in the code."

### 4:45–5:00 · Close

**Show:** the README Metrics section.

> "So it's a complete, traceable source portfolio, with M1 through M6 done, and I've been explicit about what hasn't run. The next step is connecting the two orgs, promoting Release 1 then Release 2 through the gates, and checking the dashboards against those hand counts. Happy to go deeper on any part."

---

## If something goes wrong

| Problem | Recovery line |
| --- | --- |
| `py` not found | Run `python helper/ask.py …` instead. Same result |
| Terminal output too small | Re-run with `--json` and zoom in: `py -3 helper/ask.py "How do I qualify a lead?" --json` |
| Excel won't open | Show the "Permission sets" table in `docs/profile_strategy.md` instead |
| Running over time | Skip the reporting segment. Mention "221,000 and 41.67% are hand-checked" in one sentence |
| Screen share fails entirely | Tell it verbally using the 30-second summary at the end of `INTERVIEW_GUIDE.md` |

## Likely follow-up questions

| Question | Short answer | Go deeper in |
| --- | --- | --- |
| "Why didn't you deploy it?" | The build workspace had no Salesforce CLI and no connected orgs. I documented the exact execution steps instead of claiming results | ROADMAP Horizon 1 |
| "Why not use Flosum?" | No access. A trial page or screenshot isn't access, so it's recorded as Not Executed and kept out of the pipeline | INTERVIEW_GUIDE Q41–42 |
| "What if Org B can't be a Lifecycle Center stage?" | Deploy the same commit to Org B with the CLI and record that Lifecycle Center didn't do that hop | ARCHITECTURE §2 |
| "Why are the flows Draft?" | Activation is a separate decision. Draft lets the synthetic load happen without routing overwriting the owners | INTERVIEW_GUIDE Q23 |
| "How do four personas work on two licenses?" | They're roles. UAT runs them one login at a time, or switches the group and Persona on one extra user | `docs/persona_testing.md` |
| "Why not a generative model for the assistant?" | A wrong click path in admin work is costly. Retrieval with a hard refusal can't invent one | INTERVIEW_GUIDE Q49 |

## Phrases to avoid

| Don't say | Say instead |
| --- | --- |
| "I deployed to production" | "Org A is a production stand-in. Nothing is deployed yet" |
| "I used our sandbox for UAT" | "Org B is a second Developer Edition org acting as UAT" |
| "I set up the Lifecycle Center pipeline" | "I studied Lifecycle Center and documented the pipeline. It isn't installed" |
| "I compared it with Flosum hands-on" | "I studied Flosum's published capabilities. Access is Not Executed" |
| "The dashboards show 221,000" | "The hand count is 221,000. The dashboard value isn't observed yet" |
| "The AI is 100% accurate" | "On the 30-question set it returned the right page 20 of 20 times and refused all 10 uncovered questions" |
