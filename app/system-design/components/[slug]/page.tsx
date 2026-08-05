import { createClient } from "@/lib/supabaseClient";

// Content changes frequently in Supabase (new patterns/topics get
// seeded via SQL after deploy), so force fresh data on every
// request instead of Next.js statically caching this page at build time.
export const dynamic = "force-dynamic";

export default async function ComponentDetailPage({
  params,
}: {
  params: Promise<{ slug: string }>;
}) {
  const { slug } = await params;
  const supabase = createClient();

  const { data: component } = await supabase
    .from("components")
    .select("id, name, category, description")
    .eq("slug", slug)
    .single();

  if (!component) return <p>Component not found.</p>;

  const { data: options } = await supabase
    .from("component_options")
    .select("id, name, when_to_use, tradeoffs, notes")
    .eq("component_id", component.id);

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold">{component.name}</h1>
        <p className="text-slate-600 mt-1">{component.description}</p>
      </div>

      <div className="space-y-4">
        <h2 className="text-lg font-semibold">Options</h2>
        {options?.map((o) => (
          <div key={o.id} className="rounded-lg border bg-white p-4">
            <h3 className="font-semibold">{o.name}</h3>
            <p className="text-sm mt-2">
              <span className="font-medium">When to use: </span>
              {o.when_to_use}
            </p>
            <p className="text-sm mt-1">
              <span className="font-medium">Trade-offs: </span>
              {o.tradeoffs}
            </p>
            {o.notes && <p className="text-sm mt-1 text-slate-500">{o.notes}</p>}
          </div>
        ))}
        {!options?.length && (
          <p className="text-sm text-slate-500">
            No options seeded yet for this component.
          </p>
        )}
      </div>
    </div>
  );
}
