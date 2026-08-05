-- Fixes existing rows where java_solution has literal "\n" (backslash + n)
-- instead of a real newline character. Safe to run any time — it's a no-op
-- on rows that don't contain the literal sequence.
update questions
set java_solution = replace(java_solution, '\n', chr(10));
