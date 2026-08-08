type DiagramComponent = {
  id: string;
  name: string;
  category: string | null;
};

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

function Box({
  label,
  sublabel,
  tone = "default",
}: {
  label: string;
  sublabel?: string;
  tone?: "default" | "client" | "dashed";
}) {
  const toneClass =
    tone === "client"
      ? "border-fgmuted/60 bg-surface2 text-fg"
      : tone === "dashed"
      ? "border-dashed border-accent/50 bg-transparent text-accent"
      : "";

  return (
    <div
      className={`rounded-lg border-2 px-4 py-3 flex flex-col justify-center items-center text-center min-w-[120px] max-w-[180px] ${toneClass}`}
    >
      <span className="text-sm font-mono font-semibold leading-tight">{label}</span>
      {sublabel && (
        <span className="text-[10px] uppercase tracking-wide opacity-70 mt-0.5">{sublabel}</span>
      )}
    </div>
  );
}

/**
 * Renders the full flow as ONE wrapping block — no horizontal scroll
 * hiding half of it — with the request flowing forward on top and an
 * explicit dashed "response / ack" path flowing back to the client below,
 * so the round trip is visible rather than implying a one-way flow.
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

  const lastComponent = components[components.length - 1];

  return (
    <div className="py-6 space-y-8">
      {/* Forward request path */}
      <div>
        <p className="text-[10px] uppercase tracking-widest text-fgmuted mb-2 font-mono">
          → request
        </p>
        <div className="flex flex-wrap items-center gap-2">
          <Box label="Client" tone="client" />
          {components.map((c) => (
            <div key={c.id} className="flex items-center gap-2">
              <span className="text-fgmuted text-lg font-mono">──▸</span>
              <div
                className={`rounded-lg border-2 px-4 py-3 flex flex-col justify-center items-center text-center min-w-[120px] max-w-[180px] ${
                  CATEGORY_STYLES[c.category ?? ""] ??
                  "bg-surface2 border-border text-fg"
                }`}
              >
                <span className="text-sm font-mono font-semibold leading-tight">{c.name}</span>
                {c.category && CATEGORY_LABELS[c.category] && (
                  <span className="text-[10px] uppercase tracking-wide opacity-70 mt-0.5">
                    {CATEGORY_LABELS[c.category]}
                  </span>
                )}
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Return / ACK path — makes the round trip explicit */}
      <div>
        <p className="text-[10px] uppercase tracking-widest text-fgmuted mb-2 font-mono">
          ← response / ack
        </p>
        <div className="flex flex-wrap items-center gap-2">
          <Box label={lastComponent.name} sublabel="sends response" tone="dashed" />
          <span className="text-fgmuted/50 text-lg font-mono">◂ ─ ─</span>
          <Box label="Client" sublabel="receives response" tone="dashed" />
        </div>
      </div>
    </div>
  );
}
