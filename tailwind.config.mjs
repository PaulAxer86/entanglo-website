/** @type {import('tailwindcss').Config} */
export default {
  content: ['./src/**/*.{astro,html,js,jsx,md,mdx,svelte,ts,tsx,vue}'],
  theme: {
    extend: {
      colors: {
        ink: {
          950: '#050608',
          900: '#0a0b0f',
          850: '#0f1116',
          800: '#13161d',
          700: '#1a1e27',
          600: '#252a36',
          500: '#3a4150',
          400: '#5b6478',
          300: '#8a93a8',
          200: '#b8bfd0',
          100: '#e3e7f0',
        },
        accent: {
          DEFAULT: '#7c5cff',
          glow: '#a78bfa',
          cyan: '#22d3ee',
          pink: '#f472b6',
        },
      },
      fontFamily: {
        sans: ['-apple-system', 'BlinkMacSystemFont', 'SF Pro Display', 'SF Pro Text', 'Inter', 'system-ui', 'sans-serif'],
        mono: ['SF Mono', 'ui-monospace', 'Menlo', 'monospace'],
      },
      letterSpacing: {
        tightest: '-0.04em',
      },
      animation: {
        'pulse-slow': 'pulse 6s cubic-bezier(0.4, 0, 0.6, 1) infinite',
        'float': 'float 8s ease-in-out infinite',
      },
      keyframes: {
        float: {
          '0%, 100%': { transform: 'translateY(0)' },
          '50%': { transform: 'translateY(-12px)' },
        },
      },
    },
  },
  plugins: [],
};
