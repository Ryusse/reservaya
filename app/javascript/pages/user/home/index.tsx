import { Button, Container, Heading, Stack, Text } from '@chakra-ui/react'

import { useLogout } from '@/hooks/use-logout'
import { useSession } from '@/hooks/use-session'

export function UserHomePage() {
  const { user, role } = useSession()
  const logout = useLogout()

  return (
    <Container maxW="2xl" py="10">
      <Stack gap="4" align="start">
        <Heading size="2xl">ReservaYa</Heading>
        <Text>
          Hola, {user?.name} ({role})
        </Text>
        <Button variant="outline" onClick={() => logout.mutate()} loading={logout.isPending}>
          Cerrar sesión
        </Button>
      </Stack>
    </Container>
  )
}
