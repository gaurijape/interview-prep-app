import { createClient } from "@/lib/supabaseClient";

// Content changes frequently in Supabase (new patterns/topics get
// seeded via SQL after deploy), so force fresh data on every
// request instead of Next.js statically caching this page at build time.
export const dynamic = "force-dynamic";

export default async function ComponentGlossaryPage() {
  const supabase = createClient();
  const { data: components } = await supabase
    .from("components")
    .select("id, slug, name, category, description")
    .order("category");

  return (
    <div className="space-y-4">
      <h1 className="text-2xl font-bold">Component Glossary</h1>
      <p className="text-slate-600 text-sm">
        Load balancers, caches, queues, databases — what each one does, and
        which options to reach for.
      </p>
      <div className="grid gap-3">
        {components?.map((c) => (
          <a
            key={c.id}
            href={`/system-design/components/${c.slug}`}
            className="rounded-lg border bg-white p-4 hover:shadow transition"
          >
            <div className="flex justify-between items-baseline">
              <h3 className="font-semibold">{c.name}</h3>
              <span className="text-xs text-slate-500">{c.category}</span>
            </div>
            <p className="text-sm text-slate-600 mt-1">{c.description}</p>
          </a>
        ))}
        {!components?.length && (
          <p className="text-sm text-slate-500">
            No components yet — seed the `components` table to see them here.
          </p>
        )}
      </div>
    </div>
  );
}
