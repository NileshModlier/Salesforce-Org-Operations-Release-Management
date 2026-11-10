import { Section } from "@/components/ui";

const metrics = [
  ["12", "Requirements"],
  ["8", "Fields"],
  ["6", "Validation rules"],
  ["4", "Flows"],
  ["7", "Permission sets"],
  ["4", "Permission set groups"],
  ["10", "Reports"],
  ["2", "Dashboards"],
  ["23", "Support procedures"],
  ["20", "Correct answers"],
  ["10", "Correct refusals"],
  ["0", "Hallucinations"],
];

export function Metrics() {
  return (
    <Section
      id="metrics"
      index="13"
      eyebrow="Project metrics"
      title="The inventory a reviewer can recount."
      lede="These counts come from the repository and from the local assistant evaluation. They are not live org statistics."
    >
      <div className="grid grid-cols-2 gap-3 sm:grid-cols-3 lg:grid-cols-4">
        {metrics.map(([value, label]) => (
          <article key={label} className="glass rounded-3xl px-4 py-5">
            <p className="num text-3xl text-white">{value}</p>
            <p className="mt-2 text-sm text-muted">{label}</p>
          </article>
        ))}
      </div>
    </Section>
  );
}
