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

-- > Schema, Data, and SQL > 10. More Constraints

--> 1. Import a file.
\i file/path/films2.sql

-- 2. Modify all the columns to be NOT NULL
ALTER TABLE films
ALTER title SET NOT NULL,
ALTER year SET NOT NULL,
ALTER genre SET NOT NULL,
ALTER director SET NOT NULL,
ALTER duration SET NOT NULL;

-- 3. How does modifying a column to be NOT NULL affect how it is displayed by \d films?
-- not null will be displayed in the Nullable column.

-- 4. Add a constraint to the table films that ensures that all films have a unique title.
ALTER TABLE films ADD UNIQUE (title);

-- 5. How is the constraint added in #4 displayed by \d films?
-- It is displayed under the table, under the "Indexes" as "films_title_key" UNIQUE CONSTRAINT, btree (title)

-- 6. Write a SQL statement to remove the constraint added in #4.
ALTER TABLE films DROP CONSTRAINT films_title_key;

-- 7. Add a constraint to films that requires all rows to have a value for title that is at least 1 character long.
ALTER TABLE films ADD CHECK (length(title) > 0);

-- 8. What error is shown if the constraint created in #7 is violated? Write a SQL INSERT startement that demonstrates this.
INSERT INTO films VALUES ('', 1992, 'horror', 'Jimmy', 30);
-- ERROR: new row for relation "films" violates check constraint "films_title_check"
-- DETAIL: Failing row contains (, 1992, horror, Jimmy, 30)

-- 9. How is the constraint added in #7 displayed by \d films?
-- Check constraints:
--    "films_title_check" CHECK (length(title::text) > 0)

-- 10. Write a SQL statement to remove the constraint added in #7.
ALTER TABLE films DROP CONSTRAINT films_title_check;

-- 11. Add a constraint to the table films that ensures that all films have a year between 1900 and 2100.
ALTER TABLE films ADD CHECK (year BETWEEN 1900 AND 2100);

-- 12. How is the constraint added in #11 displayed by \d films?
-- Check constraints:
--    "films_year_check" CHECK (year >= 1900 AND year <= 2100)

-- 13. Add a constraint to films that requires all rows to have a value for director that is at least 3 characters long and contains at least one space character ( ).
ALTER TABLE films
ADD CHECK (length(director)>=3 AND director LIKE '% %');

-- 14. How does the constraint created in #13 appear in \d films?
-- Check constraints:
--    "films_director_check" CHECK (length(director::text) >= 3 AND director::text ~~ '% %'::text)

-- 15. Write an UPDATE statement that attempts to change the director for "Die Hard" to "Johnny". Show the error that occurs when this statement is executed.
UPDATE films SET director='Johnny' WHERE title='Die Hard';

-- ERROR:  new row for relation "films" violates check constraint "films_director_check"
-- DETAIL:  Failing row contains (Die Hard, 1988, action, Johnny, 132).

-- 16. List three ways to use the schema to restrict what values can be stored in a column.
--    1. Setting the data type
--    2. NOT NULL constraint
--    3. Check Constraint

-- 17. Is it possible to define a default value for a column that will be considered invalid by a constraint? Create a table that tests this. 
-- I imagine so. In fact, yes. However, if the table attempts to use the default value, an error is thrown because the value violates the ocnstriant.

CREATE TABLE default_test (
  value int CHECK (value <> 0)
);

ALTER TABLE default_test ALTER COLUMN value SET DEFAULT 0;

-- > Schema, Data, and SQL > Using Keys

-- 1. Write a SQL statement that makes a new sequence called "counter".
CREATE SEQUENCE counter;

-- 2. Write a SQL statement to retrieve the next value from the sequence created in #1.
SELECT nextval('counter');

-- 3. Write a SQL statement that removes a sequence called "counter".
DROP SEQUENCE counter;

-- 4. Is it possible to create a sequence that returns only even numbers?
-- Yes. You can use the increment parameter, set to 2, to move from 0 up through the even numbers.
CREATE SEQUENCE even_counter INCREMENT BY 2 START WITH 2;
SELECT nextval('even_counter');
SELECT nextval('even_counter');

-- 5. What will the name of the sequence created by the following SQL statement be?

CREATE TABLE regions (id serial PRIMARY KEY, name text, area integer);

-- regions_id_seq

-- 6. Write a SQL statement to add an auto-incrementing integer primary key column to the films table. 

ALTER TABLE films ADD COLUMN id serial PRIMARY KEY;

