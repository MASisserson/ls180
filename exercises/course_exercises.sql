-- >Schema, Data, and SQL > 6. Working with a Single Table

-- 1. Write a SQL statement that will create the following table, people:
CREATE TABLE people (
  name text,
  age integer,
  occupation text
);

-- 2. Write SQL statements to insert the data shown in #1 into the table.
INSERT INTO people
VALUES ('Abby', 34, 'biologist'),
       ('Mu''nisah', 26, NULL),
       ('Mirabelle', 40, 'contractor');

-- 3. Write 3 SQL queries that can be used to retrieve the second row of the table shown in #1 and #2.
SELECT * FROM people LIMIT 1 OFFSET 1;

SELECT * FROM people WHERE age=26;

SELECT * FROM people WHERE occupation IS NULL;

-- 4. Write a SQL statement that will create a table named birds that can hold the following values:
CREATE TABLE birds (
  name text,
  length decimal(4,1),
  wingspan decimal(4,1),
  family text,
  extinct boolean
);

-- 5. Using the table created in #4, write the SQL statements to insert the data as shown in the listing.
INSERT INTO birds
VALUES ('Spotted Towhee', 21.6, 26.7, 'Emberizidae', false),
       ('American Robin', 25.5, 36.0, 'Turdidae', false),
       ('Greater Koa Finch', 19.0, 24.0, 'Fringillidae', true),
       ('Carolina Parakeet', 33.0, 55.8, 'Psittacidae', true),
       ('Common Kestrel', 35.5, 73.5, 'Falconidae', false);

-- 6. Write a SQL statement that finds the names and families for all birds that are not extinct, in order from longest to shortest(based on the length column's value).
SELECT name, family FROM birds
WHERE extinct=false
ORDER BY length DESC;

-- 7. Use SQL to determine the average, minimum, and maximum wingspan for the birds shown in the table.
SELECT round(avg(wingspan), 1) AS "average",
       min(wingspan) AS "minimum",
       max(wingspan) AS "maximum" FROM birds;

-- 8. Write a SQL statement to create the table shown below, menu_items:
CREATE TABLE menu_items (
  item text,
  prep_time int,
  ingredient_cost decimal(4,2),
  sales int,
  menu_price decimal(4,2)
);

-- 9. Write SQL statements to insert the data shown in #8 into the table:
INSERT INTO menu_items
VALUES ('omelette', 10, 1.50, 182, 7.99),
       ('tacos', 5, 2.00, 254, 8.99),
       ('oatmeal', 1, 0.50, 79, 5.99);

-- 10. Using the table and data from #8 and #9, write a SQL query to determine which menu item is the most profitable based on the cost of its ingredients, returning the name of the item and its profit.
SELECT item, (menu_price - ingredient_cost) as profit FROM menu_items
ORDER BY (menu_price - ingredient_cost) DESC
LIMIT 1;

-- 11. Write a SQL query to determine how profitable each item on the menu is based on the amount of time it takes to prepare one item. Assume that whoever is preparing the food is being paid $13 an hour. List the most profitable items first. Keep in mind that prep_time is represented in minutes and ingredient_cost and menu_price are in dollars and cents):
-- menu_price - (ingredient_cost + 13.0/60.0 * prep_time)
SELECT item, menu_price, ingredient_cost,
       round((13.0 / 60.0 * prep_time), 2) as labor,
       round((menu_price - (ingredient_cost + (13.0 / 60.0 * prep_time))), 2) as profit
  FROM menu_items
  ORDER BY profit DESC;

-- >Schema, Data, and SQL > 7. Loading Database Dumps

-- 1. Load a file into psql:
\i ~/path/to/file.psql

-- 2. Write a SQL statement that returns all rows in the films table.
SELECT * FROM films;

-- 3. Write a SQL statement that returns all rows in the films table with a title shorter than 12 letters.
SELECT * FROM films WHERE length(title) < 12;

-- 4. Write the SQL statements needed to add two additional columns to the films table: director, which will hold a director's full name, and duration, which will hold the length of the film in minutes:
ALTER TABLE films
ADD COLUMN director text,
ADD COLUMN duration int;

-- 5. Write SQL statements to update the existing rows in the database with values for the new columns:
UPDATE films
SET director='John MicTiernan', duration=132 WHERE title='Die Hard';

UPDATE films
SET director='Michael Curtiz', duration=102 WHERE title='Casablanca';

UPDATE films
SET director='Francis Ford Coppola', duration=113 WHERE title='The Conversation';

-- 6. Write SQL statements to insert the following data into the films table:
INSERT INTO films VALUES
('1984', 1956, 'scifi', 'Michael Anderson', 90),
('Tinker Tailor Soldier Spy', 2011, 'espionage',
 'Tomas Alfredson', 127),
('The birdcage', 1996, 'comedy', 'Mike Nichols', 118);

