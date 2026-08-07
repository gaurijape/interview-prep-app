import { createClient } from "@/lib/supabaseClient";
import DifficultyBadge from "@/components/DifficultyBadge";

// Content changes frequently in Supabase (new patterns/topics get
// seeded via SQL after deploy), so force fresh data on every
// request instead of Next.js statically caching this page at build time.
export const dynamic = "force-dynamic";

export default async function SystemDesignTopicsPage() {
  const supabase = createClient();
  const { data: topics } = await supabase
    .from("system_design_topics")
    .select("id, slug, name, difficulty, description")
    .order("difficulty");

  return (
    <div className="space-y-4">
      <h1 className="text-2xl font-bold">System Design Topics</h1>
      <p className="text-fgmuted text-sm">
        Full walkthroughs, step by step, with an architecture diagram for each.
      </p>
      <div className="grid gap-3">
        {topics?.map((t) => (
          <a
            key={t.id}
            href={`/system-design/topics/${t.slug}`}
            className="rounded-lg border border-border bg-surface p-4 hover:border-accent transition-colors"
          >
            <div className="flex justify-between items-baseline">
              <h3 className="font-semibold">{t.name}</h3>
              <DifficultyBadge level={t.difficulty} />
            </div>
            <p className="text-sm text-fgmuted mt-1">{t.description}</p>
          </a>
        ))}
        {!topics?.length && (
          <p className="text-sm text-fgmuted">
            No topics yet — seed the `system_design_topics` table to see them here.
          </p>
        )}
      </div>
    </div>
  );
}