-- 7. What error do you receive if you attempt to update a row to have a value for id that is used by another row?

ERROR:  duplicate key value violates unique constraint "films_pkey"
DETAIL:  Key (id)=(2) already exists.

-- 8. What error do you receive if you attempt to add another primary key column to the films table?

ERROR:  multiple primary keys for table "films" are not allowed

-- 9. Write a SQL statement that modifies the table films to remove its primary key while preserving the id column and the values it contains.

ALTER TABLE films DROP CONSTRAINT films_pkey;

-- > Schema, Data, and SQL > 12. GROUP BY and Aggregate

-- 1. Import file

-- 2. Write SQL statements that will insert the following films into the database:
INSERT INTO films (title, year, genre, director, duration) VALUES
('Wayne''s World', 1992, 'comedy', 'Penelope Spheeris', 95),
('Bourne Identity', 2002, 'espionage', 'Doug Liman', 118);

-- 3. Write a SQL query that lists all genres for which there is a movie in the films table.
SELECT DISTINCT genre FROM films;

-- 4. Write a SQL query that returns the same results as the answer for #3, but without using DISTINCT.
SELECT genre FROM films GROUP BY genre;

-- 5. Write a SQL query that determines the average duration across all the movies in the films table, rounded to the nearest minute.
SELECT round(avg(duration)) FROM films;

-- 6. Write a SQL query that determines the average duration for each genre in the films table, rounded to the nearest minute.
SELECT genre, round(avg(duration)) AS average_duration
FROM films
GROUP BY genre;

-- 7. Write a SQL query that determines the average duration of movies for each decade represented in the films table, rounded to the nearest minute and listed in chronological order. 

SELECT round(year, -1) as decade, round(avg(duration)) AS avg_duration
FROM films
GROUP BY decade
ORDER BY decade;

-- 8. Write a SQL query that finds all films whose director has the first name John.

SELECT * FROM films WHERE director LIKE 'John %';

-- 9. Write a SQL query that will return the following data:

SELECT genre, count(id) FROM films
GROUP BY genre
ORDER BY count(id) DESC;

-- 10. Write a SQL query that will return the following data:

SELECT year / 10 * 10 as decade, genre, string_agg(title, ', ') as films
FROM films
GROUP BY decade, genre
ORDER BY decade;

-- 11. Write a SQL query that will return the following data:

SELECT genre, SUM(duration) AS total_duration FROM films
  GROUP BY genre ORDER BY total_duration, genre;

-- Relational Data and JOINs > 6. Working with Multiple Tables

-- 2. Write a query that determines how many tickets have been sold.
SELECT count(id) FROM tickets;

-- 3. Write a query that determines how many different customers purchased tickets to at least one event.
SELECT COUNT(DISTINCT customer_id) FROM tickets;

-- 4. Write a query that determines what percentage of the customers in the database have purchased a ticket to one or more of the events.

SELECT ROUND( COUNT(DISTINCT t.customer_id)
            / COUNT(DISTINCT c.id)::decimal * 100,
            2)
FROM customers AS c
LEFT JOIN tickets AS t ON c.id = t.customer_id;

-- 5. Write a query that returns the name of each event and how many tickets were sold for it, in order from most popular to least popular.

SELECT e.name, COUNT(t.event_id) AS popularity
FROM events AS e
LEFT JOIN tickets AS t
  ON e.id = t.event_id
GROUP BY e.name
ORDER BY popularity DESC;

-- 6. Write a query that returns the user id, email address, and number of events for all customers that have purchased tickets to three events.

SELECT c.id, c.email, COUNT(DISTINCT t.event_id)
  FROM customers AS c
  JOIN tickets as t
    ON c.id = t.customer_id
  GROUP BY c.id
    HAVING count(DISTINCT t.event_id) = 3
  ORDER BY c.id;

-- 7. Write a query to print out a report of all tickets purchased by the customer with the email address 'gennaro.rath@mcdermott.co'. The report should include the event name and starts_at and the seat's section name, row, and seat number.

SELECT e.name, e.starts_at, s.name AS section,
       seats.row, seats.number AS seat
  FROM events AS e
  JOIN tickets AS t   ON e.id = t.event_id
  JOIN seats          ON seats.id = t.seat_id
  JOIN sections AS s  ON s.id = seats.section_id
  JOIN customers AS c ON c.id = t.customer_id
  WHERE c.email = 'gennaro.rath@mcdermott.co';

-- Relational Data and JOINs > Using Foreign Keys

