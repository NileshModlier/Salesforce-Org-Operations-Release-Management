import { Section } from "@/components/ui";

const tiers = [
  {
    title: "Guides",
    items: [
      "Sales Rep: qualify, update the pipeline, close, run my pipeline report.",
      "Support Agent: create a case, record first response, escalate, know the limits.",
      "Each task is one page with steps, an expected outcome, troubleshooting, and a quick reference at the end of the guide.",
    ],
  },
  {
    title: "L1 runbook",
    items: [
      "Login problems and authenticator codes.",
      "Record visibility and missing data.",
      "Report access, dashboard access, and case reassignment.",
    ],
  },
  {
    title: "L2 runbook",
    items: [
      "Flow faults and the six validation messages.",
      "Permission set group mismatches.",
      "Release failures, data corrections, and reporting discrepancies.",
    ],
  },
];

export function Support() {
  return (
    <Section
      id="support"
      index="11"
      eyebrow="User support"
      title="The next step is a page, or an escalation."
      lede="Every runbook entry has a symptom, checks, a resolution, and escalation criteria. The assistant may quote the page. A person still does the work."
    >
      <div className="grid gap-4 lg:grid-cols-3">
        {tiers.map((tier) => (
          <article key={tier.title} className="glass rounded-3xl p-5">
            <h3 className="text-lg font-semibold text-white">{tier.title}</h3>
            <ul className="mt-4 space-y-3 text-sm leading-6 text-muted">
              {tier.items.map((item) => (
                <li key={item}>{item}</li>
              ))}
            </ul>
          </article>
        ))}
      </div>
      <div className="glass mt-4 rounded-3xl p-5">
        <h3 className="text-lg font-semibold text-white">Escalation path</h3>
        <ol className="mt-4 grid gap-3 md:grid-cols-4">
          {[
            "Guide page for the task",
            "L1 entry when access or ownership is the symptom",
            "L2 entry when the rule, flow, release, or number is the symptom",
            "Ops Admin when the entry says to assign access or promote",
          ].map((step, index) => (
            <li key={step} className="rounded-2xl border border-white/10 bg-white/[0.03] p-4 text-sm text-white">
              <span className="num text-xs text-teal">0{index + 1}</span>
              <p className="mt-2 leading-6">{step}</p>
            </li>
          ))}
        </ol>
        <p className="mt-4 text-sm leading-6 text-muted">
          Knowledge lives in the markdown pages. A new answer is a new section with a stable id, not a private note in chat.
        </p>
      </div>
    </Section>
  );
}
