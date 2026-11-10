import { Section } from "@/components/ui";

const steps = [
  { name: "Question", detail: "A how-to question from a rep, an agent, or a reviewer." },
  { name: "Section retrieval", detail: "Keyword phrases from the 23 guide and runbook sections." },
  { name: "Approved procedure", detail: "Exactly one section matches. The body is copied, not rewritten." },
  { name: "Citation", detail: "The section id, such as L1:Login Problems or SalesRep:Lead Qualification." },
  { name: "Answer", detail: "The page text, or the refusal when the document has no approved procedure." },
];

const scores = [
  { value: "23", label: "Runbook sections" },
  { value: "20", label: "Correct answers" },
  { value: "10", label: "Correct refusals" },
  { value: "0", label: "Hallucinations" },
];

export function Assistant() {
  return (
    <Section
      id="assistant"
      index="12"
      eyebrow="AI how-to assistant"
      title="It answers from the runbook, or it stops."
      lede="The helper is advisory. It does not change Salesforce data, assign permissions, modify configuration, deploy a release, or trigger automation."
    >
      <ol className="grid gap-3 md:grid-cols-5">
        {steps.map((step, index) => (
          <li key={step.name} className="glass rounded-3xl p-4">
            <p className="num text-xs text-violet">0{index + 1}</p>
            <h3 className="mt-2 text-base font-semibold text-white">{step.name}</h3>
            <p className="mt-2 text-sm leading-6 text-muted">{step.detail}</p>
          </li>
        ))}
      </ol>
      <div className="mt-4 grid gap-4 lg:grid-cols-[1.1fr_0.9fr]">
        <article className="glass rounded-3xl p-5">
          <p className="text-sm font-medium text-white">Low confidence</p>
          <pre className="num mt-4 rounded-2xl bg-black/40 p-4 text-sm leading-6 whitespace-pre-wrap text-teal">
            {`This runbook does not contain
an approved answer.

Recommend escalation.`}
          </pre>
          <p className="mt-4 text-sm leading-6 text-muted">
            A near miss is still a refusal. Two matching sections are a refusal. The ten uncovered evaluation questions asked for card data, Flosum, a shared password, a mass delete, Einstein scoring, a fiscal-year change, a merge, a marketing blast, disabling MFA, and a sandbox.
          </p>
        </article>
        <div className="grid grid-cols-2 gap-3">
          {scores.map((score) => (
            <article key={score.label} className="glass rounded-3xl p-5">
              <p className="num text-4xl text-white">{score.value}</p>
              <p className="mt-2 text-sm text-muted">{score.label}</p>
            </article>
          ))}
        </div>
      </div>
    </Section>
  );
}
