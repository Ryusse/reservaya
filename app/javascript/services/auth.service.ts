import type { SessionResponse } from '@/adapters/session.adapter'
import { toUser } from '@/adapters/session.adapter'
import { http } from '@/lib/http'
import type { Credentials } from '@/models/credentials'
import type { Registration } from '@/models/registration'
import type { User } from '@/models/user'

export const authService = {
  async login(credentials: Credentials): Promise<User> {
    const { data } = await http.post<SessionResponse>('/session', credentials)
    return toUser(data)
  },

  async register(input: Registration): Promise<User> {
    const { data } = await http.post<SessionResponse>('/register', { user: input })
    return toUser(data)
  },

  async me(): Promise<User | null> {
    try {
      const { data } = await http.get<SessionResponse>('/session')
      return toUser(data)
    } catch {
      return null
    }
  },

  async logout(): Promise<void> {
    await http.delete('/session')
  },
}
