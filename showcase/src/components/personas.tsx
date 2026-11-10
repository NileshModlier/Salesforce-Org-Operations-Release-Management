import { Section } from "@/components/ui";

const personas = [
  {
    name: "Sales Rep",
    goal: "Explain an owned book in a forecast conversation.",
    responsibilities: [
      "Qualify leads and convert only from Qualified.",
      "Keep opportunities on the six-stage path with a next step.",
      "Run Pipeline By Stage on records they own.",
    ],
    kpis: ["Owned pipeline by stage", "Leads ready to convert", "Deals closing this month"],
    permissions: [
      "Create, read, and edit own leads and opportunities.",
      "Read accounts and contacts. No case access. No delete.",
      "Run Reports through the Sales Rep group.",
    ],
  },
  {
    name: "Support Agent L1",
    goal: "Turn every request into a case the next person can continue.",
    responsibilities: [
      "Open cases and work the ones they own or that sit in the L1 queue.",
      "Record the first response when status leaves New.",
      "Escalate with a reason and their own name.",
    ],
    kpis: ["Cases left New with a first response", "Escalations that include a reason", "Queue cases taken, not transferred blindly"],
    permissions: [
      "Create, read, and edit own or queue cases. No delete.",
      "Resolution notes and return guidance stay read-only.",
      "No Run Reports. The team backlog is an L2 report.",
    ],
  },
  {
    name: "Support Lead L2",
    goal: "See the backlog and finish or return every escalation.",
    responsibilities: [
      "Read every case, including ones they do not yet own.",
      "Resolve an escalated case or return it with written guidance.",
      "Run the status-and-priority backlog before standup.",
    ],
    kpis: ["Open cases by priority", "Escalations still open", "Cases closed with resolution notes"],
    permissions: [
      "Read and edit all cases. Transfer Cases. No delete.",
      "Read opportunities. Next Step is read-only.",
      "Run Reports through the Support Lead L2 group.",
    ],
  },
  {
    name: "Ops Admin",
    goal: "Keep access, releases, and the assistant's source of truth in one place.",
    responsibilities: [
      "Assign one permission set group and set User.Persona__c.",
      "Approve promotion from UAT to the production stand-in.",
      "Add queue membership. A group assignment does not do that.",
    ],
    kpis: ["Release outcome written with a commit SHA", "Personas matched to the right group", "Flows still Draft unless a work item says otherwise"],
    permissions: [
      "Customize Application, Manage Users, View Setup, View All Users.",
      "View all business records. No Modify All Data.",
      "Run and manage the project reports.",
    ],
  },
];

export function Personas() {
  return (
    <Section
      id="personas"
      index="04"
      eyebrow="Personas"
      title="Four roles. Two CRM licenses."
      lede="The personas are jobs, not four simultaneous Salesforce users. A Developer Edition org has two CRM licenses, so UAT runs one role, then the next."
    >
      <div className="grid gap-4 md:grid-cols-2">
        {personas.map((persona) => (
          <article key={persona.name} className="glass rounded-3xl p-5">
            <h3 className="text-xl font-semibold text-white">{persona.name}</h3>
            <p className="mt-2 text-sm leading-6 text-teal">{persona.goal}</p>
            <div className="mt-5 grid gap-4 sm:grid-cols-3">
              <div>
                <p className="text-xs tracking-wide text-muted uppercase">Responsibilities</p>
                <ul className="mt-2 space-y-2 text-sm leading-5 text-white/90">
                  {persona.responsibilities.map((item) => (
                    <li key={item}>{item}</li>
                  ))}
                </ul>
              </div>
              <div>
                <p className="text-xs tracking-wide text-muted uppercase">KPIs</p>
                <ul className="mt-2 space-y-2 text-sm leading-5 text-white/90">
                  {persona.kpis.map((item) => (
                    <li key={item}>{item}</li>
                  ))}
                </ul>
              </div>
              <div>
                <p className="text-xs tracking-wide text-muted uppercase">Permissions</p>
                <ul className="mt-2 space-y-2 text-sm leading-5 text-white/90">
                  {persona.permissions.map((item) => (
                    <li key={item}>{item}</li>
                  ))}
                </ul>
              </div>
            </div>
          </article>
        ))}
      </div>
    </Section>
  );
}
