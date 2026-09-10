import { createFileRoute, redirect } from '@tanstack/react-router'

import { RegisterPage } from '@/pages/auth/register'

export const Route = createFileRoute('/register')({
  beforeLoad: ({ context }) => {
    if (context.auth.isAuthenticated) {
      throw redirect({ to: '/' })
    }
  },
  component: RegisterPage,
})
