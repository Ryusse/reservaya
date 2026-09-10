import { Button, Dialog, Portal, Text } from '@chakra-ui/react'

import { useDeactivateSpace } from '@/hooks/use-deactivate-space'
import { apiErrors } from '@/lib/api-error'
import type { Space } from '@/models/space'

type DeactivateSpaceDialogProps = {
  space: Space | null
  onClose: () => void
}

export function DeactivateSpaceDialog({ space, onClose }: DeactivateSpaceDialogProps) {
  const deactivate = useDeactivateSpace()

  return (
    <Dialog.Root
      role="alertdialog"
      open={space !== null}
      onOpenChange={(event) => (event.open ? undefined : onClose())}
    >
      <Portal>
        <Dialog.Backdrop />
        <Dialog.Positioner>
          <Dialog.Content>
            <Dialog.Header>
              <Dialog.Title>Dar de baja</Dialog.Title>
            </Dialog.Header>
            <Dialog.Body>
              <Text>
                ¿Dar de baja «{space?.name}»? Dejará de estar disponible para reservas y no aparecerá
                en el listado.
              </Text>
              {deactivate.isError ? (
                <Text mt="3" color="fg.error" fontSize="sm">
                  {apiErrors(deactivate.error)[0]}
                </Text>
              ) : null}
            </Dialog.Body>
            <Dialog.Footer>
              <Dialog.ActionTrigger asChild>
                <Button variant="outline">Cancelar</Button>
              </Dialog.ActionTrigger>
              <Button
                colorPalette="red"
                loading={deactivate.isPending}
                onClick={() => space && deactivate.mutate(space.id, { onSuccess: onClose })}
              >
                Dar de baja
              </Button>
            </Dialog.Footer>
            <Dialog.CloseTrigger />
          </Dialog.Content>
        </Dialog.Positioner>
      </Portal>
    </Dialog.Root>
  )
}
