import "./globals.css";
import type { ReactNode } from "react";
import Sidebar from "@/components/Sidebar";
import { createServerSupabaseClient } from "@/lib/supabaseServer";

export const metadata = {
  title: "~/prep",
  description: "LeetCode patterns + system design, learned by doing.",
};

export default async function RootLayout({ children }: { children: ReactNode }) {
  const supabase = await createServerSupabaseClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  return (
    <html lang="en">
      <body className="min-h-screen bg-bg text-fg font-body flex">
        <Sidebar userEmail={user?.email ?? null} />
        <main className="flex-1 px-8 py-8 max-w-4xl">{children}</main>
      </body>
    </html>
  );
}
