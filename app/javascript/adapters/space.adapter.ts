import type { NewSpace, Space, SpaceStatus } from '@/models/space'

export type SpaceResponse = {
  id: number
  name: string
  capacity: number
  location: string
  start_time: string | null
  end_time: string | null
  status: string
}

export function toSpace(data: SpaceResponse): Space {
  return {
    id: data.id,
    name: data.name,
    capacity: data.capacity,
    location: data.location,
    startTime: data.start_time,
    endTime: data.end_time,
    status: (data.status === 'inactive' ? 'inactive' : 'active') as SpaceStatus,
  }
}

export function toSpacePayload(input: NewSpace) {
  return {
    space: {
      name: input.name,
      location: input.location,
      capacity: input.capacity,
      start_time: input.startTime,
      end_time: input.endTime,
    },
  }
}

export function toSpaceInput(space: Space): NewSpace {
  return {
    name: space.name,
    location: space.location,
    capacity: space.capacity,
    startTime: space.startTime ?? '',
    endTime: space.endTime ?? '',
  }
}
