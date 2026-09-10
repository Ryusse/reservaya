import { QueryClientProvider } from '@tanstack/react-query'
import { RouterProvider } from '@tanstack/react-router'
import { useEffect } from 'react'

import { useApiErrors } from './hooks/use-api-errors'
import { useSession } from './hooks/use-session'
import { queryClient } from './lib/query-client'
import { router } from './router'

export function App() {
  const auth = useSession()

  useApiErrors()

  useEffect(() => {
    router.invalidate()
  }, [auth.isAuthenticated, auth.role])

  return (
    <QueryClientProvider client={queryClient}>
      <RouterProvider router={router} context={{ auth }} />
    </QueryClientProvider>
  )
}
