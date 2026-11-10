import { ArrowDown } from "lucide-react";
import { Section } from "@/components/ui";

const before = ["Sales Team + Support Team", "Manual Processes", "Inconsistent Data", "Slow Resolution", "Operational Risk"];
const after = ["Salesforce Operational Platform", "Automation", "Reporting", "Release Governance", "User Enablement"];

function Column({ title, items, tone }: { title: string; items: string[]; tone: "risk" | "gain" }) {
  const ring = tone === "risk" ? "border-rose-300/30" : "border-teal/40";
  return (
    <div>
      <p className="text-sm font-medium text-white">{title}</p>
      <ol className="mt-4 space-y-3">
        {items.map((item, index) => (
          <li key={item}>
            <div className={`glass rounded-2xl border px-4 py-3 ${ring}`}>
              <p className="num text-[11px] tracking-widest text-muted">0{index + 1}</p>
              <p className="mt-1 text-sm text-white">{item}</p>
            </div>
            {index < items.length - 1 ? (
              <ArrowDown className="mx-auto my-2 text-muted" size={16} aria-hidden />
            ) : null}
          </li>
        ))}
      </ol>
    </div>
  );
}

export function Problem() {
  return (
    <Section
      id="problem"
      index="02"
      eyebrow="Business problem"
      title="Two teams were sharing one messy operating model."
      lede="Sales needed a forecast they could explain. Support needed a case that carried its own history. Both needed a release path that fits two Developer Edition orgs and a scratch org."
    >
      <div className="grid gap-8 lg:grid-cols-[1fr_auto_1fr] lg:items-start">
        <Column title="Where the work broke" items={before} tone="risk" />
        <div className="hidden place-items-center lg:grid">
          <span className="num rounded-full border border-white/15 px-3 py-8 text-xs tracking-[0.2em] text-teal [writing-mode:vertical-rl]">
            THEN
          </span>
        </div>
        <Column title="What the platform organizes" items={after} tone="gain" />
      </div>
    </Section>
  );
}
