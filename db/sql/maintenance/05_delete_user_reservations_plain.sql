-- BORRA (DELETE, sin vuelta atrás) TODAS las reservas de un usuario, por su id.
-- SQL plano: sirve pegado en cualquier cliente. Cambia el 1 por el id del usuario (2 sitios).
-- ¿No sabes el id? SELECT id, email FROM users WHERE email = 'correo@dominio.com';

-- 1) Ver qué se borraría
SELECT * FROM reservations WHERE user_id = 1;   -- <<< EDITAR id

-- 2) Borrar
DELETE FROM reservations WHERE user_id = 1;     -- <<< EDITAR id
