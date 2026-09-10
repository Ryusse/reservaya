import axios from 'axios'
import { useEffect } from 'react'

import { toaster } from '@/components/ui/toaster'
import { http } from '@/lib/http'

export function useApiErrors() {
  useEffect(() => {
    const interceptor = http.interceptors.response.use(
      (response) => response,
      (error) => {
        if (axios.isAxiosError(error) && error.response?.status === 403) {
          toaster.create({
            type: 'error',
            title: 'Sin permiso',
            description: 'No tienes autorización para realizar esta acción.',
          })
        }
        return Promise.reject(error)
      },
    )

    return () => {
      http.interceptors.response.eject(interceptor)
    }
  }, [])
}
