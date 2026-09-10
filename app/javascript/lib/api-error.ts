import axios from 'axios'

export function apiErrors(error: unknown): string[] {
  if (axios.isAxiosError(error)) {
    const data = error.response?.data as { errors?: unknown; error?: unknown } | undefined
    if (Array.isArray(data?.errors)) return data.errors as string[]
    if (typeof data?.error === 'string') return [data.error]
  }
  return ['Ocurrió un error inesperado']
}
