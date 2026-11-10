# Sales Rep guide

Each task below is one page. The assistant does not change Salesforce. A person follows the steps.

## SalesRep:Lead Qualification

Keywords: qualify a lead

Page: Sales Rep, task 1 of 4

### Steps

1. Open a lead you own. You can create and edit your own leads. You cannot delete a lead.
2. Enter an email address or a phone number before you save. A mobile number does not satisfy the rule. If both are blank, the save stops with: Enter an email address or a phone number before saving this lead.
3. Set Product Interest to Core Product, Add-on Service, Renewal, or Undecided.
4. Use only these statuses: Open - Not Contacted, Working - Contacted, Qualified, Unqualified, and Closed - Converted. Closed - Converted is written by the convert action.
5. Set the status to Qualified only when the lead is ready to become an account, a contact, and an opportunity.
6. Convert from Qualified. The convert action sets Closed - Converted. If the prior status was anything else, the save stops with: Convert this lead only when its status is Qualified.

### Expected outcome

The lead becomes an account, a contact, and an opportunity through the standard convert action. You still have no access to cases.

### Troubleshooting

- Do not convert an Unqualified lead to remove it from the list. Leave it Unqualified.
- Lead Assignment is Draft. The owner stays the person who created the lead until Ops Admin activates that flow under a release. Do not expect a placeholder owner such as sales.core@org-ops.invalid to appear while the flow is Draft.
- Name and Company are still required by Salesforce. This page does not replace those standard requirements.

## SalesRep:Update the Pipeline

Keywords: next step on the opportunity

Page: Sales Rep, task 2 of 4

### Steps

1. Open an opportunity you own. You can create, read, and edit your own opportunities. You cannot delete one.
2. Keep the stage on this path: Prospecting, Qualification, Proposal, Negotiation, Closed Won, Closed Lost.
3. Fill Next Step with the next action, in 255 characters or fewer.
4. Keep Amount and Close Date current when you know them. Open stages may be saved with Amount blank. Closed Lost may be saved with Amount blank.
5. Read Account and Contact for context. Do not try to edit a case from this page. You have no case access.

### Expected outcome

The opportunity shows a contract stage and a next step another person can read. Your pipeline report can group it by stage.

### Troubleshooting

- If the stage you want is not in the list, do not type a private stage. The value set is the contract path.
- Support Lead L2 can read the opportunity and Next Step is read-only for that persona. That does not change what you can edit on your own record.

## SalesRep:Close an Opportunity

Keywords: closed won amount

Page: Sales Rep, task 3 of 4

### Steps

1. Open the opportunity you own.
2. For Closed Won, enter an amount greater than zero, then set the stage to Closed Won.
3. If Amount is blank, zero, or negative, the save stops with: Enter an amount greater than zero before setting the stage to Closed Won.
4. For Closed Lost, set the stage to Closed Lost. A blank amount is allowed on Closed Lost.
5. Update Next Step so the handoff or the loss is clear.

### Expected outcome

Closed Won is saved only with a positive amount. Closed Lost is saved without that amount check.

### Troubleshooting

- Do not put a zero amount on a won deal to make a forecast look smaller. The rule blocks it.
- Closed Won and Closed Lost are the only closed stages.

## SalesRep:Run My Pipeline Report

Keywords: my pipeline report

Page: Sales Rep, task 4 of 4

### Steps

1. Confirm Ops Admin has assigned the Sales Rep permission set group. That group includes Run Reports. Your profile alone does not.
2. Open the Sales Leadership folder and run Pipeline By Stage.
3. Read the rows as your own opportunities. The report scope is the running user. Amount, close date, and next step are on the row.
4. Use Opportunities Closing This Month only as a leadership view of the current calendar month. Your own rows are the ones you can see.
5. Do not open the Support Leadership dashboard for case work. You have no case access, and that dashboard is not your job.

### Expected outcome

You can explain your own book by stage without an admin running the report for you.

### Troubleshooting

- If Run Reports is missing, stop. Ask Ops Admin to assign the Sales Rep group. Do not ask for the Ops Admin group.
- A full-book total such as 221,000 open amount is the Ops Admin figure, not the figure a single rep should expect.
- The four flows are Draft. Nothing on this page activates them.

## SalesRep:Quick Reference

Keywords: sales rep quick reference

Page: Sales Rep quick reference

| Task | Do this | Stop when |
| --- | --- | --- |
| Lead | Email or phone, then Product Interest, then Qualified, then convert | The convert error names any status other than Qualified |
| Pipeline | Contract stage plus Next Step | You need a stage that is not on the path |
| Close | Positive amount, then Closed Won | Amount is blank, zero, or negative |
| Report | Pipeline By Stage, your own rows | You have no Run Reports permission |

### Expected outcome

You can pick the page that matches the task without opening setup.

### Troubleshooting

- If the task is not in the table, do not invent a click path. Ask Support or Ops Admin.
- You cannot delete leads or opportunities, edit cases, or change users, profiles, or permission sets.
