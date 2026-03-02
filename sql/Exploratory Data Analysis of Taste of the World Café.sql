-- CUSTOMER INSIGHTS & MENU PERFORMANCE ANALYSIS FOR TASTE OF THE WORLD CAFÉ - by Lucila Aldana Quiñonez | Marketing Data Analyst
-- Exploratory Data Analysis:
DROP TABLE IF EXISTS orders_complete;

CREATE TABLE orders_complete AS
SELECT details.order_details_id, details.order_id, details.order_date, details.order_time, details.item_id,
  menu.item_name, menu.category, menu.price
FROM order_details_cleaned AS details
LEFT JOIN menu_items_cleaned AS menu
  ON details.item_id = menu.menu_item_id
WHERE details.item_id IS NOT NULL;

SELECT *
FROM orders_complete;


-- Exploring dataset basics:
	-- Time period of the dataset:
SELECT MIN(`order_date`) start_date_dataset, MAX(`order_date`) end_date_dataset
FROM orders_complete;

	-- Working days of week of the dataset:
SELECT DISTINCT DAYNAME(order_date) AS day_name
FROM orders_complete;

	-- Hour period of the dataset:
SELECT MIN(`order_time`), MAX(`order_time`)
FROM orders_complete;

	-- Number of items in the menu:
SELECT COUNT(DISTINCT item_id)
FROM orders_complete;

	-- List of items in the menu:
SELECT DISTINCT item_name, category
FROM orders_complete
GROUP BY item_name, category
ORDER BY category ;

	-- Least and most expensive items in the menu:
SELECT MIN(`price`), MAX(`price`)
FROM orders_complete;

	-- Highest and lowest priced items in the menu:
SELECT item_id, item_name, price, category
FROM orders_complete
GROUP BY item_id, item_name, price, category
ORDER BY price DESC
LIMIT 5;

SELECT item_id, item_name, price, category
FROM orders_complete
GROUP BY item_id, item_name, price, category
ORDER BY price ASC
LIMIT 5;

	-- Number of categories in the menu:
SELECT DISTINCT category AS total_item_categories
FROM orders_complete;

	-- Number of dishes per category:
SELECT category, COUNT(DISTINCT item_id)
FROM orders_complete
GROUP BY category;

	-- Least and most expensive items in the menu per category:
SELECT category, MIN(`price`), MAX(`price`)
FROM orders_complete
GROUP BY category;

	-- Average dish price per category:
SELECT category, AVG(price) AS avg_price
FROM orders_complete
GROUP BY category;

	-- Number of items ordered in the time period of the dataset:
SELECT COUNT(order_details_id) total_items_ordered
FROM orders_complete;

	-- Number of items ordered per category in the time period of the dataset:
SELECT COUNT(order_details_id) total_items_ordered, category
FROM orders_complete
GROUP BY category
ORDER BY total_items_ordered DESC;

	-- Number of orders with null values in the item_id column:
SELECT COUNT(order_details_id)
FROM order_details_cleaned
WHERE item_id IS NULL;

	-- Number of purchases per item in the time period of the dataset:
SELECT item_name, category, COUNT(order_details_id) total_purchases
FROM orders_complete
GROUP BY item_name, category
ORDER BY total_purchases DESC;

	-- Number of orders made in the time period of the dataset:
SELECT COUNT(DISTINCT order_id)
FROM orders_complete;


	-- Minimum, maximum and average of orders between times of day:
SELECT MIN(total_orders), MAX(total_orders), AVG(total_orders)
FROM
    (SELECT order_date, COUNT(DISTINCT order_id) AS total_orders
    FROM orders_complete
    WHERE order_time BETWEEN '10:30:00' AND '11:59:59'
    GROUP BY order_date
    ORDER BY total_orders DESC) AS orders_shift;


	-- Greatest and smallest order sizes:
SELECT MIN(total_items_order) lowest_items_ordered, MAX(total_items_order) highest_items_ordered
FROM (
	SELECT	*, COUNT(*) OVER (PARTITION BY order_id) AS total_items_order
	FROM orders_complete
) AS count_items_per_order;

	-- Number of orders per order size:
SELECT number_items, COUNT(*) AS order_count
FROM (
    SELECT order_id, COUNT(item_id) AS number_items
    FROM orders_complete
    GROUP BY order_id
) AS item_counts
-- WHERE number_items > 12
GROUP BY number_items
ORDER BY order_count DESC;

-- Share of sales volume by ticket size (in terms of number of items):
SELECT item_total, COUNT(*) AS order_size_count, ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS percentage_share
FROM (
    SELECT order_id, COUNT(order_id) AS item_total
    FROM orders_complete
    GROUP BY order_id
) AS order_summary
GROUP BY item_total
ORDER BY item_total;

	-- Least and most expensive orders:
SELECT order_id, SUM(price) total_spend
FROM orders_complete
GROUP BY order_id
ORDER BY total_spend ASC
LIMIT 5;

SELECT order_id, SUM(price) total_spend
FROM orders_complete
GROUP BY order_id
ORDER BY total_spend DESC
LIMIT 5;

