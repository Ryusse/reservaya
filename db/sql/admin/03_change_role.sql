-- Cambia el rol de un usuario. role: 0 = user, 1 = admin.
-- Parámetros: -v email=... -v role=0|1
-- Uso: psql "$DATABASE_URL" -v email='persona@dominio.com' -v role=1 -f db/sql/admin/03_change_role.sql

\set ON_ERROR_STOP on

BEGIN;

SELECT set_config('ops.email', lower(trim(:'email')), true), set_config('ops.role', :'role', true);

DO $$
DECLARE
  v_email text := current_setting('ops.email');
  v_role  int  := current_setting('ops.role')::int;
BEGIN
  IF v_role NOT IN (0, 1) THEN RAISE EXCEPTION 'role debe ser 0 (user) o 1 (admin)'; END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = v_email) THEN
    RAISE EXCEPTION 'No existe un usuario con email %', v_email;
  END IF;
  -- No dejar el sistema sin administradores.
  IF v_role = 0
     AND (SELECT role FROM users WHERE email = v_email) = 1
     AND (SELECT count(*) FROM users WHERE role = 1) = 1 THEN
    RAISE EXCEPTION 'Es el único admin; no se puede degradar';
  END IF;
END $$;

UPDATE users SET role = :role, updated_at = now() WHERE email = lower(trim(:'email'));

SELECT id, email, name, role FROM users WHERE email = lower(trim(:'email'));

COMMIT;
