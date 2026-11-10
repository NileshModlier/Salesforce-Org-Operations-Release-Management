import { Section } from "@/components/ui";

const stages = [
  ["Prospecting", "10%"],
  ["Qualification", "20%"],
  ["Proposal", "50%"],
  ["Negotiation", "80%"],
  ["Closed Won", "100%"],
  ["Closed Lost", "0%"],
];

const blocks = [
  {
    title: "Lead qualification",
    copy: "A lead needs an email or a phone number. Product Interest is Core Product, Add-on Service, Renewal, or Undecided. Convert only when the prior status is Qualified. The convert action writes Closed - Converted.",
  },
  {
    title: "Pipeline management",
    copy: "Next Step is a 255-character action on the opportunity. The stage path is the six values below. Open stages and Closed Lost may have a blank amount.",
  },
  {
    title: "Conversion tracking",
    copy: "The conversion-rate formula is converted leads divided by all leads. On the synthetic file that is 10 of 24, shown as 41.67% after the documented convert step.",
  },
  {
    title: "Opportunity management",
    copy: "Closed Won requires an amount greater than zero. The error sits on Amount. A Sales Rep edits their own opportunities and cannot delete them.",
  },
];

export function SalesCloud() {
  return (
    <Section
      id="sales"
      index="05"
      eyebrow="Sales Cloud"
      title="A forecast path a rep can defend."
      lede="Lead status, opportunity stage, and the close rule are configuration. The personal pipeline report is scoped to the running user."
    >
      <div className="grid gap-3 sm:grid-cols-3 lg:grid-cols-6">
        {stages.map(([name, weight], index) => (
          <div key={name} className="glass relative rounded-2xl px-3 py-4">
            <p className="num text-[11px] text-blue">0{index + 1}</p>
            <p className="mt-2 text-sm font-medium text-white">{name}</p>
            <p className="num mt-1 text-xs text-muted">{weight}</p>
          </div>
        ))}
      </div>
      <div className="mt-4 grid gap-4 md:grid-cols-2">
        {blocks.map((block) => (
          <article key={block.title} className="glass rounded-3xl p-5">
            <h3 className="text-lg font-semibold text-white">{block.title}</h3>
            <p className="mt-3 text-sm leading-6 text-muted">{block.copy}</p>
          </article>
        ))}
      </div>
      <div className="glass mt-4 rounded-3xl p-5">
        <p className="text-sm font-medium text-white">Validation on the sales path</p>
        <ul className="mt-3 grid gap-2 text-sm text-muted md:grid-cols-3">
          <li>Email or phone, or the lead does not save.</li>
          <li>Convert only from Qualified.</li>
          <li>Closed Won amount must be greater than zero.</li>
        </ul>
      </div>
    </Section>
  );
}
