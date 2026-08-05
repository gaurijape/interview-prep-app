type DiagramComponent = {
  id: string;
  name: string;
  category: string | null;
};

const CATEGORY_COLORS: Record<string, string> = {
  cdn: "bg-purple-100 border-purple-300 text-purple-900",
  load_balancer: "bg-blue-100 border-blue-300 text-blue-900",
  cache: "bg-amber-100 border-amber-300 text-amber-900",
  queue: "bg-emerald-100 border-emerald-300 text-emerald-900",
  database: "bg-rose-100 border-rose-300 text-rose-900",
  rate_limiter: "bg-slate-200 border-slate-400 text-slate-900",
};

/**
 * Renders a left-to-right flow diagram: one box per component, in the
 * order they first appear across a topic's steps, connected by arrows.
 * This is generated from data (step.component_ids) rather than hand-drawn,
 * so it automatically stays in sync as topics/steps are edited.
 */
export default function ArchitectureDiagram({
  components,
}: {
  components: DiagramComponent[];
}) {
  if (!components.length) return null;

  return (
    <div className="overflow-x-auto">
      <div className="flex items-center gap-2 py-4 min-w-max">
        {/* Client is always the implicit starting point of the flow */}
        <div className="rounded-lg border-2 border-slate-400 bg-slate-100 px-4 py-3 text-sm font-medium whitespace-nowrap">
          Client
        </div>
        {components.map((c, i) => (
          <div key={c.id} className="flex items-center gap-2">
            <span className="text-slate-400 text-lg">→</span>
            <div
              className={`rounded-lg border-2 px-4 py-3 text-sm font-medium whitespace-nowrap ${
                CATEGORY_COLORS[c.category ?? ""] ??
                "bg-slate-100 border-slate-300 text-slate-900"
              }`}
            >
              {c.name}
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