-- 2. Update the orders table so that referential integrity will be preserved for the data between orders and products.

ALTER TABLE orders
  ADD FOREIGN KEY (product_id)
    REFERENCES products(id);

-- 3. Use psql to insert the data shown in the following table into the database.

INSERT INTO products (name)
VALUES ('small bolt'),
       ('large bolt');

INSERT INTO orders (product_id, quantity)
VALUES (1, 10),
       (1, 25),
       (2, 15);

-- 4. Write a SQL statement that returns a result like this:

SELECT orders.quantity, products.name
  FROM orders
  JOIN products ON orders.product_id = products.id;

-- 5. Can you insert a row into orders without a product_id?? Write a SQL statement to prove your answer.

-- Yes. The FOREIGN key constraint does not prevent this.

INSERT INTO orders (quantity) VALUES (10);

-- 6. Write a SQL statement that will prevent NULL values from being stored in orders.product_id. What happens if you execute that statment?

-- When I run the statement, I will get an error as there is currently a null value in the table. I can delete that table row in order to add the constraint.

ALTER TABLE orders ALTER COLUMN product_id SET NOT NULL;

-- 7. Make any changes needed to avoid the error message encountered in #6. 

DELETE FROM orders WHERE product_id IS NULL;

-- 8. Create a new table called reviews to store the data shown below. This table should include a primary key and a reference to the products table. 

CREATE TABLE reviews (
  id serial PRIMARY KEY,
  product_id integer NOT NULL REFERENCES products(id),
  review text NOT NULL
);

-- 9. Write SQL statements to insert the data shown in the table in #8.

INSERT INTO reviews (product_id, review)
VALUES (1, 'a little small'),
       (1, 'very round!'),
       (2, 'could have been smaller');

-- 10. True or false: a foreign key constraint prevents NULL values from being stored in a column

-- FALSE

-- Relational Data and JOINs > One-to-Many Relationships


-- > Relational Data and JOINs > One-to-Many Relationships

-- 1. Write a SQL statement to add the following call data to othe database:

INSERT INTO calls ("when", duration, contact_id)
VALUES ('2016-01-18 14:47:00', 632, 6);

-- 2. Write a SQL statement to retrieve the call times, duration, and first names for all calls not made to William Swift.

SELECT calls.when, calls.duration, contacts.first_name
FROM calls
  JOIN contacts ON calls.contact_id = contacts.id
WHERE (first_name || last_name) <> 'WilliamSwift';

-- 3. Write SQL statements to add the following call data to the database:

INSERT INTO contacts (first_name, last_name, number)
VALUES ('Merve', 'Elk', '6343511126'),
       ('Sawa', 'Fyodorov', '6125594874');

INSERT INTO calls ("when", duration, contact_id)
VALUES ('2016-01-17 11:52:00', 175, 26),
       ('2016-01-18 21:22:00', 79, 27);

-- 4. Add a constraint to contacts that prevents a duplicate value being added in the column number.

ALTER TABLE contacts ADD UNIQUE (number);

-- 5. Write a SQL statement that attempts to insert a duplicate number for a new contact but fails. What error is shown?

INSERT INTO contacts (first_name, last_name, number)
VALUES ('a', 'b', '6343511126');

-- ERROR:  duplicate key value violates unique constraint "contacts_number_key"
-- DETAIL:  Key (number)=(6343511126) already exists.

-- 6. Why does "when" need to be quoted in many of the queries in this lesson?

-- > Because WHEN is a reserved word in PostreSQL. You can get around this by surrounding the keyword in double quotes to tell PSQL that you intend it to be something other than a keyword. Otherwise, PSQL automatically assumes anything it comes across that has the same characters as one of its keywords is a keyword. PSQL uses these reserved words to perform specific functions.

-- 7. Draw an entity-relationship diagram for the data we've been working with in this assignment.

-- __________           _______
--|          |         |       |
--| Contacts |-||----O<| Calls |
--|__________|         |_______|


-- > Relational Data and JOINS > Many-to-Many Relationships

-- 1. The books_categories table from this database was created with foreign keys that don't have the NOT NULL and ON DELETE CASCADE constraints. Go ahead and add them now. 

ALTER TABLE books_categories
ALTER COLUMN book_id SET NOT NULL,
ALTER COLUMN category_id SET NOT NULL;

ALTER TABLE books_categories
DROP CONSTRAINT books_categories_book_id_fkey,
DROP CONSTRAINT books_categories_category_id_fkey,
ADD CONSTRAINT book_fk FOREIGN KEY (book_id)
  REFERENCES books(id) ON DELETE CASCADE,
