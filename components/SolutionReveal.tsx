"use client";

import { useState } from "react";

export default function SolutionReveal({
  hints,
  javaSolution,
  complexityTime,
  complexitySpace,
}: {
  hints: string[] | null;
  javaSolution: string;
  complexityTime: string | null;
  complexitySpace: string | null;
}) {
  const [showHints, setShowHints] = useState(false);
  const [showSolution, setShowSolution] = useState(false);

  return (
    <div className="space-y-3">
      {hints && hints.length > 0 && (
        <div>
          <button
            onClick={() => setShowHints((s) => !s)}
            className="text-sm underline text-slate-600"
          >
            {showHints ? "Hide hints" : "Show hints"}
          </button>
          {showHints && (
            <ul className="list-disc list-inside text-sm text-slate-700 mt-2 space-y-1">
              {hints.map((h, i) => (
                <li key={i}>{h}</li>
              ))}
            </ul>
          )}
        </div>
      )}

      <div>
        <button
          onClick={() => setShowSolution((s) => !s)}
          className="rounded bg-slate-900 text-white text-sm px-4 py-2"
        >
          {showSolution ? "Hide solution" : "Reveal Java solution"}
        </button>

        {showSolution && (
          <div className="mt-3 space-y-2">
            <pre className="bg-slate-900 text-slate-100 text-xs p-4 rounded-lg overflow-x-auto">
              <code>{javaSolution}</code>
            </pre>
            {(complexityTime || complexitySpace) && (
              <p className="text-xs text-slate-500">
                {complexityTime && <>Time: {complexityTime}</>}
                {complexityTime && complexitySpace && " · "}
                {complexitySpace && <>Space: {complexitySpace}</>}
              </p>
            )}
          </div>
        )}
      </div>
    </div>
  );
}
