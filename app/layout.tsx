import "./globals.css";
import type { ReactNode } from "react";

export const metadata = {
  title: "Interview Prep",
  description: "LeetCode patterns + system design, learned by doing.",
};

export default function RootLayout({ children }: { children: ReactNode }) {
  return (
    <html lang="en">
      <body className="min-h-screen bg-slate-50 text-slate-900">
        <nav className="border-b bg-white px-6 py-3 flex gap-6 text-sm font-medium">
          <a href="/" className="font-semibold">Interview Prep</a>
          <a href="/leetcode">LeetCode</a>
          <a href="/system-design">System Design</a>
        </nav>
        <main className="mx-auto max-w-4xl px-6 py-8">{children}</main>
      </body>
    </html>
  );
}
