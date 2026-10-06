-- Solo lectura. Administradores actuales.
SELECT id, email, name, created_at, updated_at FROM users WHERE role = 1 ORDER BY id;
