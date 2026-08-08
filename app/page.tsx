import { createClient } from "@/lib/supabaseClient";
import DashboardClient from "@/components/DashboardClient";

export const dynamic = "force-dynamic";

export default async function Home() {
  const supabase = createClient();

  const [patterns, questions, topics, components] = await Promise.all([
    supabase.from("patterns").select("id, slug, name"),
    supabase.from("questions").select("id", { count: "exact", head: true }),
    supabase.from("system_design_topics").select("id, slug, name"),
    supabase.from("components").select("id", { count: "exact", head: true }),
  ]);

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
      <h1 className="text-2xl font-bold">Welcome back</h1>

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
