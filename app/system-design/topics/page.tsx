import { createClient } from "@/lib/supabaseClient";

export default async function SystemDesignTopicsPage() {
  const supabase = createClient();
  const { data: topics } = await supabase
    .from("system_design_topics")
    .select("id, slug, name, difficulty, description")
    .order("difficulty");

  return (
    <div className="space-y-4">
      <h1 className="text-2xl font-bold">System Design Topics</h1>
      <p className="text-slate-600 text-sm">
        Full walkthroughs, step by step, with an architecture diagram for each.
      </p>
      <div className="grid gap-3">
        {topics?.map((t) => (
          <a
            key={t.id}
            href={`/system-design/topics/${t.slug}`}
            className="rounded-lg border bg-white p-4 hover:shadow transition"
          >
            <div className="flex justify-between items-baseline">
              <h3 className="font-semibold">{t.name}</h3>
              <span className="text-xs text-slate-500 capitalize">{t.difficulty}</span>
            </div>
            <p className="text-sm text-slate-600 mt-1">{t.description}</p>
          </a>
        ))}
        {!topics?.length && (
          <p className="text-sm text-slate-500">
            No topics yet — seed the `system_design_topics` table to see them here.
          </p>
        )}
      </div>
    </div>
  );
}
