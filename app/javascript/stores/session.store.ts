import { create } from 'zustand'

import type { Session } from '@/models/session'

type SessionState = {
  session: Session | null
  setSession: (session: Session) => void
  clearSession: () => void
}

export const useSessionStore = create<SessionState>((set) => ({
  session: null,
  setSession: (session) => set({ session }),
  clearSession: () => set({ session: null }),
}))