-- 7. Write a SQL statement that will return the title and age in years of each movie, with the newest movies listed first:
SELECT title, (EXTRACT("year" from current_date) - "year") as age FROM films
ORDER BY year DESC;

-- 8. Write a SQL statement that will return the title and duration of each movie longer than two hours, with the longest movies first.
SELECT title, duration FROM films
WHERE duration > 120
ORDER BY duration DESC;

-- 9. Write a SQL statement that returns the title of the longest film.
SELECT title FROM films
ORDER BY duration DESC
LIMIT 1;


--> Schema, Data, and SQL, More Single Table Queries

-- 1. Create a new database called residents using the POstresSQL command line tools.
createdb residents

-- 2. Load a file into the database
psql -d residents < residents_with_data.sql

-- 3. Write a SQL query to list the ten states with the most rows in the people table in descending order.
SELECT DISTINCT state, count(id) FROM people
GROUP BY state
ORDER BY count(id) DESC
LIMIT 10; 

-- 4. Write a SQL query that lists each domain used in an email address in the people table and how many people in the database have an email address containing that domain. Domains should be listed with the most popular first.
SELECT substr(email, strpos(email, '@') + 1), 
       count(id) FROM people
GROUP BY substr(email, strpos(email, '@') + 1)
ORDER BY count(id) DESC;

SELECT substr(email, strpos(email, '@') + 1, length(email))

-- 5. Write a SQL statement that will delete the person with ID 3399 from the people table.
DELETE FROM people WHERE id=3399;

-- 6. Write a SQL statement that will delete all users that are located in the state of California (CA)
DELETE FROM people WHERE state='CA';

-- 7. Write a SQL statement that will update the given_name values to be all uppercase for all users with an email address that contains teleworm.us.
UPDATE people
SET given_name=upper(given_name)
WHERE email LIKE '%teleworm.us%';

-- 8. Write a SQL statement that will delete all rows from the people table.
DELETE FROM people;

-- > Schema, Data, and SQL > NOT NULL and Default Values

-- 1. What is the result of using an operator on a NULL value?
-- NULL will be returned, which signifies the absence of a value.

-- 2. Set the default value of column department to "unassigned". Then set the value of the department column to "unassigned" for any rows where it has a NULL value. Finally, add a NOT NULL constraint to the department column.
ALTER TABLE employees ALTER COLUMN department SET DEFAULT 'unassigned';

UPDATE employees SET department='unassigned' WHERE department IS NULL;

ALTER TABLE employees ALTER COLUMN department SET NOT NULL;

-- 3. Write the SQL statement to create a table called temperatures to hold the following data:
CREATE TABLE temperatures (
  date date NOT NULL,
  low int NOT NULL,
  high int NOT NULL
);

-- 4. Write the SQL statements needed to insert the data shown in #3 into the temperatures table.
INSERT INTO temperatures VALUES
('2016-03-01', 34, 43),
('2016-03-02', 32, 44),
('2016-03-03', 31, 47),
('2016-03-04', 33, 42),
('2016-03-05', 39, 46),
('2016-03-06', 32, 43),
('2016-03-07', 29, 32),
('2016-03-08', 23, 31),
('2016-03-09', 17, 28);

-- 5. Write a SQL statement to determine the average (mean) temperature -- divide the sum of the high and low temperatures by two) for each day from March 2, 2016 through March 8, 2016. Make sure to round each average value to one decimal place.
SELECT date, round((high + low) / 2.0, 1) as average FROM temperatures
WHERE EXTRACT(days from date) > '01' AND
      EXTRACT(days from date) < '09';

-- or

SELECT date, ROUND((high + low) / 2.0, 1) as average
  FROM temperatures
  WHERE date BETWEEN '2016-03-02' AND '2016-03-08';

-- 6. Write a SQL statement to add a new column, rainfall, to the temperatures table. It should store millimeters of rain as integers and have a default value of 0.
ALTER TABLE temperatures ADD COLUMN rainfall int DEFAULT 0;

-- 7. Each day, it rains one millimeter for every degree the average temperature goes above 35. Write a SQL statement to update the data in the table temperatures to reflect this.
UPDATE temperatures
SET rainfall = ((high + low) / 2) - 35
WHERE ((high + low) / 2) > 35;

-- 8. A decision has been made to store rainfall data in inches. Write the SQL statements required to modify the rainfall column to reflect these new requirements.
ALTER TABLE temperatures
ALTER COLUMN rainfall SET DATA TYPE decimal(6,3);

UPDATE temperatures SET rainfall=(rainfall * 0.039);

-- 9. Write a SQL statement that renames the temperatures table to weather.
ALTER TABLE temperatures RENAME TO weather;

-- 11. What PostgreSQL program can be used to create a SQL file that contains the SQL commands needed to recreate the current structure and data of the weather table?
pg_dump -d sql_course -t weather --inserts > dump.sql
