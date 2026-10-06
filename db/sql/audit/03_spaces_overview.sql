-- Solo lectura. Espacios con sus reservas totales, activas (futuras confirmadas) y canceladas.
SELECT s.id, s.name, s.location, s.capacity,
       CASE s.space_type WHEN 0 THEN 'private' WHEN 1 THEN 'shared' END AS tipo,
       CASE s.status     WHEN 0 THEN 'active'  WHEN 1 THEN 'inactive' END AS estado,
       s.start_time, s.end_time,
       count(r.id)                                                        AS reservas_total,
       count(r.id) FILTER (WHERE r.status = 0 AND r.date >= current_date) AS reservas_activas,
       count(r.id) FILTER (WHERE r.status = 1)                            AS canceladas
FROM spaces s
LEFT JOIN reservations r ON r.space_id = s.id
GROUP BY s.id
ORDER BY s.id;
