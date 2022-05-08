-- Set Up the Database Using \copy

CREATE TABLE bidders (
  id serial PRIMARY KEY,
  "name" text NOT NULL
);

CREATE TABLE items (
  id serial PRIMARY KEY,
  "name" text NOT NULL,
  initial_price numeric(6,2)
    NOT NULL CHECK(initial_price BETWEEN 0.01 AND 1000.00),
  sales_price numeric(6,2)
    CHECK(sales_price BETWEEN 0.01 AND 1000.00)
);

CREATE TABLE bids (
  id serial PRIMARY KEY,
  bidder_id integer NOT NULL REFERENCES bidders(id) ON DELETE CASCADE,
  item_id integer NOT NULL REFERENCES items(id) ON DELETE CASCADE,
  amount numeric(6,2) NOT NULL CHECK(amount BETWEEN 0.01 AND 1000.00)
);

CREATE INDEX ON bids (bidder_id, item_id);

\copy bidders FROM 'bidders.csv' WITH HEADER CSV;

\copy items FROM 'items.csv' WITH HEADER CSV;

\copy bids FROM 'bids.csv' WITH HEADER CSV;

-- Conditional Subqueries: IN

SELECT DISTINCT "name" AS "Bid on Items"
FROM items
WHERE items.id IN (SELECT item_id FROM bids);

-- Conditional Subqueries: NOT IN

SELECT DISTINCT "name" AS "Not Bid On" FROM items
WHERE items.id NOT IN (SELECT item_id FROM bids);

-- Conditional Subqueries: EXISTS

SELECT "name" FROM bidders
WHERE EXISTS (SELECT 1 FROM bids WHERE bids.bidder_id = bidders.id);

-- Further Exploration

SELECT DISTINCT bidders.name FROM bidders
JOIN bids
  ON bidders.id = bids.bidder_id;

-- Query From a Virtual Table

SELECT max(count)
  FROM (SELECT bidder_id, count(id) FROM bids
        GROUP BY bidder_id) AS max;

-- Scalar Subqueries

SELECT "name",
       (SELECT count(item_id) FROM bids WHERE bids.item_id = items.id)
       FROM items;

-- Further Exploration

SELECT items.name, count(bids.id)
FROM items
LEFT JOIN bids ON items.id = bids.item_id
GROUP BY items.name;

-- Row Comparison

SELECT id FROM items
WHERE ROW('Painting', 100.00, 250.00) = 
      ROW("name", initial_price, sales_price);

-- EXPLAIN

EXPLAIN SELECT name FROM bidders
WHERE EXISTS (SELECT 1 FROM bids WHERE bids.bidder_id = bidders.id);

-----------------------------------------------------------------------
 Hash Join  (cost=33.38..66.47 rows=635 width=32)
   Hash Cond: (bidders.id = bids.bidder_id)
   ->  Seq Scan on bidders  (cost=0.00..22.70 rows=1270 width=36)
   ->  Hash  (cost=30.88..30.88 rows=200 width=4)
         ->  HashAggregate  (cost=28.88..30.88 rows=200 width=4)
               Group Key: bids.bidder_id
               ->  Seq Scan on bids  (cost=0.00..25.10 rows=1510 width=4)
(7 rows)

-- It seems there were 5 nodes in this query plan. I would assume that summing the final costs would get us a total cost for the query. I think it's interesting how many rows are generated as part of the query.


EXPLAIN ANALYZE SELECT name FROM bidders
WHERE EXISTS (SELECT 1 FROM bids WHERE bids.bidder_id = bidders.id);

-----------------------------------------------------------------------
 Hash Join  (cost=33.38..66.47 rows=635 width=32) (actual time=1.369..1.375 rows=6 loops=1)
   Hash Cond: (bidders.id = bids.bidder_id)
   ->  Seq Scan on bidders  (cost=0.00..22.70 rows=1270 width=36) (actual time=1.086..1.088 rows=7 loops=1)
   ->  Hash  (cost=30.88..30.88 rows=200 width=4) (actual time=0.263..0.264 rows=6 loops=1)
         Buckets: 1024  Batches: 1  Memory Usage: 9kB
         ->  HashAggregate  (cost=28.88..30.88 rows=200 width=4) (actual time=0.253..0.256 rows=6 loops=1)
               Group Key: bids.bidder_id
               ->  Seq Scan on bids  (cost=0.00..25.10 rows=1510 width=4) (actual time=0.228..0.234 rows=26 loops=1)
 Planning Time: 0.201 ms
 Execution Time: 1.436 ms
