import { Center, Spinner } from '@chakra-ui/react'
import { QueryClientProvider } from '@tanstack/react-query'
import { RouterProvider } from '@tanstack/react-router'
import { useEffect } from 'react'

import { useApiErrors } from './hooks/use-api-errors'
import { useSession } from './hooks/use-session'
import { queryClient } from './lib/query-client'
import { router } from './router'
import { authService } from './services/auth.service'
import { useSessionStore } from './stores/session.store'

export function App() {
  const auth = useSession()
  const status = useSessionStore((s) => s.status)
  const setUser = useSessionStore((s) => s.setUser)

  useApiErrors()

  useEffect(() => {
    authService.me().then(setUser)
  }, [setUser])

  // biome-ignore lint/correctness/useExhaustiveDependencies: router is a stable singleton; re-run only when auth changes
  useEffect(() => {
    if (status === 'ready') router.invalidate()
  }, [auth.isAuthenticated, auth.role, status])

  if (status === 'loading') {
    return (
      <Center h="100dvh">
        <Spinner size="xl" />
      </Center>
    )
  }

  return (
    <QueryClientProvider client={queryClient}>
      <RouterProvider router={router} context={{ auth }} />
    </QueryClientProvider>
  )
}
