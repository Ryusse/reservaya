# QA — Sprint 1

Ejecución de las pruebas funcionales del Sprint 1. Cada escenario indica resultado y evidencia
(request spec automatizado en `test/` y/o verificación manual contra el entorno local).

- **Entorno**: local — Rails `:3000`, PostgreSQL en Docker, seed cargado (`admin@test.com` / `user@test.com`, pass `secret123`).
- **CI**: `bin/rails test` (31 casos) + `pnpm check` + `pnpm lint` + `pnpm test` (10 casos) en verde — `.github/workflows/ci.yml`.

---

## HT-01 · Pruebas de acceso (#11)

| Escenario | Esperado | Resultado | Evidencia |
|---|---|---|---|
| Login OK | 200 + `{ token, user }` | ✅ | `POST /session` con credenciales del seed → 200; `RegistrationsControllerTest`/smoke |
| Credenciales inválidas | 401 `Correo o contraseña inválidos` | ✅ | `POST /session` con password errónea → 401 |
| Endpoint protegido sin token | 401 `No autenticado` | ✅ | `GET /spaces` sin header → 401 (`SpacesControllerTest#GET /spaces without token is unauthorized`) |
| Endpoint admin con rol `user` | 403 `No autorizado` | ✅ | `POST /spaces` con token de `user@test.com` → 403 (`SpacesControllerTest#POST /spaces as non-admin is forbidden`) |
| Guard de ruta en frontend | `user` no ve `/admin`; se le oculta la navegación admin | ✅ | `routes/_authed/admin.tsx` (`beforeLoad` redirige) · `lib/nav.navItemsForRole` (`nav.test.ts`) |

## HU01 · Registro de espacios (#14)

| Escenario | Esperado | Resultado | Evidencia |
|---|---|---|---|
| Registro exitoso | 201 + espacio creado, `status: active` | ✅ | `POST /spaces` (admin) → 201 (`SpacesControllerTest#POST /spaces creates a space as admin`) |
| Campos incompletos | 422 + `errors` | ✅ | `POST /spaces` con `{ name: "" }` → 422 (`...with missing fields returns 422`) |
| Capacidad ≤ 0 | 422 `Capacity must be greater than 0` | ✅ | `POST /spaces` con `capacity: 0` → 422 (`...with non-positive capacity returns 422`) |
| Horario inconsistente | 422 `End time debe ser después de la hora de inicio` | ✅ | `POST /spaces` con `start 20:00 / end 08:00` → 422 (`...end_time before start_time returns 422`) |
| Alta desde la UI | El espacio aparece en la tabla de `/admin/spaces` | ✅ | Form → `useCreateSpace` → invalida `['spaces']` |

## HU02 · Modificación de espacio (#17)

| Escenario | Esperado | Resultado | Evidencia |
|---|---|---|---|
| Editar | 200 + cambios persistidos | ✅ | `PATCH /spaces/:id` → 200 (`SpacesControllerTest#PATCH /spaces/:id updates a space as admin`) |
| Dar de baja | 200 + `status: inactive`, desaparece de `GET /spaces` | ✅ | `DELETE /spaces/:id` → 200; `GET /spaces` ya no lo lista (`...a deactivated space no longer appears in GET /spaces`) |
| Espacio inexistente | 404 `Recurso no encontrado` | ✅ | `PATCH`/`DELETE /spaces/99999` → 404 (`...on a missing space returns 404`) |
| Modificación inválida | 422, registro sin cambios | ✅ | `PATCH` con `capacity: 0` → 422 y `capacity` intacto (`...with invalid data returns 422 and keeps the record`) |
| Baja desde la UI | Confirmación en diálogo; tras confirmar el espacio sale de la tabla | ✅ | `DeactivateSpaceDialog` + `useDeactivateSpace` (invalida `['spaces']`) |

## HU03 · Registro de nuevo usuario (#20)

| Escenario | Esperado | Resultado | Evidencia |
|---|---|---|---|
| Registro exitoso | 201 + `{ token, user }`, `role: user` | ✅ | `POST /register` → 201, `role == "user"` (`RegistrationsControllerTest#creates a user with role user and returns a token`) |
| Rol `admin` en el payload | Se ignora, queda `user` | ✅ | `POST /register` con `role: "admin"` → usuario `user` (`...ignores an admin role in the payload`) |
| Datos inválidos | 422 (`name` vacío, password < 6) | ✅ | `POST /register` inválido → 422 (`...with invalid data returns 422`) |
| Email duplicado | 422 `Email ya está registrado` | ✅ | `POST /register` con email existente → 422 (`...duplicate email returns 422 with a clear message`) |
| Público (sin token) | 201 | ✅ | `POST /register` sin `Authorization` → 201 (`...is public (no token required)`) |
| **RNF04 — hash de contraseña** | `password_digest` es un hash bcrypt, no texto plano | ✅ | `User.find_by(email: "admin@test.com").password_digest` → `$2a$12$...`; `== "secret123"` es `false`; `authenticate("secret123")` OK |
| Auto-login en la UI | Tras registrarse queda logueado y en la home | ✅ | `useRegister` → `setSession(session)` + `navigate` |

---

## Resumen

| Historia / Habilitador | Escenarios | Resultado |
|---|---|---|
| HT-01 (#11) | 5 | ✅ |
| HU01 (#14) | 5 | ✅ |
| HU02 (#17) | 5 | ✅ |
| HU03 (#20) | 7 | ✅ |

Sin defectos abiertos. Los escenarios de API están cubiertos por request specs en `test/controllers/`
y se re-ejecutan en CI en cada PR a `dev`/`main`.
