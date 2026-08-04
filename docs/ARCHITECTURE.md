# Interview Prep App — Architecture

## 1. Overview

A content-driven web app with two learning paths — **LeetCode** (pattern recognition, quizzes) and **System Design** (architecture walkthroughs, trade-off glossary) — plus lightweight progress tracking. This is a low-traffic, read-heavy, curated-content app, not a high-scale system. The architecture is intentionally simple: no custom backend service, no code execution sandbox.

## 2. Stack

| Layer | Choice | Why |
|---|---|---|
| Frontend | Next.js (App Router) + React + Tailwind + shadcn/ui | Server-rendered pages for fast content loads; one codebase for UI + light backend |
| Auth | Supabase Auth | Email/OAuth login, free tier, integrates directly with Postgres RLS |
| Database | Supabase Postgres | Single managed instance; content + progress both fit comfortably here |
| Hosting | Vercel | Zero-config Next.js deploys |
| API layer | Next.js Server Actions / Route Handlers | No separate backend needed — server code lives next to the pages that call it |

## 3. System Diagram (logical)

```
┌─────────────────────────────┐
│  Browser (Next.js client)   │
│  - Dashboard                │
│  - LeetCode: patterns,      │
│    questions, quizzes       │
│  - System Design: topics,   │
│    steps, component glossary│
└──────────────┬───────────────┘
               │
     ┌─────────┴─────────┐
     │                    │
     ▼                    ▼
┌───────────┐     ┌──────────────────┐
│ Direct     │     │ Server Actions /  │
│ Supabase   │     │ Route Handlers    │
│ reads      │     │ (Next.js server)  │
│ (content:  │     │ - submit answer   │
│  patterns, │     │ - check_answer RPC│
│  topics,   │     │ - update progress │
│  components)│    │ - bookmarks       │
└─────┬──────┘     └─────────┬─────────┘
      │                      │
      └──────────┬───────────┘
                  ▼
         ┌──────────────────┐
         │ Supabase Postgres │
         │ + Auth             │
         │ (RLS enabled)      │
         └──────────────────┘
```

**Rule of thumb used throughout:** if it's just *reading content* (patterns, questions, topics, component glossary), the client queries Supabase directly — no server round-trip needed, Postgres does the work. If it *writes* (progress, bookmarks) or *reveals something that must stay secret* (quiz answers), it goes through a server action.

## 4. Data Model

```sql
-- LEETCODE SIDE
patterns (
  id, slug, name, category, description,
  recognition_cues,      -- "how do I know this is the pattern"
  created_at
)

questions (
  id, slug, title, leetcode_url, difficulty,
  primary_pattern_id -> patterns.id,
  description, java_solution, complexity_time, complexity_space, hints
)

pattern_questions (            -- optional many-to-many
  pattern_id -> patterns.id,
  question_id -> questions.id
)

quizzes (
  id, question_id -> questions.id,
  type,                   -- 'recognition' | 'complexity' | 'code_mcq'
  prompt, options jsonb,  -- ["Sliding Window", "Two Pointers", ...]
  explanation
  -- NOTE: correct_answer is intentionally NOT in the client-readable table/view — see §6
)

-- SYSTEM DESIGN SIDE
system_design_topics (
  id, slug, name, difficulty, description
)

system_design_steps (
  id, topic_id -> system_design_topics.id,
  step_order, title, content,
  component_ids uuid[]    -- links this step to the glossary entries it touches
)

components (
  id, slug, name, category,   -- 'cache' | 'queue' | 'database' | 'cdn' | 'load_balancer' | ...
  description
)

component_options (
  id, component_id -> components.id,
  name,                    -- e.g. "Redis", "DynamoDB", "Kafka"
  when_to_use, tradeoffs, notes
)

-- SHARED
user_progress (
  id, user_id -> auth.users.id,
  item_type,                -- 'question' | 'system_design_topic' | 'pattern'
  item_id,
  status,                   -- 'not_started' | 'attempted' | 'mastered'
  times_seen, times_correct, last_seen_at
)

bookmarks (
  id, user_id -> auth.users.id,
  item_type, item_id, created_at
)
```

