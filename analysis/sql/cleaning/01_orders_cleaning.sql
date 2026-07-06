/*
====================================================================
File: 01_orders_cleaning.sql
====================================================================

Purpose
-------
Clean and prepare the orders table for analysis.

Cleaning tasks:
• Replace empty strings with NULL values
• Convert date columns to TIMESTAMP
• Add a business rule validation flag
• Verify the cleaning results

====================================================================
*/

BEGIN;

------------------------------------------------------------
-- 1. Replace Empty Strings with NULL
------------------------------------------------------------

UPDATE orders
SET order_approved_at = NULL
WHERE order_approved_at = '';

UPDATE orders
SET order_delivered_carrier_date = NULL
WHERE order_delivered_carrier_date = '';

UPDATE orders
SET order_delivered_customer_date = NULL
WHERE order_delivered_customer_date = '';

------------------------------------------------------------
-- 2. Convert Date Columns to TIMESTAMP
------------------------------------------------------------

ALTER TABLE orders
    ALTER COLUMN order_purchase_timestamp TYPE timestamp
        USING order_purchase_timestamp::timestamp,
    ALTER COLUMN order_approved_at TYPE timestamp
        USING order_approved_at::timestamp,
    ALTER COLUMN order_delivered_carrier_date TYPE timestamp
        USING order_delivered_carrier_date::timestamp,
    ALTER COLUMN order_delivered_customer_date TYPE timestamp
        USING order_delivered_customer_date::timestamp,
    ALTER COLUMN order_estimated_delivery_date TYPE timestamp
        USING order_estimated_delivery_date::timestamp;

------------------------------------------------------------
-- 3. Add Date Sequence Validation Flag
------------------------------------------------------------

ALTER TABLE orders
ADD COLUMN is_date_sequence_valid boolean;

UPDATE orders
SET is_date_sequence_valid =
    CASE
        WHEN order_delivered_carrier_date < order_approved_at THEN false
        WHEN order_delivered_customer_date < order_delivered_carrier_date THEN false
        ELSE true
    END;

------------------------------------------------------------
-- 4. Verify Cleaning
------------------------------------------------------------

SELECT
    COUNT(*) - COUNT(order_approved_at) AS missing_approved_at,
    COUNT(*) - COUNT(order_delivered_carrier_date) AS missing_carrier_date,
    COUNT(*) - COUNT(order_delivered_customer_date) AS missing_customer_delivery
FROM orders;

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

SELECT
    is_date_sequence_valid,
    COUNT(*) AS orders
FROM orders
GROUP BY is_date_sequence_valid
ORDER BY is_date_sequence_valid DESC;

COMMIT;

/*
====================================================================
Cleaning Summary

• Empty strings converted to NULL values.
• Date columns converted from VARCHAR to TIMESTAMP.
• Validation flag added for date sequence checks.
• Orders table is ready for downstream analysis.

====================================================================
*/

/*
====================================================================
End of Script
====================================================================
*/
