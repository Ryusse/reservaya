import { toSession } from '@/adapters/session.adapter'
import type { LoginResponse } from '@/adapters/session.adapter'
import { http } from '@/lib/http'
import type { Credentials } from '@/models/credentials'
import type { Session } from '@/models/session'

export const authService = {
  async login(credentials: Credentials): Promise<Session> {
    const { data } = await http.post<LoginResponse>('/session', credentials)
    return toSession(data)
  },

  async logout(): Promise<void> {
    await http.delete('/session')
  },
}
