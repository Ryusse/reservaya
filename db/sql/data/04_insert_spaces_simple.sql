-- Inserta espacios. SQL plano: se puede pegar en cualquier cliente (psql, DBeaver, Railway...).
-- Edita la lista de abajo (una fila = un espacio) y ejecútalo. Si el nombre ya existe, lo omite.
--
-- Columnas:  nombre, ubicación, capacidad, hora inicio, hora fin, tipo, estado
-- tipo:      0 = privado (se reserva completo)   1 = compartido (se reserva por cupos)
-- estado:    0 = activo                          1 = inactivo

INSERT INTO spaces (name, location, capacity, start_time, end_time, space_type, status, created_at, updated_at)
SELECT v.name, v.location, v.capacity, v.start_time::time, v.end_time::time, v.space_type, v.status, now(), now()
FROM (VALUES
  -- nombre,                 ubicación,           cap, inicio,  fin,     tipo, estado
  ('Sala de Juntas A',       'Edificio 1 - Piso 1',  8, '08:00', '18:00', 0, 0),
  ('Sala de Juntas B',       'Edificio 1 - Piso 1', 12, '08:00', '18:00', 0, 0),
  ('Cabina Individual 1',    'Edificio 1 - Piso 2',  1, '07:00', '21:00', 0, 0),
  ('Cabina Individual 2',    'Edificio 1 - Piso 2',  1, '07:00', '21:00', 0, 0),
  ('Laboratorio de Cómputo', 'Edificio 2 - Piso 1', 30, '08:00', '20:00', 1, 0),
  ('Biblioteca - Sala Silenciosa', 'Biblioteca',    40, '07:00', '22:00', 1, 0),
  ('Coworking Terraza',      'Edificio 2 - Terraza', 20, '08:00', '19:00', 1, 0),
  ('Auditorio Pequeño',      'Edificio 3 - Piso 1', 60, '09:00', '17:00', 1, 0)
) AS v(name, location, capacity, start_time, end_time, space_type, status)
WHERE NOT EXISTS (SELECT 1 FROM spaces s WHERE s.name = v.name);

-- Ver cómo quedó
SELECT id, name, location, capacity, start_time, end_time,
       CASE space_type WHEN 0 THEN 'privado' ELSE 'compartido' END AS tipo,
       CASE status WHEN 0 THEN 'activo' ELSE 'inactivo' END AS estado
FROM spaces ORDER BY id;
