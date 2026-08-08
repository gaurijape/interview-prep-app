"use client";

import { useState } from "react";
import { submitLessonAnswer } from "@/app/actions/patternLesson";

export type LessonStep = {
  id: string;
  step_order: number;
  step_type: "concept" | "recognition" | "reasoning" | "complexity_time" | "complexity_space" | "data_structure" | "practice";
  title: string;
  content: string | null;
  prompt: string | null;
  options: string[] | null;
  practice_question_slug: string | null;
};

const STEP_TYPE_LABELS: Record<string, string> = {
  concept: "Concept",
  recognition: "Recognize",
  reasoning: "Reason Why",
  complexity_time: "Time Complexity",
  complexity_space: "Space Complexity",
  data_structure: "Data Structure",
  practice: "Practice",
};

/**
 * Generic driver for the pattern-level interactive lesson: one step at a
 * time, quiz-type steps require a correct answer before advancing (a
 * wrong answer gets a HINT, not the answer, and can be retried), concept
 * steps just need acknowledgment, and the final practice step links out
 * to a real question. Built once, reusable for any pattern's lessons —
 * this instance is driven entirely by the `steps` prop, no Sliding
 * Window-specific logic lives in this file.
 */
export default function PatternLearningFlow({
  patternName,
  steps,
}: {
  patternName: string;
  steps: LessonStep[];
}) {
  const [currentIndex, setCurrentIndex] = useState(0);
  const [selected, setSelected] = useState<string | null>(null);
  const [result, setResult] = useState<{ correct: boolean; hint: string | null; explanation: string | null } | null>(null);
  const [loading, setLoading] = useState(false);

  const step = steps[currentIndex];
  const isLastStep = currentIndex === steps.length - 1;

  function goNext() {
    setSelected(null);
    setResult(null);
    setCurrentIndex((i) => i + 1);
  }

  async function handleSubmit() {
    if (!selected) return;
    setLoading(true);
    const res = await submitLessonAnswer(step.id, selected);
    setResult(res);
    setLoading(false);
  }

  return (
    <div className="space-y-4">
      <div className="flex items-center gap-2 text-xs font-mono text-fgmuted">
        <span>
          STEP {currentIndex + 1} / {steps.length} · {STEP_TYPE_LABELS[step.step_type]}
        </span>
        <div className="flex-1 h-1 bg-surface2 rounded-full overflow-hidden">
          <div
            className="h-full bg-accent transition-all"
            style={{ width: `${((currentIndex + 1) / steps.length) * 100}%` }}
          />
        </div>
      </div>

      <div className="rounded-lg border border-border bg-surface p-5 space-y-4">
        <h2 className="font-semibold">{step.title}</h2>

        {step.step_type === "concept" && (
          <>
            <p className="text-sm text-fg whitespace-pre-line">{step.content}</p>
            <button
              onClick={goNext}
              className="bg-accent text-bg font-semibold text-sm px-4 py-2 rounded hover:bg-accent/80 transition-colors"
            >
              Got it — continue →
            </button>
          </>
        )}

        {step.step_type === "practice" && (
          <>
            <p className="text-sm text-fg whitespace-pre-line">{step.content}</p>
            {step.practice_question_slug && (
              <a
                href={`/leetcode/questions/${step.practice_question_slug}`}
                className="inline-block bg-accent text-bg font-semibold text-sm px-4 py-2 rounded hover:bg-accent/80 transition-colors"
              >
                Try the practice problem →
              </a>
            )}
          </>
        )}

        {!["concept", "practice"].includes(step.step_type) && (
          <div className="space-y-3">
            <p className="text-sm text-fg">{step.prompt}</p>
            <div className="grid gap-2">
              {step.options?.map((opt) => (
                <button
                  key={opt}
                  onClick={() => {
                    setSelected(opt);
                    setResult(null);
                  }}
                  disabled={result?.correct === true}
                  className={`text-left rounded border px-3 py-2 text-sm transition-colors ${
                    selected === opt
                      ? "border-accent bg-surface2"
                      : "border-border hover:border-fgmuted"
                  } disabled:opacity-60`}
                >
                  {opt}
                </button>
              ))}
            </div>

            {result?.correct !== true && (
              <button
                onClick={handleSubmit}
                disabled={!selected || loading}
                className="bg-accent text-bg font-semibold text-sm px-4 py-2 rounded disabled:opacity-40 disabled:bg-fgmuted transition-colors"
              >
                {loading ? "Checking..." : "Submit"}
              </button>
            )}

            {result && !result.correct && (
              <p className="text-sm text-hard">
                Not quite. Hint: {result.hint}
              </p>
            )}
            {result && result.correct && (
              <div className="space-y-3">
                <p className="text-sm text-easy">Correct! {result.explanation}</p>
                <button
                  onClick={isLastStep ? undefined : goNext}
                  className="bg-accent text-bg font-semibold text-sm px-4 py-2 rounded hover:bg-accent/80 transition-colors"
                >
                  Continue →
                </button>
              </div>
            )}
          </div>
        )}
      </div>
    </div>
  );
}
