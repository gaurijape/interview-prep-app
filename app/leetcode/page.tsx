export default function LeetCodeHome() {
  return (
    <div className="space-y-4">
      <h1 className="text-2xl font-bold">LeetCode</h1>
      <div className="grid gap-3">
        <a
          href="/leetcode/questions"
          className="rounded-lg border border-border bg-surface p-4 hover:border-accent transition-colors"
        >
          <h2 className="font-semibold">All Questions</h2>
          <p className="text-sm text-fgmuted mt-1">
            Just want to practice? Jump straight to any question.
          </p>
        </a>
        <a
          href="/leetcode/patterns"
          className="rounded-lg border border-border bg-surface p-4 hover:border-accent transition-colors"
        >
          <h2 className="font-semibold">Pattern Glossary</h2>
          <p className="text-sm text-fgmuted mt-1">
            Want to learn a pattern first? Browse recognition cues and linked questions.
          </p>
        </a>
      </div>
    </div>
  );
}