SELECT MIN(`order_price`), MAX(`order_price`)
FROM (
SELECT order_id, sum(price) order_price
FROM orders_complete
GROUP BY order_id
) AS order_prices;


	-- Top performing menu items, in terms of sales:
SELECT item_id, item_name, COUNT(item_id) AS top_5_all
FROM orders_complete
GROUP BY item_id, item_name
ORDER BY top_5_all DESC
LIMIT 5;

-- Bottom performing menu items, in terms of sales:
SELECT item_id, item_name, COUNT(item_id) AS top_5_all
FROM orders_complete
GROUP BY item_id, item_name
ORDER BY top_5_all ASC
LIMIT 5;


-- Total revenue collected:
SELECT SUM(price) revenue_total
FROM orders_complete;

SELECT SUM(price) revenue_jan
FROM orders_complete
WHERE order_date BETWEEN '2023-01-01' AND '2023-01-31';

SELECT SUM(price) revenue_feb
FROM orders_complete
WHERE order_date BETWEEN '2023-02-01' AND '2023-02-28';

SELECT SUM(price) revenue_mar
FROM orders_complete
WHERE order_date BETWEEN '2023-03-01' AND '2023-03-31';


-- Revenue share per item and category:
SELECT item_name, revenue, ROUND(100 * revenue / total_all, 2) AS revenue_share_percent
FROM (
	SELECT item_name, SUM(COALESCE(price, 0)) revenue, SUM(SUM(COALESCE(price, 0))) OVER () AS total_all
	FROM orders_complete
	GROUP BY item_name
) AS revenue_data
ORDER BY revenue DESC;

SELECT category, revenue, ROUND(100 * revenue / total_all, 2) AS revenue_share_percent
FROM (
	SELECT category, SUM(COALESCE(price, 0)) AS revenue, SUM(SUM(COALESCE(price, 0))) OVER () AS total_all
	FROM orders_complete
	GROUP BY category
) AS revenue_data
ORDER BY revenue DESC;


-- Top performing menu items, in terms of revenue:
SELECT item_id, item_name, SUM(price) AS top_5_rev_all
FROM orders_complete
GROUP BY item_id, item_name
ORDER BY top_5_rev_all DESC
LIMIT 5;


-- Bottom performing menu items, in terms of revenue:
SELECT item_id, item_name, SUM(price) AS worst_5_rev_all
FROM orders_complete
GROUP BY item_id, item_name
ORDER BY worst_5_rev_all ASC
LIMIT 5;   


-- Exploring sales volume and revenue level correlation:
SELECT item_id, item_name, COUNT(item_id) sales_volume, SUM(price) revenue
FROM orders_complete
GROUP BY item_id , item_name
ORDER BY revenue DESC;


-- Customer demand across price levels:
SELECT item_id, item_name, price, COUNT(item_id) quantity_all
FROM orders_complete
GROUP BY item_id, item_name, price
ORDER BY price DESC;


-- Average spend per customer:
	-- Average spend per order in entire dataset time period:
SELECT AVG(price_total) AS avg_spend_per_order
FROM (
    SELECT order_id, SUM(price) AS price_total
    FROM orders_complete
    GROUP BY order_id
) AS price_totals;

	-- Average spend per small order (1-2 items):
SELECT AVG(price_total) AS avg_spend_small_order
FROM (
	SELECT order_id, SUM(price) AS price_total, COUNT(order_id) AS item_total
	FROM orders_complete
	GROUP BY order_id
	HAVING item_total < 3
	ORDER BY order_id
) AS small_order_total;

	-- Average spend per medium order (3–4 items):
SELECT AVG(price_total) AS avg_spend_medium_order
FROM (
	SELECT order_id, SUM(price) AS price_total, COUNT(order_id) AS item_total
	FROM orders_complete
	GROUP BY order_id
	HAVING item_total >= 3 AND item_total < 5
	ORDER BY order_id
) AS medium_order_total;

	-- Average spend per large order (5+ items):
SELECT AVG(price_total) AS avg_spend_large_order
FROM (
	SELECT order_id, SUM(price) AS price_total, COUNT(order_id) AS item_total
	FROM orders_complete
	GROUP BY order_id
	HAVING item_total >= 5
	ORDER BY order_id
) AS large_order_total;


-- Average ticket size per item (only orders with 2 to 4 items are included, as +5 are outliers):
WITH order_totals AS (
  SELECT order_id, SUM(price) AS order_total, COUNT(*) AS item_count
  FROM orders_complete
  GROUP BY order_id
  HAVING COUNT(*) BETWEEN 2 AND 4
),
item_orders AS (
  SELECT DISTINCT item_id, item_name, order_id
  FROM orders_complete
)
SELECT io.item_id, io.item_name, COUNT(*) AS orders_with_item, AVG(ot.order_total) AS avg_order_price_with_item
FROM item_orders io
JOIN order_totals ot USING (order_id)
GROUP BY io.item_id, io.item_name
ORDER BY avg_order_price_with_item DESC;


