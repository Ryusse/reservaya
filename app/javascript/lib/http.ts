import axios from 'axios'

import { useSessionStore } from '@/stores/session.store'

export const http = axios.create({
  baseURL: '/',
  headers: { Accept: 'application/json' },
  withCredentials: true,
})

http.interceptors.response.use(
  (response) => response,
  (error) => {
    if (axios.isAxiosError(error) && error.response?.status === 401) {
      useSessionStore.getState().clearUser()
    }
    return Promise.reject(error)
  },
)
