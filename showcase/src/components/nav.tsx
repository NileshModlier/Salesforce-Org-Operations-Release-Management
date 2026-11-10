"use client";

import { Menu, X } from "lucide-react";
import { useState } from "react";
import { nav } from "@/lib/site";

export function Nav() {
  const [open, setOpen] = useState(false);

  return (
    <header className="fixed inset-x-0 top-0 z-50 border-b border-white/10 bg-[#070b14]/75 backdrop-blur-xl">
      <div className="mx-auto flex h-16 max-w-6xl items-center justify-between px-5 sm:px-8">
        <a href="#top" className="flex items-center gap-3">
          <span className="grid h-8 w-8 grid-cols-2 gap-0.5 rounded-lg bg-white/10 p-1.5">
            <span className="rounded-sm bg-blue" />
            <span className="rounded-sm bg-teal" />
            <span className="rounded-sm bg-violet" />
            <span className="rounded-sm bg-white/70" />
          </span>
          <span className="text-sm font-semibold tracking-tight text-white">Org Operations</span>
        </a>
        <nav className="hidden items-center gap-4 lg:flex">
          {nav.map((item) => (
            <a key={item.href} href={item.href} className="text-xs text-muted transition hover:text-white">
              {item.label}
            </a>
          ))}
        </nav>
        <button
          type="button"
          className="grid h-10 w-10 place-items-center rounded-xl border border-white/10 lg:hidden"
          aria-expanded={open}
          aria-label={open ? "Close menu" : "Open menu"}
          onClick={() => setOpen((value) => !value)}
        >
          {open ? <X size={18} /> : <Menu size={18} />}
        </button>
      </div>
      {open ? (
        <nav className="grid gap-1 border-t border-white/10 px-5 py-4 lg:hidden">
          {nav.map((item) => (
            <a
              key={item.href}
              href={item.href}
              className="rounded-lg px-2 py-2 text-sm text-muted hover:bg-white/5 hover:text-white"
              onClick={() => setOpen(false)}
            >
              {item.label}
            </a>
          ))}
        </nav>
      ) : null}
    </header>
  );
}
