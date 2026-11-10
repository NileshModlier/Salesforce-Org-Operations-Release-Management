import { Section } from "@/components/ui";

const rows = [
  ["Lead", "CRU", "—", "—", "CRUD"],
  ["Account", "R", "R", "R", "CRUD"],
  ["Contact", "R", "R", "R", "CRUD"],
  ["Opportunity", "CRU", "—", "R", "CRUD"],
  ["Case", "—", "CRU", "RU", "CRUD"],
  ["User", "R", "R", "R", "RE"],
];

const layers = [
  {
    title: "Profiles",
    copy: "Four custom profiles. Each one sets the default app and the page layouts. None of them grant object permissions.",
  },
  {
    title: "Permission sets",
    copy: "Sales_Rep, Support_L1, Support_L2, and Ops_Admin hold the business access. Reporting_Sales, Reporting_Support, and Reporting_Admin add Run Reports for the roles that should have it.",
  },
  {
    title: "Permission set groups",
    copy: "One group per persona is the assignment point. Support Agent L1 does not receive a reporting set. A later set can be added to the group once.",
  },
  {
    title: "Queues",
    copy: "L1 Support Queue members come from the public group Support_L1. L2 Escalation Queue uses Support_L2. Assigning a permission set group does not add that membership.",
  },
];

export function Security() {
  return (
    <Section
      id="security"
      index="08"
      eyebrow="Security model"
      title="The profile opens the app. The group decides the job."
      lede="Persona on the user record drives Lightning visibility. It does not grant a single record. No permission set includes Modify All Data."
    >
      <div className="grid gap-4 md:grid-cols-2 xl:grid-cols-4">
        {layers.map((layer) => (
          <article key={layer.title} className="glass rounded-3xl p-5">
            <h3 className="text-lg font-semibold text-white">{layer.title}</h3>
            <p className="mt-3 text-sm leading-6 text-muted">{layer.copy}</p>
          </article>
        ))}
      </div>
      <div className="glass mt-4 overflow-x-auto rounded-3xl">
        <table className="min-w-[640px] w-full text-left text-sm">
          <caption className="px-5 pt-5 text-left text-sm font-medium text-white">
            CRM access matrix. C create, R read, U edit, E edit user, D delete. A dash is no object access.
          </caption>
          <thead className="text-muted">
            <tr>
              {["Object", "Sales Rep", "L1", "L2", "Ops Admin"].map((heading) => (
                <th key={heading} className="px-5 py-3 font-medium">
                  {heading}
                </th>
              ))}
            </tr>
          </thead>
          <tbody>
            {rows.map((row) => (
              <tr key={row[0]} className="border-t border-white/10">
                {row.map((cell, index) => (
                  <td key={`${row[0]}-${index}`} className="px-5 py-3 text-white">
                    {cell}
                  </td>
                ))}
              </tr>
            ))}
          </tbody>
        </table>
        <p className="px-5 pb-5 text-xs leading-5 text-muted">
          L1 case access excludes delete, and resolution notes plus return guidance are read-only. L2 case access is view all, with Transfer Cases, and First Response At is read-only. Ops Admin has view all on the business objects and view-all users. Delete on User is not granted.
        </p>
      </div>
    </Section>
  );
}
