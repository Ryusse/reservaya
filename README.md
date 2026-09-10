# Reservaya

App de reservas de espacios. **Rails 8.1** (backend API + página Inertia) + **Vite / React / TypeScript** (frontend) + **PostgreSQL**.

- **Backend** y **frontend** corren en tu máquina con los scripts del template.
- **Docker se usa solo para PostgreSQL** (un contenedor). El backend se conecta a la BD por `localhost:5432`; no están acoplados.

---

## Requisitos

| Herramienta | Versión | Para qué |
|---|---|---|
| Ruby | `3.4.10` (ver `.ruby-version`) | Rails |
| Node.js | `>= 20` | Vite / React |
| pnpm | `>= 9` | dependencias del frontend |
| Docker Desktop | reciente | correr PostgreSQL |
| `libpq` (Homebrew) | — | compilar el gem `pg` |

### macOS — instalar `libpq` (necesario para el gem `pg`)

```bash
brew install libpq
bundle config build.pg --with-pg-config="$(brew --prefix libpq)/bin/pg_config"
```

`libpq` es *keg-only* (no se enlaza al PATH), por eso hay que decirle a bundler dónde está `pg_config`.

---

## Puesta en marcha (una sola vez)

```bash
# 1. Dependencias
bundle install
pnpm install

# 2. Base de datos (PostgreSQL en Docker)
docker compose up -d          # levanta el contenedor `postgres`
bin/rails db:prepare          # crea las BD y corre las migraciones

# 3. Usuario admin (rol 1) — necesario para los endpoints protegidos
bin/rails runner "User.create!(name: 'Admin', email: 'admin@test.com', password: 'secret123', role: 1)"
```

---

## Día a día

```bash
docker compose up -d          # PostgreSQL (si no está corriendo)

pnpm dev                      # Rails + Vite juntos (foreman)
#   Rails -> http://localhost:3100
#   Vite  -> http://localhost:3036
```

O por separado, en dos terminales:

```bash
pnpm backend                  # bin/rails server  -> http://localhost:3000
pnpm frontend                 # bin/vite dev      -> http://localhost:3036
```

Abre la app en el navegador según el puerto de Rails (`:3100` con `pnpm dev`, `:3000` con `pnpm backend`).

Apagar la base de datos:

```bash
docker compose down           # conserva los datos
docker compose down -v        # borra los datos (BD desde cero)
```

---

## Base de datos

`config/database.yml` apunta a `localhost` con estas credenciales (definidas en `compose.yml`):

| | |
|---|---|
| host | `localhost` (override: `DATABASE_HOST`) |
| port | `5432` (override: `DATABASE_PORT`) |
| user / password | `user` / `password` |
| BD desarrollo | `reservaya_development` |

Comandos útiles:

```bash
bin/rails db:migrate                 # aplicar migraciones nuevas
bin/rails db:migrate:status          # ver estado
bin/rails db:reset                   # drop + create + schema + seed
bin/rails console                    # consola
docker compose exec postgres psql -U user reservaya_development   # psql directo
```

---

## API — endpoints

Autenticación por **JWT**: `POST /session` devuelve un `token`; el resto de rutas requieren el header
`Authorization: Bearer <token>`.

| Método | Ruta | Auth |
|---|---|---|
| `POST` | `/session` | pública (login) |
| `DELETE` | `/session` | token |
| `POST` | `/users` | token + admin |
| `GET` | `/spaces` | token |
| `GET` | `/spaces/:id` | token |
| `POST` | `/spaces` | token + admin |
| `PATCH` | `/spaces/:id` | token + admin |
| `DELETE` | `/spaces/:id` | token + admin (soft delete) |
| `GET` | `/reservations` | token (las del usuario) |
| `POST` | `/reservations` | token |
| `PATCH` | `/reservations/:id` | token + dueño |
| `PATCH` | `/reservations/:id/cancel` | token + dueño |

Listar todas: `bin/rails routes`.

### Ejemplo

```bash
TOKEN=$(curl -s -X POST http://localhost:3000/session \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@test.com","password":"secret123"}' \
  | ruby -rjson -e 'puts JSON.parse(STDIN.read)["token"]')

curl -s http://localhost:3000/spaces -H "Authorization: Bearer $TOKEN"

curl -s -X POST http://localhost:3000/spaces \
  -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  -d '{"space":{"name":"Sala A","location":"Piso 2","capacity":10,"status":"active"}}'
```

---

## Estructura

| | |
|---|---|
| `app/controllers/api_controller.rb` | base de la API JSON (`ActionController::API` + auth JWT) |
| `app/controllers/{sessions,users,spaces,reservations}_controller.rb` | endpoints |
| `app/controllers/application_controller.rb` | base de la parte Inertia (`ActionController::Base`) |
| `app/controllers/inertia_controller.rb` | base de las páginas React/Inertia |
| `app/services/json_web_token.rb` | encode/decode del JWT |
| `app/javascript/` | frontend React/TypeScript (páginas en `pages/`) |
| `app/views/**/*.jbuilder` | serialización JSON de la API |

---

## Tests

```bash
bin/rails test
```

---

## Problemas comunes

**`A server is already running (pid: ...)`**
Quedó un proceso o pidfile viejo (típico al mezclar `pnpm dev` y `pnpm backend`):

```bash
rm -f tmp/pids/server.pid
# y si sigue: pkill -f puma
```

**`could not connect to server` / `PG::ConnectionBad`**
El contenedor de Postgres no está arriba:

```bash
docker compose up -d
docker compose ps          # `postgres` debe estar "healthy"
```

**`bundle install` falla en el gem `pg`**
Falta configurar `libpq` (ver sección Requisitos).
