import { useMutation, useQueryClient } from '@tanstack/react-query'

import { spacesService } from '@/services/spaces.service'

import { spacesQueryKey } from './use-spaces'

export function useDeactivateSpace() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: (id: number) => spacesService.deactivate(id),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: spacesQueryKey }),
  })
}
