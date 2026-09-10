import { useMutation } from '@tanstack/react-query'
import { useNavigate } from '@tanstack/react-router'

import { authService } from '@/services/auth.service'
import { useSessionStore } from '@/stores/session.store'

export function useLogout() {
  const navigate = useNavigate()
  const clearSession = useSessionStore((s) => s.clearSession)

  return useMutation({
    mutationFn: () => authService.logout(),
    onSettled: () => {
      clearSession()
      navigate({ to: '/login' })
    },
  })
}
