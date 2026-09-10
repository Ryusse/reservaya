# Arquitectura del frontend

SPA de **React + TypeScript + Vite** que consume la API REST de Rails (RNF07). La sesión
va en una cookie httpOnly encriptada que pone `POST /session`; el SPA no maneja el token.
Estructura por capas inspirada en
*Front-End Clean Architecture* (Gentleman Programming), adaptada a **TanStack Router**,
**Zustand** y **CSS Modules**.

## Carpetas (`app/javascript/`)

| Carpeta | Responsabilidad | Puede depender de |
|---|---|---|
| `models/` | Tipos de dominio: `User`, `Session`, `Space`, `Reservation`, enums | — |
| `adapters/` | Traducen la respuesta cruda de la API (jbuilder) a `models` y viceversa: fechas, enums, `snake_case → camelCase` | `models` |
| `lib/` | Infra transversal: cliente HTTP (axios, withCredentials, manejo 401/403), configuración | `models` |
| `services/` | Lógica de negocio y orquestación de llamadas: `authService`, `spacesService`, … | `lib`, `adapters`, `models` |
| `hooks/` | Encapsulan `services` + estado para los componentes: `useAuth`, `useSpaces`, … | `services`, `stores`, `models` |
| `stores/` | Estado global con Zustand (sesión: `user`, `role`, estado de carga — sin token) | `models` |
| `components/ui/` | Componentes de presentación (Base UI envuelto). **No** llaman a `services` ni `stores` | — |
| `components/<feature>/` | Componentes compuestos de una feature | `components/ui`, `hooks`, `models` |
| `pages/` | Contenedores de ruta; componen `hooks` + `components` | `hooks`, `components`, `models` |
| `routes/` | Árbol de rutas (file-based de TanStack Router) + guards | `pages` |
| `utilities/` | Funciones puras auxiliares | — |
| `styles/` | CSS global y tokens de tema | — |
| `__tests__/`, `__mocks__/` | Pruebas y dobles | — |

**Regla de dependencias:** hacia adentro.
`routes → pages → hooks → services → adapters → lib/http → API`.
`components/ui` es la capa más externa y no conoce nada de negocio.

## Composición

- `entrypoints/application.tsx` — entrada de Vite; monta `<App/>` en `#root`.
- `App.tsx` — providers + `<RouterProvider router={router} />`.
- `router.tsx` — `createRouter({ routeTree })`.
- `routeTree.gen.ts` — generado por `@tanstack/router-plugin` a partir de `routes/`. No editar.

## Routing

**TanStack Router**, file-based:

- `routes/__root.tsx` — layout raíz (`<Outlet/>` + devtools en dev).
- `routes/index.tsx` — `/`.
- Rutas protegidas y guard por rol: ver HT-02 #31.

El plugin de Vite regenera `routeTree.gen.ts` en cada `vite dev` / `vite build`.
Para generarlo sin Vite (CI, `pnpm check`): `pnpm exec tsr generate` (config en `tsr.config.json`).

## Estado

- **Global**: Zustand (`stores/`). Solo lo que es realmente compartido y no cabe en la URL (sesión).
- **De servidor / cache**: los `hooks` sobre `services` (se puede añadir TanStack Query más adelante si hace falta).
- **De URL**: TanStack Router (search params, path params).

## Estilos

**CSS Modules** (`*.module.css`) junto a cada componente. Tokens globales en `styles/`.
Los componentes accesibles vienen de **Base UI** (sin estilos) — ver HT-02 #30.

## Servido por Rails

`PagesController#show` renderiza `app/views/pages/show.html.erb` (`<div id="root">`) con
el layout que incluye los tags de Vite. `config/routes.rb` tiene un catch-all
`get "*path"` para formatos HTML, de modo que los deep links del cliente
(`/login`, `/espacios`, …) sirven la SPA. Las rutas de la API van antes y no se ven afectadas.
