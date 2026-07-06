/*
====================================================================
File: 03_duplicates.sql
====================================================================

Purpose
-------
Check the Olist dataset for duplicate records before data cleaning.

The goal is to identify:
• Duplicate primary keys
• Duplicate composite keys
• Full-row duplicates

No data is modified in this script.

====================================================================
*/

------------------------------------------------------------
-- 1. Orders
------------------------------------------------------------

SELECT
    order_id,
    COUNT(*) AS duplicate_count
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;

------------------------------------------------------------
-- 2. Customers
------------------------------------------------------------

SELECT
    customer_id,
    COUNT(*) AS duplicate_count
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

------------------------------------------------------------
-- 3. Products
------------------------------------------------------------

SELECT
    product_id,
    COUNT(*) AS duplicate_count
FROM products
GROUP BY product_id
HAVING COUNT(*) > 1;

------------------------------------------------------------
-- 4. Sellers
------------------------------------------------------------

SELECT
    seller_id,
    COUNT(*) AS duplicate_count
FROM sellers
GROUP BY seller_id
HAVING COUNT(*) > 1;

------------------------------------------------------------
-- 5. Order Items
-- Composite key: order_id + order_item_id
------------------------------------------------------------

SELECT
    order_id,
    order_item_id,
    COUNT(*) AS duplicate_count
FROM order_items
GROUP BY
    order_id,
    order_item_id
HAVING COUNT(*) > 1;

------------------------------------------------------------
-- 6. Order Payments
-- Composite key: order_id + payment_sequential
------------------------------------------------------------

SELECT
    order_id,
    payment_sequential,
    COUNT(*) AS duplicate_count
FROM order_payments
GROUP BY
    order_id,
    payment_sequential
HAVING COUNT(*) > 1;

------------------------------------------------------------
-- 7. Order Reviews
------------------------------------------------------------

SELECT
    review_id,
    COUNT(*) AS duplicate_count
FROM order_reviews
GROUP BY review_id
HAVING COUNT(*) > 1;

------------------------------------------------------------
-- 8. Geolocation
-- Check for complete duplicate rows
------------------------------------------------------------

SELECT
    geolocation_zip_code_prefix,
    geolocation_lat,
    geolocation_lng,
    geolocation_city,
    geolocation_state,
    COUNT(*) AS duplicate_count
FROM geolocation
GROUP BY
    geolocation_zip_code_prefix,
    geolocation_lat,
    geolocation_lng,
    geolocation_city,
    geolocation_state
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;

 /*
====================================================================
Findings

• No duplicate primary keys were found in the transactional tables.
• No duplicate composite keys were found in order_items or
  order_payments.
• The geolocation table contains a large number of full-row
  duplicates. These are expected because the table stores
  repeated geocoding results rather than unique locations.
• Duplicate removal is performed later during data cleaning.

====================================================================
*/

/*
====================================================================
End of Script
====================================================================
*/
