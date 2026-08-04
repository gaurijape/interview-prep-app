-- ============================================================
-- Interview Prep App — Supabase Postgres schema
-- Run this in the Supabase SQL editor (or via `supabase db push`)
-- ============================================================

create extension if not exists "pgcrypto";

-- ---------- LEETCODE SIDE ----------

create table patterns (
  id uuid primary key default gen_random_uuid(),
  slug text unique not null,
  name text not null,
  category text,
  description text,
  recognition_cues text,
  created_at timestamptz default now()
);

create table questions (
  id uuid primary key default gen_random_uuid(),
  slug text unique not null,
  title text not null,
  leetcode_url text,
  difficulty text check (difficulty in ('easy','medium','hard')),
  primary_pattern_id uuid references patterns(id),
  description text,
  java_solution text,
  complexity_time text,
  complexity_space text,
  hints text[],
  created_at timestamptz default now()
);

create table pattern_questions (
  pattern_id uuid references patterns(id) on delete cascade,
  question_id uuid references questions(id) on delete cascade,
  primary key (pattern_id, question_id)
);

create table quizzes (
  id uuid primary key default gen_random_uuid(),
  question_id uuid references questions(id) on delete cascade,
  type text check (type in ('recognition','complexity','code_mcq')),
  prompt text not null,
  options jsonb not null,       -- e.g. ["Sliding Window", "Two Pointers", "BFS", "DFS"]
  correct_answer text not null, -- INDEX into options, never exposed to client — see view below
  explanation text,
  created_at timestamptz default now()
);

-- Client-safe view: correct_answer is deliberately omitted
create view public_quizzes as
  select id, question_id, type, prompt, options, explanation, created_at
  from quizzes;

-- Server-side grading function — the only way to learn the correct answer
create or replace function check_quiz_answer(p_quiz_id uuid, p_submitted text)
returns jsonb
language plpgsql
security definer
as $$
declare
  v_correct text;
  v_explanation text;
  v_is_correct boolean;
begin
  select correct_answer, explanation into v_correct, v_explanation
  from quizzes where id = p_quiz_id;

  if v_correct is null then
    raise exception 'quiz not found';
  end if;

  v_is_correct := (v_correct = p_submitted);

  return jsonb_build_object(
    'correct', v_is_correct,
    'explanation', v_explanation
  );
end;
$$;

-- ---------- SYSTEM DESIGN SIDE ----------

create table system_design_topics (
  id uuid primary key default gen_random_uuid(),
  slug text unique not null,
  name text not null,
  difficulty text check (difficulty in ('easy','medium','hard')),
  description text,
  created_at timestamptz default now()
);

create table system_design_steps (
  id uuid primary key default gen_random_uuid(),
  topic_id uuid references system_design_topics(id) on delete cascade,
  step_order int not null,
  title text not null,
  content text,
  component_ids uuid[]
);

create table components (
  id uuid primary key default gen_random_uuid(),
  slug text unique not null,
  name text not null,
  category text,   -- 'cache' | 'queue' | 'database' | 'cdn' | 'load_balancer' | ...
  description text,
  created_at timestamptz default now()
);

create table component_options (
  id uuid primary key default gen_random_uuid(),
  component_id uuid references components(id) on delete cascade,
  name text not null,          -- e.g. 'Redis', 'DynamoDB', 'Kafka'
  when_to_use text,
  tradeoffs text,
  notes text
);

-- ---------- SHARED: progress + bookmarks ----------

create table user_progress (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade,
  item_type text check (item_type in ('question','system_design_topic','pattern')),
  item_id uuid not null,
  status text check (status in ('not_started','attempted','mastered')) default 'not_started',
  times_seen int default 0,
  times_correct int default 0,
  last_seen_at timestamptz,
  unique (user_id, item_type, item_id)
);

create table bookmarks (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade,
  item_type text not null,
  item_id uuid not null,
  created_at timestamptz default now(),
  unique (user_id, item_type, item_id)
);

-- Upserts a user's progress row, incrementing counters, called from
-- the updateProgress server action after a quiz is answered.
create or replace function upsert_progress(
  p_user_id uuid, p_item_type text, p_item_id uuid, p_was_correct boolean
)
returns void
language plpgsql
security definer
as $$
begin
  insert into user_progress (user_id, item_type, item_id, status, times_seen, times_correct, last_seen_at)
  values (
    p_user_id, p_item_type, p_item_id,
    case when p_was_correct then 'mastered' else 'attempted' end,
    1, case when p_was_correct then 1 else 0 end, now()
  )
  on conflict (user_id, item_type, item_id) do update set
    times_seen = user_progress.times_seen + 1,
    times_correct = user_progress.times_correct + (case when p_was_correct then 1 else 0 end),
    status = case when p_was_correct then 'mastered' else 'attempted' end,
    last_seen_at = now();
end;
$$;

-- ---------- ROW LEVEL SECURITY ----------

alter table user_progress enable row level security;
alter table bookmarks enable row level security;

create policy "users read own progress" on user_progress
  for select using (auth.uid() = user_id);
create policy "users write own progress" on user_progress
  for insert with check (auth.uid() = user_id);
create policy "users update own progress" on user_progress
  for update using (auth.uid() = user_id);

create policy "users read own bookmarks" on bookmarks
  for select using (auth.uid() = user_id);
create policy "users write own bookmarks" on bookmarks
  for insert with check (auth.uid() = user_id);
create policy "users delete own bookmarks" on bookmarks
  for delete using (auth.uid() = user_id);

-- Content tables: RLS is enabled explicitly (rather than left off) so this
-- schema is robust even if a dashboard tool or future migration turns RLS
-- on automatically. Each gets one permissive "anyone can read" policy.
-- The raw `quizzes` table gets NO read policy at all — it's only ever
-- reached through the `public_quizzes` view and the `check_quiz_answer`
-- RPC (both are security definer / bypass RLS via the view's owner rights),
-- so the correct_answer column is never directly selectable by the client.

alter table patterns enable row level security;
alter table questions enable row level security;
alter table pattern_questions enable row level security;
alter table quizzes enable row level security;
alter table system_design_topics enable row level security;
alter table system_design_steps enable row level security;
alter table components enable row level security;
alter table component_options enable row level security;

create policy "anyone can read patterns" on patterns for select using (true);
create policy "anyone can read questions" on questions for select using (true);
create policy "anyone can read pattern_questions" on pattern_questions for select using (true);
create policy "anyone can read system_design_topics" on system_design_topics for select using (true);
create policy "anyone can read system_design_steps" on system_design_steps for select using (true);
create policy "anyone can read components" on components for select using (true);
create policy "anyone can read component_options" on component_options for select using (true);
-- Intentionally NO policy on `quizzes` itself — see note above.
