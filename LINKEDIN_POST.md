# LinkedIn Post

The post text is between the lines below. It's about 2,882 characters, so it stays under LinkedIn's 3,000-character limit after you replace `[link]` with the repository URL.

**Suggested image:** the README architecture diagram, or a screenshot of the terminal showing one verbatim answer, one refusal, and the evaluation summary from `helper/eval/run_eval.py`.

---

🚀 New portfolio project: Salesforce Org Operations & Release Management

Most Salesforce orgs don't struggle because a feature is missing. They struggle because nobody wrote down who owns what, access drifts from the job, and changes move between orgs with no record.

I built a functional operations project across Sales Cloud and Service Cloud administration to tackle that, using only free Developer Edition orgs and Salesforce's public documentation.

🏗️ What it covers
• 4 personas and 12 user stories, each traced to metadata, a release package and a validation script
• Process contracts as standard value sets: one stage path, lead statuses, case statuses
• 6 validation rules that require information at the right transition (qualified-only conversion with PRIORVALUE, escalation reason, return guidance, resolution notes)
• 4 record-triggered flows for lead routing, case queues, first-response tracking and one-day escalation, each with a fault path and shipped as Draft
• Least-privilege access: profiles with zero object permissions, 7 permission sets in 4 persona groups, no Modify All Data
• 10 reports and 2 dashboards, with expected values hand-checked against a synthetic dataset
• Release governance without sandboxes: scratch org → UAT org → production stand-in, 7 gates, 2 separable packages, revert-plus-destructive rollback
• L1 and L2 runbooks, plus an AI helper that quotes one approved page or refuses

📊 By the numbers
• 4 personas · 12 requirements
• 8 custom fields · 6 validation rules · 4 flows
• 7 permission sets · 4 permission set groups
• 10 reports · 2 dashboards
• 23 support procedure sections
• AI helper: 20/20 correct answers, 10/10 correct refusals, 0 hallucinations on a 30-question test set

💡 What I learned
1. Release governance: a skipped gate is a failed promotion, not a rollback. Every hop deploys the same commit.
2. Metadata vs data recovery: a deploy is an upsert. Rollback needs a destructive list, and it can't restore records or picklist values you never retrieved.
3. Salesforce DX: without sandboxes, scratch orgs are the only source-tracked dev environment, and the edition's limits shape the architecture.
4. Runbooks: one symptom per entry, with escalation criteria that name the next person.
5. Human-in-the-loop AI: refusal is a feature. Measure it.

🔍 Scope, stated plainly
Built for Developer Edition: no production org, Enterprise org or sandbox. The metadata is complete in source but not yet deployed. Lifecycle Center was studied and the process documented for it. Flosum access was not obtained. Connecting the two orgs and promoting the releases is next.

If you work in Salesforce admin, operations or release management, I'd value your feedback.

🔗 GitHub repository: [link]

#Salesforce #SalesforceAdmin #SalesCloud #ServiceCloud #SalesforceDX #ReleaseManagement #Flow #Trailblazer #CRM #KnowledgeManagement

---

## Shorter variant (about 566 characters)

Built a Salesforce functional operations project on Developer Edition: 4 personas and 12 traced requirements, 8 fields, 6 validation rules, 4 Draft flows, 7 permission sets in 4 groups (no Modify All Data), and 10 reports with 2 dashboards. Release governance without sandboxes uses 7 gates, 2 packages and a revert-plus-destructive rollback. L1 and L2 runbooks sit behind an AI helper that scored 20/20 correct answers, 10/10 correct refusals and 0 hallucinations. Complete in source, not yet deployed.

#Salesforce #SalesforceAdmin #ReleaseManagement #ServiceCloud

---

## Posting notes

- Post the full version on a weekday morning, and reply to early comments within the first hour.
- Keep the "Scope, stated plainly" paragraph. It answers the first question a Salesforce reviewer will ask.
- If you tag tools, describe Lifecycle Center as *studied* and Flosum as *not obtained*. Don't tag them as tools you used.
