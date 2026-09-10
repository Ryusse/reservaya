import { useMutation } from '@tanstack/react-query'
import { useNavigate } from '@tanstack/react-router'

import { authService } from '@/services/auth.service'
import type { Credentials } from '@/models/credentials'
import { Role } from '@/models/role'
import { useSessionStore } from '@/stores/session.store'

export function useLogin() {
  const navigate = useNavigate()
  const setSession = useSessionStore((s) => s.setSession)

  return useMutation({
    mutationFn: (credentials: Credentials) => authService.login(credentials),
    onSuccess: (session) => {
      setSession(session)
      navigate({ to: session.user.role === Role.Admin ? '/admin' : '/' })
    },
  })
}
