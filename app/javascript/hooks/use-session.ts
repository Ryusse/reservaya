import { useSessionStore } from '@/stores/session.store'

export type SessionInfo = {
  user: import('@/models/user').User | null
  role: import('@/models/role').Role | null
  isAuthenticated: boolean
}

export function useSession(): SessionInfo {
  const session = useSessionStore((s) => s.session)
  return {
    user: session?.user ?? null,
    role: session?.user.role ?? null,
    isAuthenticated: session !== null,
  }
}
