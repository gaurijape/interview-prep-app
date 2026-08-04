# Interview Prep App

See `docs/ARCHITECTURE.md` for the full design and the reasoning behind the
answer-hiding approach for quizzes.

## Setup

1. **Create a Supabase project** at supabase.com (free tier is plenty).
2. **Run the schema**: Supabase dashboard → SQL Editor → paste and run
   `supabase/schema.sql`, then `supabase/seed_example.sql` to get one
   working pattern + question + quiz + component so you have something to
   click through immediately.
3. **Copy env vars**: `cp .env.local.example .env.local`, then fill in
   `NEXT_PUBLIC_SUPABASE_URL` and `NEXT_PUBLIC_SUPABASE_ANON_KEY` from
   Supabase → Project Settings → API.
4. **Install and run**:
   ```
   npm install
   npm run dev
   ```
   Visit http://localhost:3000 — you should see the dashboard, and
   `/leetcode/patterns` should show the seeded Sliding Window pattern,
   `/system-design/components` should show the seeded Cache component.

## What's built so far

- Full DB schema (`supabase/schema.sql`) — patterns, questions, quizzes,
  system design topics/steps, component glossary, progress, bookmarks
- Answer-hiding for quizzes via a Postgres view + RPC (see architecture
  doc §6.1) — `check_quiz_answer` is the only way to learn if a guess was right
- Pattern glossary list page (`app/leetcode/patterns/page.tsx`)
- Component glossary list + detail pages (`app/system-design/components/`)
- `QuizCard` component wired end-to-end to the server action

## Not built yet — next steps

- Auth pages (Supabase Auth UI or custom email/OAuth forms)
- Question detail page (quiz → Java solution reveal flow)
- System design topic detail page (step-by-step walkthrough)
- Pattern detail page (recognition cues + linked questions list)
- Progress dashboard reading from `user_progress`
- The actual content — patterns, questions, and component writeups beyond
  the one seeded example (planned as a separate content-drafting pass)
