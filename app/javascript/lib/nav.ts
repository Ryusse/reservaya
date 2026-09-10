import type { IconType } from 'react-icons'
import { LuBuilding2, LuHouse } from 'react-icons/lu'

import { Role } from '@/models/role'

export type NavItem = {
  label: string
  to: string
  icon: IconType
  roles: Role[]
}

export const navItems: NavItem[] = [
  { label: 'Inicio', to: '/', icon: LuHouse, roles: [Role.User] },
  { label: 'Espacios', to: '/admin', icon: LuBuilding2, roles: [Role.Admin] },
]

export function navItemsForRole(role: Role | null): NavItem[] {
  if (!role) return []
  return navItems.filter((item) => item.roles.includes(role))
}
