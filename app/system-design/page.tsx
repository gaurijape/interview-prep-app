export default function SystemDesignHome() {
  return (
    <div className="space-y-4">
      <h1 className="text-2xl font-bold">System Design</h1>
      <div className="grid gap-3">
        <a
          href="/system-design/topics"
          className="rounded-lg border border-border bg-surface p-4 hover:border-accent transition-colors"
        >
          <h2 className="font-semibold">Topics</h2>
          <p className="text-sm text-fgmuted mt-1">
            Full architecture walkthroughs, step by step, with a diagram.
          </p>
        </a>
        <a
          href="/system-design/components"
          className="rounded-lg border border-border bg-surface p-4 hover:border-accent transition-colors"
        >
          <h2 className="font-semibold">Component Glossary</h2>
          <p className="text-sm text-fgmuted mt-1">
            Every building block — options and trade-offs for each.
          </p>
        </a>
      </div>
    </div>
  );
}
