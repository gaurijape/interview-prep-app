"use client";

// Lightweight, no-dependency progress tracking using localStorage. This is
// a deliberate stopgap: user_progress in Supabase is RLS-keyed to a real
// logged-in user (auth.uid()), and there's no auth flow yet, so every
// Supabase progress write currently fails silently. This gives the
// dashboard real "recently practiced" / "continue where you left off"
// data today; swapping to Supabase-backed progress once auth exists means
// changing the read/write calls here, not the dashboard UI that uses them.

const STORAGE_KEY = "prep_local_progress_v1";
const MAX_RECENT = 8;

type RecentItem = { type: "question" | "topic"; slug: string; title: string; ts: number };

type LocalProgress = {
  recent: RecentItem[];
  answeredQuestionSlugs: string[];
  revealedTopicSlugs: string[];
};

function readAll(): LocalProgress {
  if (typeof window === "undefined") {
    return { recent: [], answeredQuestionSlugs: [], revealedTopicSlugs: [] };
  }
  try {
    const raw = window.localStorage.getItem(STORAGE_KEY);
    if (!raw) return { recent: [], answeredQuestionSlugs: [], revealedTopicSlugs: [] };
    return JSON.parse(raw);
  } catch {
    return { recent: [], answeredQuestionSlugs: [], revealedTopicSlugs: [] };
  }
}

function writeAll(data: LocalProgress) {
  if (typeof window === "undefined") return;
  try {
    window.localStorage.setItem(STORAGE_KEY, JSON.stringify(data));
  } catch {
    // localStorage can fail (private browsing, quota) — non-fatal, just skip persisting
  }
}

export function recordRecentQuestion(slug: string, title: string) {
  const data = readAll();
  data.recent = [
    { type: "question" as const, slug, title, ts: Date.now() },
    ...data.recent.filter((r) => !(r.type === "question" && r.slug === slug)),
  ].slice(0, MAX_RECENT);
  writeAll(data);
}

export function recordRecentTopic(slug: string, title: string) {
  const data = readAll();
  data.recent = [
    { type: "topic" as const, slug, title, ts: Date.now() },
    ...data.recent.filter((r) => !(r.type === "topic" && r.slug === slug)),
  ].slice(0, MAX_RECENT);
  writeAll(data);
}

export function recordQuestionAnswered(slug: string) {
  const data = readAll();
  if (!data.answeredQuestionSlugs.includes(slug)) {
    data.answeredQuestionSlugs.push(slug);
  }
  writeAll(data);
}

export function recordTopicRevealed(slug: string) {
  const data = readAll();
  if (!data.revealedTopicSlugs.includes(slug)) {
    data.revealedTopicSlugs.push(slug);
  }
  writeAll(data);
}

export function getLocalProgress(): LocalProgress {
  return readAll();
}
