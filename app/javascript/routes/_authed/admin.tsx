import { createFileRoute, redirect } from '@tanstack/react-router'

import { Role } from '@/models/role'
import { AdminHomePage } from '@/pages/admin/home'

export const Route = createFileRoute('/_authed/admin')({
  beforeLoad: ({ context }) => {
    if (context.auth.role !== Role.Admin) {
      throw redirect({ to: '/' })
    }
  },
  component: AdminHomePage,
})
