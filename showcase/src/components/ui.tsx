"use client";

import { useInView } from "framer-motion";
import { useEffect, useRef, useState, type ReactNode } from "react";

export function Section({
  id,
  index,
  eyebrow,
  title,
  lede,
  children,
}: {
  id: string;
  index: string;
  eyebrow: string;
  title: string;
  lede: string;
  children: ReactNode;
}) {
  return (
    <section id={id} className="scroll-mt-24 px-5 py-20 sm:px-8 lg:px-12">
      <div className="mx-auto max-w-6xl">
        <div className="rise">
          <p className="num text-xs tracking-[0.22em] text-teal uppercase">
            {index} · {eyebrow}
          </p>
          <h2 className="mt-3 max-w-3xl text-3xl font-semibold tracking-tight text-white sm:text-4xl">
            {title}
          </h2>
          <p className="mt-4 max-w-3xl text-base leading-7 text-muted sm:text-lg">{lede}</p>
        </div>
        <div className="mt-10">{children}</div>
      </div>
    </section>
  );
}

export function Counter({ value, label }: { value: number; label: string }) {
  const ref = useRef<HTMLDivElement>(null);
  const inView = useInView(ref, { once: true });
  const [current, setCurrent] = useState(0);

  useEffect(() => {
    if (!inView) return;
    const start = performance.now();
    let frame = 0;
    const tick = (now: number) => {
      const progress = Math.min(1, (now - start) / 900);
      const eased = 1 - Math.pow(1 - progress, 3);
      setCurrent(Math.round(value * eased));
      if (progress < 1) frame = requestAnimationFrame(tick);
    };
    frame = requestAnimationFrame(tick);
    return () => cancelAnimationFrame(frame);
  }, [inView, value]);

  return (
    <div ref={ref} className="glass rounded-2xl px-4 py-4">
      <p className="num text-3xl font-medium text-white">{current}</p>
      <p className="mt-1 text-sm text-muted">{label}</p>
    </div>
  );
}
