import { createClient } from "@/lib/supabaseClient";
import QuizCard from "@/components/QuizCard";
import SolutionReveal from "@/components/SolutionReveal";

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
      "id, title, leetcode_url, difficulty, description, java_solution, complexity_time, complexity_space, hints, primary_pattern_id"
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

  return (
    <div className="space-y-6">
      <div>
        <div className="flex justify-between items-baseline">
          <h1 className="text-2xl font-bold">{question.title}</h1>
          <span className="text-xs text-slate-500 capitalize">{question.difficulty}</span>
        </div>
        <p className="text-slate-700 mt-2">{question.description}</p>
        <a
          href={question.leetcode_url ?? "#"}
          target="_blank"
          rel="noreferrer"
          className="text-sm text-blue-600 underline mt-1 inline-block"
        >
          View on LeetCode
        </a>
      </div>

      {/* Quiz first — pattern recognition before solution, per the app's core loop */}
      <div className="space-y-3">
        {quizzes?.map((q) => (
          <QuizCard
            key={q.id}
            quiz={{
              id: q.id,
              question_id: q.question_id,
              prompt: q.prompt,
              options: q.options as string[],
            }}
          />
        ))}
      </div>

      {/* Solution stays hidden behind a click, so the quiz above isn't undermined */}
      <SolutionReveal
        hints={question.hints}
        javaSolution={question.java_solution}
        complexityTime={question.complexity_time}
        complexitySpace={question.complexity_space}
      />
    </div>
  );
}
