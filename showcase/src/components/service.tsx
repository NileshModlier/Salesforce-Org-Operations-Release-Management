import { Section } from "@/components/ui";

const lifecycle = ["New", "Working", "Waiting on Customer", "Escalated", "Closed"];

const topics = [
  {
    title: "First response tracking",
    copy: "When status leaves New and First Response At is empty, the before-save flow stamps it once. A later edit does not overwrite a value that is already there.",
  },
  {
    title: "Escalation management",
    copy: "Status Escalated requires Escalation Reason and Escalated By. L1 writes both. The scheduled flow, still Draft, would do the same after one day for an aged high-priority case and notify Ops Admin.",
  },
  {
    title: "Resolution management",
    copy: "Closing requires resolution notes. Sending an escalated case back to New, Working, or Waiting on Customer requires return guidance. L1 sees both fields as read-only. L2 edits them and still cannot delete the case.",
  },
  {
    title: "Case assignment",
    copy: "On create, High plus Problem, Feature Request, or a blank type routes to the L2 Escalation Queue. Every other new case routes to the L1 Support Queue. A missing queue is an outcome, not a crash. The flow is Draft, so create does not route yet.",
  },
];

export function ServiceCloud() {
  return (
    <Section
      id="service"
      index="06"
      eyebrow="Service Cloud"
      title="A case that remembers who touched it."
      lede="Standard Case, because this Developer Edition picture has zero Service Cloud user licenses. The lifecycle, the first response, and the escalation still have a home."
    >
      <ol className="grid gap-3 sm:grid-cols-5">
        {lifecycle.map((status, index) => (
          <li key={status} className="glass rounded-2xl px-3 py-4">
            <p className="num text-[11px] text-violet">{String(index + 1).padStart(2, "0")}</p>
            <p className="mt-2 text-sm font-medium text-white">{status}</p>
          </li>
        ))}
      </ol>
      <div className="mt-4 grid gap-4 md:grid-cols-2">
        {topics.map((topic) => (
          <article key={topic.title} className="glass rounded-3xl p-5">
            <h3 className="text-lg font-semibold text-white">{topic.title}</h3>
            <p className="mt-3 text-sm leading-6 text-muted">{topic.copy}</p>
          </article>
        ))}
      </div>
    </Section>
  );
}
