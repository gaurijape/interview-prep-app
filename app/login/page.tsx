import { signIn, signUp } from "@/app/actions/auth";

export default async function LoginPage({
  searchParams,
}: {
  searchParams: Promise<{ error?: string; message?: string }>;
}) {
  const { error, message } = await searchParams;

  return (
    <div className="max-w-sm mx-auto mt-12 space-y-6">
      <div>
        <h1 className="text-2xl font-bold">Sign in</h1>
        <p className="text-sm text-fgmuted mt-1">
          So your progress follows you across devices instead of staying on this browser only.
        </p>
      </div>

      {error && (
        <p className="text-sm text-hard bg-hard/10 border border-hard/30 rounded p-3">{error}</p>
      )}
      {message && (
        <p className="text-sm text-easy bg-easy/10 border border-easy/30 rounded p-3">{message}</p>
      )}

      <form action={signIn} className="space-y-3">
        <input
          name="email"
          type="email"
          placeholder="you@example.com"
          required
          className="w-full rounded border border-border bg-surface px-3 py-2 text-sm"
        />
        <input
          name="password"
          type="password"
          placeholder="Password"
          required
          className="w-full rounded border border-border bg-surface px-3 py-2 text-sm"
        />
        <div className="flex gap-2">
          <button
            type="submit"
            className="flex-1 bg-accent text-bg font-semibold text-sm px-4 py-2 rounded hover:bg-accent/80 transition-colors"
          >
            Sign in
          </button>
          <button
            type="submit"
            formAction={signUp}
            className="flex-1 border border-border text-fg font-semibold text-sm px-4 py-2 rounded hover:border-accent transition-colors"
          >
            Sign up
          </button>
        </div>
      </form>
    </div>
  );
}
