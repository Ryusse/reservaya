import { describe, expect, it } from 'vitest'

import type { Space } from '@/models/space'
import { toSpace, toSpaceInput, toSpacePayload } from './space.adapter'

describe('space.adapter', () => {
  it('toSpace maps snake_case and trims ISO datetimes to HH:MM', () => {
    const result = toSpace({
      id: 1,
      name: 'Sala A',
      capacity: 10,
      location: 'Piso 2',
      start_time: '2000-01-01T08:00:00.000Z',
      end_time: '2000-01-01T20:00:00.000Z',
      status: 'active',
    })

    expect(result).toEqual({
      id: 1,
      name: 'Sala A',
      capacity: 10,
      location: 'Piso 2',
      startTime: '08:00',
      endTime: '20:00',
      status: 'active',
    })
  })

  it('toSpace falls back to active for unknown status and null times stay null', () => {
    const result = toSpace({
      id: 2,
      name: 'X',
      capacity: 1,
      location: 'Y',
      start_time: null,
      end_time: null,
      status: 'weird',
    })

    expect(result.status).toBe('active')
    expect(result.startTime).toBeNull()
    expect(result.endTime).toBeNull()
  })

  it('toSpace keeps an inactive status', () => {
    const result = toSpace({
      id: 3,
      name: 'X',
      capacity: 1,
      location: 'Y',
      start_time: null,
      end_time: null,
      status: 'inactive',
    })

    expect(result.status).toBe('inactive')
  })

  it('toSpacePayload wraps values under space without forcing a status', () => {
    expect(
      toSpacePayload({
        name: 'A',
        location: 'P1',
        capacity: 5,
        startTime: '08:00',
        endTime: '17:00',
      }),
    ).toEqual({
      space: { name: 'A', location: 'P1', capacity: 5, start_time: '08:00', end_time: '17:00' },
    })
  })

  it('toSpaceInput turns a Space into form values, null times become empty strings', () => {
    const space: Space = {
      id: 1,
      name: 'A',
      location: 'P1',
      capacity: 5,
      startTime: null,
      endTime: null,
      status: 'active',
    }

    expect(toSpaceInput(space)).toEqual({
      name: 'A',
      location: 'P1',
      capacity: 5,
      startTime: '',
      endTime: '',
    })
  })
})