--  Average number of items in order per menu item (only orders with 2 to 4 items are included, as +5 are outliers):
WITH order_item_counts AS (
  SELECT order_id, COUNT(*) AS item_count
  FROM orders_complete
  GROUP BY order_id
  HAVING COUNT(*) BETWEEN 2 AND 4
),
item_orders AS (
  SELECT DISTINCT item_id, item_name, order_id
  FROM orders_complete
)
SELECT io.item_id, io.item_name, COUNT(*) AS orders_with_item, AVG(oic.item_count) AS avg_items_in_order_with_item
FROM item_orders io
JOIN order_item_counts oic USING (order_id)
GROUP BY io.item_id, io.item_name
ORDER BY avg_items_in_order_with_item DESC;


-- Average revenue share in order per menu item (only orders with 2 to 4 items are included, as +5 are outliers)::
WITH order_totals AS (
  SELECT order_id, SUM(price) AS order_total, COUNT(*) AS item_count
  FROM orders_complete
  GROUP BY order_id
  HAVING COUNT(*) BETWEEN 2 AND 4
),
item_orders AS (
  SELECT order_id, item_id, item_name, SUM(price) AS item_revenue
  FROM orders_complete
  GROUP BY order_id, item_id, item_name
)
SELECT io.item_id, io.item_name, COUNT(DISTINCT io.order_id) AS orders_with_item, ROUND(100 * AVG(io.item_revenue / ot.order_total), 2) AS avg_revenue_share_percent
FROM item_orders io
JOIN order_totals ot USING (order_id)
GROUP BY io.item_id, io.item_name
ORDER BY avg_revenue_share_percent DESC;


-- Calculating the rank for menu items drivers of high order sizes:
WITH 
		-- 1. Calculate average order total per item (point 1)
avg_order_price AS (
  SELECT 
      io.item_id,
      io.item_name,
      AVG(ot.order_total) AS avg_order_price_with_item
  FROM (
      SELECT DISTINCT item_id, item_name, order_id
      FROM orders_complete
  ) io
  JOIN (
      SELECT order_id, SUM(price) AS order_total
      FROM orders_complete
      GROUP BY order_id
      HAVING COUNT(*) BETWEEN 2 AND 4 -- optional: exclude outlier orders
  ) ot USING (order_id)
  GROUP BY io.item_id, io.item_name
),
		-- 2. Calculate average revenue share per item (point 3)
avg_revenue_share AS (
  SELECT 
      io.item_id,
      io.item_name,
      AVG(100 * oc.price / ot.order_total) AS avg_revenue_share_percent
  FROM orders_complete oc
  JOIN (
      SELECT order_id, SUM(price) AS order_total
      FROM orders_complete
      GROUP BY order_id
      HAVING COUNT(*) BETWEEN 2 AND 4
  ) ot USING (order_id)
  JOIN (
      SELECT DISTINCT item_id, item_name, order_id
      FROM orders_complete
  ) io ON oc.order_id = io.order_id AND oc.item_id = io.item_id
  GROUP BY io.item_id, io.item_name
)
		-- 3. Combine both metrics into one final ranking
SELECT 
    a.item_id,
    a.item_name,
    ROUND(a.avg_order_price_with_item, 2) AS avg_order_price_with_item,
    ROUND(r.avg_revenue_share_percent, 2) AS avg_revenue_share_percent,
    ROUND(
        (a.avg_order_price_with_item / (SELECT MAX(avg_order_price_with_item) FROM avg_order_price)) * 0.5 +
        (r.avg_revenue_share_percent / (SELECT MAX(avg_revenue_share_percent) FROM avg_revenue_share)) * 0.5,
        2
    ) AS combined_score
FROM avg_order_price a
JOIN avg_revenue_share r USING (item_id, item_name)
ORDER BY combined_score DESC;


-- Exploring time-based trends in menu item performance:
SELECT item_id, item_name, time_of_day, ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY item_name), 1) AS pct_share
FROM (
    SELECT item_id, item_name,
        CASE
			WHEN HOUR(order_time) BETWEEN 11 AND 15 THEN 'Lunch (11am–3pm)'
			WHEN HOUR(order_time) BETWEEN 16 AND 18 THEN 'Early Evening (4–6pm)'
			ELSE 'Dinner'
        END AS time_of_day
    FROM orders_complete
) AS t
GROUP BY item_id, item_name, time_of_day
ORDER BY item_id, pct_share DESC;


-- Items frequently ordered together:
SELECT a.item_id AS item_1, a.item_name AS item_1_name, b.item_id AS item_2, b.item_name AS item_2_name, COUNT(*) AS times_ordered_together
FROM orders_complete a
JOIN (
    SELECT order_id, item_id, item_name
    FROM orders_complete
) b 
    ON a.order_id = b.order_id
    AND a.item_id < b.item_id
GROUP BY 
	a.item_id, b.item_id,
    a.item_name, b.item_name
ORDER BY times_ordered_together DESC;
