import { createServerSupabaseClient } from "@/lib/supabaseServer";
import { NextResponse } from "next/server";

// Confirmation emails (and any future magic-link/OAuth flows) redirect
// here with a `code` query param. This is the piece that was missing —
// without it, that code just sits in the URL unused and the person never
// actually gets signed in.
export async function GET(request: Request) {
  const { searchParams, origin } = new URL(request.url);
  const code = searchParams.get("code");

  if (code) {
    const supabase = await createServerSupabaseClient();
    await supabase.auth.exchangeCodeForSession(code);
  }

  return NextResponse.redirect(`${origin}/`);
}
