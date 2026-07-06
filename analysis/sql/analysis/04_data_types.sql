/*
====================================================================
File: 04_data_types.sql
====================================================================

Purpose
-------
Inspect imported data types before data cleaning.

This script identifies columns that were imported with
incorrect data types and require conversion before analysis.

No data is modified in this script.

====================================================================
*/

------------------------------------------------------------
-- 1. Orders Table
------------------------------------------------------------

SELECT
    column_name,
    data_type
FROM information_schema.columns
WHERE table_name = 'orders'
ORDER BY ordinal_position;

------------------------------------------------------------
-- 2. Order Items Table
------------------------------------------------------------

SELECT
    column_name,
    data_type
FROM information_schema.columns
WHERE table_name = 'order_items'
ORDER BY ordinal_position;

------------------------------------------------------------
-- 3. Order Reviews Table
------------------------------------------------------------

SELECT
    column_name,
    data_type
FROM information_schema.columns
WHERE table_name = 'order_reviews'
ORDER BY ordinal_position;

------------------------------------------------------------
-- 4. Timestamp Columns Requiring Attention
------------------------------------------------------------

-- Verify that date columns were imported as character varying
-- instead of timestamp.

SELECT
    table_name,
    column_name,
    data_type
FROM information_schema.columns
WHERE table_name IN ('orders', 'order_items', 'order_reviews')
AND column_name IN (
    'order_purchase_timestamp',
    'order_approved_at',
    'order_delivered_carrier_date',
    'order_delivered_customer_date',
    'order_estimated_delivery_date',
    'shipping_limit_date',
    'review_creation_date',
    'review_answer_timestamp'
)
ORDER BY
    table_name,
    column_name;

/*
====================================================================
Findings

• Several date columns were imported as character varying
  instead of timestamp.
• Date calculations and time-series analysis cannot be
  performed until these columns are converted.
• Data type conversion is performed in the cleaning scripts.

====================================================================
*/

/*
====================================================================
End of Script
====================================================================
*/
