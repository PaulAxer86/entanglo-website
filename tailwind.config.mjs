/** @type {import('tailwindcss').Config} */
export default {
  content: ['./src/**/*.{astro,html,js,jsx,md,mdx,svelte,ts,tsx,vue}'],
  theme: {
    extend: {
      colors: {
        cream: {
          50: '#f5f1e6',
          100: '#efeadd',
          200: '#e6dfce',
          300: '#d8cfba',
        },
        ink: {
          950: '#0a0b0f',
          900: '#141519',
          850: '#1c1e25',
          800: '#262932',
          700: '#353946',
          600: '#4a5062',
          500: '#5f6579',
          400: '#7a8091',
          300: '#9199a8',
          200: '#a8afbc',
          100: '#c0c6d1',
        },
        accent: {
          DEFAULT: '#5b3fe0',
          glow: '#7c5cff',
          cyan: '#0891b2',
          pink: '#ec4899',
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
