import { useMutation, useQueryClient } from '@tanstack/react-query'

import type { NewSpace } from '@/models/space'
import { spacesService } from '@/services/spaces.service'

import { spacesQueryKey } from './use-spaces'

type UpdateSpaceInput = {
  id: number
  input: NewSpace
}

export function useUpdateSpace() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: ({ id, input }: UpdateSpaceInput) => spacesService.update(id, input),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: spacesQueryKey }),
  })
}
