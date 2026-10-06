-- Resetea la contraseña de un usuario.
-- Parámetros: -v email=... -v password=...
-- Uso: psql "$DATABASE_URL" -v email='persona@dominio.com' -v password='NuevaClave1' -f db/sql/admin/04_reset_password.sql

\set ON_ERROR_STOP on
CREATE EXTENSION IF NOT EXISTS pgcrypto;

BEGIN;

SELECT set_config('ops.email', lower(trim(:'email')), true), set_config('ops.password', :'password', true);

DO $$
DECLARE v_pass text := current_setting('ops.password');
BEGIN
  IF length(v_pass) NOT BETWEEN 6 AND 64 OR v_pass !~ '[A-Z]' OR v_pass !~ '[0-9]' THEN
    RAISE EXCEPTION 'La contraseña debe tener 6-64 caracteres, una mayúscula y un número';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = current_setting('ops.email')) THEN
    RAISE EXCEPTION 'No existe un usuario con ese email';
  END IF;
END $$;

UPDATE users
SET password_digest = crypt(:'password', gen_salt('bf', 12)), updated_at = now()
WHERE email = lower(trim(:'email'));

SELECT id, email, name, role, updated_at FROM users WHERE email = lower(trim(:'email'));

COMMIT;
