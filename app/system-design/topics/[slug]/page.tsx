import { createClient } from "@/lib/supabaseClient";
import ArchitectureDiagram from "@/components/ArchitectureDiagram";

// Content changes frequently in Supabase (new patterns/topics get
// seeded via SQL after deploy), so force fresh data on every
// request instead of Next.js statically caching this page at build time.
export const dynamic = "force-dynamic";

export default async function TopicDetailPage({
  params,
}: {
  params: Promise<{ slug: string }>;
}) {
  const { slug } = await params;
  const supabase = createClient();

  const { data: topic } = await supabase
    .from("system_design_topics")
    .select("id, name, difficulty, description")
    .eq("slug", slug)
    .single();

  if (!topic) return <p>Topic not found.</p>;

  const { data: steps } = await supabase
    .from("system_design_steps")
    .select("id, step_order, title, content, component_ids")
    .eq("topic_id", topic.id)
    .order("step_order");

  // Collect every component referenced across all steps, in first-seen
  // order, to drive the flow diagram at the top of the page.
  const allComponentIds = Array.from(
    new Set((steps ?? []).flatMap((s) => s.component_ids ?? []))
  );

  const { data: components } = allComponentIds.length
    ? await supabase
        .from("components")
        .select("id, name, category, slug")
        .in("id", allComponentIds)
    : { data: [] };

  const orderedComponents = allComponentIds
    .map((id) => components?.find((c) => c.id === id))
    .filter((c): c is NonNullable<typeof c> => !!c);

  return (
    <div className="space-y-6">
      <div>
        <div className="flex justify-between items-baseline">
          <h1 className="text-2xl font-bold">{topic.name}</h1>
          <span className="text-xs text-slate-500 capitalize">{topic.difficulty}</span>
        </div>
        <p className="text-slate-700 mt-2">{topic.description}</p>
      </div>

      <div className="rounded-lg border bg-white px-4">
        <ArchitectureDiagram components={orderedComponents} />
      </div>

      <div className="space-y-4">
        {steps?.map((s) => {
          const stepComponents = (s.component_ids ?? [])
            .map((id: string) => components?.find((c) => c.id === id))
            .filter(Boolean);
          return (
            <div key={s.id} className="rounded-lg border bg-white p-4">
              <div className="flex items-baseline gap-2">
                <span className="text-xs font-semibold text-slate-400">
                  STEP {s.step_order}
                </span>
                <h2 className="font-semibold">{s.title}</h2>
              </div>
              <p className="text-sm text-slate-700 mt-2">{s.content}</p>
              {stepComponents.length > 0 && (
                <div className="flex gap-2 mt-3 flex-wrap">
                  {stepComponents.map((c: any) => (
                    <a
                      key={c.id}
                      href={`/system-design/components/${c.slug}`}
                      className="text-xs rounded-full border px-2 py-1 text-slate-600 hover:bg-slate-50"
                    >
                      {c.name}
                    </a>
                  ))}
                </div>
              )}
            </div>
          );
        })}
      </div>
    </div>
  );
}
