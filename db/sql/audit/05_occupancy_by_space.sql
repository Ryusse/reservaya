-- Solo lectura. Ocupación por espacio en un rango de fechas (solo reservas confirmadas).
-- Parámetros opcionales: -v from=YYYY-MM-DD -v to=YYYY-MM-DD (por defecto, últimos 30 días hasta hoy)
-- Uso: psql "$DATABASE_URL" -v from=2026-10-01 -v to=2026-10-31 -f db/sql/audit/05_occupancy_by_space.sql
\if :{?from} \else \set from `date -v-30d +%F 2>/dev/null || date -d '-30 days' +%F` \endif
\if :{?to}   \else \set to   `date +%F` \endif

SELECT s.id, s.name,
       count(r.id)                                                     AS reservas,
       coalesce(sum(r.seats_reserved), 0)                              AS asientos_reservados,
       round(coalesce(sum(extract(epoch FROM (r.end_time - r.start_time)) / 3600), 0)::numeric, 1) AS horas_reservadas,
       count(DISTINCT r.user_id)                                       AS usuarios_distintos
FROM spaces s
LEFT JOIN reservations r
       ON r.space_id = s.id AND r.status = 0 AND r.date BETWEEN :'from'::date AND :'to'::date
GROUP BY s.id
ORDER BY horas_reservadas DESC, s.name;
