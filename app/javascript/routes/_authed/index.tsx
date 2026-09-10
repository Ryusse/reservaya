import { createFileRoute, redirect } from '@tanstack/react-router'

import { Role } from '@/models/role'
import { UserHomePage } from '@/pages/user/home'

export const Route = createFileRoute('/_authed/')({
  beforeLoad: ({ context }) => {
    if (context.auth.role === Role.Admin) {
      throw redirect({ to: '/admin' })
    }
  },
  component: UserHomePage,
})
