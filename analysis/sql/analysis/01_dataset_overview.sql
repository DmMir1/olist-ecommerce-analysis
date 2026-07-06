/*
====================================================================
File: 01_dataset_overview.sql
====================================================================

Purpose
-------
Explore the Olist Brazilian E-Commerce dataset before performing
any data cleaning or business analysis.

This script provides a high-level understanding of:

• Dataset size
• Table structure
• Order statuses
• Analysis period

No data is modified in this script.

====================================================================
*/

------------------------------------------------------------
-- 1. Dataset Overview
-- Number of rows in each table
------------------------------------------------------------

SELECT 'orders' AS table_name, COUNT(*) AS rows
FROM orders

UNION ALL

SELECT 'customers', COUNT(*)
FROM customers

UNION ALL

SELECT 'order_items', COUNT(*)
FROM order_items

UNION ALL

SELECT 'order_payments', COUNT(*)
FROM order_payments

UNION ALL

SELECT 'order_reviews', COUNT(*)
FROM order_reviews

UNION ALL

SELECT 'products', COUNT(*)
FROM products

UNION ALL

SELECT 'sellers', COUNT(*)
FROM sellers

UNION ALL

SELECT 'product_category_translation', COUNT(*)
FROM product_category_name_translation;

------------------------------------------------------------
-- 2. Sample Data
-- Preview the main transaction table
------------------------------------------------------------

SELECT *
FROM orders
LIMIT 10;

------------------------------------------------------------
-- 3. Order Status Distribution
-- Understand the lifecycle of customer orders
------------------------------------------------------------

SELECT
    order_status,
    COUNT(*) AS total_orders
FROM orders
GROUP BY order_status
ORDER BY total_orders DESC;

------------------------------------------------------------
-- 4. Dataset Time Coverage
-- Identify the time period available for analysis
------------------------------------------------------------

SELECT
    MIN(order_purchase_timestamp) AS first_order,
    MAX(order_purchase_timestamp) AS last_order
FROM orders;

------------------------------------------------------------
-- 5. Primary Business Entities
-- Quick overview of the core business objects
------------------------------------------------------------

SELECT
    COUNT(DISTINCT order_id) AS orders,
    COUNT(DISTINCT customer_id) AS customers
FROM orders;

/*
====================================================================
Findings

• The dataset contains 8 relational tables.
• Orders is the central fact table.
• The analysis period spans October 2016 to August 2018.
• Delivered orders represent the majority of transactions.

====================================================================
*/

/*
====================================================================
End of Script
====================================================================
*/
