"use client";

import { useState } from "react";

// Worked example: "abcabcbb" — the classic Longest Substring Without
// Repeating Characters trace. Each entry is one right-pointer step,
// already resolved for however many left-shrinks it took to stay valid.
const STRING = "abcabcbb";
const STEPS = [
  { right: 0, left: 0, note: "Add 'a' — window valid." },
  { right: 1, left: 0, note: "Add 'b' — window valid." },
  { right: 2, left: 0, note: "Add 'c' — window valid. New max length: 3." },
  { right: 3, left: 1, note: "'a' repeats — shrink left past it, then add 'a'." },
  { right: 4, left: 2, note: "'b' repeats — shrink left past it, then add 'b'." },
  { right: 5, left: 3, note: "'c' repeats — shrink left past it, then add 'c'." },
  { right: 6, left: 5, note: "'b' repeats — shrink left twice, then add 'b'." },
  { right: 7, left: 7, note: "'b' repeats — shrink left twice, then add 'b'." },
];

export default function SlidingWindowDiagram() {
  const [stepIndex, setStepIndex] = useState(0);
  const step = STEPS[stepIndex];
  const windowStr = STRING.slice(step.left, step.right + 1);

  const maxLenSoFar = Math.max(
    ...STEPS.slice(0, stepIndex + 1).map((s) => s.right - s.left + 1)
  );

  return (
    <div className="rounded-lg border border-border bg-bg p-4 space-y-3">
      <div className="flex gap-1 font-mono text-lg justify-center">
        {STRING.split("").map((char, i) => {
          const inWindow = i >= step.left && i <= step.right;
          const isRightEdge = i === step.right;
          return (
            <div
              key={i}
              className={`w-9 h-9 flex items-center justify-center rounded border-2 transition-colors ${
                inWindow
                  ? "border-accent bg-accent/10 text-accent"
                  : "border-border text-fgmuted"
              } ${isRightEdge ? "ring-2 ring-accent2" : ""}`}
            >
              {char}
            </div>
          );
        })}
      </div>

      <p className="text-xs text-fgmuted text-center font-mono">
        window = "{windowStr}" &nbsp;·&nbsp; max length so far: {maxLenSoFar}
      </p>
      <p className="text-sm text-fg text-center">{step.note}</p>

      <div className="flex justify-center gap-2 pt-1">
        <button
          onClick={() => setStepIndex((i) => Math.max(0, i - 1))}
          disabled={stepIndex === 0}
          className="text-xs border border-border rounded px-3 py-1 disabled:opacity-30 hover:border-accent transition-colors"
        >
          ← Back
        </button>
        <span className="text-xs text-fgmuted font-mono self-center">
          {stepIndex + 1} / {STEPS.length}
        </span>
        <button
          onClick={() => setStepIndex((i) => Math.min(STEPS.length - 1, i + 1))}
          disabled={stepIndex === STEPS.length - 1}
          className="text-xs border border-border rounded px-3 py-1 disabled:opacity-30 hover:border-accent transition-colors"
        >
          Next →
        </button>
      </div>
    </div>
  );
}
