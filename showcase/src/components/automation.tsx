import { Section } from "@/components/ui";

const flows = [
  {
    name: "Lead Assignment",
    inputs: "Product Interest on create or change.",
    logic: "Core Product, Add-on Service, and Renewal each map to a named placeholder. Anything else, including Undecided, uses the default placeholder.",
    outputs: "Owner becomes that user when the username is active. Otherwise the creator stays owner and the outcome is OwnerNotFound.",
    failure: "A lookup or update error takes the fault path and stores the fault message. A missing placeholder is a handled outcome.",
  },
  {
    name: "Case Assignment",
    inputs: "Priority and Type, on create only.",
    logic: "High with Problem, Feature Request, or a blank type goes to L2. High Question, Medium, and Low go to L1.",
    outputs: "Owner becomes the L1 Support Queue or the L2 Escalation Queue.",
    failure: "A missing queue is QueueNotFound and the owner stays put. A real DML error is the fault path.",
  },
  {
    name: "First Response",
    inputs: "Case status changes, before save.",
    logic: "Stamp only when the prior status was New, the new status is not New, and First Response At is empty.",
    outputs: "First Response At becomes the current date and time. Later changes are skipped.",
    failure: "The fault path records the message. The flow does not overwrite a time an agent already entered.",
  },
  {
    name: "Escalation",
    inputs: "High priority, status not Escalated and not Closed. A path runs one day after create.",
    logic: "If the case is still past the one-day mark, look up the L2 queue and an active Ops Admin. Write status, reason, and Escalated By together so the validation rule can pass.",
    outputs: "Status becomes Escalated, the case moves to the L2 queue, and Ops Admin gets the Escalation Alert notification.",
    failure: "No queue or no Ops Admin means no update. Lookup, update, and notification errors use the fault path. The flow test covers the not-yet-due immediate path.",
  },
];

export function Automation() {
  return (
    <Section
      id="automation"
      index="07"
      eyebrow="Automation"
      title="Four flows, each with a way to fail in the open."
      lede="All four are Draft. They are designed, tested as metadata, and not running in an org. Activation belongs to a later release work item."
    >
      <div className="grid gap-4 lg:grid-cols-2">
        {flows.map((flow) => (
          <article key={flow.name} className="glass rounded-3xl p-5">
            <h3 className="text-lg font-semibold text-white">{flow.name}</h3>
            <dl className="mt-4 space-y-3 text-sm">
              {[
                ["Inputs", flow.inputs],
                ["Logic", flow.logic],
                ["Outputs", flow.outputs],
                ["Failure handling", flow.failure],
              ].map(([label, value]) => (
                <div key={label}>
                  <dt className="text-xs tracking-wide text-teal uppercase">{label}</dt>
                  <dd className="mt-1 leading-6 text-muted">{value}</dd>
                </div>
              ))}
            </dl>
          </article>
        ))}
      </div>
    </Section>
  );
}
