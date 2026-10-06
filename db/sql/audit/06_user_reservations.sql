-- Solo lectura. Historial de reservas de un usuario.
-- Parámetro: -v email=...
-- Uso: psql "$DATABASE_URL" -v email='persona@dominio.com' -f db/sql/audit/06_user_reservations.sql

SELECT r.id, r.date, r.start_time, r.end_time, s.name AS espacio, r.seats_reserved AS asientos,
       CASE r.status WHEN 0 THEN 'confirmed' WHEN 1 THEN 'cancelled' END AS estado,
       r.created_at
FROM reservations r
JOIN users  u ON u.id = r.user_id
JOIN spaces s ON s.id = r.space_id
WHERE u.email = lower(trim(:'email'))
ORDER BY r.date DESC, r.start_time DESC;
