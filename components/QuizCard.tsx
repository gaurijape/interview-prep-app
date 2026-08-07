"use client";

import { useState } from "react";
import { submitQuizAnswer, updateProgress } from "@/app/actions/quiz";

type Quiz = {
  id: string;
  question_id: string;
  prompt: string;
  options: string[];
};

/**
 * Renders a quiz (options only — no correct_answer field exists on this
 * object, since it comes from the public_quizzes view). Grading happens
 * via the submitQuizAnswer server action, which calls the check_quiz_answer
 * RPC. The correct answer is never sent to the browser until after the
 * user has already submitted a guess.
 */
export default function QuizCard({
  quiz,
  onAnswered,
}: {
  quiz: Quiz;
  onAnswered?: () => void;
}) {
  const [selected, setSelected] = useState<string | null>(null);
  const [result, setResult] = useState<{ correct: boolean; explanation: string | null } | null>(null);
  const [loading, setLoading] = useState(false);
  const [hasFiredCallback, setHasFiredCallback] = useState(false);

  async function handleSubmit() {
    if (!selected) return;
    setLoading(true);
    const res = await submitQuizAnswer(quiz.id, selected);
    setResult(res);
    await updateProgress("question", quiz.question_id, res.correct);
    setLoading(false);
    // Fire once per quiz — an "attempt" unlocks the solution regardless of
    // how many times the user re-submits after that first try.
    if (!hasFiredCallback) {
      setHasFiredCallback(true);
      onAnswered?.();
    }
  }

  return (
    <div className="rounded-lg border bg-white p-4 space-y-3">
      <p className="font-medium">{quiz.prompt}</p>
      <div className="grid gap-2">
        {quiz.options.map((opt) => (
          <button
            key={opt}
            onClick={() => setSelected(opt)}
            className={`text-left rounded border px-3 py-2 text-sm ${
              selected === opt ? "border-slate-900 bg-slate-100" : "border-slate-200"
            }`}
          >
            {opt}
          </button>
        ))}
      </div>
      <button
        onClick={handleSubmit}
        disabled={!selected || loading}
        className="rounded bg-slate-900 text-white text-sm px-4 py-2 disabled:opacity-50"
      >
        {loading ? "Checking..." : "Submit"}
      </button>
      {result && (
        <p className={`text-sm ${result.correct ? "text-green-600" : "text-red-600"}`}>
          {result.correct ? "Correct! " : "Not quite. "}
          {result.explanation}
        </p>
      )}
    </div>
  );
}
