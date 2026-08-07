import { createClient } from "@/lib/supabaseClient";
import DifficultyBadge from "@/components/DifficultyBadge";
import QuestionFlow from "@/components/QuestionFlow";

// Content changes frequently in Supabase (new patterns/topics get
// seeded via SQL after deploy), so force fresh data on every
// request instead of Next.js statically caching this page at build time.
export const dynamic = "force-dynamic";

export default async function QuestionDetailPage({
  params,
}: {
  params: Promise<{ slug: string }>;
}) {
  const { slug } = await params;
  const supabase = createClient();

  const { data: question } = await supabase
    .from("questions")
    .select(
      "id, title, leetcode_url, difficulty, description, java_solution, complexity_time, complexity_space, hints, primary_pattern_id, patterns(name, slug)"
    )
    .eq("slug", slug)
    .single();

  if (!question) return <p>Question not found.</p>;

  // public_quizzes excludes correct_answer — see docs/ARCHITECTURE.md §6.1.
  // Grading happens server-side via the check_quiz_answer RPC, called from QuizCard.
  const { data: quizzes } = await supabase
    .from("public_quizzes")
    .select("id, question_id, type, prompt, options, explanation")
    .eq("question_id", question.id);

  // Prev/next navigation — same alphabetical-by-title order as the
  // "All Questions" list page, so the ordering is consistent everywhere.
  const { data: allTitles } = await supabase
    .from("questions")
    .select("slug, title")
    .order("title");

  const currentIndex = allTitles?.findIndex((q) => q.slug === slug) ?? -1;
  const prevQuestion =
    currentIndex > 0 ? allTitles?.[currentIndex - 1] : null;
  const nextQuestion =
    currentIndex >= 0 && currentIndex < (allTitles?.length ?? 0) - 1
      ? allTitles?.[currentIndex + 1]
      : null;

  const pattern = (question as any).patterns;

  return (
    <div className="space-y-6">
      <div>
        <div className="flex justify-between items-baseline">
          <h1 className="text-2xl font-bold">{question.title}</h1>
          <DifficultyBadge level={question.difficulty} />
        </div>
        <p className="text-fg mt-2">{question.description}</p>
        <div className="flex gap-4 mt-2 text-sm">
          <a
            href={question.leetcode_url ?? "#"}
            target="_blank"
            rel="noreferrer"
            className="text-accent underline"
          >
            View on LeetCode
          </a>
          {pattern && (
            <a
              href={`/leetcode/patterns/${pattern.slug}`}
              className="text-fgmuted underline"
            >
              Learn the {pattern.name} pattern →
            </a>
          )}
        </div>
      </div>

      <QuestionFlow
        quizzes={(quizzes ?? []).map((q) => ({
          id: q.id,
          question_id: q.question_id,
          prompt: q.prompt,
          options: q.options as string[],
        }))}
        hints={question.hints}
        javaSolution={question.java_solution}
        complexityTime={question.complexity_time}
        complexitySpace={question.complexity_space}
      />

      <div className="flex justify-between items-center pt-4 border-t text-sm">
        {prevQuestion ? (
          <a
            href={`/leetcode/questions/${prevQuestion.slug}`}
            className="text-fgmuted hover:text-fg"
          >
            ← {prevQuestion.title}
          </a>
        ) : (
          <span />
        )}
        {nextQuestion ? (
          <a
            href={`/leetcode/questions/${nextQuestion.slug}`}
            className="rounded bg-accent text-bg font-semibold px-4 py-2 rounded hover:bg-accent/80 transition-colors"
          >
            Next: {nextQuestion.title} →
          </a>
        ) : (
          <a
            href="/leetcode/questions"
            className="rounded bg-accent text-bg font-semibold px-4 py-2 rounded hover:bg-accent/80 transition-colors"
          >
            Back to all questions
          </a>
        )}
      </div>
    </div>
  );
}
