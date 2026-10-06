-- Crea un espacio.
-- Parámetros: -v name=... -v location=... -v capacity=N -v start_time=HH:MM -v end_time=HH:MM
--             -v space_type=0|1 (0 privado, 1 compartido) -v status=0|1 (0 activo, 1 inactivo)
-- Uso: psql "$DATABASE_URL" -v name='Sala A' -v location='Piso 1' -v capacity=6 \
--        -v start_time=08:00 -v end_time=18:00 -v space_type=0 -v status=0 -f db/sql/data/01_create_space.sql

\set ON_ERROR_STOP on

BEGIN;

SELECT set_config('ops.capacity', :'capacity', true), set_config('ops.start_time', :'start_time', true),
       set_config('ops.end_time', :'end_time', true), set_config('ops.space_type', :'space_type', true),
       set_config('ops.status', :'status', true);

DO $$
BEGIN
  IF current_setting('ops.capacity')::int <= 0 THEN RAISE EXCEPTION 'capacity debe ser > 0'; END IF;
  IF current_setting('ops.end_time')::time <= current_setting('ops.start_time')::time THEN
    RAISE EXCEPTION 'end_time debe ser posterior a start_time';
  END IF;
  IF current_setting('ops.space_type')::int NOT IN (0, 1) THEN RAISE EXCEPTION 'space_type debe ser 0 o 1'; END IF;
  IF current_setting('ops.status')::int NOT IN (0, 1) THEN RAISE EXCEPTION 'status debe ser 0 o 1'; END IF;
END $$;

INSERT INTO spaces (name, location, capacity, start_time, end_time, space_type, status, created_at, updated_at)
VALUES (trim(:'name'), trim(:'location'), :capacity, :'start_time'::time, :'end_time'::time,
        :space_type, :status, now(), now());

SELECT id, name, location, capacity, start_time, end_time, space_type, status FROM spaces ORDER BY id DESC LIMIT 1;

COMMIT;
