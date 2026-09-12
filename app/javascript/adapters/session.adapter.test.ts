import { describe, expect, it } from 'vitest'

import { toUser } from './session.adapter'

describe('toUser', () => {
  it('maps the session response into a User', () => {
    expect(
      toUser({ user: { id: 7, name: 'Ana', email: 'ana@example.com', role: 'admin' } }),
    ).toEqual({
      id: 7,
      name: 'Ana',
      email: 'ana@example.com',
      role: 'admin',
    })
  })
})
