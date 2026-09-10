import { Button, Card, Container, Field, Heading, Input, Stack, Text } from '@chakra-ui/react'
import { Link as RouterLink } from '@tanstack/react-router'
import { useState } from 'react'

import { useLogin } from '@/hooks/use-login'

export function LoginPage() {
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const login = useLogin()

  return (
    <Container maxW="sm" py="16">
      <Card.Root>
        <Card.Header>
          <Heading size="xl">Iniciar sesión</Heading>
        </Card.Header>
        <Card.Body>
          <form
            onSubmit={(event) => {
              event.preventDefault()
              login.mutate({ email, password })
            }}
          >
            <Stack gap="4">
              <Field.Root required>
                <Field.Label>Correo</Field.Label>
                <Input
                  type="email"
                  value={email}
                  onChange={(event) => setEmail(event.target.value)}
                  autoComplete="email"
                />
              </Field.Root>
              <Field.Root required>
                <Field.Label>Contraseña</Field.Label>
                <Input
                  type="password"
                  value={password}
                  onChange={(event) => setPassword(event.target.value)}
                  autoComplete="current-password"
                />
              </Field.Root>
              {login.isError ? (
                <Text color="fg.error" fontSize="sm">
                  Correo o contraseña inválidos
                </Text>
              ) : null}
              <Button type="submit" loading={login.isPending}>
                Entrar
              </Button>

              <Text fontSize="sm" color="fg.muted">
                ¿No tienes cuenta?{' '}
                <RouterLink to="/register" style={{ textDecoration: 'underline' }}>
                  Regístrate
                </RouterLink>
              </Text>
            </Stack>
          </form>
        </Card.Body>
      </Card.Root>
    </Container>
  )
}
