-- 1. Create an Extrasolar Planetary Database
createdb extrasolar
psql -d extrasolar

CREATE TABLE stars (
  id serial PRIMARY KEY,
  name varchar(25) UNIQUE NOT NULL,
  distance integer NOT NULL CHECK (distance>0),
  spectral_type char(1),
  companions integer NOT NULL CHECK (companions>=0)
);

CREATE TABLE planets (
  id serial PRIMARY KEY,
  designation char(1) UNIQUE,
  mass integer
);


-- 2. Relating Stars and Planets
ALTER TABLE planets
  ADD COLUMN star_id integer NOT NULL REFERENCES stars(id);


-- 3. Increase Star Name Length
ALTER TABLE stars ALTER COLUMN name TYPE varchar(50);


-- 4. Stellar Distance Precision
ALTER TABLE stars ALTER COLUMN distance TYPE decimal;


-- 5. Check Values in List
ALTER TABLE stars ALTER COLUMN spectral_type SET NOT NULL;

ALTER TABLE stars ADD CHECK
  (spectral_type IN ('O', 'B', 'A', 'F', 'G', 'K', 'M'));

UPDATE stars SET spectral_type='K' WHERE name='Epsilon Eridani';
UPDATE stars SET spectral_type='M' WHERE name='Lacaille 9352';

-- 6. Enumerated Types
