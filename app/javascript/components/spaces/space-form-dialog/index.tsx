import { Dialog, Portal } from '@chakra-ui/react'

import { toSpaceInput } from '@/adapters/space.adapter'
import { SpaceForm } from '@/components/spaces/space-form'
import { useCreateSpace } from '@/hooks/use-create-space'
import { useUpdateSpace } from '@/hooks/use-update-space'
import { apiErrors } from '@/lib/api-error'
import type { NewSpace, Space } from '@/models/space'

type SpaceFormDialogProps = {
  space: Space | null
  open: boolean
  onClose: () => void
}

export function SpaceFormDialog({ space, open, onClose }: SpaceFormDialogProps) {
  const createSpace = useCreateSpace()
  const updateSpace = useUpdateSpace()

  const isEdit = space !== null
  const mutation = isEdit ? updateSpace : createSpace

  const handleSubmit = (values: NewSpace) => {
    if (space) {
      updateSpace.mutate({ id: space.id, input: values }, { onSuccess: onClose })
    } else {
      createSpace.mutate(values, { onSuccess: onClose })
    }
  }

  return (
    <Dialog.Root open={open} onOpenChange={(event) => (event.open ? undefined : onClose())}>
      <Portal>
        <Dialog.Backdrop />
        <Dialog.Positioner>
          <Dialog.Content>
            <Dialog.Header>
              <Dialog.Title>{isEdit ? 'Editar espacio' : 'Nuevo espacio'}</Dialog.Title>
            </Dialog.Header>
            <Dialog.Body>
              <SpaceForm
                initialValues={space ? toSpaceInput(space) : undefined}
                submitLabel={isEdit ? 'Guardar cambios' : 'Crear'}
                pending={mutation.isPending}
                errors={mutation.isError ? apiErrors(mutation.error) : undefined}
                onSubmit={handleSubmit}
              />
            </Dialog.Body>
            <Dialog.CloseTrigger />
          </Dialog.Content>
        </Dialog.Positioner>
      </Portal>
    </Dialog.Root>
  )
}
