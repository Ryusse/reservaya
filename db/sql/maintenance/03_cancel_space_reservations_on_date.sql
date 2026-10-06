-- Cancela (status = 1) las reservas confirmadas de un espacio en una fecha (p. ej. mantenimiento).
-- Parámetros: -v space_id=N -v date=YYYY-MM-DD
-- Uso: psql "$DATABASE_URL" -v space_id=3 -v date=2026-10-10 -f db/sql/maintenance/03_cancel_space_reservations_on_date.sql

\set ON_ERROR_STOP on

BEGIN;

UPDATE reservations
SET status = 1, updated_at = now()
WHERE space_id = :space_id AND date = :'date'::date AND status = 0
RETURNING id, user_id, start_time, end_time;

COMMIT;
