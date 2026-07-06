/*
====================================================================
File: 02_missing_values.sql
====================================================================

Purpose
-------
Investigate missing values across the Olist dataset before
performing any data cleaning.

This script distinguishes between:
• NULL values
• Empty strings ('')
• Legitimate missing business data

No data is modified in this script.

Related script:
cleaning/01_orders_cleaning.sql
====================================================================
*/

------------------------------------------------------------
-- 1. Initial NULL Check
-- Verify missing values in the orders table
------------------------------------------------------------

SELECT
    COUNT(*) AS total_rows,
    COUNT(order_approved_at) AS approved_not_null,
    COUNT(order_delivered_carrier_date) AS carrier_not_null,
    COUNT(order_delivered_customer_date) AS delivered_not_null
FROM orders;

-- Observation:
-- COUNT() suggested no major issues. Results looked suspicious
-- considering the nature of transactional data.

------------------------------------------------------------
-- 2. Investigate Empty Strings
-- CSV imports may store missing values as ''
------------------------------------------------------------

SELECT
    SUM(CASE WHEN order_approved_at = '' THEN 1 ELSE 0 END) AS empty_approved_at,
    SUM(CASE WHEN order_delivered_carrier_date = '' THEN 1 ELSE 0 END) AS empty_carrier_date,
    SUM(CASE WHEN order_delivered_customer_date = '' THEN 1 ELSE 0 END) AS empty_customer_delivery
FROM orders;

------------------------------------------------------------
-- 3. Product Category Investigation
------------------------------------------------------------

SELECT
    COUNT(*) AS empty_categories
FROM products
WHERE product_category_name = '';

------------------------------------------------------------
-- 4. Product Attribute Investigation
------------------------------------------------------------

SELECT
    COUNT(*) AS missing_name_length
FROM products
WHERE product_name_lenght IS NULL;

SELECT
    COUNT(*) AS missing_description_length
FROM products
WHERE product_description_lenght IS NULL;

SELECT
    COUNT(*) AS missing_weight
FROM products
WHERE product_weight_g IS NULL;

------------------------------------------------------------
-- 5. Review Comments
------------------------------------------------------------

SELECT
    COUNT(*) AS missing_review_titles
FROM order_reviews
WHERE review_comment_title IS NULL;

SELECT
    COUNT(*) AS missing_review_messages
FROM order_reviews
WHERE review_comment_message IS NULL;

------------------------------------------------------------
-- Findings
------------------------------------------------------------
/*
Key observations

• Empty CSV cells were imported by DBeaver as empty strings ('')
  instead of NULL values for several date columns.

• Product category names contained empty strings that would
  negatively affect category-level analysis.

• Missing review comments are expected behaviour because
  customers are not required to leave written feedback.

• Missing product dimensions were retained because they are
  legitimate unknown values and were not required for the
  planned analysis.

Cleaning actions are implemented in:
cleaning/01_orders_cleaning.sql
cleaning/02_products_cleaning.sql
cleaning/05_reviews_cleaning.sql
*/

/*
====================================================================
End of Script
====================================================================
*/
