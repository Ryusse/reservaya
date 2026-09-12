import { create } from 'zustand'

import type { User } from '@/models/user'

type SessionStatus = 'loading' | 'ready'

type SessionState = {
  user: User | null
  status: SessionStatus
  setUser: (user: User | null) => void
  clearUser: () => void
}

export const useSessionStore = create<SessionState>((set) => ({
  user: null,
  status: 'loading',
  setUser: (user) => set({ user, status: 'ready' }),
  clearUser: () => set({ user: null, status: 'ready' }),
}))
