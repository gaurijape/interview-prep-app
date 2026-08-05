-- Run this FIRST in the Supabase SQL Editor to clean up the partial run,
-- then run the corrected schema.sql fresh.

drop table if exists bookmarks cascade;
drop table if exists user_progress cascade;
drop table if exists component_options cascade;
drop table if exists components cascade;
drop table if exists system_design_steps cascade;
drop table if exists system_design_topics cascade;
drop view if exists public_quizzes cascade;
drop table if exists quizzes cascade;
drop table if exists pattern_questions cascade;
drop table if exists questions cascade;
drop table if exists patterns cascade;
drop function if exists check_quiz_answer(uuid, text);
drop function if exists upsert_progress(uuid, text, uuid, boolean);
