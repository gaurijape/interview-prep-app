import { createClient } from "@/lib/supabaseClient";

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
      <p className="text-slate-600 text-sm">
        Every pattern, browsable on its own — not just inside a question.
      </p>
      <div className="grid gap-3">
        {patterns?.map((p) => (
          <a
            key={p.id}
            href={`/leetcode/patterns/${p.slug}`}
            className="rounded-lg border bg-white p-4 hover:shadow transition"
          >
            <div className="flex justify-between items-baseline">
              <h3 className="font-semibold">{p.name}</h3>
              <span className="text-xs text-slate-500">{p.category}</span>
            </div>
            <p className="text-sm text-slate-600 mt-1">{p.description}</p>
          </a>
        ))}
        {!patterns?.length && (
          <p className="text-sm text-slate-500">
            No patterns yet — seed the `patterns` table to see them here.
          </p>
        )}
      </div>
    </div>
  );
}
