import { createClient } from "@/lib/supabaseClient";
import DifficultyBadge from "@/components/DifficultyBadge";
import ArchitectureDiagram from "@/components/ArchitectureDiagram";
import TopicRevealGate from "@/components/TopicRevealGate";
import FollowupQA from "@/components/FollowupQA";

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
    .select("id, name, difficulty, description, tradeoffs, followup_questions, followup_answers")
    .eq("slug", slug)
    .single();

  if (!topic) return <p>Topic not found.</p>;

  const { data: steps } = await supabase
    .from("system_design_steps")
    .select("id, step_order, title, content, component_ids")
    .eq("topic_id", topic.id)
    .order("step_order");

  // Every referenced component (for linking chips + category coloring),
  // regardless of whether it appears in the diagram.
  const allComponentIds = Array.from(
    new Set((steps ?? []).flatMap((s) => s.component_ids ?? []))
  );

  const { data: components } = allComponentIds.length
    ? await supabase
        .from("components")
        .select("id, name, category, slug")
        .in("id", allComponentIds)
    : { data: [] };

  // Diagram nodes = one per STEP (not just steps that matched a generic
  // component), so the diagram always shows the full architecture that's
  // actually described below it — labeled with the step's own title, and
  // colored by its linked component's category when one exists.
  const diagramNodes = (steps ?? []).map((s) => {
    const linkedComponent = (s.component_ids ?? [])
      .map((id: string) => components?.find((c) => c.id === id))
      .find(Boolean);
    return {
      id: s.id,
      name: s.title,
      category: linkedComponent?.category ?? null,
    };
  });

  return (
    <div className="space-y-6">
      <div>
        <div className="flex justify-between items-baseline">
          <h1 className="text-2xl font-bold">{topic.name}</h1>
          <DifficultyBadge level={topic.difficulty} />
        </div>
        <p className="text-fg mt-2">{topic.description}</p>
      </div>

      <TopicRevealGate
        topicId={topic.id}
        topicSlug={slug}
        topicTitle={topic.name}
        guidingQuestions={topic.followup_questions}
      >
        <div className="space-y-6">
          <div className="rounded-lg border border-border bg-surface px-4">
            <ArchitectureDiagram components={diagramNodes} />
          </div>

          <div className="space-y-4">
            {steps?.map((s) => {
              const stepComponents = (s.component_ids ?? [])
                .map((id: string) => components?.find((c) => c.id === id))
                .filter(Boolean);
              return (
                <div key={s.id} className="rounded-lg border border-border bg-surface p-4">
                  <div className="flex items-baseline gap-2">
                    <span className="text-xs font-semibold text-fgmuted">
                      STEP {s.step_order}
                    </span>
                    <h2 className="font-semibold">{s.title}</h2>
                  </div>
                  <p className="text-sm text-fg mt-2">{s.content}</p>
                  {stepComponents.length > 0 && (
                    <div className="flex gap-2 mt-3 flex-wrap">
                      {stepComponents.map((c: any) => (
                        <a
                          key={c.id}
                          href={`/system-design/components/${c.slug}`}
                          className="text-xs rounded-full border px-2 py-1 text-fgmuted hover:bg-bg"
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

          {topic.tradeoffs && (
            <div className="rounded-lg border border-border bg-accent2/10 border-accent2/30 p-4">
              <h2 className="font-semibold text-accent2 text-sm uppercase tracking-wide mb-2">
                Key Trade-offs
              </h2>
              <p className="text-sm text-fg">{topic.tradeoffs}</p>
            </div>
          )}

          {topic.followup_questions && topic.followup_questions.length > 0 && (
            <FollowupQA
              questions={topic.followup_questions}
              answers={topic.followup_answers}
            />
          )}
        </div>
      </TopicRevealGate>
    </div>
  );
}