ADD CONSTRAINT category_fk FOREIGN KEY (category_id)
  REFERENCES categories(id) ON DELETE CASCADE;

-- 2. Write a SQL statement that will return the following result:

ALTER TABLE books
ALTER COLUMN title SET DATA TYPE text,
ALTER COLUMN author SET DATA TYPE text;

INSERT INTO books (title, author)
VALUES ('Sally Ride: America''s First Woman in Space', 'Lynn Sherr'),
       ('Jane Eyre', 'Charlotte Brontë'),
       ('Vij''s: Elegant and Inspired Indian Cuisine', 'Meeru Dhalwala and Vikram Vij');

INSERT INTO categories ("name")
VALUES ('Space Exploration'),
       ('Cookbook'),
       ('South Asia');

INSERT INTO books_categories (book_id, category_id)
VALUES (4, 5),
       (4, 1),
       (4, 7),
       (5, 2),
       (5, 4),
       (6, 8),
       (6, 1),
       (6, 9);

-- 4. Write a SQL statement to add a uniqueness constraint on the combination of columns book_id and category_id of the books_categories table. This constraint should be a table constraint; so, it should check for uniqueness on the combination of book_id and category_id across all rows of the books_categories table.

ALTER TABLE books_categories ADD UNIQUE (book_id, category_id);

-- 5. Write a SQL statement that will return the following result:

SELECT categories.name, count(books.id) AS book_count,
       string_agg(books.title, ', ') AS book_titles
FROM books
JOIN books_categories AS b_c ON books.id = b_c.book_id
JOIN categories ON b_c.category_id = categories.id
GROUP BY categories.name
ORDER BY categories.name;

SELECT categories.name, count(books.id) AS book_count,
       string_agg(books.title, ', ') AS book_titles
FROM categories
JOIN books_categories AS b_c ON categories.id = b_c.category_id
JOIN books ON b_c.book_id = books.id
GROUP BY categories.name
ORDER BY categories.name;

-- Relational Data and JOINs > Converting a 1:M Relationship to a M:M relationship

-- 2. Write the SQL statement needed to create a join table that will allow a film to have multiple directors, and directors to have multiple films. Include an id column in this table, and add foreign key constraints to the other columns.

CREATE TABLE directors_films (
  id serial PRIMARY KEY,
  director_id integer NOT NULL REFERENCES directors(id)
    ON DELETE CASCADE,
  film_id integer NOT NULL REFERENCES films(id)
    ON DELETE CASCADE
);

-- 3. Write the SQL statements needed to insert data into the new join table to represent the existing one-to-many relationships.

INSERT INTO directors_films (film_id, director_id)
VALUES (1, 1),
       (2, 2),
       (3, 3),
       (4, 4),
       (5, 5),
       (6, 6),
       (7, 3),
       (8, 7),
       (9, 8),
       (10, 4);

INSERT INTO directors_films (film_id, director_id)
  SELECT id, director_id FROM films;

-- 4. Write a SQL statement to remove any unneeded columns from films.

ALTER TABLE films DROP COLUMN director_id;

-- 5. Write a SQL statement that will return the following result:

SELECT films.title, directors.name FROM films
JOIN directors_films ON films.id = directors_films.film_id
JOIN directors ON directors.id = directors_films.director_id
ORDER BY films.title;

-- 6. Write SQL statements to insert data for the following films into the database:

INSERT INTO films (title, "year", genre, duration)
VALUES ('Fargo', 1996, 'comedy', 98),
       ('No Country for Old Men', 2007, 'western', 122),
       ('Sin City', 2005, 'crime', 124),
       ('Spy kids', 2001, 'scifi', 88);

INSERT INTO directors ("name")
VALUES ('Joel Coen'), ('Ethan Coen'), ('Frank Miller'), ('Robert Rodriguez');

INSERT INTO directors_films (film_id, director_id)
VALUES (11, 9),
       (12, 9),
       (12, 10),
       (13, 11),
       (13, 12),
       (14, 12);

-- 7. Write a SQL statement that determines how many films each director in the database has directed. Sort the results by number of films (greatest first) and then name (in alphabetical order).

SELECT d.name AS director, count(d_f.id) AS films FROM directors AS d
JOIN directors_films as d_f ON d.id = d_f.director_id
GROUP BY d.name
ORDER BY films DESC, director;
