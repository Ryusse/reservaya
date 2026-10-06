-- Cancela (status = 1) las reservas confirmadas de hoy en adelante de un usuario.
-- No borra filas. Muestra lo que cancela.
-- Parámetro: -v email=...
-- Uso: psql "$DATABASE_URL" -v email='persona@dominio.com' -f db/sql/maintenance/01_cancel_user_future_reservations.sql

\set ON_ERROR_STOP on

BEGIN;

UPDATE reservations r
SET status = 1, updated_at = now()
FROM users u
WHERE u.id = r.user_id AND u.email = lower(trim(:'email'))
  AND r.status = 0 AND r.date >= current_date
RETURNING r.id, r.space_id, r.date, r.start_time, r.end_time;

COMMIT;
