import { createClient } from "@/lib/supabaseClient";
import { createServerSupabaseClient } from "@/lib/supabaseServer";
import DashboardClient from "@/components/DashboardClient";

export const dynamic = "force-dynamic";

export default async function Home() {
  const supabase = createClient();
  const authClient = await createServerSupabaseClient();
  const {
    data: { user },
  } = await authClient.auth.getUser();

  const [patterns, questions, topics, components] = await Promise.all([
    supabase.from("patterns").select("id, slug, name"),
    supabase.from("questions").select("id", { count: "exact", head: true }),
    supabase.from("system_design_topics").select("id, slug, name"),
    supabase.from("components").select("id", { count: "exact", head: true }),
  ]);

  // Real per-user counts AND recent activity, only meaningful when logged
  // in — this replaces the old localStorage-only "recent" tracking, which
  // was shared by anyone on the same browser/device regardless of who
  // was logged in. That's the actual bug behind "a new visitor sees my
  // progress" — it wasn't leaking across accounts, it was never
  // account-scoped in the first place.
  let realAnsweredQuestions = 0;
  let realRevealedTopics = 0;
  let realRecent: { type: "question" | "topic"; slug: string; title: string }[] = [];

  if (user) {
    const [answeredRes, topicsRes, recentRes] = await Promise.all([
      authClient
        .from("user_progress")
        .select("id", { count: "exact", head: true })
        .eq("item_type", "question"),
      authClient
        .from("user_progress")
        .select("id", { count: "exact", head: true })
        .eq("item_type", "system_design_topic"),
      authClient
        .from("user_progress")
        .select("item_type, item_id, last_seen_at")
        .order("last_seen_at", { ascending: false })
        .limit(8),
    ]);
    realAnsweredQuestions = answeredRes.count ?? 0;
    realRevealedTopics = topicsRes.count ?? 0;

    const recentRows = recentRes.data ?? [];
    const questionIds = recentRows.filter((r) => r.item_type === "question").map((r) => r.item_id);
    const topicIds = recentRows.filter((r) => r.item_type === "system_design_topic").map((r) => r.item_id);

    const [questionTitles, topicTitles] = await Promise.all([
      questionIds.length
        ? supabase.from("questions").select("id, slug, title").in("id", questionIds)
        : { data: [] },
      topicIds.length
        ? supabase.from("system_design_topics").select("id, slug, name").in("id", topicIds)
        : { data: [] },
    ]);

    realRecent = recentRows
      .map((row) => {
        if (row.item_type === "question") {
          const q = questionTitles.data?.find((x) => x.id === row.item_id);
          return q ? { type: "question" as const, slug: q.slug, title: q.title } : null;
        } else {
          const t = topicTitles.data?.find((x) => x.id === row.item_id);
          return t ? { type: "topic" as const, slug: t.slug, title: t.name } : null;
        }
      })
      .filter((x): x is NonNullable<typeof x> => x !== null);
  }

  const patternList = patterns.data ?? [];
  const topicList = topics.data ?? [];

  // Deterministic "pick of the day" — same day-of-year, same pick, no
  // extra table needed, no randomness mismatch between server/client.
  const dayOfYear = Math.floor(
    (Date.now() - new Date(new Date().getFullYear(), 0, 0).getTime()) / 86400000
  );
  const dailyPattern = patternList.length
    ? patternList[dayOfYear % patternList.length]
    : null;
  const dailyTopic = topicList.length
    ? topicList[dayOfYear % topicList.length]
    : null;

  return (
    <div className="space-y-8">
      <div>
        <h1 className="text-2xl font-bold">~/prep</h1>
        <p className="text-sm text-fgmuted mt-1">
          {user
            ? "Signed in — your progress follows you across devices."
            : "Progress below is tracked on this device only — sign in to save it across devices."}
        </p>
      </div>

      <div className="grid grid-cols-2 gap-4">
        <a
          href="/leetcode"
          className="rounded-lg border border-border bg-surface p-6 hover:border-accent transition-colors"
        >
          <h2 className="text-lg font-semibold">LeetCode</h2>
          <p className="text-sm text-fgmuted mt-1">
            Pattern glossary, recognition quizzes, complexity checks.
          </p>
        </a>
        <a
          href="/system-design"
          className="rounded-lg border border-border bg-surface p-6 hover:border-accent transition-colors"
        >
          <h2 className="text-lg font-semibold">System Design</h2>
          <p className="text-sm text-fgmuted mt-1">
            Component glossary, trade-offs, full walkthroughs.
          </p>
        </a>
      </div>

      <DashboardClient
        isLoggedIn={!!user}
        realAnsweredQuestions={realAnsweredQuestions}
        realRevealedTopics={realRevealedTopics}
        realRecent={realRecent}
        totals={{
          patternCount: patternList.length,
          questionCount: questions.count ?? 0,
          topicCount: topicList.length,
          componentCount: components.count ?? 0,
          dailyPattern: dailyPattern
            ? { slug: dailyPattern.slug, name: dailyPattern.name }
            : null,
          dailyTopic: dailyTopic
            ? { slug: dailyTopic.slug, name: dailyTopic.name }
            : null,
        }}
      />
    </div>
  );
}
