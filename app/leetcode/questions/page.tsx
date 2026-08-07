import { createClient } from "@/lib/supabaseClient";

// Content changes frequently in Supabase, so force fresh data every request
// instead of Next.js statically caching this page at build time.
export const dynamic = "force-dynamic";

export default async function AllQuestionsPage() {
  const supabase = createClient();
  const { data: questions } = await supabase
    .from("questions")
    .select("id, slug, title, difficulty, primary_pattern_id, patterns(name)")
    .order("title");

  return (
    <div className="space-y-4">
      <h1 className="text-2xl font-bold">All Questions</h1>
      <p className="text-slate-600 text-sm">
        Jump straight to any question — no need to go through a pattern first.
      </p>
      <div className="grid gap-2">
        {questions?.map((q: any) => (
          <a
            key={q.id}
            href={`/leetcode/questions/${q.slug}`}
            className="rounded-lg border bg-white p-3 hover:shadow transition flex justify-between items-center"
          >
            <div>
              <span className="font-medium">{q.title}</span>
              {q.patterns?.name && (
                <span className="text-xs text-slate-400 ml-2">
                  {q.patterns.name}
                </span>
              )}
            </div>
            <span className="text-xs text-slate-500 capitalize">{q.difficulty}</span>
          </a>
        ))}
        {!questions?.length && (
          <p className="text-sm text-slate-500">No questions yet.</p>
        )}
      </div>
    </div>
  );
}
