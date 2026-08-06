-- Migration: add trade-offs + follow-up questions at the topic level.
-- These don't belong to any single step, so they get their own columns
-- rather than being stuffed into step content.
alter table system_design_topics add column if not exists tradeoffs text;
alter table system_design_topics add column if not exists followup_questions text[];
