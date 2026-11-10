"use client";

import { AnimatePresence, motion } from "framer-motion";
import { useEffect, useState } from "react";
import { Section } from "@/components/ui";

const stages = [
  {
    name: "Requirements",
    detail:
      "Twelve stories cover pipeline hygiene, lead qualification, case handling, escalation, reporting, and access. Each story names a persona and an acceptance check.",
  },
  {
    name: "Data Model",
    detail:
      "Eight custom fields sit on Lead, Opportunity, Case, and User. Standard value sets lock lead status, opportunity stage, case status, and case type to the process contract.",
  },
  {
    name: "Validation Rules",
    detail:
      "Six active rules block a lead with no email or phone, a conversion that did not start from Qualified, a Closed Won deal without a positive amount, an escalation without a reason and a user, a close without resolution notes, and a return to L1 without guidance.",
  },
  {
    name: "Flows",
    detail:
      "Four record-triggered flows are in source and stay Draft: lead assignment, case assignment, first response, and a scheduled escalation. Each one has a fault path and a flow test.",
  },
  {
    name: "Permission Sets",
    detail:
      "Profiles hold the app and the page layout. Create, read, edit, delete, field access, and system permissions live on permission sets, assigned through one group per persona.",
  },
  {
    name: "Dashboards",
    detail:
      "Ten reports feed a Sales Dashboard and a Support Dashboard. Both run as the logged-in user. The headline numbers are hand counts from a synthetic file, not a live render.",
  },
  {
    name: "Release Governance",
    detail:
      "Path B is Lifecycle Center plus git. Release 1 is the operating process. Release 2 is the reports and dashboards. Flosum stays out until a tenant exists. Neither package has a deploy id.",
  },
  {
    name: "Runbooks",
    detail:
      "Sales and support guides hold one task per page. The L1 runbook covers access and ownership. The L2 runbook covers flows, rules, permissions, releases, data corrections, and report gaps.",
  },
  {
    name: "AI Helper",
    detail:
      "The assistant retrieves one approved section or it refuses. On the 30-question set it returned 20 expected pages, refused 10 uncovered questions, and invented 0 answers.",
  },
];

export function Architecture() {
  const [active, setActive] = useState(0);
  const [ready, setReady] = useState(false);
  const current = stages[active];

  useEffect(() => {
    setReady(true);
  }, []);

  return (
    <Section
      id="architecture"
      index="03"
      eyebrow="Architecture"
      title="One path from a requirement to a cited answer."
      lede="Select a stage. The panel is the work that stage actually contains in this repository."
    >
      <div className="grid gap-6 lg:grid-cols-[280px_1fr]">
        <ol className="space-y-2">
          {stages.map((stage, index) => {
            const selected = index === active;
            return (
              <li key={stage.name}>
                <button
                  type="button"
                  onClick={() => setActive(index)}
                  className={`flex w-full items-center gap-3 rounded-2xl border px-3 py-3 text-left transition ${
                    selected
                      ? "border-teal/50 bg-teal/10 text-white"
                      : "border-white/10 bg-white/[0.03] text-muted hover:text-white"
                  }`}
                >
                  <span className="num text-xs">{String(index + 1).padStart(2, "0")}</span>
                  <span className="text-sm">{stage.name}</span>
                </button>
              </li>
            );
          })}
        </ol>
        <div className="glass flex min-h-72 flex-col justify-between rounded-3xl p-6 sm:p-8">
          <AnimatePresence mode="wait">
            <motion.div
              key={current.name}
              initial={ready ? { opacity: 0, y: 10 } : false}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -8 }}
              transition={{ duration: 0.28 }}
            >
              <p className="num text-xs tracking-[0.2em] text-violet uppercase">
                Stage {String(active + 1).padStart(2, "0")} of 09
              </p>
              <h3 className="mt-3 text-2xl font-semibold text-white">{current.name}</h3>
              <p className="mt-4 max-w-xl text-base leading-7 text-muted">{current.detail}</p>
            </motion.div>
          </AnimatePresence>
          <div className="mt-8 flex flex-wrap gap-2">
            {stages.map((stage, index) => (
              <span
                key={stage.name}
                className={`h-1.5 flex-1 rounded-full ${index <= active ? "bg-teal" : "bg-white/10"}`}
              />
            ))}
          </div>
        </div>
      </div>
    </Section>
  );
}
