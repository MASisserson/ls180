
-- DDL (Data Definition Language)

-- 1

CREATE TABLE stars (
  id serial PRIMARY KEY,
  "name" varchar(25) NOT NULL UNIQUE,
  distance integer NOT NULL CHECK (distance > 0),
  spectral_type char(1) CHECK (spectral_type ~ '^[OBAFGKM]{1}$'),
  companions integer NOT NULL CHECK (companions >= 0)
);

CREATE TABLE planets (
  id serial PRIMARY KEY,
  designation char(1) UNIQUE CHECK (designation ~ '^[a-z]{1}$'),
  mass integer
);

ALTER TABLE planets ADD UNIQUE (designation);

-- 2

ALTER TABLE planets
ADD COLUMN star_id integer NOT NULL REFERENCES stars(id);

-- 3.

ALTER TABLE stars
ALTER COLUMN "name" TYPE varchar(50);

-- 4. Stellar Distance Precision

ALTER TABLE stars
ALTER COLUMN distance TYPE numeric;

-- 5. Check Values in List

ALTER TABLE stars
ALTER COLUMN spectral_type SET NOT NULL;

-- Further Exploration: We run into an error. To fix it, we just have to UPDATE the data in that field to an appropriate value. Or just get rid of the rows entirely.

DELETE FROM stars WHERE id >= 3;

ALTER TABLE stars
ADD CHECK (spectral_type IN ('O', 'B', 'A', 'F', 'G', 'K', 'M')),
ALTER COLUMN spectral_type SET NOT NULL;

-- 6. Enumerated Types

ALTER TABLE stars DROP CONSTRAINT stars_spectral_type_check;

CREATE TYPE spec_type AS ENUM ('O', 'B', 'A', 'F', 'G', 'K', 'M');

ALTER TABLE stars
ALTER COLUMN spectral_type TYPE spec_type USING spectral_type::spec_type;

-- 7. Planetary Mass Precision

ALTER TABLE planets
  ALTER COLUMN mass TYPE numeric,
  ALTER COLUMN mass SET NOT NULL,
  ADD CHECK (mass > 0),
  ALTER COLUMN designation SET NOT NULL;

-- 8. Add a Semi-Major Axis Column

ALTER TABLE planets
  ADD COLUMN semi_major_axis numeric NOT NULL;

-- 9. Add a Moons Table

CREATE TABLE moons (
  id serial PRIMARY KEY,
  designation integer NOT NULL,
  semi_major_axis numeric CHECK (semi_major_axis > 0),
  mass numeric CHECK (mass > 0),
  planet_id integer NOT NULL REFERENCES planets(id)
);

ALTER TABLE moons ADD CHECK (designation > 0);

ALTER TABLE moons
  ADD COLUMN planet_id integer NOT NULL REFERENCES planets(id) ON DELETE CASCADE;


######################################################################

-- DML (Data Manipulation Language)

-- 1. Set Up Database

CREATE TABLE devices (
  id serial PRIMARY KEY,
  "name" text NOT NULL,
  created_at timestamp DEFAULT NOW()
);

CREATE TABLE parts (
  id serial PRIMARY KEY,
  part_number integer UNIQUE NOT NULL,
  device_id integer REFERENCES devices(id)
);

-- 2. Insert Data for Parts and Devices

INSERT INTO devices ("name") VALUES ('Accelerometer'), ('Gyroscope');

INSERT INTO parts (part_number, device_id)
  VALUES (5, 1),
         (6, 1),
         (7, 1),
         (30, 2),
         (31, 2),
         (32, 2),
         (33, 2),
         (34, 2),
         (50, NULL),
         (51, NULL),
         (52, NULL);

-- 3. INNER JOIN

SELECT devices.name, parts.part_number
  FROM devices
  JOIN parts ON devices.id = parts.device_id;

-- 4. SELECT part_number

SELECT * FROM parts WHERE part_number::text LIKE '3%';

SELECT * FROM parts WHERE CAST(part_number AS text) LIKE '3%';

-- 5. Aggregate Functions

SELECT devices.name, COUNT(parts.id)
  FROM devices
  JOIN parts ON devices.id = parts.device_id
  GROUP BY devices.name;

-- 6. ORDER BY 

SELECT devices.name, COUNT(parts.id)
  FROM devices
  JOIN parts ON devices.id = parts.device_id
  GROUP BY devices.name
  ORDER BY devices.name DESC;

-- 7. IS NULL and IS NOT NULL

SELECT part_number, device_id
  FROM parts
  WHERE device_id IS NOT NULL;

SELECT part_number, device_id
  FROM parts
  WHERE device_id IS NULL;


-- 8. Oldest Device

INSERT INTO devices (name) VALUES ('Magnetometer');
INSERT INTO parts (part_number, device_id) VALUES (42, 3);

SELECT "name"
  FROM devices
  ORDER BY created_at
  LIMIT 1;