(10 rows)

-- I think it's odd that the actual values were way off from the estimated values.

-- Comparing SQL Statements

EXPLAIN ANALYZE SELECT MAX(bid_counts.count) FROM
  (SELECT COUNT(bidder_id) FROM bids GROUP BY bidder_id) AS bid_counts;
                                                 
-----------------------------------------------------------------------
 Aggregate  (cost=37.15..37.16 rows=1 width=8) (actual time=0.037..0.038 rows=1 loops=1)
   ->  HashAggregate  (cost=32.65..34.65 rows=200 width=12) (actual time=0.030..0.033 rows=6 loops=1)
         Group Key: bids.bidder_id
         ->  Seq Scan on bids  (cost=0.00..25.10 rows=1510 width=4) (actual time=0.006..0.009 rows=26 loops=1)
 Planning Time: 0.356 ms
 Execution Time: 0.101 ms
(6 rows)



EXPLAIN ANALYZE SELECT COUNT(bidder_id) AS max_bid FROM bids
  GROUP BY bidder_id
  ORDER BY max_bid DESC
  LIMIT 1;

-----------------------------------------------------------------------
 Limit  (cost=35.65..35.65 rows=1 width=12) (actual time=0.062..0.063 rows=1 loops=1)
   ->  Sort  (cost=35.65..36.15 rows=200 width=12) (actual time=0.061..0.061 rows=1 loops=1)
         Sort Key: (count(bidder_id)) DESC
         Sort Method: top-N heapsort  Memory: 25kB
         ->  HashAggregate  (cost=32.65..34.65 rows=200 width=12) (actual time=0.035..0.039 rows=6 loops=1)
               Group Key: bidder_id
               ->  Seq Scan on bids  (cost=0.00..25.10 rows=1510 width=4) (actual time=0.009..0.013 rows=26 loops=1)
 Planning Time: 0.135 ms
 Execution Time: 0.105 ms
(9 rows)

-- Total Costs: Subquery-37.16; ORDER-35.65
-- Looks like ORDER_BY is the way to go, for my computer. It has less system costs and takes less time.


-- Further Exploration

EXPLAIN ANALYZE SELECT items.name, count(bids.id)
FROM items
LEFT JOIN bids ON items.id = bids.item_id
GROUP BY items.name;

-----------------------------------------------------------------------
 HashAggregate  (cost=66.44..68.44 rows=200 width=40) (actual time=0.086..0.091 rows=6 loops=1)
   Group Key: items.name
   ->  Hash Right Join  (cost=29.80..58.89 rows=1510 width=36) (actual time=0.040..0.066 rows=27 loops=1)
         Hash Cond: (bids.item_id = items.id)
         ->  Seq Scan on bids  (cost=0.00..25.10 rows=1510 width=8) (actual time=0.004..0.008 rows=26 loops=1)
         ->  Hash  (cost=18.80..18.80 rows=880 width=36) (actual time=0.020..0.020 rows=6 loops=1)
               Buckets: 1024  Batches: 1  Memory Usage: 9kB
               ->  Seq Scan on items  (cost=0.00..18.80 rows=880 width=36) (actual time=0.010..0.012 rows=6 loops=1)
 Planning Time: 0.207 ms
 Execution Time: 0.141 ms
(10 rows)



EXPLAIN ANALYZE SELECT name,
(SELECT COUNT(item_id) FROM bids WHERE item_id = items.id)
FROM items;

-----------------------------------------------------------------------
 Seq Scan on items  (cost=0.00..25455.20 rows=880 width=40) (actual time=0.033..0.081 rows=6 loops=1)
   SubPlan 1
     ->  Aggregate  (cost=28.89..28.91 rows=1 width=8) (actual time=0.009..0.010 rows=1 loops=6)
           ->  Seq Scan on bids  (cost=0.00..28.88 rows=8 width=4) (actual time=0.004..0.007 rows=4 loops=6)
                 Filter: (item_id = items.id)
                 Rows Removed by Filter: 22
 Planning Time: 0.129 ms
 Execution Time: 0.120 ms
(8 rows)

-- Looks like the scalar subquery was indeed faster, but it was also way, way more taxing on system resources.
