/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        primary: "#3B82F6",
        secondary: "#10B981",
        accent: "#F59E0B",
        text: "#1F2937",
        textSecondary: "#6B7280",
        background: "#F9FAFB",
        card: "#FFFFFF",
        border: "#E5E7EB",
        correct: "#10B981",
        incorrect: "#EF4444",
        selected: "#3B82F6",
        disabled: "#9CA3AF",
      },
      spacing: {
        xs: "0.25rem",
        sm: "0.5rem",
        md: "1rem",
        lg: "1.5rem",
        xl: "2rem",
        xxl: "3rem",
      },
      borderWidth: {
        '3': '3px',
      },
      aspectRatio: {
        '4/3': '4 / 3',
      },
    },
  },
  plugins: [],
}