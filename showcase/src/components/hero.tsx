"use client";

import { Counter } from "@/components/ui";

const counters = [
  { value: 12, label: "Requirements" },
  { value: 8, label: "Custom Fields" },
  { value: 6, label: "Validation Rules" },
  { value: 4, label: "Flows" },
  { value: 10, label: "Reports" },
  { value: 2, label: "Dashboards" },
  { value: 23, label: "Runbook Sections" },
  { value: 0, label: "Hallucinations" },
];

export function Hero() {
  return (
    <section id="top" className="px-5 pt-28 pb-16 sm:px-8 lg:px-12">
      <div className="mx-auto grid max-w-6xl items-end gap-10 lg:grid-cols-[1.4fr_0.8fr]">
        <div>
          <p className="rise num text-xs tracking-[0.22em] text-teal uppercase">Portfolio case study</p>
          <h1 className="rise rise-delay mt-4 max-w-4xl text-4xl leading-tight font-semibold tracking-tight text-white sm:text-6xl">
            Salesforce Org Operations & Release Management
          </h1>
          <p className="mt-5 max-w-2xl text-lg leading-8 text-muted">
            Salesforce Administration, CRM Operations, Release Governance and AI-Assisted User Support
          </p>
          <div className="mt-8 flex flex-wrap gap-3">
            <a href="#problem" className="rounded-full bg-blue px-5 py-2.5 text-sm font-semibold text-[#041225]">
              Read the case study
            </a>
            <a href="#architecture" className="rounded-full border border-white/15 px-5 py-2.5 text-sm text-white">
              View the architecture
            </a>
          </div>
        </div>
        <aside className="rise rise-late glass rounded-3xl p-5">
          <p className="text-sm font-medium text-white">Environment boundary</p>
          <ul className="mt-4 space-y-3 text-sm text-muted">
            <li className="flex items-start justify-between gap-4">
              <span>Org A</span>
              <span className="text-right text-white">Production stand-in and Dev Hub</span>
            </li>
            <li className="flex items-start justify-between gap-4">
              <span>Org B</span>
              <span className="text-right text-white">UAT stand-in</span>
            </li>
            <li className="flex items-start justify-between gap-4">
              <span>Scratch org</span>
              <span className="text-right text-white">Development</span>
            </li>
            <li className="flex items-start justify-between gap-4">
              <span>Edition</span>
              <span className="text-right text-white">Developer Edition</span>
            </li>
            <li className="flex items-start justify-between gap-4">
              <span>Flosum</span>
              <span className="text-right text-white">Studied. Access not executed</span>
            </li>
            <li className="flex items-start justify-between gap-4">
              <span>Lifecycle Center</span>
              <span className="text-right text-white">Documented. Not installed</span>
            </li>
          </ul>
          <p className="mt-4 text-xs leading-5 text-muted">
            Source is complete. The orgs are not connected, and nothing in this case study has been deployed.
          </p>
        </aside>
      </div>
      <div className="mx-auto mt-10 grid max-w-6xl grid-cols-2 gap-3 sm:grid-cols-4 lg:grid-cols-8">
        {counters.map((item) => (
          <Counter key={item.label} value={item.value} label={item.label} />
        ))}
      </div>
    </section>
  );
}
