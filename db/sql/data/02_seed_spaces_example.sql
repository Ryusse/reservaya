-- Carga varios espacios de una vez. Edita la lista VALUES y ejecuta.
-- Es idempotente por nombre: no inserta un espacio cuyo nombre ya existe.
-- Columnas: name, location, capacity, start_time, end_time, space_type (0 privado, 1 compartido), status (0 activo, 1 inactivo)
-- Uso: psql "$DATABASE_URL" -f db/sql/data/02_seed_spaces_example.sql

\set ON_ERROR_STOP on

BEGIN;

INSERT INTO spaces (name, location, capacity, start_time, end_time, space_type, status, created_at, updated_at)
SELECT v.name, v.location, v.capacity, v.start_time::time, v.end_time::time, v.space_type, v.status, now(), now()
FROM (VALUES
  ('Sala Privada 1',    'Piso 1', 4,  '08:00', '18:00', 0, 0),
  ('Sala Privada 2',    'Piso 1', 6,  '08:00', '18:00', 0, 0),
  ('Sala de Estudio',   'Piso 2', 20, '08:00', '20:00', 1, 0),
  ('Coworking Abierto', 'Piso 3', 30, '07:00', '21:00', 1, 0)
) AS v(name, location, capacity, start_time, end_time, space_type, status)
WHERE NOT EXISTS (SELECT 1 FROM spaces s WHERE s.name = v.name);

SELECT id, name, location, capacity, start_time, end_time, space_type, status FROM spaces ORDER BY id;

COMMIT;