-- 9. UPDATE device_id

UPDATE parts
  SET device_id = 1
  WHERE part_number = 33 OR part_number = 34;

-- Further Exploration: Set smallest part_number part to be associated with 'Gyroscope'

UPDATE parts
  SET device_id = 2
  WHERE part_number = 
    (SELECT MIN(part_number) FROM parts);



#######################################################################

-- Medium: Many to Many

-- 1. Set Up Database

CREATE TABLE customers (
  id serial PRIMARY KEY,
  "name" text NOT NULL,
  payment_token varchar(8)
    NOT NULL UNIQUE CHECK (payment_token ~ '^[A-Z]{8}$')
);

CREATE TABLE services (
  id serial PRIMARY KEY,
  "description" text NOT NULL,
  price numeric(10, 2) NOT NULL CHECK (price >= 0.00)
);

CREATE TABLE customers_services (
  id serial PRIMARY KEY,
  customer_id integer
    NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
  service_id integer
    NOT NULL REFERENCES services(id)
);

ALTER TABLE customers_services ADD UNIQUE (customer_id, service_id);

INSERT INTO customers (name, payment_token)
VALUES
  ('Pat Johnson', 'XHGOAHEQ'),
  ('Nancy Monreal', 'JKWQPJKL'),
  ('Lynn Blake', 'KLZXWEEE'),
  ('Chen Ke-Hua', 'KWETYCVX'),
  ('Scott Lakso', 'UUEAPQPS'),
  ('Jim Pornot', 'XKJEYAZA');

INSERT INTO services (description, price)
VALUES
  ('Unix Hosting', 5.95),
  ('DNS', 4.95),
  ('Whois Registration', 1.95),
  ('High Bandwidth', 15.00),
  ('Business Support', 250.00),
  ('Dedicated Hosting', 50.00),
  ('Bulk Email', 250.00),
  ('One-to-one Training', 999.00);

INSERT INTO customers_services (customer_id, service_id)
VALUES
  (1, 1), -- Pat Johnson/Unix Hosting
  (1, 2), --            /DNS
  (1, 3), --            /Whois Registration
  (3, 1), -- Lynn Blake/Unix Hosting
  (3, 2), --           /DNS
  (3, 3), --           /Whois Registration
  (3, 4), --           /High Bandwidth
  (3, 5), --           /Business Support
  (4, 1), -- Chen Ke-Hua/Unix Hosting
  (4, 4), --            /High Bandwidth
  (5, 1), -- Scott Lakso/Unix Hosting
  (5, 2), --            /DNS
  (5, 6), --            /Dedicated Hosting
  (6, 1), -- Jim Pornot/Unix Hosting
  (6, 6), --           /Dedicated Hosting
  (6, 7); --           /Bulk Email

-- 2. Get Customers With Services

SELECT DISTINCT c.* FROM customers AS c
  JOIN customers_services AS cs
    ON c.id = cs.customer_id;

-- 3. Get Customers With No Services

SELECT c.* FROM customers AS c
  LEFT JOIN customers_services AS cs
    ON c.id = cs.customer_id
  WHERE cs.id IS NULL;

-- Further Exploration: Query a result with all the customers without services and all the services without customers

SELECT c.*, s.* FROM customers AS c
  LEFT JOIN customers_services AS cs
    ON c.id = cs.customer_id
  FULL JOIN services AS s
    ON s.id = cs.service_id
  WHERE cs.id IS NULL;

-- 4. Get Services With No Customers

SELECT "description"
  FROM customers_services
  RIGHT JOIN services AS s
    ON service_id = s.id
  WHERE customer_id IS NULL;

-- 5. Services for each Customer

SELECT "name", STRING_AGG("description", ', ') AS "services"
  FROM customers
  LEFT JOIN customers_services
    ON customer_id = customers.id
  LEFT JOIN services
    ON service_id = services.id
  GROUP BY "name";


-- Further Exploration

SELECT CASE WHEN lag(customers.name)
                   OVER (ORDER BY customers.name) = 
                   customers.name
            THEN NULL
            ELSE customers.name
            END,
       services.description
FROM customers
LEFT OUTER JOIN customers_services
             ON customer_id = customers.id
LEFT OUTER JOIN services
             ON services.id = service_id;

-- 6. Services With At Least 3 Customers

SELECT "description", COUNT(service_id) AS amore
  FROM services
  JOIN customers_services
    ON service_id = services.id
  GROUP BY "description"
  HAVING COUNT(service_id) >= 3
  ORDER BY "description";

-- 7. Total Gross Income

SELECT sum(price) AS "gross"
  FROM services
  JOIN customers_services
    ON services.id = service_id;

-- 8. Add New Customer

INSERT INTO customers ("name", payment_token)
  VALUES ('John Doe', 'EYODHLCN');

