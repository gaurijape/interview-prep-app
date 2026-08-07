import type { Config } from "tailwindcss";

const config: Config = {
  content: ["./app/**/*.{ts,tsx}", "./components/**/*.{ts,tsx}"],
  theme: {
    extend: {
      colors: {
        bg: "#0B0F14",
        surface: "#121821",
        surface2: "#1A2230",
        border: "#26303F",
        fg: "#E6EDF3",
        fgmuted: "#8B98A5",
        accent: "#2DD4BF",
        accent2: "#A78BFA",
        easy: "#34D399",
        medium: "#FBBF24",
        hard: "#F87171",
      },
      fontFamily: {
        mono: ["JetBrains Mono", "ui-monospace", "monospace"],
        body: ["Inter", "ui-sans-serif", "sans-serif"],
      },
    },
  },
  plugins: [],
};

export default config;
