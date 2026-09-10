export type SpaceStatus = 'active' | 'inactive'

export type Space = {
  id: number
  name: string
  capacity: number
  location: string
  startTime: string | null
  endTime: string | null
  status: SpaceStatus
}

export type NewSpace = {
  name: string
  location: string
  capacity: number
  startTime: string
  endTime: string
}
