import { Button, Container, Heading, Stack, Text } from '@chakra-ui/react'

import { useLogout } from '@/hooks/use-logout'
import { useSession } from '@/hooks/use-session'

export function AdminHomePage() {
  const { user } = useSession()
  const logout = useLogout()

  return (
    <Container maxW="2xl" py="10">
      <Stack gap="4" align="start">
        <Heading size="2xl">Panel de administración</Heading>
        <Text>
          {user?.name} — solo visible para el rol admin.
        </Text>
        <Button variant="outline" onClick={() => logout.mutate()} loading={logout.isPending}>
          Cerrar sesión
        </Button>
      </Stack>
    </Container>
  )
}
