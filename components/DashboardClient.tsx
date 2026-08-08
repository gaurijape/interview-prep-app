"use client";

import { useEffect, useState } from "react";
import { getLocalProgress } from "@/lib/localProgress";

type Totals = {
  patternCount: number;
  questionCount: number;
  topicCount: number;
  componentCount: number;
  dailyPattern: { slug: string; name: string } | null;
  dailyTopic: { slug: string; name: string } | null;
};

function ProgressBar({ label, done, total }: { label: string; done: number; total: number }) {
  const pct = total > 0 ? Math.min(100, Math.round((done / total) * 100)) : 0;
  return (
    <div>
      <div className="flex justify-between text-xs font-mono text-fgmuted mb-1">
        <span>{label}</span>
        <span>
          {done} / {total}
        </span>
      </div>
      <div className="h-2 bg-surface2 rounded-full overflow-hidden">
        <div className="h-full bg-accent transition-all" style={{ width: `${pct}%` }} />
      </div>
    </div>
  );
}

export default function DashboardClient({ totals }: { totals: Totals }) {
  const [progress, setProgress] = useState<ReturnType<typeof getLocalProgress> | null>(null);

  useEffect(() => {
    setProgress(getLocalProgress());
  }, []);

  const answeredCount = progress?.answeredQuestionSlugs.length ?? 0;
  const revealedTopicCount = progress?.revealedTopicSlugs.length ?? 0;
  const recent = progress?.recent ?? [];
  const continueItem = recent[0];

  return (
    <div className="space-y-6">
      <div className="rounded-lg border border-border bg-surface p-4 space-y-4">
        <h2 className="font-semibold text-sm uppercase tracking-wide text-fgmuted">
          Progress
        </h2>
        <ProgressBar label="LeetCode questions practiced" done={answeredCount} total={totals.questionCount} />
        <ProgressBar label="System design topics explored" done={revealedTopicCount} total={totals.topicCount} />
      </div>

      {continueItem && (
        <a
          href={
            continueItem.type === "question"
              ? `/leetcode/questions/${continueItem.slug}`
              : `/system-design/topics/${continueItem.slug}`
          }
          className="block rounded-lg border border-accent/40 bg-accent/5 p-4 hover:border-accent transition-colors"
        >
          <p className="text-xs font-mono text-accent uppercase tracking-wide mb-1">
            Continue where you left off
          </p>
          <p className="font-medium">{continueItem.title}</p>
        </a>
      )}

      <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
        {totals.dailyPattern && (
          <a
            href={`/leetcode/patterns/${totals.dailyPattern.slug}`}
            className="rounded-lg border border-border bg-surface p-4 hover:border-accent transition-colors"
          >
            <p className="text-xs font-mono text-accent2 uppercase tracking-wide mb-1">
              Today's Pattern
            </p>
            <p className="font-medium">{totals.dailyPattern.name}</p>
          </a>
        )}
        {totals.dailyTopic && (
          <a
            href={`/system-design/topics/${totals.dailyTopic.slug}`}
            className="rounded-lg border border-border bg-surface p-4 hover:border-accent transition-colors"
          >
            <p className="text-xs font-mono text-accent2 uppercase tracking-wide mb-1">
              Today's System Design
            </p>
            <p className="font-medium">{totals.dailyTopic.name}</p>
          </a>
        )}
      </div>

      {recent.length > 0 && (
        <div className="space-y-2">
          <h2 className="font-semibold text-sm uppercase tracking-wide text-fgmuted">
            Recently Practiced
          </h2>
          <div className="grid gap-2">
            {recent.map((item) => (
              <a
                key={`${item.type}-${item.slug}`}
                href={
                  item.type === "question"
                    ? `/leetcode/questions/${item.slug}`
                    : `/system-design/topics/${item.slug}`
                }
                className="flex justify-between items-center rounded-lg border border-border bg-surface p-3 hover:border-accent transition-colors text-sm"
              >
                <span>{item.title}</span>
                <span className="text-xs text-fgmuted font-mono uppercase">{item.type}</span>
              </a>
            ))}
          </div>
        </div>
      )}
    </div>
  );
}
