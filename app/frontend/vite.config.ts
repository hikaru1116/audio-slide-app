/// <reference types="vitest" />
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [react()],
  server: {
    port: 3000,
    host: true,
  },
  define: {
    // REACT_APP_* 環境変数をViteで使用可能にする
    'import.meta.env.VITE_REACT_APP_API_BASE_URL': JSON.stringify(process.env.REACT_APP_API_BASE_URL),
  },
  test: {
    globals: true,
    environment: 'jsdom',
    setupFiles: './src/setupTests.ts',
  },
})
