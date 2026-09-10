import { describe, expect, it } from 'vitest'

import { Role, roleLabel } from './role'

describe('roleLabel', () => {
  it('labels known roles in Spanish', () => {
    expect(roleLabel(Role.Admin)).toBe('Administrador')
    expect(roleLabel(Role.User)).toBe('Usuario')
  })

  it('returns an empty string when there is no role', () => {
    expect(roleLabel(null)).toBe('')
  })
})
