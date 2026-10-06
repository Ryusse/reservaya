-- Solo lectura. Reservas de una fecha.
-- Parámetro opcional: -v date=YYYY-MM-DD (por defecto, hoy)
-- Uso: psql "$DATABASE_URL" -v date=2026-10-07 -f db/sql/audit/04_reservations_by_date.sql
\if :{?date} \else \set date `date +%F` \endif

SELECT r.id, r.date, r.start_time, r.end_time, s.name AS espacio, u.email AS usuario,
       r.seats_reserved AS asientos,
       CASE r.status WHEN 0 THEN 'confirmed' WHEN 1 THEN 'cancelled' END AS estado
FROM reservations r
JOIN spaces s ON s.id = r.space_id
JOIN users  u ON u.id = r.user_id
WHERE r.date = :'date'::date
ORDER BY s.name, r.start_time;
