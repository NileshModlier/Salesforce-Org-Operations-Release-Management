import { Section } from "@/components/ui";

const timeline = [
  { name: "Development", detail: "Scratch org from Org A. Work item branch." },
  { name: "UAT", detail: "Org B. Same commit. Lifecycle Center stage is still an open check." },
  { name: "Approval", detail: "Ops Admin writes the commit SHA. The author is not the only reviewer." },
  { name: "Production stand-in", detail: "Org A receives that commit. This is not a customer production org." },
];

export function Release() {
  return (
    <Section
      id="release"
      index="10"
      eyebrow="Release governance"
      title="Promote a known commit, or do not promote."
      lede="The control plane is Lifecycle Center on Org A, with git as the source of truth. Flosum was studied and left unused because access was never obtained."
    >
      <ol className="grid gap-3 md:grid-cols-4">
        {timeline.map((step, index) => (
          <li key={step.name} className="glass rounded-3xl p-4">
            <p className="num text-xs text-blue">0{index + 1}</p>
            <h3 className="mt-2 text-base font-semibold text-white">{step.name}</h3>
            <p className="mt-2 text-sm leading-6 text-muted">{step.detail}</p>
          </li>
        ))}
      </ol>
      <div className="mt-4 grid gap-4 lg:grid-cols-3">
        <article className="glass rounded-3xl p-5">
          <h3 className="text-lg font-semibold text-white">Release packages</h3>
          <p className="mt-3 text-sm leading-6 text-muted">
            Release 1 is fields, rules, layouts, record pages, Draft flows, queues, profiles, permission sets, and groups. Release 2 is the ten reports and two dashboards. Both outcomes are Not executed. Rollback status is Not required.
          </p>
        </article>
        <article className="glass rounded-3xl p-5">
          <h3 className="text-lg font-semibold text-white">Rollback strategy</h3>
          <p className="mt-3 text-sm leading-6 text-muted">
            Revert the commit. Do not force push. A normal deploy does not delete what the bad commit added, so removing Release 2 uses an explicit destructive list after Org B accepts it. The drill is a tabletop.
          </p>
        </article>
        <article className="glass rounded-3xl p-5">
          <h3 className="text-lg font-semibold text-white">Change log</h3>
          <p className="mt-3 text-sm leading-6 text-muted">
            Every entry records date, components, reason, outcome, and rollback status. The template is ready for the next work item. No deploy id exists yet.
          </p>
        </article>
      </div>
      <div className="glass mt-4 overflow-x-auto rounded-3xl">
        <table className="w-full min-w-[640px] text-left text-sm">
          <caption className="px-5 pt-5 text-left font-medium text-white">Lifecycle Center and Flosum</caption>
          <thead className="text-muted">
            <tr>
              {["Question", "Lifecycle Center", "Flosum"].map((heading) => (
                <th key={heading} className="px-5 py-3 font-medium">
                  {heading}
                </th>
              ))}
            </tr>
          </thead>
          <tbody className="text-white/90">
            {[
              ["Role in this case study", "Documented control plane", "Studied. Not connected"],
              ["Access", "Available in Developer Edition. Not installed", "Not Executed"],
              ["Git", "GitHub.com or Bitbucket Cloud", "Not evaluated in a tenant"],
              ["Promotion", "Work item, review, UAT, then Org A", "No branching model was written as live"],
              ["Rollback", "Git revert plus a destructive list when delete is required", "No tenant procedure"],
            ].map((row) => (
              <tr key={row[0]} className="border-t border-white/10">
                {row.map((cell, index) => (
                  <td key={`${row[0]}-${index}`} className="px-5 py-3 align-top">
                    {cell}
                  </td>
                ))}
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </Section>
  );
}
