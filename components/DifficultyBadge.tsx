const STYLES: Record<string, string> = {
  easy: "bg-easy/10 text-easy border-easy/30",
  medium: "bg-medium/10 text-medium border-medium/30",
  hard: "bg-hard/10 text-hard border-hard/30",
};

export default function DifficultyBadge({ level }: { level: string }) {
  const style = STYLES[level?.toLowerCase()] ?? "bg-surface2 text-fgmuted border-border";
  return (
    <span
      className={`text-xs font-mono px-2 py-0.5 rounded-full border ${style}`}
    >
      {level}
    </span>
  );
}
