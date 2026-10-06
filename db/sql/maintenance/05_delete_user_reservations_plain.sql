-- BORRA (DELETE, sin vuelta atrás) las reservas de un usuario. SQL PLANO: sin variables de psql,
-- sirve pegado en cualquier cliente (Railway, DBeaver, TablePlus, pgAdmin...).
-- Equivale a 04_delete_user_reservations.sql, que solo funciona con psql.
--
-- Edita SOLO las dos líneas marcadas con <<< EDITAR:
--   email        -> correo del usuario (en minúsculas)
--   only_future  -> false = todas sus reservas | true = solo las de hoy y futuras
-- Para solo liberar cupo y conservar historial, usa mejor un UPDATE a status = 1 (cancelar).

-- 1) VER qué se borraría (ejecuta esto primero)
WITH params AS (
  SELECT 'usuario@correo.com'::text AS email,   -- <<< EDITAR
         false                      AS only_future  -- <<< EDITAR
)
SELECT r.id, r.date, r.start_time, r.end_time, s.name AS espacio, r.status
FROM reservations r
JOIN users  u ON u.id = r.user_id
JOIN spaces s ON s.id = r.space_id
CROSS JOIN params p
WHERE u.email = lower(trim(p.email))
  AND (NOT p.only_future OR r.date >= current_date)
ORDER BY r.date;

-- 2) BORRAR (repite aquí los mismos valores de arriba)
BEGIN;

WITH params AS (
  SELECT 'usuario@correo.com'::text AS email,   -- <<< EDITAR
         false                      AS only_future  -- <<< EDITAR
)
DELETE FROM reservations r
USING users u, params p
WHERE u.id = r.user_id
  AND u.email = lower(trim(p.email))
  AND (NOT p.only_future OR r.date >= current_date)
RETURNING r.id, r.space_id, r.date, r.start_time, r.end_time, r.status;

COMMIT;   -- para revisar sin borrar, cambia COMMIT por ROLLBACK
