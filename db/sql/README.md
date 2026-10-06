# db/sql — scripts SQL operativos

Scripts manuales para operar la base de datos desplegada. **Rails no los carga ni los ejecuta**
(solo lee `db/migrate`, `schema.rb` y `seeds.rb`). No reemplazan migraciones: el esquema se cambia
siempre con `db/migrate`.

## Cómo ejecutarlos

```bash
# DATABASE_URL = cadena de conexión de Postgres (Railway → servicio Postgres → Connect)
psql "$DATABASE_URL" -v email='nuevo@reservaya.local' -v name='Nombre' -v password='Password123' \
     -f db/sql/admin/01_create_admin.sql
```

- Los parámetros se pasan con `-v nombre=valor`; cada script lista los suyos en su cabecera.
- Los scripts de `audit/` son de **solo lectura** (`SELECT`). Los de `admin/`, `data/` y
  `maintenance/` modifican datos y van dentro de `BEGIN ... COMMIT`.
- Para probar sin persistir, cambia el `COMMIT;` final por `ROLLBACK;`.
- Antes de modificar producción: haz un backup y corre primero el equivalente de `audit/`.

## Valores de los enums (enteros en la BD)

| Tabla.columna | Valores |
|---|---|
| `users.role` | `0` user, `1` admin |
| `spaces.status` | `0` active, `1` inactive |
| `spaces.space_type` | `0` private_space, `1` shared_space |
| `reservations.status` | `0` confirmed, `1` cancelled |

## Gotchas

- **Email en minúsculas**: el login hace `downcase` del email; un usuario guardado con mayúsculas
  nunca podrá entrar. Los scripts aplican `lower()`.
- **Contraseñas**: `password_digest` es bcrypt. Los scripts usan `crypt(..., gen_salt('bf', 12))`
  de `pgcrypto` (Rails/bcrypt lo acepta, prefijo `$2a$`). Aquí se valida lo mismo que el modelo
  (6–64 caracteres, al menos una mayúscula y un número).
- **Timestamps**: `created_at`/`updated_at` son `NOT NULL` sin default; todo `INSERT` debe
  poner `now()`, y todo `UPDATE` debe refrescar `updated_at`.
- **Reglas del modelo que el SQL no aplica**: máx. 3 reservas activas por usuario, horizonte de
  7 días, solapes y capacidad. Insertar reservas a mano puede violarlas; usar la API cuando se pueda.

## Índice

| Carpeta | Script | Qué hace |
|---|---|---|
| `admin/` | `01_create_admin.sql` | Crea un admin (o promueve si el email ya existe) |
| | `02_create_user.sql` | Crea un usuario normal |
| | `03_change_role.sql` | Cambia el rol de un usuario (user ↔ admin) |
| | `04_reset_password.sql` | Resetea la contraseña de un usuario |
| `data/` | `01_create_space.sql` | Crea un espacio |
| | `02_seed_spaces_example.sql` | Carga de varios espacios de ejemplo (editable) |
| | `03_seed_reservations_wide_ranges.sql` | Reservas demo de 2–10 h para los próximos 7 días (solo usuarios `@reservaya.local`) |
| | `04_insert_spaces_simple.sql` | Inserta varios espacios (SQL plano, editable, idempotente por nombre) |
| `audit/` | `01_users_overview.sql` | Usuarios, roles y cantidad de reservas |
| | `02_admins.sql` | Lista de administradores |
| | `03_spaces_overview.sql` | Espacios con reservas totales/futuras |
| | `04_reservations_by_date.sql` | Reservas de una fecha, con usuario y espacio |
| | `05_occupancy_by_space.sql` | Ocupación por espacio en un rango de fechas |
| | `06_user_reservations.sql` | Historial de reservas de un usuario |
| | `07_integrity_checks.sql` | Detecta datos inválidos (solapes, fuera de horario, > 3 activas...) |
| | `08_cancellations.sql` | Cancelaciones por espacio y por usuario |
| `maintenance/` | `01_cancel_user_future_reservations.sql` | Cancela reservas futuras de un usuario |
| | `02_set_space_status.sql` | Activa/desactiva un espacio |
| | `03_cancel_space_reservations_on_date.sql` | Cancela las reservas de un espacio en una fecha |
| | `04_delete_user_reservations.sql` | **Borra** las reservas de un usuario (todas, o solo futuras con `only_future=1`) |
