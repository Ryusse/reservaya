# ReservaYa — Backend API

API REST para el sistema de reserva y gestión de espacios universitarios **ReservaYa**, desarrollada con **Ruby on Rails 8** y **PostgreSQL 18**.

---

## 🛠️ Stack Tecnológico

- **Lenguaje / Framework:** Ruby 4.0 (vía contenedor Docker) / Ruby on Rails 8.1
- **Base de Datos:** PostgreSQL 18.6
- **Colas / Tareas:** Solid Queue (`reservaya_development_queue`)
- **Autenticación:** Sesión por cookie cifrada `httpOnly` (`reservaya_session`) con fallback a header `Authorization: Bearer` (JWT)
- **Pruebas:** RSpec / FactoryBot
- **Contenedores:** Docker & Docker Compose

---

## 🐳 Arquitectura Docker

El proyecto está configurado bajo el stack `reservaya-backend` en [compose.yml](compose.yml) con nombres fijos e identificables para evitar conflictos en Docker Desktop:

| Servicio | Nombre Contenedor | Puerto Host | Puerto Contenedor | Descripción |
|---|---|---|---|---|
| `api` | `reservaya-backend-api` | `3301` | `3000` | Entorno Rails (mantenido en espera para comandos interactivos) |
| `postgres` | `reservaya-backend-postgres` | `5436` | `5432` | Servidor PostgreSQL 18 |

> **Volumen de persistencia:** Los datos de Postgres se almacenan en el volumen nombrado `reservaya-backend_postgres`.

---

## 🚀 Cómo Levantar el Proyecto

### Opción A: Desde RubyMine (Flujo Recomendado)

1. **Levantar los contenedores de Docker:**
   ```bash
   docker compose up -d
   ```
   *(Verás en Docker Desktop el grupo `reservaya-backend` con ambos contenedores en verde).*

2. **Dar Play en RubyMine:**
   - En la barra superior, selecciona la configuración de ejecución compartida: **`Run Backend (Docker)`**.
   - Haz clic en **▶️ Play** (o `Control + R` / `Shift + F10`).
   - El script [`bin/dev-server`](bin/dev-server) se encargará automáticamente de:
     - Comprobar que Docker esté activo.
     - Limpiar cualquier residuo de `tmp/pids/server.pid` (para evitar el error *"A server is already running"*).
     - Iniciar Puma en el puerto `3301`.
   - Los logs aparecerán en vivo en la pestaña inferior **Run** de RubyMine.
   - Para detener el servidor, pulsa **⏹️ Stop** (cuadrado rojo).

---

### Opción B: Desde la Terminal

1. **Iniciar contenedores en segundo plano:**
   ```bash
   docker compose up -d
   ```

2. **Iniciar el servidor Rails:**
   ```bash
   ./bin/dev-server
   # O directamente:
   docker compose exec api bundle exec rails s -b 0.0.0.0
   ```

3. **Verificar estado:**
   - **Health Check:** [http://localhost:3301/up](http://localhost:3301/up) (debe devolver `200 OK`)
   - **Endpoint Base:** [http://localhost:3301](http://localhost:3301)

---

## 🗄️ Base de Datos y Migraciones

Rails 8 utiliza una configuración multi-base de datos en desarrollo:
- `primary`: `reservaya_development`
- `queue`: `reservaya_development_queue` (Solid Queue)

### Comandos de Base de Datos:
```bash
# Crear bases de datos (si es la primera vez)
docker compose exec api bundle exec rails db:create

# Ejecutar migraciones pendientes
docker compose exec api bundle exec rails db:migrate

# Cargar datos de prueba (seeds)
docker compose exec api bundle exec rails db:seed

# Ver estado de migraciones
docker compose exec api bundle exec rails db:migrate:status
```

### Conexión directa a PostgreSQL (desde el host):
- **Host:** `localhost`
- **Puerto:** `5436`
- **Usuario:** `user`
- **Contraseña:** `password`
- **Base de datos:** `reservaya_development`

---

## 🧪 Pruebas y Consola

```bash
# Ejecutar suite de pruebas (RSpec)
docker compose exec api bundle exec rspec

# Abrir consola interactiva de Rails
docker compose exec api bundle exec rails c

# Detener los contenedores
docker compose down
```

---

## 📝 Aprendizajes y Notas Técnicas Clave

1. **Error *"A server is already running" (server.pid)*:**
   Si el contenedor o el servidor se cierra abruptamente, queda un archivo residual en `tmp/pids/server.pid`. El script `bin/dev-server` lo limpia antes de iniciar, pero en caso manual se puede borrar con `rm -f tmp/pids/server.pid`.

2. **Solid Queue y error `ActiveRecord::NoDatabaseError`:**
   Al usar Rails 8 con Solid Queue en desarrollo, Rails espera la base de datos `reservaya_development_queue`. Si arroja error 500 en `/up`, se soluciona ejecutando `rails db:create`.

3. **Identificación en Docker Desktop:**
   El proyecto define explícitamente `name: reservaya-backend` y `container_name: reservaya-backend-*` en `compose.yml` para evitar colisiones con otros proyectos que tengan servicios `api` o `postgres`.
