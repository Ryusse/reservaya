import axios from 'axios'

import { useSessionStore } from '@/stores/session.store'

export const http = axios.create({
  baseURL: '/',
  headers: { Accept: 'application/json' },
})

http.interceptors.request.use((config) => {
  const token = useSessionStore.getState().session?.token
  if (token) {
    config.headers.Authorization = `Bearer ${token}`
  }
  return config
})

http.interceptors.response.use(
  (response) => response,
  (error) => {
    if (axios.isAxiosError(error) && error.response?.status === 401) {
      useSessionStore.getState().clearSession()
    }
    return Promise.reject(error)
  },
)
