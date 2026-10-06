-- Reservas de demo con rangos largos (2 a 10 h) para los próximos 7 días, en los espacios activos.
-- SQL plano: funciona en psql y en editores gráficos (sin variables).
--
-- Usa SOLO usuarios demo (email terminado en @reservaya.local, role = 0); no toca usuarios reales.
-- Respeta las reglas del modelo: máx. 3 reservas activas por usuario, sin cruces por usuario,
-- privados sin solape, compartidos sin exceder capacidad, dentro del horario del espacio.
-- Se puede re-ejecutar: agrega lo que aún quepa y omite lo que choque.
--
-- Uso: psql "$DATABASE_URL" -f db/sql/data/03_seed_reservations_wide_ranges.sql

BEGIN;

DO $$
DECLARE
  sp      record;
  slot    record;
  u       record;
  v_start time;
  v_end   time;
  v_seats int;
  v_date  date;
  v_ok    boolean;
  v_total int := 0;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM users WHERE email LIKE '%@reservaya.local' AND role = 0) THEN
    RAISE EXCEPTION 'No hay usuarios demo (@reservaya.local, role 0). Créalos con admin/02_create_user.sql o db/seeds.rb';
  END IF;

  -- Recorre primero los horarios y luego los espacios, para repartir las reservas entre todos
  -- los espacios aunque los usuarios demo se queden sin cupo.
  FOR slot IN
      SELECT * FROM (VALUES
        (1, '08:00'::time, '12:00'::time, 2),
        (1, '12:00'::time, '18:00'::time, 3),
        (2, '09:00'::time, '15:00'::time, 4),
        (2, '15:00'::time, '20:00'::time, 2),
        (3, '08:00'::time, '18:00'::time, 1),
        (4, '10:00'::time, '14:00'::time, 5),
        (5, '08:00'::time, '13:00'::time, 2),
        (6, '13:00'::time, '21:00'::time, 3)
      ) AS t(day_offset, s, e, seats)
  LOOP
    FOR sp IN SELECT * FROM spaces WHERE status = 0 ORDER BY id LOOP
      v_date  := current_date + slot.day_offset;
      v_start := greatest(slot.s, sp.start_time);
      v_end   := least(slot.e, sp.end_time);
      CONTINUE WHEN v_end <= v_start;
      v_seats := CASE WHEN sp.space_type = 0 THEN sp.capacity ELSE least(slot.seats, sp.capacity) END;

      -- ¿el espacio tiene lugar en ese intervalo?
      IF sp.space_type = 0 THEN
        v_ok := NOT EXISTS (SELECT 1 FROM reservations r WHERE r.space_id = sp.id AND r.date = v_date AND r.status = 0
                              AND r.start_time < v_end AND r.end_time > v_start);
      ELSE
        v_ok := coalesce((SELECT sum(r.seats_reserved) FROM reservations r WHERE r.space_id = sp.id AND r.date = v_date
                           AND r.status = 0 AND r.start_time < v_end AND r.end_time > v_start), 0) + v_seats <= sp.capacity;
      END IF;
      CONTINUE WHEN NOT v_ok;

      -- primer usuario demo con cupo (< 3 activas) y sin cruce ese día
      SELECT us.id INTO u
      FROM users us
      WHERE us.email LIKE '%@reservaya.local' AND us.role = 0
        AND (SELECT count(*) FROM reservations r WHERE r.user_id = us.id AND r.status = 0 AND r.date >= current_date) < 3
        AND NOT EXISTS (SELECT 1 FROM reservations r WHERE r.user_id = us.id AND r.status = 0 AND r.date = v_date
                          AND r.start_time < v_end AND r.end_time > v_start)
      ORDER BY (SELECT count(*) FROM reservations r WHERE r.user_id = us.id AND r.status = 0 AND r.date >= current_date), us.id
      LIMIT 1;
      CONTINUE WHEN u.id IS NULL;

      INSERT INTO reservations (user_id, space_id, date, start_time, end_time, seats_reserved, status, created_at, updated_at)
      VALUES (u.id, sp.id, v_date, v_start, v_end, v_seats, 0, now(), now());
      v_total := v_total + 1;
    END LOOP;
  END LOOP;

  RAISE NOTICE 'Reservas creadas: %', v_total;
END $$;

SELECT r.date, s.name AS espacio, r.start_time, r.end_time, r.seats_reserved AS asientos, u.email AS usuario
FROM reservations r JOIN spaces s ON s.id = r.space_id JOIN users u ON u.id = r.user_id
WHERE r.status = 0 AND r.date > current_date
ORDER BY r.date, s.name, r.start_time;

COMMIT;
