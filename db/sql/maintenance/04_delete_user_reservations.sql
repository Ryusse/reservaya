-- Borra TODAS las reservas de un usuario, por su id. Cambia el 1 por el id (2 sitios).
-- ¿No sabes el id? SELECT id, email FROM users WHERE email = 'correo@dominio.com';

SELECT * FROM reservations WHERE user_id = 1;

DELETE FROM reservations WHERE user_id = 1;
