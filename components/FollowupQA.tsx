"use client";

import { useState } from "react";

export default function FollowupQA({
  questions,
  answers,
}: {
  questions: string[];
  answers: string[] | null;
}) {
  const [revealedIndex, setRevealedIndex] = useState<number | null>(null);

  return (
    <div className="space-y-2">
      <h2 className="font-semibold text-sm uppercase tracking-wide text-fgmuted">
        Interviewer Follow-ups
      </h2>
      {questions.map((q, i) => {
        const answer = answers?.[i];
        const isRevealed = revealedIndex === i;
        return (
          <div key={i} className="rounded-lg border border-border bg-surface p-3 text-sm">
            <p className="text-fg">
              <span className="font-semibold text-red-500 mr-2">Q{i + 1}.</span>
              {q}
            </p>
            {answer && (
              <>
                {isRevealed ? (
                  <p className="text-fgmuted mt-2 pl-5 border-l-2 border-accent2/40">{answer}</p>
                ) : (
                  <button
                    onClick={() => setRevealedIndex(i)}
                    className="text-xs text-accent underline mt-2"
                  >
                    Think it through, then show expected answer
                  </button>
                )}
              </>
            )}
          </div>
        );
      })}
    </div>
  );
}
