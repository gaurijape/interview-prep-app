import { createBrowserClient } from "@supabase/ssr";

// Client-side Supabase client — safe to use in Client Components.
// Only ever reads public content tables/views (patterns, questions,
// public_quizzes, system_design_topics, system_design_steps, components,
// component_options) or the user's own progress/bookmarks (RLS-protected).
export function createClient() {
  return createBrowserClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
  );
}
