import { useQuery } from '@tanstack/react-query'

import { spacesService } from '@/services/spaces.service'

export const spacesQueryKey = ['spaces'] as const

export function useSpaces() {
  return useQuery({ queryKey: spacesQueryKey, queryFn: spacesService.list })
}
