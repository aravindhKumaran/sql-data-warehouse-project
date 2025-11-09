/*
===============================================================================
                                 EXPLORATORY DATA ANALYSIS (EDA)
===============================================================================

Column Classification Rules:
- For every column, determine whether it is a **Dimension** or a **Measure**.
- If the column data type is numeric:
    1. Check if it logically supports aggregation (SUM, AVG, etc.).
       - If yes → classify as a **Measure**.
    2. If not (e.g., IDs, codes), classify as a **Dimension**.

EDA Analysis Categories:
1. Database Exploration       -- Basic understanding of tables / row counts
2. Dimension Exploration      -- Cardinality, data types, uniqueness
3. Date Exploration           -- Time-based analysis, trends
4. Measure Exploration        -- Aggregating numerical metrics
5. Magnitude Analysis         -- Aggregating measures by dimensions
6. Ranking                    -- Ranking measures by dimensions (Top-N analysis)

*/


-- ================================================================================================================
--												2.Dimensions Exploration
-- ================================================================================================================

-- Explore all countries
SELECT DISTINCT country FROM gold.dim_customers;


-- Explore all categories "The major Divisions"
SELECT DISTINCT category, subcategory, product_name FROM gold.dim_products;

-- ================================================================================================================
--												3.Date Exploration
-- ================================================================================================================

-- date column boundaries
SELECT 
	MIN(birthdate) AS oldest_birthdate, 
	DATEDIFF(YEAR, MIN(birthdate), GETDATE()) AS oldest_age,
	MAX(birthdate) AS latest_birthdate,  
	DATEDIFF(YEAR, MAX(birthdate), GETDATE()) AS latest_age,
	MIN(create_date) AS oldest_create_date, 
	MAX(create_date) AS latest_create_date  
FROM gold.dim_customers;

-- ---------------------------------------------------------------------------------------------------------------
-- order date boundaries
SELECT
	MIN(order_date) AS first_order_date, -- 2010-12-29
	MAX(order_date) AS latest_order_date, -- 2014-01-28
	DATEDIFF(YEAR, MIN(order_date), MAX(order_date)) AS order_range_year,
	DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS order_range_month
FROM gold.fact_sales;

-- ================================================================================================================
--												4.Measures Exploration
-- ================================================================================================================

-- Find total sales, how many items are sold, average selling price
-- number of orders, customers, products

-->>>>>> Wide format
SELECT 
	SUM(sales_amount) AS total_sales,
	SUM(quantity) AS num_of_items_sold,
	AVG(price) AS avg_selling_price,
	COUNT(DISTINCT order_number)  AS tot_orders,
	COUNT(DISTINCT customer_key) AS tot_customers,
	COUNT(DISTINCT product_key) AS tot_products
FROM gold.fact_sales;

-- ---------------------------------------------------------------------------------------------------------------
-->>>>>> Long Format
SELECT 'Total Sales' AS measure_name, SUM(sales_amount) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Items Sold' AS measure_name, SUM(quantity) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Avg selling price' AS measure_name, AVG(price) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Total Orders' AS measure_name, COUNT(DISTINCT order_number) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Total Customers' AS measure_name, COUNT(DISTINCT customer_key) AS measure_value FROM gold.dim_customers
UNION ALL
SELECT 'Total Products' AS measure_name, COUNT(DISTINCT product_key) AS measure_value FROM gold.dim_products


-- ================================================================================================================
--													5.Magnitude
-- ================================================================================================================

-- Find total customers by countries
SELECT
	country, COUNT(1) AS 'total customers'
FROM gold.dim_customers
GROUP BY country;

-- ---------------------------------------------------------------------------------------------------------------
-- Find total customers by gender
SELECT
	gender, COUNT(1) AS 'total customers'
FROM gold.dim_customers
GROUP BY gender;

-- ---------------------------------------------------------------------------------------------------------------
-- Find total product by category
SELECT
	category, COUNT(1) AS 'total products'
FROM gold.dim_products
GROUP BY category;

-- -----------------------------------------------------------------------------------------
-- What is the avg costs in each category
SELECT
	category, AVG(cost) AS 'Avg Costs'
FROM gold.dim_products
GROUP BY category;

-- -----------------------------------------------------------------------------------------
-- What is the total revenue generated for each category
SELECT
	p.category, SUM(s.sales_amount) AS 'Total Revenue'
FROM gold.fact_sales s
LEFT JOIN gold.dim_products p
ON s.product_key = p.product_key
GROUP BY p.category
ORDER BY SUM(s.sales_amount) DESC;


-- -----------------------------------------------------------------------------------------
-- What is the total revenue generated for each customer
SELECT
	c.first_name, c.last_name, SUM(s.sales_amount) AS 'Total Revenue'
FROM gold.fact_sales s
LEFT JOIN gold.dim_customers c
ON s.customer_key = c.customer_key
GROUP BY s.customer_key, c.first_name, c.last_name
ORDER BY SUM(s.sales_amount) DESC;

-- -----------------------------------------------------------------------------------------
SELECT * FROM gold.dim_products;
SELECT * FROM gold.dim_customers;
SELECT * FROM gold.fact_sales;
SELECT * FROM gold.dim_products;

-- -----------------------------------------------------------------------------------------
-- What is the distribution of sold items across countries
SELECT
	c.country, SUM(s.quantity) AS 'Total sold items'
FROM gold.fact_sales s
LEFT JOIN gold.dim_customers c
ON s.customer_key = c.customer_key
GROUP BY c.country
ORDER BY SUM(s.quantity) DESC;


-- ================================================================================================================
--													6.Ranking
-- ================================================================================================================

-- Which 5 products generate the highest revenue
DECLARE @top_products INT;
SET @top_products = 5;

SELECT 
	b.product_key,
	b.tot_sales,
	p.product_name,
	p.category
FROM (
	SELECT TOP (@top_products)
		product_key,
		SUM(sales_amount) AS tot_sales
	FROM gold.fact_sales 
	GROUP BY product_key
	ORDER BY SUM(sales_amount) DESC
) b
LEFT JOIN gold.dim_products p
ON b.product_key = p.product_key
ORDER BY b.tot_sales DESC;

-- -----------------------------------------------------------------------------------------
-- What are the worst performing products in terms of sales

DECLARE @top_products INT;
SET @top_products = 5;

SELECT 
	TOP (@top_products)
	p.product_name,
	SUM(s.sales_amount) AS tot_sales
FROM gold.fact_sales s
LEFT JOIN gold.dim_products p
ON s.product_key = p.product_key
GROUP BY p.product_name
ORDER BY SUM(s.sales_amount)

-- -----------------------------------------------------------------------------------------
