-- Crea un usuario normal (role = 0). Falla si el email ya existe.
-- Parámetros: -v email=... -v name=... -v password=...
-- Uso: psql "$DATABASE_URL" -v email='persona@dominio.com' -v name='Persona' -v password='Clave123' -f db/sql/admin/02_create_user.sql

\set ON_ERROR_STOP on
CREATE EXTENSION IF NOT EXISTS pgcrypto;

BEGIN;

-- psql no interpola variables dentro de $$...$$, por eso se pasan con set_config.
SELECT set_config('ops.email', lower(trim(:'email')), true),
       set_config('ops.name', trim(:'name'), true),
       set_config('ops.password', :'password', true);

DO $$
DECLARE
  v_email text := current_setting('ops.email');
  v_name  text := current_setting('ops.name');
  v_pass  text := current_setting('ops.password');
BEGIN
  IF v_email !~ '^[^@\s]+@[^@\s]+\.[^@\s]+$' THEN RAISE EXCEPTION 'Email inválido: %', v_email; END IF;
  IF length(v_name) = 0 OR length(v_name) > 50 OR v_name ~ '[<>]' THEN RAISE EXCEPTION 'Nombre inválido'; END IF;
  IF length(v_pass) NOT BETWEEN 6 AND 64 OR v_pass !~ '[A-Z]' OR v_pass !~ '[0-9]' THEN
    RAISE EXCEPTION 'La contraseña debe tener 6-64 caracteres, una mayúscula y un número';
  END IF;
END $$;

INSERT INTO users (email, name, password_digest, role, created_at, updated_at)
VALUES (lower(trim(:'email')), trim(:'name'), crypt(:'password', gen_salt('bf', 12)), 0, now(), now());

SELECT id, email, name, role FROM users WHERE email = lower(trim(:'email'));

COMMIT;
