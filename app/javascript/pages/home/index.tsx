import {
  Button,
  CloseButton,
  Container,
  Dialog,
  Heading,
  HStack,
  Portal,
  Stack,
  Switch,
  Text,
} from '@chakra-ui/react'

export function HomePage() {
  return (
    <Container maxW="2xl" py="10">
      <Stack gap="6">
        <Stack gap="1">
          <Heading size="2xl">ReservaYa</Heading>
          <Text color="fg.muted">
            Frontend inicializado — TanStack Router + Chakra UI + arquitectura por capas.
          </Text>
        </Stack>

        <HStack gap="4">
          <Switch.Root>
            <Switch.HiddenInput />
            <Switch.Control />
          </Switch.Root>

          <Dialog.Root>
            <Dialog.Trigger asChild>
              <Button variant="outline">Abrir diálogo</Button>
            </Dialog.Trigger>
            <Portal>
              <Dialog.Backdrop />
              <Dialog.Positioner>
                <Dialog.Content>
                  <Dialog.CloseTrigger asChild>
                    <CloseButton size="sm" />
                  </Dialog.CloseTrigger>
                  <Dialog.Header>
                    <Dialog.Title>Prueba de Chakra UI</Dialog.Title>
                  </Dialog.Header>
                  <Dialog.Body>
                    <Text>Los componentes renderizan sin errores.</Text>
                  </Dialog.Body>
                  <Dialog.Footer>
                      <Button>Cerrar</Button>
                  </Dialog.Footer>
                </Dialog.Content>
              </Dialog.Positioner>
            </Portal>
          </Dialog.Root>
        </HStack>
      </Stack>
    </Container>
  )
}
