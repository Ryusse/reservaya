import { createFileRoute, redirect } from '@tanstack/react-router'

import { Role } from '@/models/role'
import { AdminSpacesPage } from '@/pages/admin/spaces'

export const Route = createFileRoute('/_authed/admin')({
  beforeLoad: ({ context }) => {
    if (context.auth.role !== Role.Admin) {
      throw redirect({ to: '/' })
    }
  },
  component: AdminSpacesPage,
})
