import { createClient } from "@/lib/supabaseClient";
import DifficultyBadge from "@/components/DifficultyBadge";

// Content changes frequently in Supabase (new patterns/topics get
// seeded via SQL after deploy), so force fresh data on every
// request instead of Next.js statically caching this page at build time.
export const dynamic = "force-dynamic";

export default async function PatternDetailPage({
  params,
}: {
  params: Promise<{ slug: string }>;
}) {
  const { slug } = await params;
  const supabase = createClient();

  const { data: pattern } = await supabase
    .from("patterns")
    .select("id, name, category, description, recognition_cues")
    .eq("slug", slug)
    .single();

  if (!pattern) return <p>Pattern not found.</p>;

  const { data: questions } = await supabase
    .from("questions")
    .select("id, slug, title, difficulty")
    .eq("primary_pattern_id", pattern.id);

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold">{pattern.name}</h1>
        <p className="text-xs text-fgmuted mt-1">{pattern.category}</p>
        <p className="text-fg mt-3">{pattern.description}</p>
      </div>

      <div className="rounded-lg border border-border bg-surface p-4">
        <h2 className="font-semibold mb-1">How to recognize it</h2>
        <p className="text-sm text-fg">{pattern.recognition_cues}</p>
      </div>

      <div className="space-y-3">
        <h2 className="text-lg font-semibold">Linked Questions</h2>
        {questions?.map((q) => (
          <a
            key={q.id}
            href={`/leetcode/questions/${q.slug}`}
            className="block rounded-lg border border-border bg-surface p-4 hover:border-accent transition-colors"
          >
            <div className="flex justify-between items-baseline">
              <h3 className="font-medium">{q.title}</h3>
              <DifficultyBadge level={q.difficulty} />
            </div>
          </a>
        ))}
        {!questions?.length && (
          <p className="text-sm text-fgmuted">
            No questions linked to this pattern yet.
          </p>
        )}
      </div>
    </div>
  );
}
