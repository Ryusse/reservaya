import { useMutation } from '@tanstack/react-query'
import { useNavigate } from '@tanstack/react-router'
import type { Credentials } from '@/models/credentials'
import { Role } from '@/models/role'
import { authService } from '@/services/auth.service'
import { useSessionStore } from '@/stores/session.store'

export function useLogin() {
  const navigate = useNavigate()
  const setUser = useSessionStore((s) => s.setUser)

  return useMutation({
    mutationFn: (credentials: Credentials) => authService.login(credentials),
    onSuccess: (user) => {
      setUser(user)
      navigate({ to: user.role === Role.Admin ? '/admin' : '/' })
    },
  })
}
