import type { Role } from './role'

export type User = {
  id: number
  name: string
  email: string
  role: Role
}
