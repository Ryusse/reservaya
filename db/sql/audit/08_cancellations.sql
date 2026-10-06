-- Solo lectura. Cancelaciones por espacio y por usuario.

\echo '== Por espacio'
SELECT s.name, count(*) FILTER (WHERE r.status = 1) AS canceladas, count(*) AS total,
       round(100.0 * count(*) FILTER (WHERE r.status = 1) / nullif(count(*), 0), 1) AS pct_canceladas
FROM spaces s JOIN reservations r ON r.space_id = s.id
GROUP BY s.name ORDER BY canceladas DESC;

\echo '== Por usuario'
SELECT u.email, count(*) FILTER (WHERE r.status = 1) AS canceladas, count(*) AS total
FROM users u JOIN reservations r ON r.user_id = u.id
GROUP BY u.email HAVING count(*) FILTER (WHERE r.status = 1) > 0
ORDER BY canceladas DESC;
