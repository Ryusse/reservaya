import { tanstackRouter } from '@tanstack/router-plugin/vite'
import react from '@vitejs/plugin-react'
import { defineConfig } from 'vite'
import RubyPlugin from 'vite-plugin-ruby'

export default defineConfig({
  plugins: [
    tanstackRouter({
      target: 'react',
      routesDirectory: 'routes',
      generatedRouteTree: 'routeTree.gen.ts',
      autoCodeSplitting: true,
    }),
    RubyPlugin(),
    react(),
  ],
})
