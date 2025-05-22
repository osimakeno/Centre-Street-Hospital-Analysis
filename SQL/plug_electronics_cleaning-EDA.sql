USE plug_electronics;

/* Performing an initial review of the dataset to identify errors, inconsistencies, duplicates, 
and null values. This is part of the general EDA (Exploratory Data Analysis) process, 
after which the data will be cleaned and any identified issues will be corrected. */

-- overview of all tables
SELECT * 
FROM orders
LIMIT 100;

SELECT *
FROM customers
LIMIT 100;

SELECT *
FROM geo_lookup
LIMIT 100;

SELECT *
FROM order_status
LIMIT 100;

-- Null values check in orders table

SELECT 
	SUM(CASE WHEN orders.customer_id IS NULL THEN 1 ELSE 0 END) AS nullcount_custid,
    SUM(CASE WHEN orders.id IS NULL THEN 1 ELSE 0 END) AS nullcount_orderid,
    SUM(CASE WHEN orders.purchase_ts IS NULL THEN 1 ELSE 0 END) AS nullcount_purchasets,
    SUM(CASE WHEN orders.product_id IS NULL THEN 1 ELSE 0 END) AS nullcount_productid,
    SUM(CASE WHEN orders.product_name IS NULL THEN 1 ELSE 0 END) AS nullcount_productname,
    SUM(CASE WHEN orders.currency IS NULL THEN 1 ELSE 0 END) AS nullcount_currency,
    SUM(CASE WHEN orders.local_price IS NULL THEN 1 ELSE 0 END) AS nullcount_localprice,
    SUM(CASE WHEN Orders.usd_price IS NULL THEN 1 ELSE 0 END) AS nullcount_usdprice,
    SUM(CASE WHEN orders.purchase_platform IS NULL THEN 1 ELSE 0 END) AS nullcount_purchaseplatform
FROM orders;

-- checking for name inconsistences in product names, purchase, marketing platforms etc. 

SELECT 
	DISTINCT product_name
FROM orders;
-- cleaning up product names
UPDATE orders
SET product_name = '27in 4K gaming monitor'
WHERE product_name = '27in"" 4k gaming monitor';

SELECT 
	DISTINCT purchase_platform
FROM orders;

SELECT
	DISTINCT customers.country_code,
    geo_lookup.region
FROM customers
LEFT JOIN geo_lookup 
ON customers.country_code = geo_lookup.country
ORDER BY country_code
ASC;

SELECT
    COUNT(customers.country_code) AS null_count
FROM customers
LEFT JOIN geo_lookup 
ON customers.country_code = geo_lookup.country
WHERE geo_lookup.region IS NULL
GROUP BY country_code;

SELECT 
	DISTINCT marketing_channel,
    COUNT(marketing_channel) AS count
FROM customers
GROUP BY marketing_channel;
-- updating the null values in the marketing channel to unkwown category 
UPDATE customers
SET marketing_channel = 'unknown' 
WHERE marketing_channel = '';

-- checking products that have zero price

SELECT
    usd_price,
    COUNT(*) AS count_of_orders
FROM orders
WHERE usd_price = 0
GROUP BY 1;

-- checking time frame ranges for account creation, purchaeses, refunds, delivery etc

SELECT
	MIN(created_on) AS oldest_account,
    MAX(created_on) AS newest_account
FROM customers;

SELECT
    MIN(ship_ts) AS earliest_ship_date,
    MAX(ship_ts) AS latest_ship_date,
	MIN(purchase_ts) AS earliest_order_date,
    MAX(purchase_ts) AS latest_order_date,
    MIN(delivery_ts) AS earliest_delivery_date,
    MAX(delivery_ts) AS latest_delivery_date,
    MIN(refund_ts) AS earliest_return_date,
    MAX(refund_ts) AS latest_return_date
FROM order_status;



