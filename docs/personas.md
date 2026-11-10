# Personas

Four operating roles define who does the work in this project. They are roles, not four licensed Salesforce users. A standard Developer Edition org includes two Salesforce CRM user licenses, and a Developer scratch org has the same CRM license ceiling. Later milestones map these roles onto the licenses the connected org actually shows on Company Information.

Permissions, reports, and objects below are the target operating model. M1 does not create profiles, permission sets, permission set groups, reports, dashboards, fields, or automation.

## Sales Rep

### Responsibilities

- Own leads from first contact through qualification.
- Convert qualified leads into an account, a contact, and an opportunity.
- Keep owned opportunities on the documented stage path, with amount and close date current.
- Prepare a personal pipeline view for forecast conversations.
- Leave case handling and org setup to support and the Ops Admin.

### Objects Used

- Lead: create, read, and edit records the rep owns.
- Account: read.
- Contact: read.
- Opportunity: create, read, and edit records the rep owns.
- Task and Event: create and read the rep's own follow-up activity.

### Reports Needed

- My open pipeline by stage, with amount and close date.
- My leads by status.
- My opportunities closing this month.

These report names are requirements only. No report metadata is created in M1.

### Permissions Needed

- Create, read, and edit own leads. No lead delete.
- Read accounts and contacts.
- Create, read, and edit own opportunities. No opportunity delete.
- Run reports on records the rep can already see.
- No case access.
- No Manage Users, Customize Application, Modify All Data, or View All Data.

### Pain Points

- Stage names drift when each rep invents a private sales process.
- Unqualified leads become empty opportunities and distort the forecast.
- A rep cannot see which owned deals need action this week without a personal pipeline list.
- A shared login hides who actually owns a deal.

### Success Criteria

- Every owned opportunity uses the documented stage path.
- Only a Qualified lead is converted.
- The rep can run a personal pipeline report without an admin in the middle.
- The rep cannot edit cases or change setup.

## Support Agent L1

### Responsibilities

- Open a case for each customer request.
- Work cases the agent owns and cases waiting in the L1 Support Queue.
- Record status changes and the notes the next person needs.
- Escalate a case that is beyond L1 skill or authority, and include the reason.
- Leave opportunity edits and org setup alone.

### Objects Used

- Case: create, read, and edit owned cases and cases in the L1 Support Queue.
- Account: read, to see who the customer is.
- Contact: read, and relate the case to a contact when the person is known.
- Case comments or Chatter feed: add the working history on the case.

### Reports Needed

- My open cases.
- L1 Support Queue by priority.

### Permissions Needed

- Create cases.
- Read and edit cases the agent owns or that sit in the L1 Support Queue.
- Read accounts and contacts.
- Add comments on those cases.
- No case delete.
- No edit on leads or opportunities.
- No Manage Users, Customize Application, Modify All Data, or View All Data.

### Pain Points

- Requests arrive with no priority, no customer link, and no single owner.
- Escalation is a side conversation, so L2 never receives a reason.
- An agent cloned from an admin profile can change records the job does not need.
- Working notes live in chat instead of on the case.

### Success Criteria

- Every new request is a case with owner, status, priority, and origin.
- Escalation sets status to Escalated, stores a reason, and lands on the L2 Escalation Queue.
- The escalating agent remains identifiable.
- L1 cannot delete cases or edit opportunities.

## Support Lead L2

### Responsibilities

- Watch the L2 Escalation Queue and take ownership of escalated cases.
- Resolve an escalated case, or return it to L1 with written guidance.
- Review backlog by status, priority, and owner before a support standup.
- Read sales context when a case depends on an open opportunity.
- Leave user administration and application setup to the Ops Admin.

### Objects Used

- Case: read and edit support cases, including cases the lead does not yet own.
- Account: read.
- Contact: read.
- Opportunity: read, for commercial context on a case.
- User: read, to see who owns a case.

### Reports Needed

- Escalated cases.
- Case backlog by status and priority.
- Open cases by owner.

### Permissions Needed

- Read and edit all support cases in this operating model.
- Transfer case ownership and assign the L1 Support Queue or the L2 Escalation Queue.
- Read accounts, contacts, and opportunities.
- Run the support backlog reports.
- No case delete.
- No Manage Users, Customize Application, Modify All Data, or authoring of profiles and permission sets.

### Pain Points

- Escalations arrive with no reason and no previous owner.
- Without one queue, L2 hunts through personal case lists.
- Backlog is invisible until someone exports a spreadsheet.
- A case returned to L1 loses the guidance when the note is optional.

### Success Criteria

- L2 can see every Escalated case before taking ownership.
- A returned case includes guidance and a clear L1 destination.
- A closed case stores a resolution.
- L2 can run the team backlog report and cannot change setup.

## Ops Admin

### Responsibilities

- Own configuration of Org A and the promotion path into Org B.
- Map the four personas onto the CRM licenses the org actually has.
- Author profiles, permission sets, and permission set groups only in the milestone that implements the security model.
- Keep this git repository as the source of truth and keep secrets out of it.
- Confirm Developer Edition limits before promising a feature, especially Service Cloud user licenses.
- Answer access and process questions from sales and support.

### Objects Used

- User, Profile, Permission Set, and Permission Set Group, when the security milestone starts.
- Lead, Account, Contact, Opportunity, and Case, for troubleshooting the same records the other personas use.
- Report and Dashboard, when the reporting milestone starts.

### Reports Needed

- Users by profile, once more than one user exists.
- Cases opened this week, as an operations check.
- Opportunities by stage, as a check that the stage path is actually used.

### Permissions Needed

- System Administrator on the project orgs, including Customize Application and Manage Users.
- Authorize the Salesforce CLI to Org A, Org B, and scratch orgs created from Org A.
- Open Lifecycle Center on Org A in M5, using the permission sets that product assigns.
- A named admin user. No shared password.

### Pain Points

- Org A and Org B are separate Developer Edition orgs, so there is no sandbox refresh and no change set between them.
- Four roles must fit on two Salesforce CRM licenses.
- The partner license comparison lists zero Service Cloud user licenses on Developer Edition, so Service Cloud-only features cannot be assumed.
- Flosum access was not obtained, so the release path cannot depend on a Flosum tenant.
- The Dev Hub allows three active scratch orgs and six creations a day, so throwaway environments are scarce.

### Success Criteria

- Org roles, persona access, and requirements are written down before any metadata is built.
- The project states Developer Edition as the edition in use.
- Secrets stay out of git.
- A later milestone can implement access without inventing a fifth persona.
