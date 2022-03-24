-- 1. Create a Database
CREATE DATABASE animals;

-- 2. Create a Table
CREATE TABLE birds (
  id serial PRIMARY KEY,
  name varchar(25),
  age integer,
  species varchar(25)
);

-- 3. Insert Data
INSERT INTO birds (name, age, species)
VALUES ('Charlie', 3, 'Finch'),
       ('Allie', 5, 'Owl'),
       ('Jennifer', 3, 'Magpie'),
       ('Jamie', 4, 'Owl'),
       ('Roy', 8, 'Crow');

-- 4. Select Data
SELECT * FROM birds;

-- 5. WHERE Clause
SELECT * FROM birds WHERE age < 5;

-- 6. Update Data
UPDATE birds SET species='Raven' WHERE name='Roy';
UPDATE birds SET species='Hawk' WHERE name='Jamie';

-- 7. Delete Data
DELETE FROM birds WHERE species='Finch' AND age=3;

-- 8. Add Constraint
ALTER TABLE birds ADD CHECK (age >= 0);

INSERT INTO birds (name, age, species)
VALUES ('Peter', (-1), 'Duck');

-- 9. Drop Table
DROP TABLE birds;

-- 10. Drop Database
dropdb animals -- From command line
