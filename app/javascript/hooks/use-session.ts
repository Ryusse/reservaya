import type { Role } from '@/models/role'
import type { User } from '@/models/user'
import { useSessionStore } from '@/stores/session.store'

export type SessionInfo = {
  user: User | null
  role: Role | null
  isAuthenticated: boolean
}

export function useSession(): SessionInfo {
  const user = useSessionStore((s) => s.user)

  return {
    user,
    role: user?.role ?? null,
    isAuthenticated: user !== null,
  }
}
