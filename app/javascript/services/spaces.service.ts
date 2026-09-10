import { toSpace, toSpacePayload } from '@/adapters/space.adapter'
import type { SpaceResponse } from '@/adapters/space.adapter'
import { http } from '@/lib/http'
import type { NewSpace, Space } from '@/models/space'

export const spacesService = {
  async list(): Promise<Space[]> {
    const { data } = await http.get<SpaceResponse[]>('/spaces')
    return data.map(toSpace)
  },

  async create(input: NewSpace): Promise<Space> {
    const { data } = await http.post<SpaceResponse>('/spaces', toSpacePayload(input))
    return toSpace(data)
  },
}
