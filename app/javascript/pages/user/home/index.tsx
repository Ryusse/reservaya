import { Heading, Stack, Text } from '@chakra-ui/react'

import { useSession } from '@/hooks/use-session'

export function UserHomePage() {
  const { user } = useSession()

  return (
    <Stack gap="4" maxW="2xl">
      <Heading size="2xl">Hola, {user?.name}</Heading>
      <Text color="fg.muted">Bienvenido a ReservaYa.</Text>
    </Stack>
  )
}
