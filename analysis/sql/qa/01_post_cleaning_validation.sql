/*
====================================================================
File: 01_post_cleaning_validation.sql
====================================================================

Purpose
-------
Verify that all cleaning scripts completed successfully before
performing business analysis or building Power BI dashboards.

This script does not modify any data.

====================================================================
*/

------------------------------------------------------------
-- 1. Orders Validation
------------------------------------------------------------

-- Empty strings should no longer exist.

SELECT
    COUNT(*) FILTER (WHERE order_approved_at::text = '') AS empty_approved_at,
    COUNT(*) FILTER (WHERE order_delivered_carrier_date::text = '') AS empty_carrier_date,
    COUNT(*) FILTER (WHERE order_delivered_customer_date::text = '') AS empty_customer_delivery
FROM orders;

-- Verify timestamp data types.

SELECT
    column_name,
    data_type
FROM information_schema.columns
WHERE table_name = 'orders'
  AND column_name IN (
      'order_purchase_timestamp',
      'order_approved_at',
      'order_delivered_carrier_date',
      'order_delivered_customer_date',
      'order_estimated_delivery_date'
)
ORDER BY ordinal_position;

------------------------------------------------------------
-- 2. Products Validation
------------------------------------------------------------

SELECT
    COUNT(*) AS remaining_empty_categories
FROM products
WHERE product_category_name = '';

------------------------------------------------------------
-- 3. Translation Table Validation
------------------------------------------------------------

SELECT
    product_category_name,
    product_category_name_english
FROM product_category_name_translation
WHERE product_category_name IN (
    'unknown',
    'pc_gamer',
    'portateis_cozinha_e_preparadores_de_alimentos'
);

------------------------------------------------------------
-- 4. Customers Validation
------------------------------------------------------------

SELECT
    COUNT(*) AS remaining_original_city_names
FROM customers
WHERE customer_city IN (
    'belo campo',
    'mogi-mirim',
    'rio do pires',
    'estrela d oeste',
    'palmeira d oeste',
    'dias d avila',
    'arraial d ajuda'
);

------------------------------------------------------------
-- 5. Sellers Validation
------------------------------------------------------------

SELECT
    COUNT(*) AS cities_with_double_spaces
FROM sellers
WHERE seller_city LIKE '%  %';

SELECT
    COUNT(*) AS cities_with_slashes
FROM sellers
WHERE seller_city LIKE '%/%';

SELECT
    COUNT(*) AS cities_with_acute_accent
FROM sellers
WHERE seller_city LIKE '%' || chr(180) || '%';

------------------------------------------------------------
-- 6. Reviews Validation
------------------------------------------------------------

SELECT
    COUNT(*) AS invalid_review_scores
FROM order_reviews
WHERE review_score NOT BETWEEN 1 AND 5;

------------------------------------------------------------
-- 7. Geolocation Validation
------------------------------------------------------------

SELECT
    COUNT(*) AS coordinate_outliers
FROM geolocation
WHERE geolocation_lat NOT BETWEEN -34 AND 6
   OR geolocation_lng NOT BETWEEN -75 AND -28;

SELECT
    MIN(geolocation_lat) AS min_latitude,
    MAX(geolocation_lat) AS max_latitude,
    MIN(geolocation_lng) AS min_longitude,
    MAX(geolocation_lng) AS max_longitude
FROM geolocation;

/*
====================================================================
QA Summary

Expected Results

✓ No empty product categories
✓ No invalid review scores
✓ No seller city formatting issues
✓ No remaining coordinate outliers
✓ Translation table contains all required values
✓ Orders use TIMESTAMP columns

If all checks pass, the dataset is ready for analysis
and Power BI reporting.

====================================================================
*/

/*
====================================================================
End of Script
====================================================================
*/
