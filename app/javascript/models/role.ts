export const Role = {
  User: 'user',
  Admin: 'admin',
} as const

export type Role = (typeof Role)[keyof typeof Role]

const roleLabels: Record<Role, string> = {
  [Role.User]: 'Usuario',
  [Role.Admin]: 'Administrador',
}

export function roleLabel(role: Role | null): string {
  return role ? roleLabels[role] : ''
}
