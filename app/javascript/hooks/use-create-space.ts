import { useMutation, useQueryClient } from '@tanstack/react-query'

import type { NewSpace } from '@/models/space'
import { spacesService } from '@/services/spaces.service'

import { spacesQueryKey } from './use-spaces'

export function useCreateSpace() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: (input: NewSpace) => spacesService.create(input),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: spacesQueryKey }),
  })
}
