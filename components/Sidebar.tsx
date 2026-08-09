"use client";

import { useState } from "react";
import { signOut } from "@/app/actions/auth";

type NavItem = { label: string; href: string };
type NavSection = { label: string; items: NavItem[] };

const SECTIONS: NavSection[] = [
  {
    label: "leetcode/",
    items: [
      { label: "all_questions.tsx", href: "/leetcode/questions" },
      { label: "patterns.tsx", href: "/leetcode/patterns" },
    ],
  },
  {
    label: "system_design/",
    items: [
      { label: "topics.tsx", href: "/system-design/topics" },
      { label: "components.tsx", href: "/system-design/components" },
    ],
  },
];

export default function Sidebar({ userEmail }: { userEmail: string | null }) {
  const [open, setOpen] = useState<Record<string, boolean>>({
    "leetcode/": true,
    "system_design/": true,
  });

  return (
    <aside className="w-64 shrink-0 border-r border-border bg-surface min-h-screen font-mono text-sm flex flex-col">
      <div className="px-4 py-5 border-b border-border">
        <a href="/" className="text-accent font-semibold tracking-tight">
          ~/prep <span className="text-fgmuted">$</span>
          <span className="inline-block w-2 h-4 bg-accent align-middle ml-1 animate-pulse" />
        </a>
      </div>

      <nav className="px-2 py-3 flex-1">
        {SECTIONS.map((section) => (
          <div key={section.label} className="mb-1">
            <button
              onClick={() =>
                setOpen((o) => ({ ...o, [section.label]: !o[section.label] }))
              }
              className="w-full flex items-center gap-1.5 px-2 py-1.5 text-fgmuted hover:text-fg transition-colors"
            >
              <span className="text-accent2">
                {open[section.label] ? "▾" : "▸"}
              </span>
              {section.label}
            </button>
            {open[section.label] && (
              <div className="ml-4 border-l border-border pl-3 space-y-0.5">
                {section.items.map((item) => (
                  <a
                    key={item.href}
                    href={item.href}
                    className="block px-2 py-1 rounded text-fgmuted hover:text-accent hover:bg-surface2 transition-colors"
                  >
                    {item.label}
                  </a>
                ))}
              </div>
            )}
          </div>
        ))}
      </nav>

      <div className="px-4 py-3 border-t border-border">
        {userEmail ? (
          <div className="space-y-2">
            <p className="text-xs text-fgmuted truncate">{userEmail}</p>
            <form action={signOut}>
              <button
                type="submit"
                className="text-xs text-fgmuted hover:text-hard transition-colors"
              >
                Sign out
              </button>
            </form>
          </div>
        ) : (
          <a
            href="/login"
            className="text-xs text-accent hover:text-accent/80 transition-colors"
          >
            Sign in →
          </a>
        )}
      </div>
    </aside>
  );
}
