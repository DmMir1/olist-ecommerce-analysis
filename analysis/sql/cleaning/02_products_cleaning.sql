/*
====================================================================
File: 02_products_cleaning.sql
====================================================================

Purpose
-------
Clean and prepare the products table for analysis.

Cleaning tasks:
• Replace empty product category names
• Verify category updates
• Review remaining missing product attributes

====================================================================
*/

BEGIN;

------------------------------------------------------------
-- 1. Replace Empty Category Names
------------------------------------------------------------

UPDATE products
SET product_category_name = 'unknown'
WHERE product_category_name = '';

------------------------------------------------------------
-- 2. Verify Category Update
------------------------------------------------------------

SELECT
    COUNT(*) AS remaining_empty_categories
FROM products
WHERE product_category_name = '';

------------------------------------------------------------
-- 3. Review Remaining Missing Product Attributes
------------------------------------------------------------

-- Product name length

SELECT
    COUNT(*) AS missing_name_length
FROM products
WHERE product_name_lenght IS NULL;

-- Product description length

SELECT
    COUNT(*) AS missing_description_length
FROM products
WHERE product_description_lenght IS NULL;

-- Product weight

SELECT
    COUNT(*) AS missing_weight
FROM products
WHERE product_weight_g IS NULL;

COMMIT;

/*
====================================================================
Cleaning Summary

• Empty product category names were replaced with 'unknown'.
• Missing product dimensions were intentionally retained,
  as they represent unknown values and were not required
  for the planned analysis.
• Products table is ready for downstream analysis.

====================================================================
*/

/*
====================================================================
End of Script
====================================================================
*/
