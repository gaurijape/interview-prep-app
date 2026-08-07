import "./globals.css";
import type { ReactNode } from "react";
import Sidebar from "@/components/Sidebar";

export const metadata = {
  title: "~/prep",
  description: "LeetCode patterns + system design, learned by doing.",
};

export default function RootLayout({ children }: { children: ReactNode }) {
  return (
    <html lang="en">
      <body className="min-h-screen bg-bg text-fg font-body flex">
        <Sidebar />
        <main className="flex-1 px-8 py-8 max-w-4xl">{children}</main>
      </body>
    </html>
  );
}
