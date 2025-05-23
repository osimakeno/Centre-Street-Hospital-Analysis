/* What is the average quarterly order count and total sales for Macbooks sold in North America? 
(i.e. “For North America Macbooks, average of X units sold per quarter and Y in dollar sales per quarter”) */

WITH quarterly_macbook_sales AS
(
SELECT 
	YEAR(o.purchase_ts) AS year,
	QUARTER(o.purchase_ts) AS quarter,
    COUNT(o.id) AS order_count,
    ROUND(SUM(o.usd_price),2) AS total_sales
FROM orders o
	JOIN customers c
	ON o.customer_id = c.id
	JOIN geo_lookup g
	ON c.country_code = g.country
WHERE LOWER(o.product_name) LIKE '%macbook%'
AND (g.region) = 'NA'
GROUP BY YEAR(o.purchase_ts), QUARTER(o.purchase_ts)
)
SELECT
	ROUND(AVG(order_count),2) AS avg_total_orders,
	ROUND(AVG(total_sales),2) AS avg_total_sales
FROM quarterly_macbook_sales;

-- Within each region, what is the most popular product?

WITH product_count AS (
SELECT 
	g.region,
	o.product_name,
    COUNT(*) AS order_count,
    ROW_NUMBER() OVER (
		PARTITION BY g.region
        ORDER BY COUNT(*) DESC
	) AS rank_in_region
FROM orders o
JOIN customers c
	ON o.customer_id = c.id
	JOIN geo_lookup g
	ON c.country_code = g.country
GROUP BY g.region, o.product_name
)
SELECT
	region,
    product_name AS most_popular_product,
    order_count
FROM product_count
WHERE rank_in_region = 1;

-- What was the refund rate and refund count for each product per year?

SELECT 
	YEAR(o.purchase_ts) AS year,
    o.product_name,
    COUNT(*),
    SUM(CASE WHEN os.refund_ts IS NOT NULL THEN 1 ELSE 0 END) AS refund_count,
    ROUND(AVG(CASE WHEN os.refund_ts IS NOT NULL THEN 1 ELSE 0 END),2) AS refund_rate
FROM orders o
JOIN order_status os
ON o.id = os.id
GROUP BY 1,2;

/* Which region has the average highest time to deliver for website purchases made in 2022 or 
Samsung purchases made in 2021, expressing time to deliver in weeks */

WITH delivery_times AS (
  SELECT 
    g.region,
    DATEDIFF(os.delivery_ts, os.purchase_ts) / 7 AS delivery_weeks
  FROM orders o
  JOIN customers c ON o.customer_id = c.id
  JOIN order_status os ON o.id = os.id
  JOIN geo_lookup g ON c.country_code = g.country
  WHERE (
    (o.purchase_platform = 'Website' AND YEAR(o.purchase_ts) = 2022)
    OR
    (o.product_name LIKE '%Samsung%' AND YEAR(o.purchase_ts) = 2021)
  )
)

SELECT 
  region,
  ROUND(AVG(delivery_weeks), 2) AS avg_weeks_to_deliver
FROM delivery_times
GROUP BY region
ORDER BY avg_weeks_to_deliver DESC
LIMIT 1;

-- How does the time to make a purchase differ between loyalty customers vs. non-loyalty customers, per purchase plaftorm.

SELECT
  o.purchase_platform,
  CASE 
    WHEN c.loyalty_program = 1 THEN 'Loyalty' 
    ELSE 'Non-Loyalty' 
  END AS loyalty_status,
  ROUND(AVG(DATEDIFF(o.purchase_ts, c.created_on)), 1) AS avg_days_to_order,
  COUNT(*) AS order_count
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.id
GROUP BY o.purchase_platform, loyalty_status;