import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'

import { App } from '@/App'
import { Provider } from '@/components/ui/provider'

const el = document.getElementById('root')
if (!el) throw new Error('Missing <div id="root"> in the layout')

createRoot(el).render(
  <StrictMode>
    <Provider>
      <App />
    </Provider>
  </StrictMode>,
)
