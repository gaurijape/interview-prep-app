import { createClient } from "@/lib/supabaseClient";
import PatternLearningFlow from "@/components/PatternLearningFlow";

export const dynamic = "force-dynamic";

export default async function PatternLearnPage({
  params,
}: {
  params: Promise<{ slug: string }>;
}) {
  const { slug } = await params;
  const supabase = createClient();

  const { data: pattern } = await supabase
    .from("patterns")
    .select("id, name")
    .eq("slug", slug)
    .single();

  if (!pattern) return <p>Pattern not found.</p>;

  const { data: steps } = await supabase
    .from("public_pattern_lessons")
    .select("id, step_order, step_type, title, content, prompt, options, practice_question_slug")
    .eq("pattern_id", pattern.id)
    .order("step_order");

  if (!steps || steps.length === 0) {
    return (
      <div className="space-y-4">
        <h1 className="text-2xl font-bold">{pattern.name}</h1>
        <p className="text-sm text-fgmuted">
          No interactive lesson built for this pattern yet.
        </p>
      </div>
    );
  }

  return (
    <div className="space-y-4">
      <h1 className="text-2xl font-bold">{pattern.name} — Interactive Lesson</h1>
      <PatternLearningFlow
        patternName={pattern.name}
        steps={steps.map((s) => ({
          id: s.id,
          step_order: s.step_order,
          step_type: s.step_type,
          title: s.title,
          content: s.content,
          prompt: s.prompt,
          options: s.options as string[] | null,
          practice_question_slug: s.practice_question_slug,
        }))}
      />
    </div>
  );
}
