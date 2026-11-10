import { Section } from "@/components/ui";

const items = [
  {
    title: "Real sandboxes",
    copy: "This case study has none. A customer org with sandboxes would replace the Org B stand-in and let Lifecycle Center use the stage type it expects.",
  },
  {
    title: "Lifecycle Center validation",
    copy: "Install it on a connected Dev Hub, attach the pipeline, and record whether a second Developer Edition org can be a UAT stage.",
  },
  {
    title: "Flosum hands-on usage",
    copy: "Only after a real tenant exists. Until then the access status stays Not Executed, and no Flosum branching model is treated as live.",
  },
  {
    title: "Advanced AI search",
    copy: "Synonym search can come later, with the same refusal rule: if the corpus does not contain the procedure, the assistant still stops.",
  },
  {
    title: "Ticketing integration",
    copy: "A support ticket could deep-link to a runbook section. The assistant would still quote that section rather than edit the case.",
  },
  {
    title: "Knowledge analytics",
    copy: "Count which sections are retrieved and which questions are refused, then add the missing page instead of lowering the refusal bar.",
  },
];

export function Roadmap() {
  return (
    <Section
      id="roadmap"
      index="15"
      eyebrow="Future roadmap"
      title="Next work sits outside this Developer Edition boundary."
      lede="M6 closes the case study. The items below are what a later environment would make possible. They are not started here."
    >
      <ol className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
        {items.map((item, index) => (
          <li key={item.title} className="glass rounded-3xl p-5">
            <p className="num text-xs text-blue">0{index + 1}</p>
            <h3 className="mt-2 text-lg font-semibold text-white">{item.title}</h3>
            <p className="mt-3 text-sm leading-6 text-muted">{item.copy}</p>
          </li>
        ))}
      </ol>
    </Section>
  );
}
