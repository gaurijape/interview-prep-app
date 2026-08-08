"use client";

import { useEffect, useState } from "react";
import QuizCard from "@/components/QuizCard";
import { recordRecentQuestion, recordQuestionAnswered } from "@/lib/localProgress";

type Quiz = {
  id: string;
  question_id: string;
  prompt: string;
  options: string[];
};

type Stage = { kind: "quiz"; index: number } | { kind: "hints" } | { kind: "solution" };

/**
 * A real step-by-step wizard: one quiz at a time (not all dumped on the
 * page at once), then an explicit "want a hint?" stage, then the solution —
 * each stage only reachable after the previous one is done.
 */
export default function QuestionFlow({
  questionSlug,
  questionTitle,
  quizzes,
  hints,
  javaSolution,
  complexityTime,
  complexitySpace,
}: {
  questionSlug: string;
  questionTitle: string;
  quizzes: Quiz[];
  hints: string[] | null;
  javaSolution: string;
  complexityTime: string | null;
  complexitySpace: string | null;
}) {
  const [stage, setStage] = useState<Stage>(
    quizzes.length > 0 ? { kind: "quiz", index: 0 } : { kind: "hints" }
  );
  const [answeredCurrent, setAnsweredCurrent] = useState(false);
  const [revealedHints, setRevealedHints] = useState(0);

  // Record this as a recently-viewed question once, on mount.
  useEffect(() => {
    recordRecentQuestion(questionSlug, questionTitle);
  }, [questionSlug, questionTitle]);

  const totalSteps = quizzes.length + 2; // quizzes + hints stage + solution stage
  const currentStepNumber =
    stage.kind === "quiz" ? stage.index + 1 : stage.kind === "hints" ? quizzes.length + 1 : totalSteps;

  function advance() {
    if (stage.kind === "quiz") {
      const nextIndex = stage.index + 1;
      setAnsweredCurrent(false);
      setStage(nextIndex < quizzes.length ? { kind: "quiz", index: nextIndex } : { kind: "hints" });
    } else if (stage.kind === "hints") {
      setStage({ kind: "solution" });
    }
  }

  return (
    <div className="space-y-4">
      <div className="flex items-center gap-2 text-xs font-mono text-fgmuted">
        <span>
          STEP {currentStepNumber} / {totalSteps}
        </span>
        <div className="flex-1 h-1 bg-surface2 rounded-full overflow-hidden">
          <div
            className="h-full bg-accent transition-all"
            style={{ width: `${(currentStepNumber / totalSteps) * 100}%` }}
          />
        </div>
      </div>

      {stage.kind === "quiz" && (
        <div className="space-y-3">
          <QuizCard
            quiz={quizzes[stage.index]}
            onAnswered={() => {
              setAnsweredCurrent(true);
              recordQuestionAnswered(questionSlug);
            }}
          />
          {answeredCurrent && (
            <button
              onClick={advance}
              className="bg-accent text-bg font-semibold text-sm px-4 py-2 rounded hover:bg-accent/80 transition-colors"
            >
              {stage.index + 1 < quizzes.length ? "Next question →" : "Continue to hints →"}
            </button>
          )}
        </div>
      )}

      {stage.kind === "hints" && (
        <div className="rounded-lg border border-border bg-surface p-4 space-y-3">
          <h3 className="font-semibold text-sm">Want a hint before the solution?</h3>
          {hints && hints.length > 0 ? (
            <div className="space-y-2">
              {hints.slice(0, revealedHints).map((h, i) => (
                <p key={i} className="text-sm text-fgmuted border-l-2 border-accent2/40 pl-3">
                  {h}
                </p>
              ))}
              {revealedHints < hints.length && (
                <button
                  onClick={() => setRevealedHints((n) => n + 1)}
                  className="text-sm text-accent underline"
                >
                  Show hint {revealedHints + 1} of {hints.length}
                </button>
              )}
            </div>
          ) : (
            <p className="text-sm text-fgmuted italic">No hints for this one — you're on your own.</p>
          )}
          <div>
            <button
              onClick={advance}
              className="bg-accent text-bg font-semibold text-sm px-4 py-2 rounded hover:bg-accent/80 transition-colors"
            >
              I'm ready — show the solution →
            </button>
          </div>
        </div>
      )}

      {stage.kind === "solution" && (
        <div className="space-y-2">
          <pre className="bg-surface2 text-fg text-xs p-4 rounded-lg overflow-x-auto border border-border font-mono">
            <code>{javaSolution}</code>
          </pre>
          {(complexityTime || complexitySpace) && (
            <p className="text-xs text-fgmuted">
              {complexityTime && <>Time: {complexityTime}</>}
              {complexityTime && complexitySpace && " · "}
              {complexitySpace && <>Space: {complexitySpace}</>}
            </p>
          )}
        </div>
      )}
    </div>
  );
}
