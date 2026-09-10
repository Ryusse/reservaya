import { Button, Field, Input, Stack, Text } from '@chakra-ui/react'
import { useState } from 'react'

import type { NewSpace } from '@/models/space'

type SpaceFormProps = {
  initialValues?: NewSpace
  submitLabel?: string
  pending?: boolean
  errors?: string[]
  onSubmit: (values: NewSpace) => void
}

const empty: NewSpace = { name: '', location: '', capacity: 1, startTime: '', endTime: '' }

export function SpaceForm({ initialValues, submitLabel = 'Guardar', pending, errors, onSubmit }: SpaceFormProps) {
  const [values, setValues] = useState<NewSpace>(initialValues ?? empty)

  const set = <K extends keyof NewSpace>(key: K, value: NewSpace[K]) =>
    setValues((current) => ({ ...current, [key]: value }))

  return (
    <form
      onSubmit={(event) => {
        event.preventDefault()
        onSubmit(values)
      }}
    >
      <Stack gap="4">
        <Field.Root required>
          <Field.Label>Nombre</Field.Label>
          <Input value={values.name} onChange={(e) => set('name', e.target.value)} />
        </Field.Root>
        <Field.Root required>
          <Field.Label>Ubicación</Field.Label>
          <Input value={values.location} onChange={(e) => set('location', e.target.value)} />
        </Field.Root>
        <Field.Root required>
          <Field.Label>Capacidad</Field.Label>
          <Input
            type="number"
            min={1}
            value={values.capacity}
            onChange={(e) => set('capacity', Number(e.target.value))}
          />
        </Field.Root>
        <Field.Root required>
          <Field.Label>Hora de apertura</Field.Label>
          <Input type="time" value={values.startTime} onChange={(e) => set('startTime', e.target.value)} />
        </Field.Root>
        <Field.Root required>
          <Field.Label>Hora de cierre</Field.Label>
          <Input type="time" value={values.endTime} onChange={(e) => set('endTime', e.target.value)} />
        </Field.Root>

        {errors?.length ? (
          <Stack gap="1">
            {errors.map((message) => (
              <Text key={message} color="fg.error" fontSize="sm">
                {message}
              </Text>
            ))}
          </Stack>
        ) : null}

        <Button type="submit" loading={pending}>
          {submitLabel}
        </Button>
      </Stack>
    </form>
  )
}
