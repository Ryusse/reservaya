import { createRouter } from '@tanstack/react-router'

import type { SessionInfo } from './hooks/use-session'
import { routeTree } from './routeTree.gen'

export type RouterContext = {
  auth: SessionInfo
}

export const router = createRouter({
  routeTree,
  defaultPreload: 'intent',
  scrollRestoration: true,
  context: { auth: undefined as unknown as SessionInfo },
})

declare module '@tanstack/react-router' {
  interface Register {
    router: typeof router
  }
}
