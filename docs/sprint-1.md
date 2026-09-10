# Sprint 1 — Fundamentos: espacios y usuarios

**Periodo:** 18/08/2026 – 08/09/2026 · **9 puntos**
**Objetivo (APF1 §9.1):** implementar la gestión inicial de espacios físicos y el registro de usuarios institucionales.

Alcance: **HT-01, HT-02, HT-03, HU01, HU02, HU03**. (HU04/HU05 = Sprint 2.)

Habilitadores (no son HU de producto, van primero — las HU dependen de ellos):
- **HT-01** — Autenticación y control de acceso (login, JWT, guard por rol, seed de admin).
- **HT-02** — Arquitectura y setup del frontend (capas clean-arch, Base UI + CSS Modules, router, store, http client).
- **HT-03** — Configuración del repositorio y flujo de trabajo (README ✓, plantillas ✓, CLAUDE.md ✓, gitflow, CI, skills).

---

## Decisiones de arquitectura

1. **Frontend desacoplado — CERRADA.** React SPA consume la API REST con `Authorization: Bearer`
   (RNF07 + prototipo en Vercel + API JWT del colega). Estructura por capas en `app/javascript/`
   (`models → services → adapters → hooks → stores → components/pages`). Estilado con CSS Modules,
   componentes con Base UI. Detalle en `docs/frontend-architecture.md` (tarea #29).

2. **Endpoint de auto-registro (HU03).**
   Hoy `POST /users` exige admin. Se añade `POST /register` público que crea usuario con
   rol `user` forzado. `POST /users` (admin) se mantiene para altas internas.

3. **`start_time` / `end_time` en Space: ¿obligatorios?** — pendiente confirmar con PO.
   El escenario 1 de HU01 los lista como datos a ingresar; hoy son opcionales.

---

## HT-01 · Autenticación y control de acceso (habilitador)

Las HU no incluyen una historia de login, pero HU01/HU02 la presuponen ("administrador
autenticado") y RNF04 la exige. Se implementa como habilitador, no como HU. Va primero.

- [ ] **[BE]** `db/seeds.rb`: 1 admin + 2-3 espacios de ejemplo
- [ ] **[BE]** `rescue_from ActiveRecord::RecordNotFound` en `ApiController` → 404 JSON consistente
- [ ] **[FE]** Pantalla Login (consume `POST /session`, guarda el JWT)
- [ ] **[FE]** Cliente HTTP con `Authorization: Bearer` + guard: 401 → Login
- [ ] **[FE]** Mostrar/ocultar UI de admin según `user.role`; manejar 403
- [ ] **[QA]** Login OK / credenciales inválidas / acceso sin token

Estado backend: `POST /session` y `require_login`/`require_admin` **ya existen** (`ApiController`).

---

## HU01 · Registro de espacios (3)

**Como** administrador de espacios, **necesito** registrar un espacio con nombre, capacidad,
ubicación y horario, **para** que los usuarios puedan reservarlo.

Escenarios: registro exitoso · datos obligatorios incompletos · capacidad ≤ 0 · horario inconsistente.
Cubre: RF01, RNF03.

- [ ] **[BE]** Validación de `start_time`/`end_time` presentes (si PO confirma) + request specs `POST /spaces` (4 escenarios) + anotación apipie
- [ ] **[FE]** Form "Nuevo espacio" con validación + listado del catálogo de espacios activos
- [ ] **[QA]** Prueba funcional de los 4 escenarios

Estado backend: `POST /spaces` (admin), modelo `Space` con `capacity > 0` y `end_time > start_time` **ya existen**.

---

## HU02 · Modificación de espacio (3)

**Como** administrador de espacios, **necesito** editar y/o dar de baja un espacio existente,
**para** que los usuarios no puedan reservarlo.

Escenarios: edición exitosa · dar de baja · espacio inexistente · modificación inválida.
Cubre: RF02, RNF03.

- [ ] **[BE]** 404 en espacio inexistente + request specs `PATCH`/`DELETE /spaces/:id` + apipie
- [ ] **[FE]** Editar espacio (form precargado) + "dar de baja" con confirmación (sale del listado)
- [ ] **[QA]** Prueba funcional de los 4 escenarios

Estado backend: `PATCH`/`DELETE /spaces/:id` (admin, soft-delete `status: inactive`) **ya existen**. Falta el 404.

---

## HU03 · Registro de nuevo usuario (3)

**Como** usuario no registrado, **necesito** registrarme como usuario institucional,
**para** poder reservar espacios.

Escenarios: registro exitoso · datos inválidos · credenciales ya registradas.
Cubre: RF07, RNF04 (hash).

- [ ] **[BE]** `RegistrationsController` + ruta `POST /register` (público, rol `user` forzado) + mensaje claro en email duplicado + request specs (3 escenarios) + apipie
- [ ] **[FE]** Pantalla Registro con validación; al terminar → login automático o redirect a Login
- [ ] **[QA]** 3 escenarios + verificar en BD que `password_digest` es hash (RNF04)

Estado backend: `User` con `has_secure_password` y email único/formato **ya existen**. Falta el endpoint público.

---

## Definition of Done (APF1 §5.1)

Cada tarea/HU se cierra cuando:
implementada y en repo · revisada por otro integrante (PR) · criterios verificados con pruebas ·
RNF aplicables considerados · disponible en entorno de pruebas · doc técnica (`/apipie`) actualizada.

## Demo de la Sprint Review

```
1. bin/rails db:seed                          -> existe un admin
2. Login como admin
3. Registrar un espacio                        (HU01)
4. Editarlo y darlo de baja                    (HU02)
5. Cerrar sesión -> registrarse como usuario nuevo -> entrar   (HU03)
```