This schema directly supports the two glossaries you asked for: `patterns` is the LeetCode glossary (browsable standalone, each row links to its questions), and `components` + `component_options` is the System Design glossary (e.g. component = "Cache", options = Redis vs Memcached, each with `when_to_use`/`tradeoffs`).

## 5. Navigation / Screens (MVP)

1. **Home Dashboard** — pick LeetCode or System Design, shows overall progress
2. **LeetCode**
   - Pattern Glossary (list of all patterns, browsable independent of any question)
   - Pattern detail (recognition cues + linked questions)
   - Question detail → recognition quiz → complexity quiz → Java solution (read-only) → optional code-MCQ
3. **System Design**
   - Component Glossary (list of all components, browsable independent of any topic)
   - Component detail (all options + trade-offs)
   - Topic detail → step-by-step walkthrough, each step linking back to relevant components
4. **Progress** — simple status per item, no spaced-repetition scheduling yet

## 6. Hard Parts (in order of actual risk)

### 6.1 Hiding quiz answers from the client (the riskiest piece)

Supabase's client library queries Postgres directly from the browser. If `quizzes.correct_answer` is a normal column, any user can open dev tools, inspect the network tab, and read the correct answer straight out of the API response — the app becomes trivially defeatable.

**Approach A — Postgres view + RPC function**
Expose a `public_quizzes` view that excludes `correct_answer` entirely. All client reads hit the view. Grading happens via a Postgres function `check_quiz_answer(quiz_id, submitted_answer) returns boolean`, called through Supabase RPC. The function reads the real table (server-side, inside Postgres) and returns only true/false plus the explanation text.
- *Pros:* answer never leaves the database until after grading; simple mental model (one function per quiz type); works even if you later ship a mobile client, since the rule lives in the DB, not in your app code.
- *Cons:* logic lives in SQL/PLpgSQL, which is less comfortable to write/test than TypeScript; harder to unit test than a JS function.

**Approach B — Next.js Server Action does the check**
Keep `correct_answer` in the real table but never expose that table to the client at all — only fetch quiz content (prompt + options) via a server action that strips the answer before returning JSON. Grading is a second server action: it re-fetches the row server-side (using the Supabase service role key, which bypasses RLS) and compares.
- *Pros:* logic lives in TypeScript, easy to test, easy to extend with partial credit/hints later, matches how you're already handling progress writes.
- *Cons:* now two different code paths decide what's "safe to send to the client" (the fetch action and the grade action) — easy to accidentally leak the answer if someone adds a new query later that selects `*`.

**My recommendation: Approach A (view + RPC).** It's a one-time schema decision (exclude the column from the view) rather than a discipline you have to maintain in every future query, and it means "don't leak the answer" is enforced by the database itself, not by remembering to strip a field in application code. Given you're solo and building incrementally, removing that class of mistake entirely is worth the small SQL learning curve. Approach B is the better call if you expect this to grow into a team project with more engineers touching the API layer, since TypeScript logic is easier for a team to review than PL/pgSQL — but that's not where you are right now.

### 6.2 Content modeling flexibility

Different quiz types (recognition vs complexity vs code-MCQ) and system design step types don't all need the exact same fields. Using a `jsonb` column (`options`) for quiz-type-specific shape avoids a schema migration every time you add a new quiz type, at the cost of losing some type safety — worth it here since you're the only one writing content and will iterate on quiz formats as you go.

### 6.3 Content completeness (not an engineering risk, but the real bottleneck)

The architecture doesn't care whether there are 5 or 500 patterns. This is entirely a content-writing task — covered separately, since you asked to draft that in a follow-up pass.

## 7. What's deliberately out of scope for MVP

- Code execution / online judge (decided against — read-only code + MCQ instead)
- Spaced-repetition scheduling (simple status flag for now)
- AI feedback / mock interviews / architecture builder (listed as "Future" in your docs — nothing here blocks adding them later, since they'd be additive server actions calling an LLM API)
