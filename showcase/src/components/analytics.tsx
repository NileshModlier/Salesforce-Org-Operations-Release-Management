import { Section } from "@/components/ui";

const kpis = [
  { label: "Conversion rate", value: "41.67%", note: "10 converted leads of 24, after the documented convert step." },
  { label: "Open opportunity value", value: "221,000", note: "13 open rows. Full book for a user who can read every opportunity." },
  { label: "Open cases", value: "15", note: "High 7, Medium 4, Low 4. Status is not Closed." },
  { label: "Escalations", value: "4", note: "High 2, Medium 1, Low 1." },
];

const salesReports = [
  "Lead Conversion By Source",
  "Pipeline By Stage",
  "Opportunities Closing This Month",
  "Open Opportunity Value",
  "Conversion Rate",
];

const supportReports = [
  "Open Cases By Priority",
  "Cases By Status",
  "First Response Performance",
  "Escalations By Priority",
  "Cases Closed By Agent",
];

const bars = [
  { label: "High", value: 7, width: "100%" },
  { label: "Medium", value: 4, width: "57%" },
  { label: "Low", value: 4, width: "57%" },
];

export function Analytics() {
  return (
    <Section
      id="analytics"
      index="09"
      eyebrow="Analytics"
      title="Ten reports. Two leadership dashboards."
      lede="Sales Dashboard and Support Dashboard run as the logged-in user. These figures are the synthetic hand count. They were not read from a rendered dashboard."
    >
      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
        {kpis.map((kpi) => (
          <article key={kpi.label} className="glass rounded-3xl p-5">
            <p className="text-sm text-muted">{kpi.label}</p>
            <p className="num mt-2 text-3xl text-white">{kpi.value}</p>
            <p className="mt-3 text-sm leading-6 text-muted">{kpi.note}</p>
          </article>
        ))}
      </div>
      <div className="mt-4 grid gap-4 lg:grid-cols-[1.1fr_0.9fr]">
        <article className="glass rounded-3xl p-5">
          <h3 className="text-lg font-semibold text-white">Open cases by priority</h3>
          <ul className="mt-5 space-y-4">
            {bars.map((bar) => (
              <li key={bar.label}>
                <div className="mb-1 flex justify-between text-sm">
                  <span className="text-white">{bar.label}</span>
                  <span className="num text-muted">{bar.value}</span>
                </div>
                <div className="h-2 rounded-full bg-white/10">
                  <div className="h-2 rounded-full bg-gradient-to-r from-blue to-teal" style={{ width: bar.width }} />
                </div>
              </li>
            ))}
          </ul>
        </article>
        <article className="glass rounded-3xl p-5">
          <h3 className="text-lg font-semibold text-white">Report inventory</h3>
          <div className="mt-4 grid gap-4 sm:grid-cols-2">
            <div>
              <p className="text-xs tracking-wide text-teal uppercase">Sales Dashboard</p>
              <ul className="mt-2 space-y-2 text-sm text-muted">
                {salesReports.map((name) => (
                  <li key={name}>{name}</li>
                ))}
              </ul>
            </div>
            <div>
              <p className="text-xs tracking-wide text-violet uppercase">Support Dashboard</p>
              <ul className="mt-2 space-y-2 text-sm text-muted">
                {supportReports.map((name) => (
                  <li key={name}>{name}</li>
                ))}
              </ul>
            </div>
          </div>
        </article>
      </div>
    </Section>
  );
}
