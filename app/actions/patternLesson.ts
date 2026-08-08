"use server";

import { createServerSupabaseClient } from "@/lib/supabaseServer";

/**
 * Grades a pattern-lesson step answer server-side via the
 * check_lesson_answer Postgres RPC. Same answer-hiding design as
 * submitQuizAnswer in quiz.ts — the correct answer never touches the
 * client. On a wrong answer, returns a hint instead of the answer itself.
 */
export async function submitLessonAnswer(stepId: string, submittedAnswer: string) {
  const supabase = await createServerSupabaseClient();

  const { data, error } = await supabase.rpc("check_lesson_answer", {
    p_step_id: stepId,
    p_submitted: submittedAnswer,
  });

  if (error) {
    return { correct: false, hint: null, explanation: null, error: error.message };
  }

  return { correct: data.correct, hint: data.hint, explanation: data.explanation, error: null };
}
