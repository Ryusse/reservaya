-- Activa (0) o desactiva (1) un espacio. Desactivar NO cancela reservas existentes;
-- usa 03_cancel_space_reservations_on_date.sql o audit/07 (última sección) para revisarlas.
-- Parámetros: -v space_id=N -v status=0|1
-- Uso: psql "$DATABASE_URL" -v space_id=3 -v status=1 -f db/sql/maintenance/02_set_space_status.sql

\set ON_ERROR_STOP on

BEGIN;

SELECT set_config('ops.status', :'status', true);
DO $$
BEGIN
  IF current_setting('ops.status')::int NOT IN (0, 1) THEN RAISE EXCEPTION 'status debe ser 0 (active) o 1 (inactive)'; END IF;
END $$;

UPDATE spaces SET status = :status, updated_at = now() WHERE id = :space_id
RETURNING id, name, status;

COMMIT;
