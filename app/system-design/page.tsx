export default function SystemDesignHome() {
  return (
    <div className="space-y-4">
      <h1 className="text-2xl font-bold">System Design</h1>
      <div className="grid gap-3">
        <a
          href="/system-design/topics"
          className="rounded-lg border bg-white p-4 hover:shadow transition"
        >
          <h2 className="font-semibold">Topics</h2>
          <p className="text-sm text-slate-600 mt-1">
            Full architecture walkthroughs, step by step, with a diagram.
          </p>
        </a>
        <a
          href="/system-design/components"
          className="rounded-lg border bg-white p-4 hover:shadow transition"
        >
          <h2 className="font-semibold">Component Glossary</h2>
          <p className="text-sm text-slate-600 mt-1">
            Every building block — options and trade-offs for each.
          </p>
        </a>
      </div>
    </div>
  );
}
