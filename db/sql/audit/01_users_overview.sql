-- Solo lectura. Usuarios con su rol y cantidad de reservas.
SELECT u.id, u.email, u.name,
       CASE u.role WHEN 0 THEN 'user' WHEN 1 THEN 'admin' ELSE 'sin rol (' || coalesce(u.role::text, 'NULL') || ')' END AS role,
       count(r.id)                                    AS reservas_total,
       count(r.id) FILTER (WHERE r.status = 0 AND r.date >= current_date) AS reservas_activas,
       count(r.id) FILTER (WHERE r.status = 1)        AS canceladas,
       u.created_at
FROM users u
LEFT JOIN reservations r ON r.user_id = u.id
GROUP BY u.id
ORDER BY u.id;
