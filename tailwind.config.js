/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{vue,js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        orange: {
          primary: '#FF8C42',
          light: '#FFB380',
          dark: '#E67E22',
          50: '#fff8f2',
          100: '#ffe9d5',
        },
      },
    },
  },
  plugins: [],
}
