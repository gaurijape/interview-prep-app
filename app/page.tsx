export default function Home() {
  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-bold">Welcome back</h1>
      <div className="grid grid-cols-2 gap-4">
        <a
          href="/leetcode"
          className="rounded-lg border bg-white p-6 hover:shadow transition"
        >
          <h2 className="text-lg font-semibold">LeetCode</h2>
          <p className="text-sm text-slate-600 mt-1">
            Pattern glossary, recognition quizzes, complexity checks.
          </p>
        </a>
        <a
          href="/system-design"
          className="rounded-lg border bg-white p-6 hover:shadow transition"
        >
          <h2 className="text-lg font-semibold">System Design</h2>
          <p className="text-sm text-slate-600 mt-1">
            Component glossary, trade-offs, full walkthroughs.
          </p>
        </a>
      </div>
      {/* TODO: pull real counts from user_progress once auth is wired up */}
    </div>
  );
}
