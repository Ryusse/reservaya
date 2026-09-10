---
name: nuevo-endpoint
description: Añadir o modificar un endpoint de la API de ReservaYa con todas sus piezas — ruta, controlador, jbuilder, anotación apipie y request spec.
---

# Nuevo endpoint de la API

Cuando se añade o cambia un endpoint, **las cinco piezas van juntas** en el mismo PR.

## 1. Ruta — `config/routes.rb`

RESTful cuando se pueda (`resources`); rutas sueltas para acciones no-REST (`post "register", to: "registrations#create"`).

## 2. Controlador — `app/controllers/<x>_controller.rb`

- Hereda de `ApiController` (`ActionController::API`, JWT).
- Filtros: `before_action :require_login` / `:require_admin` según permisos.
- Éxito → `render :<accion>, status: :<code>`; error de validación → `render json: { errors: model.errors.full_messages }, status: :unprocessable_entity`.
- El 404 de `RecordNotFound` ya lo maneja `ApiController` (`{ error: "Recurso no encontrado" }`).

## 3. Vista — `app/views/<x>/<accion>.json.jbuilder`

Reusar parciales `_<recurso>.json.jbuilder`. Nada de lógica de negocio en la vista.

## 4. Anotación apipie (encima de la acción)

```ruby
api :POST, "/ruta", "Descripción corta"
header "Authorization", "Bearer <token>", required: true   # si requiere login
param :campo, String, required: true, desc: "..."
error code: 401, desc: "No autenticado"
error code: 403, desc: "No autorizado"
error code: 422, desc: "Errores de validación"
```

Si el controlador es nuevo, añadirlo a `config.api_controllers_matcher` en `config/initializers/apipie.rb`. Docs en `/apipie` (`validate = false`, solo documentación).

## 5. Request spec — `test/controllers/<x>_controller_test.rb`

`ActionDispatch::IntegrationTest`. Helper `auth_headers(user)` (en `test/test_helper.rb`) y `JSON_HEADERS` para las peticiones anónimas. Cubrir: éxito, datos inválidos (422), sin token (401), sin permiso (403), recurso inexistente (404) cuando aplique.

```bash
bin/rails test test/controllers/<x>_controller_test.rb
```
