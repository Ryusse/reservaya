---
name: nueva-migracion
description: Crear y aplicar una migración de base de datos en ReservaYa, con el esquema y las fixtures/anotaciones al día.
---

# Nueva migración

PostgreSQL corre en Docker (`docker compose up -d`); `rails` corre en el host.

## Pasos

1. **Generar**:
   ```bash
   bin/rails g migration <NombreDescriptivo> [campo:tipo ...]
   ```
   Nombres claros: `AddStatusToSpaces`, `CreateReservations`, `AddNoOverlapIndexToReservations`.

2. **Editar la migración** en `db/migrate/`:
   - Constraints en la BD cuando aporten (`null: false`, `add_check_constraint`, índices `unique: true`).
   - `add_index` para claves foráneas y búsquedas frecuentes.

3. **Aplicar**:
   ```bash
   bin/rails db:migrate
   bin/rails db:test:prepare   # deja la BD de test al día
   ```
   Se actualiza `db/schema.rb` (revisar el diff).

4. **Modelo**: añadir validaciones que reflejen las constraints (`presence`, `numericality`, `uniqueness`, validaciones custom). Refrescar el bloque `# == Schema Information` si el proyecto lo usa.

5. **Fixtures y tests**: ajustar `test/fixtures/*.yml` a las nuevas columnas/constraints (las fixtures saltan validaciones pero **no** las constraints de BD). Correr `bin/rails test`.

6. **Seeds**: si el dato nuevo es relevante para desarrollo, actualizar `db/seeds.rb` (idempotente, con `find_or_create_by!`).

## Notas

- No usar Docker para `rails`/`bundle` (solo para Postgres).
- Producción (Railway) corre `db:prepare` en el arranque del contenedor.
