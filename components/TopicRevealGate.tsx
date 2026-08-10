"use client";

import { useState, type ReactNode } from "react";
import { recordTopicRevealed } from "@/lib/localProgress";
import { updateProgress } from "@/app/actions/quiz";

const FALLBACK_QUESTIONS = [
  "What APIs would you expose?",
  "SQL or NoSQL — and why?",
  "How will IDs/keys be generated?",
  "What happens if one server fails?",
];

/**
 * Instead of dumping the full architecture immediately, this asks
 * framing questions first and makes the person commit to thinking before
 * revealing the reference design underneath. Uses the topic's OWN
 * follow-up questions (already written, already topic-specific) rather
 * than a generic hardcoded list — falls back to generic ones only for a
 * topic that genuinely has none written yet.
 */
export default function TopicRevealGate({
  children,
  topicId,
  topicSlug,
  topicTitle,
  guidingQuestions,
}: {
  children: ReactNode;
  topicId: string;
  topicSlug: string;
  topicTitle: string;
  guidingQuestions: string[] | null;
}) {
  const [revealed, setRevealed] = useState(false);
  const questions =
    guidingQuestions && guidingQuestions.length > 0 ? guidingQuestions : FALLBACK_QUESTIONS;

  if (revealed) return <>{children}</>;

  function reveal() {
    setRevealed(true);
    recordTopicRevealed(topicSlug);
    updateProgress("system_design_topic", topicId, true);
  }

  return (
    <div className="rounded-lg border border-border bg-surface p-5 space-y-4">
      <h2 className="font-semibold text-sm uppercase tracking-wide text-fgmuted">
        Before you look — think through this
      </h2>
      <ul className="space-y-2">
        {questions.map((q, i) => (
          <li key={i} className="text-sm text-fg flex gap-2">
            <span className="text-accent2 font-mono">{i + 1}.</span>
            {q}
          </li>
        ))}
      </ul>
      <p className="text-xs text-fgmuted italic">
        Sketch an answer in your head (or on paper) — then reveal the reference architecture and compare.
      </p>
      <button
        onClick={reveal}
        className="bg-accent text-bg font-semibold text-sm px-4 py-2 rounded hover:bg-accent/80 transition-colors"
      >
        I've thought it through — show me the architecture →
      </button>
    </div>
  );
}
