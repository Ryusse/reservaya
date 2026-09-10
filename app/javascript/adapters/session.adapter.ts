import type { Role } from '@/models/role'
import type { Session } from '@/models/session'

export type LoginResponse = {
  token: string
  user: { id: number; name: string; email: string; role: string }
}

export function toSession(data: LoginResponse): Session {
  return {
    token: data.token,
    user: {
      id: data.user.id,
      name: data.user.name,
      email: data.user.email,
      role: data.user.role as Role,
    },
  }
}
