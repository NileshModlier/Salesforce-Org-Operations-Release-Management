import { Section } from "@/components/ui";

const lessons = [
  {
    title: "Salesforce administration",
    copy: "Standard objects were enough. The custom work was the fields, value sets, and rules the stories actually needed. Service Cloud licenses were zero, so Case stayed standard.",
  },
  {
    title: "Release governance",
    copy: "A manifest that adds metadata will not remove it later. Rollback needs a revert and, when the component must disappear, a destructive list rehearsed on UAT first.",
  },
  {
    title: "CRM operations",
    copy: "Four personas on two CRM licenses only work if UAT is sequential. Queue membership and permission set groups are different grants and have to be explained that way.",
  },
  {
    title: "Knowledge management",
    copy: "The assistant's corpus is the guide and the runbook, not the whole repository. A fact that lives only in a design note is invisible on purpose.",
  },
  {
    title: "User enablement",
    copy: "One task per page, with the exact validation message, beats a tour of Setup. The quick reference is the index. The runbook is the exception path.",
  },
  {
    title: "Human-in-the-loop AI",
    copy: "Retrieval with a hard refusal beat a model that might improvise a click path. The person still saves the record, assigns the group, and approves the release.",
  },
];

export function Lessons() {
  return (
    <Section
      id="lessons"
      index="14"
      eyebrow="Lessons learned"
      title="What this build would change about the next one."
      lede="The useful constraint was honesty about edition limits. The useful design choice was keeping business access off the profile."
    >
      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
        {lessons.map((lesson) => (
          <article key={lesson.title} className="glass rounded-3xl p-5">
            <h3 className="text-lg font-semibold text-white">{lesson.title}</h3>
            <p className="mt-3 text-sm leading-6 text-muted">{lesson.copy}</p>
          </article>
        ))}
      </div>
    </Section>
  );
}
