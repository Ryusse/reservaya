import { Button, Card, Container, Field, Heading, Input, Stack, Text } from '@chakra-ui/react'
import { Link as RouterLink } from '@tanstack/react-router'
import { useState } from 'react'

import { useRegister } from '@/hooks/use-register'
import type { Registration } from '@/models/registration'
import { apiErrors } from '@/lib/api-error'

const empty: Registration = { name: '', email: '', password: '' }

type FieldErrors = Partial<Record<keyof Registration, string>>

function validate(values: Registration): FieldErrors {
  const errors: FieldErrors = {}
  if (!values.name.trim()) errors.name = 'El nombre es obligatorio'
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(values.email)) errors.email = 'Correo inválido'
  if (values.password.length < 6) errors.password = 'Mínimo 6 caracteres'
  return errors
}

export function RegisterPage() {
  const [values, setValues] = useState<Registration>(empty)
  const [errors, setErrors] = useState<FieldErrors>({})
  const [submitted, setSubmitted] = useState(false)
  const register = useRegister()

  const set = <K extends keyof Registration>(key: K, value: Registration[K]) => {
    const next = { ...values, [key]: value }
    setValues(next)
    if (submitted) setErrors(validate(next))
  }

  const handleSubmit = (event: React.FormEvent) => {
    event.preventDefault()
    setSubmitted(true)
    const found = validate(values)
    setErrors(found)
    if (Object.keys(found).length === 0) register.mutate(values)
  }

  return (
    <Container maxW="sm" py="16">
      <Card.Root>
        <Card.Header>
          <Heading size="xl">Crear cuenta</Heading>
        </Card.Header>
        <Card.Body>
          <form onSubmit={handleSubmit} noValidate>
            <Stack gap="4">
              <Field.Root required invalid={Boolean(errors.name)}>
                <Field.Label>Nombre</Field.Label>
                <Input value={values.name} onChange={(event) => set('name', event.target.value)} autoComplete="name" />
                <Field.ErrorText>{errors.name}</Field.ErrorText>
              </Field.Root>

              <Field.Root required invalid={Boolean(errors.email)}>
                <Field.Label>Correo</Field.Label>
                <Input
                  type="email"
                  value={values.email}
                  onChange={(event) => set('email', event.target.value)}
                  autoComplete="email"
                />
                <Field.ErrorText>{errors.email}</Field.ErrorText>
              </Field.Root>

              <Field.Root required invalid={Boolean(errors.password)}>
                <Field.Label>Contraseña</Field.Label>
                <Input
                  type="password"
                  value={values.password}
                  onChange={(event) => set('password', event.target.value)}
                  autoComplete="new-password"
                />
                <Field.ErrorText>{errors.password}</Field.ErrorText>
                <Field.HelperText>Al menos 6 caracteres.</Field.HelperText>
              </Field.Root>

              {register.isError ? (
                <Stack gap="1">
                  {apiErrors(register.error).map((message) => (
                    <Text key={message} color="fg.error" fontSize="sm">
                      {message}
                    </Text>
                  ))}
                </Stack>
              ) : null}

              <Button type="submit" loading={register.isPending}>
                Registrarme
              </Button>

              <Text fontSize="sm" color="fg.muted">
                ¿Ya tienes cuenta?{' '}
                <RouterLink to="/login" style={{ textDecoration: 'underline' }}>
                  Inicia sesión
                </RouterLink>
              </Text>
            </Stack>
          </form>
        </Card.Body>
      </Card.Root>
    </Container>
  )
}
