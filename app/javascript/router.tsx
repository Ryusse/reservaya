import { createRouter } from '@tanstack/react-router'

import type { SessionInfo } from './hooks/use-session'
import { routeTree } from './routeTree.gen'

export type RouterContext = {
  auth: SessionInfo
}

const initialAuth: SessionInfo = { user: null, role: null, isAuthenticated: false }

export const router = createRouter({
  routeTree,
  defaultPreload: 'intent',
  scrollRestoration: true,
  context: { auth: initialAuth },
})

declare module '@tanstack/react-router' {
  interface Register {
    router: typeof router
  }
}
