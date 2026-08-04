"use server";

import { createServerSupabaseClient } from "@/lib/supabaseServer";

/**
 * Grades a quiz answer server-side via the check_quiz_answer Postgres RPC.
 * The correct answer never touches the client — see docs/ARCHITECTURE.md §6.1.
 */
export async function submitQuizAnswer(quizId: string, submittedAnswer: string) {
  const supabase = await createServerSupabaseClient();

  const { data, error } = await supabase.rpc("check_quiz_answer", {
    p_quiz_id: quizId,
    p_submitted: submittedAnswer,
  });

  if (error) {
    return { correct: false, explanation: null, error: error.message };
  }

  return { correct: data.correct, explanation: data.explanation, error: null };
}

/**
 * Updates the user's progress on a question/topic/pattern after they
 * answer a quiz or view a solution.
 */
export async function updateProgress(
  itemType: "question" | "system_design_topic" | "pattern",
  itemId: string,
  wasCorrect: boolean
) {
  const supabase = await createServerSupabaseClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) return { error: "not authenticated" };

  const { error } = await supabase.rpc("upsert_progress", {
    p_user_id: user.id,
    p_item_type: itemType,
    p_item_id: itemId,
    p_was_correct: wasCorrect,
  });

  return { error: error?.message ?? null };
}
