-- 1. Set Up Database
createdb billing

CREATE TABLE customers (
  id serial PRIMARY KEY,
  name text NOT NULL,
  payment_token varchar(8) NOT NULL CHECK (payment_token ~ '^[A-Z]{8}$')
);

CREATE TABLE services (
  id serial PRIMARY KEY,
  description text NOT NULL,
  price numeric(10, 2) NOT NULL CHECK (price > 0.00)
);

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

CREATE TABLE customers_services (
  id serial PRIMARY KEY,
  customer_id integer REFERENCES customers(id) ON DELETE CASCADE,
  service_id integer REFERENCES services(id),
  UNIQUE (customer_id, service_id)
);

ALTER TABLE customers_services
ALTER COLUMN customer_id SET NOT NULL,
ALTER COLUMN service_id SET NOT NULL;

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
JOIN customer_services on c.id=customers_services.customer_id;

-- 3. Get Customers With No Services
SELECT DISTINCT c.* FROM customers AS c
LEFT JOIN customers_services on c.id = customers_services.customer_id
WHERE customers_services.customer_id IS NULL;

-- Further Exploration
SELECT DISTINCT c.*, s.* FROM customers AS c
FULL JOIN customers_services ON c.id = customers_services.customer_id
FULL JOIN services AS s ON customers_services.service_id = s.id
WHERE c.* IS NULL OR s.* IS NULL;

-- 4. Get Services With No Customers
SELECT DISTINCT s.description FROM customer_services AS c_s
RIGHT JOIN services AS s ON c_s.service_id = s.id
WHERE c_s.* IS NULL;

-- 5. Services for each Customer
SELECT c.name, string_agg(s.description, ', ') AS services
FROM customers AS c
FULL JOIN customers_services AS c_s ON c.id = c_s.customer_id
FULL JOIN services AS s ON c_s.service_id = s.id
GROUP BY c.id;

-- Further Exploration
SELECT c.name, string_agg(s.description, e'\n') AS services
FROM customers AS c
FULL JOIN customers_services AS c_s ON c.id = c_s.customer_id
FULL JOIN services AS s ON c_s.service_id = s.id
GROUP BY c.id;

SELECT "name" (CASE WHEN
              customers.name = lag(customers.name)
                                  OVER (ORDER BY customers.name)
            THEN NULL ELSE customers.name END),
       services.description
FROM customers
LEFT OUTER JOIN customers_services
             ON customer_id = customers.id
LEFT OUTER JOIN services
             ON services.id = service_id;

-- 6. Services With At Least 3 Customers

SELECT "description",
       count(c_s.customer_id)
  FROM services AS s
  JOIN customers_services AS c_s ON s.id = c_s.service_id
  GROUP BY "description"
  HAVING COUNT(c_s.customer_id) >= 3
  ORDER BY "description";

-- 7. Total Gross Income

SELECT SUM(price) AS gross
  FROM services
  JOIN customers_services AS c_s 
    ON services.id = c_s.service_id;

-- 8. Add New Customer

INSERT INTO customers ("name", payment_token)
VALUES ('John Doe', 'EYODHLCN');

INSERT INTO customers_services (customer_id, service_id)
VALUES (7, 1),
       (7, 2),
       (7, 3);

-- 9. Hypothetically

SELECT SUM(price)
  FROM services
  JOIN customers_services AS c_s
    ON services.id = c_s.service_id
  WHERE price >= 100.00;

SELECT SUM(price)
  FROM services
  CROSS JOIN customers
  WHERE price > 100;

-- Further Exploration:
-- Another use might be in determining the best possible combination of meals in a day to meet certain nutritional goals. Cross join to get all possible combinations of breakfast, lunch, and dinner, and select for the combos that meet your criteria.

-- 10. Deleting Rows

ALTER TABLE customers_services
DROP CONSTRAINT customer_services_service_id_fkey;

ALTER TABLE customers_services
ADD FOREIGN KEY (service_id) REFERENCES services(id) ON DELETE CASCADE;

DELETE FROM services WHERE "description"='Bulk Email';

DELETE FROM customers WHERE "name"='Chen Ke-Hua';
