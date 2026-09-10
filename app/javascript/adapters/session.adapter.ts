import type { Role } from '@/models/role'
import type { User } from '@/models/user'

export type SessionResponse = {
  user: { id: number; name: string; email: string; role: string }
}

export function toUser(data: SessionResponse): User {
  return {
    id: data.user.id,
    name: data.user.name,
    email: data.user.email,
    role: data.user.role as Role,
  }
}
