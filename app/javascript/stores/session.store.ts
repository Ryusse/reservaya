import { create } from 'zustand'
import { createJSONStorage, persist } from 'zustand/middleware'

import { isTokenExpired } from '@/lib/jwt'
import type { Session } from '@/models/session'

type SessionState = {
  session: Session | null
  setSession: (session: Session) => void
  clearSession: () => void
}

export const useSessionStore = create<SessionState>()(
  persist(
    (set) => ({
      session: null,
      setSession: (session) => set({ session }),
      clearSession: () => set({ session: null }),
    }),
    {
      name: 'reservaya.session',
      storage: createJSONStorage(() => sessionStorage),
      onRehydrateStorage: () => (state) => {
        if (state?.session && isTokenExpired(state.session.token)) {
          state.clearSession()
        }
      },
    },
  ),
)
