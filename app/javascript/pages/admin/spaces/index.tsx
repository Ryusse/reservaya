import { Button, Flex, Heading, Spinner, Stack, Table, Text } from '@chakra-ui/react'
import { useState } from 'react'

import { DeactivateSpaceDialog } from '@/components/spaces/deactivate-space-dialog'
import { SpaceFormDialog } from '@/components/spaces/space-form-dialog'
import { useSpaces } from '@/hooks/use-spaces'
import type { Space } from '@/models/space'

export function AdminSpacesPage() {
  const spaces = useSpaces()
  const [formSpace, setFormSpace] = useState<Space | null>(null)
  const [formOpen, setFormOpen] = useState(false)
  const [toDeactivate, setToDeactivate] = useState<Space | null>(null)

  const openCreate = () => {
    setFormSpace(null)
    setFormOpen(true)
  }

  const openEdit = (space: Space) => {
    setFormSpace(space)
    setFormOpen(true)
  }

  const isEmpty = !spaces.isPending && !spaces.isError && spaces.data.length === 0

  return (
    <>
      <Stack gap="6" maxW="5xl">
        <Flex justify="space-between" align="center" gap="4">
          <Heading size="2xl">Espacios</Heading>
          <Button onClick={openCreate}>Nuevo espacio</Button>
        </Flex>

        {spaces.isPending ? (
          <Spinner />
        ) : spaces.isError ? (
          <Text color="fg.error">No se pudo cargar el catálogo</Text>
        ) : isEmpty ? (
          <Text color="fg.muted">No hay espacios activos.</Text>
        ) : (
          <Table.ScrollArea borderWidth="1px" rounded="md">
            <Table.Root>
              <Table.Header>
                <Table.Row>
                  <Table.ColumnHeader>Nombre</Table.ColumnHeader>
                  <Table.ColumnHeader>Ubicación</Table.ColumnHeader>
                  <Table.ColumnHeader>Capacidad</Table.ColumnHeader>
                  <Table.ColumnHeader>Horario</Table.ColumnHeader>
                  <Table.ColumnHeader textAlign="end">Acciones</Table.ColumnHeader>
                </Table.Row>
              </Table.Header>
              <Table.Body>
                {spaces.data.map((space) => (
                  <Table.Row key={space.id}>
                    <Table.Cell>{space.name}</Table.Cell>
                    <Table.Cell>{space.location}</Table.Cell>
                    <Table.Cell>{space.capacity}</Table.Cell>
                    <Table.Cell>
                      {space.startTime && space.endTime
                        ? `${space.startTime}–${space.endTime}`
                        : '—'}
                    </Table.Cell>
                    <Table.Cell>
                      <Flex gap="2" justify="end">
                        <Button size="xs" variant="outline" onClick={() => openEdit(space)}>
                          Editar
                        </Button>
                        <Button
                          size="xs"
                          variant="outline"
                          colorPalette="red"
                          onClick={() => setToDeactivate(space)}
                        >
                          Dar de baja
                        </Button>
                      </Flex>
                    </Table.Cell>
                  </Table.Row>
                ))}
              </Table.Body>
            </Table.Root>
          </Table.ScrollArea>
        )}
      </Stack>

      <SpaceFormDialog
        key={formOpen ? (formSpace?.id ?? 'new') : 'closed'}
        space={formSpace}
        open={formOpen}
        onClose={() => setFormOpen(false)}
      />
      <DeactivateSpaceDialog
        key={toDeactivate?.id ?? 'none'}
        space={toDeactivate}
        onClose={() => setToDeactivate(null)}
      />
    </>
  )
}