INSERT INTO customers_services (customer_id, service_id)
  VALUES (7, 1),
         (7, 2),
         (7, 3);

-- 9. Hypothetically

-- Make a table containing only the JOINing of customers ahd products > $100

SELECT SUM(price)
  FROM services
  JOIN customers_services
    ON services.id = service_id
  JOIN customers
    ON customer_id = customers.id
  WHERE price > 100.00;

-- Multiply the number of current customers by the number total cost of big ticket items.
-- Cross join the customers table with a subquery of the services table containing items > $100 and sum the price column.

SELECT SUM(price)
  FROM customers
  CROSS JOIN (
    SELECT * FROM services WHERE price > 100.00
  ) AS expensive_services;

SELECT SUM(price)
  FROM customers
  CROSS JOIN services
  WHERE price > 100.00;

-- Further Exploration: Meal planning

-- 10. Deleting Rows

DELETE FROM customers WHERE "name" = 'Chen Ke-Hua';

SELECT "name", "description"
  FROM customers
  JOIN customers_services
    ON customers.id = customer_id
  JOIN services
    ON service_id = services.id;

ALTER TABLE customers_services
  DROP CONSTRAINT customers_services_service_id_fkey,
  ADD FOREIGN KEY (service_id) REFERENCES services(id) ON DELETE CASCADE;

DELETE FROM services WHERE "description" = 'Bulk Email';

#################################################################

-- Medium: Subqueries and MMore

-- 1. Set Up the Database using \copy

CREATE TABLE bidders (
  id serial
    PRIMARY KEY,
  "name" text
    NOT NULL
);

CREATE TABLE items (
  id serial
    PRIMARY KEY,
  "name" text NOT NULL,
  initial_price numeric(6, 2)
    NOT NULL CHECK (initial_price BETWEEN 0 AND 1000.01),
  sales_price numeric(6, 2)
    CHECK (sales_price BETWEEN 0 AND 1000.01)
);

CREATE TABLE bids (
  id serial
    PRIMARY KEY,
  bidder_id integer
    NOT NULL REFERENCES bidders(id) ON DELETE CASCADE,
  item_id integer
    NOT NULL REFERENCES items(id) ON DELETE CASCADE,
  amount numeric(6, 2)
    NOT NULL CHECK (amount BETWEEN 0 AND 1000.01)
);

CREATE INDEX bidder_item_idx ON bids (bidder_id, item_id);

\copy bidders FROM 'bidders.csv' WITH HEADER CSV

\copy items FROM 'items.csv' WITH HEADER CSV

\copy bids FROM 'bids.csv' WITH HEADER CSV

-- 2. Conditional Subqueries: IN

SELECT "name" AS "Bid on Items"
  FROM items
  WHERE id IN 
    (SELECT item_id FROM bids);

-- 3. Conditional Subqueries: NOT IN

SELECT "name" AS "Not Bid On"
  FROM items
  WHERE id NOT IN
    (SELECT item_id FROM bids);

-- 4. Conditional Subqueries: EXISTS

SELECT "name"
  FROM bidders
  WHERE EXISTS
    (SELECT 1 FROM bids WHERE bidders.id = bidder_id);

-- Further Exploration: Use a JOIN clause instead

SELECT DISTINCT "name"
  FROM bidders
  JOIN bids
    ON bidders.id = bidder_id;

-- 5. Query From a Virtual Table

-- Query largest number of bids from an individual bidder
-- get the max(count) of a query that found (bidder_id, count(id))

SELECT max(bids)
  FROM
    (SELECT bidder_id, count(id) AS "bids"
      FROM bids
      GROUP BY bidder_id) AS "bid count by bidder";

-- 6. Scalar Subqueries

SELECT "name",
       (SELECT count(item_id) FROM bids WHERE items.id = item_id)
  FROM items;

-- Further Exploration

SELECT "name", COUNT(item_id)
  FROM items
  LEFT JOIN bids
    ON items.id = item_id
  GROUP BY "name";

-- 7. Row Comparison

SELECT id
  FROM items
  WHERE ROW('Painting', 100.00, 250.00) =
        ROW("name", initial_price, sales_price);

-- 8. EXPLAIN

EXPLAIN SELECT name FROM bidders
WHERE EXISTS (SELECT 1 FROM bids WHERE bids.bidder_id = bidders.id);

-- 9. Comparing SQL Statemments

EXPLAIN ANALYZE SELECT MAX(bid_counts.count) FROM
  (SELECT COUNT(bidder_id) FROM bids GROUP BY bidder_id) AS bid_counts;

EXPLAIN ANALYZE SELECT COUNT(bidder_id) AS max_bid FROM bids
  GROUP BY bidder_id
  ORDER BY max_bid DESC
  LIMIT 1;



##################################################################

SELECT users.name AS "Admins"
  FROM users
  JOIN user_roles
    ON users.id = user_roles.user_id
  WHERE user_roles.role = 'Admin';
