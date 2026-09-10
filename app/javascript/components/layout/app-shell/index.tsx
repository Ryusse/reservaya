import { Box, CloseButton, Drawer, Flex, Heading, IconButton, Portal } from '@chakra-ui/react'
import type { ReactNode } from 'react'
import { useState } from 'react'
import { LuMenu } from 'react-icons/lu'

import { Sidebar } from '@/components/layout/sidebar'

type AppShellProps = {
  children: ReactNode
}

export function AppShell({ children }: AppShellProps) {
  const [open, setOpen] = useState(false)

  return (
    <Flex direction={{ base: 'column', lg: 'row' }} minH="100dvh">
      <Box
        as="aside"
        hideBelow="lg"
        position="sticky"
        top="0"
        h="100dvh"
        w="64"
        flexShrink="0"
        borderRightWidth="1px"
        borderColor="border.subtle"
        bg="bg.panel"
      >
        <Sidebar />
      </Box>

      <Flex
        as="header"
        hideFrom="lg"
        position="sticky"
        top="0"
        zIndex="docked"
        align="center"
        gap="3"
        h="14"
        px="4"
        borderBottomWidth="1px"
        borderColor="border.subtle"
        bg="bg.panel"
      >
        <Drawer.Root
          open={open}
          onOpenChange={(event) => setOpen(event.open)}
          placement="start"
          size="xs"
        >
          <Drawer.Trigger asChild>
            <IconButton aria-label="Abrir menú" variant="ghost" size="sm">
              <LuMenu />
            </IconButton>
          </Drawer.Trigger>
          <Portal>
            <Drawer.Backdrop />
            <Drawer.Positioner>
              <Drawer.Content>
                <Drawer.Body p="0">
                  <Sidebar onNavigate={() => setOpen(false)} />
                </Drawer.Body>
                <Drawer.CloseTrigger asChild>
                  <CloseButton size="sm" />
                </Drawer.CloseTrigger>
              </Drawer.Content>
            </Drawer.Positioner>
          </Portal>
        </Drawer.Root>
        <Heading size="sm">ReservaYa</Heading>
      </Flex>

      <Box as="main" flex="1" minW="0" px={{ base: 4, md: 8 }} py={{ base: 6, md: 8 }}>
        {children}
      </Box>
    </Flex>
  )
}
