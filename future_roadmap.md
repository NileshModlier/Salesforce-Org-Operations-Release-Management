# Future roadmap

M6 closes the portfolio as specified. The items below are later work. They are not started, and this file does not claim an org is ready for them.

## When Org A and Org B are real logins

1. Install the Salesforce CLI and authorize Org A and Org B on login.salesforce.com. Confirm the Developer Edition license counts before assigning personas.
2. Enable Dev Hub on Org A and read the scratch-org limits.
3. Turn on Lifecycle Center, connect GitHub.com or Bitbucket Cloud, and create the one project and three-stage pipeline in the release plan.
4. Record whether Org B can be attached as a stage. If it cannot, keep UAT as a CLI deploy of the same commit.
5. Promote Release 1, then Release 2, using the checklists. Do not force push.

## After the first promotion

- Load `data/synthetic/` with the flows still Draft, then compare the two hand-checked metrics per dashboard.
- Activate a flow only through a new work item, with UAT first.
- Add one requirement per later work item. Do not bundle unrelated changes into Release 1 or Release 2 after they have a deploy id.

## Still closed

- Flosum stays Not Executed until a real tenant exists. Do not describe a Flosum pipeline before that.
- Do not add a sandbox or call either Developer Edition org a customer production org.
- Do not extend the how-to assistant so that it deploys, assigns permissions, or answers from outside the guides and runbooks.
- Service Cloud features that need a Service Cloud user license stay out of reach while that license count is zero.
