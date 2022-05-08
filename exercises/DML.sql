-- 1. Set Up Database
createdb workshop

psql workshop

CREATE TABLE devices (
  id serial PRIMARY KEY,
  name text NOT NULL,
  created_at timestamp DEFAULT now()
);

CREATE TABLE parts (
  id serial PRIMARY KEY,
  part_number integer UNIQUE NOT NULL,
  device_id integer REFERENCES devices(id)
);

-- 2. Insert Data for Parts and Devices
INSERT INTO devices (name) VALUES ('Accelerometer'), ('Gyroscope');
INSERT INTO parts (part_number, device_id)
VALUES (1, 1),
       (2, 1),
       (3, 1),
       (4, 2),
       (5, 2),
       (6, 2),
       (7, 2),
       (8, 2);
INSERT INTO parts (part_number) VALUES (9), (10), (11);

-- 3. INNER JOIN
SELECT devices.name, parts.part_number FROM devices
JOIN parts on devices.id = parts.device_id;

-- 4. SELECT part_number
SELECT * FROM parts
WHERE LEFT(CAST(part_number AS text), 1) LIKE '3';

-- 5. Aggregate Functions
SELECT devices.name, count(parts.id) FROM devices
LEFT JOIN parts on devices.id = parts.device_id
GROUP BY devices.name;

-- 6. ORDER BY
SELECT devices.name, count(parts.id) FROM devices
LEFT JOIN parts on devices.id = parts.device_id
GROUP BY devices.name
ORDER BY name DESC;

-- 7. IS NULL and IS NOT NULL
SELECT part_number, device_id FROM parts WHERE device_id IS NOT NULL;

SELECT part_number, device_id FROM parts WHERE device_id IS NULL;

-- 8. Oldest Device
SELECT name FROM devices
ORDER BY age(created_at) DESC
LIMIT 1;

-- 9. UPDATE device_id
UPDATE parts SET device_id=1
WHERE part_number=7 OR part_number=8;

-- 10. Delete Accelerometer
ALTER TABLE parts
DROP CONSTRAINT parts_device_id_fkey;

ALTER TABLE parts
ADD FOREIGN KEY (device_id) REFERENCES devices(id)
ON DELETE CASCADE;

DELETE FROM devices
WHERE name='Accelerometer';

