# CLAUDE.md

Contexto del proyecto para Claude Code. Mantener corto y actualizado.

## Qué es

**ReservaYa** — plataforma web de reserva de espacios físicos.
Backend **Rails 8.1** (API REST + JWT) · Frontend **React + TypeScript + Vite** (SPA desacoplada) · **PostgreSQL** (en Docker).

Arquitectura: API REST y frontend en capas independientes (RNF07). El React consume la API con `Authorization: Bearer <token>`.

## Cómo levantar

```bash
docker compose up -d          # solo PostgreSQL (localhost:5432, user/password, reservaya_development)
bundle install && pnpm install
bin/rails db:prepare          # crea BD + migra
bin/rails runner "User.create!(name:'Admin', email:'admin@test.com', password:'secret123', role:1)"

pnpm dev                      # Rails + Vite juntos (foreman) → Rails :3100, Vite :3036
# o por separado:
pnpm backend                  # bin/rails server → :3000
pnpm frontend                 # bin/vite dev → :3036
```

Requisito macOS: `brew install libpq` + `bundle config build.pg --with-pg-config="$(brew --prefix libpq)/bin/pg_config"`.

## Backend

- `app/controllers/application_controller.rb` — `ActionController::Base`, para la parte Inertia/HTML.
- `app/controllers/api_controller.rb` — `ActionController::API`, auth JWT (`require_login`, `require_admin`, `current_user`). **Todos los controllers de la API heredan de aquí.**
- `app/services/json_web_token.rb` — encode/decode del token.
- Vistas de la API: `app/views/**/*.json.jbuilder`.
- Doc de la API generada de las anotaciones: **`/apipie`** (gem `apipie-rails`, `config/initializers/apipie.rb`, modo `validate=false`). Al tocar un endpoint, actualizar su bloque `api ... / param ...`.
- `config.api_only = false` (la app sirve API y, si hiciera falta, HTML).

## Frontend (`app/javascript/`)

Capas, dependencias hacia adentro — `pages → hooks → services → adapters → lib/http → API`:

| Carpeta | Contiene |
|---|---|
| `models/` | tipos de dominio (User, Session, Space, Reservation) |
| `services/` | lógica + llamadas a la API |
| `adapters/` | mapear respuesta jbuilder ⇄ model (fechas, enums, snake→camel) |
| `hooks/` | `useAuth`, `useSpaces`, … |
| `stores/` | estado global (sesión: user, token, rol) |
| `lib/` | `http` (axios + interceptor Bearer, manejo 401/403), config |
| `routes/` | rutas + guards por rol |
| `components/ui/` | **Base UI** envuelto · `components/<feature>/` |
| `pages/` | contenedores de ruta |

Estilado: **CSS Modules** (`*.module.css`). Componentes: **Base UI** (sin estilos).

## Pruebas

```bash
bin/rails test        # backend (Minitest)
pnpm check            # tsc del frontend
```

## Git y flujo de trabajo

Detalle completo en `docs/gitflow.md`. Resumen:

1. Rama **desde el issue**: `gh issue develop <N> --base dev --name feature/<ID>-<slug>`
2. En local: `git fetch origin && git switch feature/<ID>-<slug>`
3. Desarrollar.
4. **Commits = Conventional Commits**: `<tipo>(<scope>): <desc>` — tipos `feat|fix|refactor|test|docs|chore|ci|build`, scope `backend`/`frontend`/módulo (`spaces`, `auth`, `http`, …). Referencia al issue con `Refs #<N>` en el pie.
5. `git push -u origin <rama>` → `gh pr create --base dev --fill` (plantilla con DoD, `Closes #<N>`) → review → merge squash.

**Nunca** añadir `Co-authored-by` ni trailers de herramientas a los commits.

## Planificación

- Requisitos fuente: `docs/prd/` (el APF1 es el autoritativo).
- `docs/backlog.md` — Product Backlog HU01–HU10.
- `docs/sprint-1.md` — alcance y tareas del sprint en curso.
- `docs/frontend-architecture.md` — detalle de capas del front (pendiente, tarea #29).
- GitHub Project: https://github.com/users/Ryusse/projects/10 (campo `Iteración` = sprints; label `sprint:N`).

## Reglas para Claude

- No commitear sin que se pida explícitamente. Commits en Conventional Commits, con scope, **sin `Co-authored-by` ni trailers**.
- No empezar a desarrollar una issue sin antes: rama desde el issue → `git fetch` → `git switch` (ver `docs/gitflow.md`).
- Toda la ejecución de `rails`/`bundle`/`pnpm`/`vite` es en la máquina, no en Docker (Docker solo corre Postgres).
- Al añadir/cambiar un endpoint: ruta + controller (`< ApiController`) + jbuilder + anotación apipie + request spec.
- Respetar la dirección de dependencias del frontend; los componentes de `components/ui/` no llaman a `services`.
