import { useMutation } from '@tanstack/react-query'
import { useNavigate } from '@tanstack/react-router'

import type { Registration } from '@/models/registration'
import { Role } from '@/models/role'
import { authService } from '@/services/auth.service'
import { useSessionStore } from '@/stores/session.store'

export function useRegister() {
  const navigate = useNavigate()
  const setUser = useSessionStore((s) => s.setUser)

  return useMutation({
    mutationFn: (input: Registration) => authService.register(input),
    onSuccess: (user) => {
      setUser(user)
      navigate({ to: user.role === Role.Admin ? '/admin' : '/' })
    },
  })
}
