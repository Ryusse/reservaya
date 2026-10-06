-- BORRA (DELETE, sin vuelta atrás) las reservas de un usuario. Para solo liberar cupo y conservar
-- historial, usa mejor 01_cancel_user_future_reservations.sql.
-- Parámetros: -v email=...  [-v only_future=1]  (con only_future=1 borra solo hoy y futuras)
-- Uso: psql "$DATABASE_URL" -v email='persona@dominio.com' -f db/sql/maintenance/04_delete_user_reservations.sql
--      psql "$DATABASE_URL" -v email='persona@dominio.com' -v only_future=1 -f db/sql/maintenance/04_delete_user_reservations.sql
-- Para revisar antes de confirmar, cambia el COMMIT final por ROLLBACK.

\set ON_ERROR_STOP on
\if :{?only_future} \else \set only_future 0 \endif

BEGIN;

DELETE FROM reservations r
USING users u
WHERE u.id = r.user_id AND u.email = lower(trim(:'email'))
  AND (:only_future = 0 OR r.date >= current_date)
RETURNING r.id, r.space_id, r.date, r.start_time, r.end_time, r.status;

COMMIT;
