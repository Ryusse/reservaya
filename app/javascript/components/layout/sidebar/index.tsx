import { Avatar, Button, Flex, HStack, Heading, Icon, Link, Separator, Stack, Text } from '@chakra-ui/react'
import { Link as RouterLink } from '@tanstack/react-router'
import { LuCalendarCheck, LuLogOut } from 'react-icons/lu'

import { useLogout } from '@/hooks/use-logout'
import { useSession } from '@/hooks/use-session'
import { navItemsForRole } from '@/lib/nav'
import { roleLabel } from '@/models/role'

type SidebarProps = {
  onNavigate?: () => void
}

export function Sidebar({ onNavigate }: SidebarProps) {
  const { user, role } = useSession()
  const logout = useLogout()
  const items = navItemsForRole(role)

  return (
    <Flex direction="column" h="full" gap="6" px="4" py="6">
      <HStack gap="2" px="2">
        <Icon as={LuCalendarCheck} boxSize="6" color="colorPalette.solid" />
        <Heading size="md">ReservaYa</Heading>
      </HStack>

      <Stack as="nav" gap="1" flex="1">
        {items.map((item) => (
          <Link
            key={item.to}
            asChild
            display="flex"
            alignItems="center"
            gap="3"
            rounded="md"
            px="3"
            py="2.5"
            fontWeight="medium"
            color="fg.muted"
            _hover={{ textDecoration: 'none', bg: 'bg.muted', color: 'fg' }}
            css={{ '&[aria-current="page"]': { bg: 'bg.emphasized', color: 'fg' } }}
          >
            <RouterLink to={item.to} onClick={onNavigate} activeOptions={{ exact: item.to === '/' }}>
              <Icon as={item.icon} boxSize="4" />
              {item.label}
            </RouterLink>
          </Link>
        ))}
      </Stack>

      <Stack gap="3">
        <Separator />
        <HStack gap="3" px="2">
          <Avatar.Root size="sm">
            <Avatar.Fallback name={user?.name} />
          </Avatar.Root>
          <Stack gap="0" flex="1" minW="0">
            <Text fontSize="sm" fontWeight="medium" truncate>
              {user?.name}
            </Text>
            <Text fontSize="xs" color="fg.muted">
              {roleLabel(role)}
            </Text>
          </Stack>
        </HStack>
        <Button variant="outline" size="sm" onClick={() => logout.mutate()} loading={logout.isPending}>
          <LuLogOut />
          Cerrar sesión
        </Button>
      </Stack>
    </Flex>
  )
}
