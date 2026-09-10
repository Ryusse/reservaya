import { describe, expect, it } from 'vitest'

import { Role } from '@/models/role'
import { navItemsForRole } from './nav'

describe('navItemsForRole', () => {
  it('returns nothing when there is no role', () => {
    expect(navItemsForRole(null)).toEqual([])
  })

  it('gives a user only the non-admin items', () => {
    const labels = navItemsForRole(Role.User).map((item) => item.label)

    expect(labels).toContain('Inicio')
    expect(labels).not.toContain('Espacios')
  })

  it('gives an admin the admin items', () => {
    const paths = navItemsForRole(Role.Admin).map((item) => item.to)

    expect(paths).toContain('/admin')
  })
})
