import { createClient } from "@/lib/supabaseClient";

// Content changes frequently in Supabase (new patterns/topics get
// seeded via SQL after deploy), so force fresh data on every
// request instead of Next.js statically caching this page at build time.
export const dynamic = "force-dynamic";

// Server Component: reads directly from Supabase, no server action needed —
// this is pure public content, no auth or answer-hiding concerns.
export default async function PatternGlossaryPage() {
  const supabase = createClient();
  const { data: patterns } = await supabase
    .from("patterns")
    .select("id, slug, name, category, description")
    .order("category");

  return (
    <div className="space-y-4">
      <h1 className="text-2xl font-bold">Pattern Glossary</h1>
      <p className="text-fgmuted text-sm">
        Every pattern, browsable on its own — not just inside a question.
      </p>
      <div className="grid gap-3">
        {patterns?.map((p) => (
          <a
            key={p.id}
            href={`/leetcode/patterns/${p.slug}`}
            className="rounded-lg border border-border bg-surface p-4 hover:border-accent transition-colors"
          >
            <div className="flex justify-between items-baseline">
              <h3 className="font-semibold">{p.name}</h3>
              <span className="text-xs text-fgmuted">{p.category}</span>
            </div>
            <p className="text-sm text-fgmuted mt-1">{p.description}</p>
          </a>
        ))}
        {!patterns?.length && (
          <p className="text-sm text-fgmuted">
            No patterns yet — seed the `patterns` table to see them here.
          </p>
        )}
      </div>
    </div>
  );
}
