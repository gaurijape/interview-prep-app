type DiagramComponent = {
  id: string;
  name: string;
  category: string | null;
};

// Syntax-highlighter-inspired palette, each category gets a distinct hue
// against the dark surface — mirrors how an IDE colors different token types.
const CATEGORY_STYLES: Record<string, string> = {
  cdn: "bg-accent2/10 border-accent2/40 text-accent2",
  load_balancer: "bg-accent/10 border-accent/40 text-accent",
  cache: "bg-medium/10 border-medium/40 text-medium",
  queue: "bg-easy/10 border-easy/40 text-easy",
  database: "bg-hard/10 border-hard/40 text-hard",
  rate_limiter: "bg-surface2 border-border text-fgmuted",
};

const CATEGORY_LABELS: Record<string, string> = {
  cdn: "CDN",
  load_balancer: "Load Balancer",
  cache: "Cache",
  queue: "Queue",
  database: "Database",
  rate_limiter: "Rate Limiter",
};

/**
 * Renders a left-to-right flow diagram: one box per component, in the
 * order they first appear across a topic's steps, connected by arrows,
 * each labeled with its category so the diagram reads like an architecture
 * sketch rather than a plain list.
 */
export default function ArchitectureDiagram({
  components,
}: {
  components: DiagramComponent[];
}) {
  if (!components.length) {
    return (
      <p className="text-sm text-fgmuted italic py-4">
        No components linked to this topic's steps yet.
      </p>
    );
  }

  return (
    <div className="overflow-x-auto">
      <div className="flex items-stretch gap-2 py-6 min-w-max">
        <div className="rounded-lg border-2 border-fgmuted/40 bg-surface2 px-4 py-3 flex flex-col justify-center whitespace-nowrap">
          <span className="text-sm font-mono font-semibold text-fg">Client</span>
        </div>
        {components.map((c) => (
          <div key={c.id} className="flex items-center gap-2">
            <span className="text-fgmuted text-lg font-mono">──▸</span>
            <div
              className={`rounded-lg border-2 px-4 py-3 flex flex-col justify-center whitespace-nowrap ${
                CATEGORY_STYLES[c.category ?? ""] ??
                "bg-surface2 border-border text-fg"
              }`}
            >
              <span className="text-sm font-mono font-semibold">{c.name}</span>
              {c.category && CATEGORY_LABELS[c.category] && (
                <span className="text-[10px] uppercase tracking-wide opacity-70">
                  {CATEGORY_LABELS[c.category]}
                </span>
              )}
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
