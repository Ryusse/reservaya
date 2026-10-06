-- Solo lectura. Cada consulta debería devolver 0 filas; si devuelve algo, hay datos que violan
-- reglas del modelo (típicamente por inserts manuales).

\echo '== Usuarios sin rol o con email con mayúsculas / duplicado ignorando mayúsculas'
SELECT id, email, role FROM users
WHERE role IS NULL OR email <> lower(email)
   OR lower(email) IN (SELECT lower(email) FROM users GROUP BY lower(email) HAVING count(*) > 1);

\echo '== Espacios con horario inválido o capacidad <= 0 o sin estado'
SELECT id, name, start_time, end_time, capacity, status FROM spaces
WHERE start_time IS NULL OR end_time IS NULL OR end_time <= start_time
   OR capacity IS NULL OR capacity <= 0 OR status IS NULL;

\echo '== Reservas fuera del horario del espacio o con hora fin <= inicio'
SELECT r.id, r.date, r.start_time, r.end_time, s.name, s.start_time AS espacio_desde, s.end_time AS espacio_hasta
FROM reservations r JOIN spaces s ON s.id = r.space_id
WHERE r.end_time <= r.start_time OR r.start_time < s.start_time OR r.end_time > s.end_time;

\echo '== Reservas que exceden la capacidad del espacio'
SELECT r.id, s.name, r.seats_reserved, s.capacity
FROM reservations r JOIN spaces s ON s.id = r.space_id
WHERE r.seats_reserved > s.capacity OR r.seats_reserved <= 0;

\echo '== Espacios privados con reservas confirmadas solapadas'
SELECT a.id AS reserva_a, b.id AS reserva_b, s.name, a.date, a.start_time, a.end_time, b.start_time, b.end_time
FROM reservations a
JOIN reservations b ON b.space_id = a.space_id AND b.date = a.date AND b.id > a.id
                   AND a.start_time < b.end_time AND a.end_time > b.start_time
JOIN spaces s ON s.id = a.space_id
WHERE s.space_type = 0 AND a.status = 0 AND b.status = 0;

\echo '== Espacios compartidos que superan su capacidad en algún instante (por inicio de reserva)'
SELECT s.name, a.date, a.start_time, sum(b.seats_reserved) AS ocupados, s.capacity
FROM reservations a
JOIN spaces s ON s.id = a.space_id AND s.space_type = 1
JOIN reservations b ON b.space_id = a.space_id AND b.date = a.date AND b.status = 0
                   AND b.start_time <= a.start_time AND b.end_time > a.start_time
WHERE a.status = 0
GROUP BY s.name, s.capacity, a.date, a.start_time
HAVING sum(b.seats_reserved) > s.capacity;

\echo '== Usuarios con más de 3 reservas activas (confirmadas, hoy o futuras)'
SELECT u.email, count(*) AS activas
FROM reservations r JOIN users u ON u.id = r.user_id
WHERE r.status = 0 AND r.date >= current_date
GROUP BY u.email HAVING count(*) > 3;

\echo '== Usuarios con reservas confirmadas cruzadas el mismo día'
SELECT a.user_id, a.date, a.id AS reserva_a, b.id AS reserva_b
FROM reservations a
JOIN reservations b ON b.user_id = a.user_id AND b.date = a.date AND b.id > a.id
                   AND a.start_time < b.end_time AND a.end_time > b.start_time
WHERE a.status = 0 AND b.status = 0;

\echo '== Reservas confirmadas sobre espacios inactivos (hoy o futuras)'
SELECT r.id, r.date, s.name FROM reservations r JOIN spaces s ON s.id = r.space_id
WHERE r.status = 0 AND s.status = 1 AND r.date >= current_date;
