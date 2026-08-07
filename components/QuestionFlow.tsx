"use client";

import { useState } from "react";
import QuizCard from "@/components/QuizCard";
import SolutionReveal from "@/components/SolutionReveal";

type Quiz = {
  id: string;
  question_id: string;
  prompt: string;
  options: string[];
};

/**
 * Ties the quiz(zes) and the solution reveal together: the solution stays
 * locked until the user has actually attempted at least one quiz, instead
 * of being available to click immediately. Small step toward the
 * "attempt before you see the answer" interactive flow.
 */
export default function QuestionFlow({
  quizzes,
  hints,
  javaSolution,
  complexityTime,
  complexitySpace,
}: {
  quizzes: Quiz[];
  hints: string[] | null;
  javaSolution: string;
  complexityTime: string | null;
  complexitySpace: string | null;
}) {
  const [attemptedCount, setAttemptedCount] = useState(0);
  const unlocked = quizzes.length === 0 || attemptedCount >= quizzes.length;

  return (
    <div className="space-y-6">
      {quizzes.length > 0 && (
        <div className="space-y-3">
          {quizzes.map((q) => (
            <QuizCard
              key={q.id}
              quiz={q}
              onAnswered={() => setAttemptedCount((c) => c + 1)}
            />
          ))}
        </div>
      )}

      {unlocked ? (
        <SolutionReveal
          hints={hints}
          javaSolution={javaSolution}
          complexityTime={complexityTime}
          complexitySpace={complexitySpace}
        />
      ) : (
        <p className="text-sm text-slate-400 italic">
          Answer the quiz above to unlock hints and the solution.
        </p>
      )}
    </div>
  );
}
