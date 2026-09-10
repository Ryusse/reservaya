import {
  Button,
  Container,
  Dialog,
  Flex,
  Heading,
  Portal,
  Spinner,
  Stack,
  Table,
  Text,
  useDisclosure,
} from '@chakra-ui/react'

import { SpaceForm } from '@/components/spaces/space-form'
import { useCreateSpace } from '@/hooks/use-create-space'
import { useLogout } from '@/hooks/use-logout'
import { useSpaces } from '@/hooks/use-spaces'
import { apiErrors } from '@/lib/api-error'

export function AdminSpacesPage() {
  const spaces = useSpaces()
  const createSpace = useCreateSpace()
  const logout = useLogout()
  const dialog = useDisclosure()

  return (
    <Container maxW="4xl" py="10">
      <Stack gap="6">
        <Flex justify="space-between" align="center">
          <Heading size="2xl">Espacios</Heading>
          <Flex gap="3">
            <Button onClick={dialog.onOpen}>Nuevo espacio</Button>
            <Button variant="outline" onClick={() => logout.mutate()} loading={logout.isPending}>
              Cerrar sesión
            </Button>
          </Flex>
        </Flex>

        {spaces.isPending ? (
          <Spinner />
        ) : spaces.isError ? (
          <Text color="fg.error">No se pudo cargar el catálogo</Text>
        ) : (
          <Table.Root>
            <Table.Header>
              <Table.Row>
                <Table.ColumnHeader>Nombre</Table.ColumnHeader>
                <Table.ColumnHeader>Ubicación</Table.ColumnHeader>
                <Table.ColumnHeader>Capacidad</Table.ColumnHeader>
                <Table.ColumnHeader>Horario</Table.ColumnHeader>
              </Table.Row>
            </Table.Header>
            <Table.Body>
              {spaces.data.map((space) => (
                <Table.Row key={space.id}>
                  <Table.Cell>{space.name}</Table.Cell>
                  <Table.Cell>{space.location}</Table.Cell>
                  <Table.Cell>{space.capacity}</Table.Cell>
                  <Table.Cell>
                    {space.startTime && space.endTime ? `${space.startTime}–${space.endTime}` : '—'}
                  </Table.Cell>
                </Table.Row>
              ))}
            </Table.Body>
          </Table.Root>
        )}
      </Stack>

      <Dialog.Root open={dialog.open} onOpenChange={(e) => (e.open ? dialog.onOpen() : dialog.onClose())}>
        <Portal>
          <Dialog.Backdrop />
          <Dialog.Positioner>
            <Dialog.Content>
              <Dialog.Header>
                <Dialog.Title>Nuevo espacio</Dialog.Title>
              </Dialog.Header>
              <Dialog.Body>
                <SpaceForm
                  pending={createSpace.isPending}
                  errors={createSpace.isError ? apiErrors(createSpace.error) : undefined}
                  onSubmit={(values) =>
                    createSpace.mutate(values, { onSuccess: () => dialog.onClose() })
                  }
                />
              </Dialog.Body>
              <Dialog.CloseTrigger />
            </Dialog.Content>
          </Dialog.Positioner>
        </Portal>
      </Dialog.Root>
    </Container>
  )
}
