import { createRootRoute, Outlet } from '@tanstack/react-router'
import { lazy, Suspense } from 'react'

const TanStackRouterDevtools = import.meta.env.PROD
  ? () => null
  : lazy(() =>
      import('@tanstack/router-devtools').then((m) => ({
        default: m.TanStackRouterDevtools,
      })),
    )

export const Route = createRootRoute({
  component: RootLayout,
  notFoundComponent: () => <p>404 — página no encontrada</p>,
})

function RootLayout() {
  return (
    <>
      <Outlet />
      <Suspense>
        <TanStackRouterDevtools position="bottom-right" />
      </Suspense>
    </>
  )
}
