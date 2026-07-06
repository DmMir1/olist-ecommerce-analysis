/*
====================================================================
File: 05_business_rule_validation.sql
====================================================================

Purpose
-------
Validate business rules before data cleaning.

These checks identify records that violate expected business
logic but are not necessarily data entry errors.

No data is modified in this script.

====================================================================
*/

------------------------------------------------------------
-- 1. Delivery Before Purchase
------------------------------------------------------------

SELECT COUNT(*) AS delivery_before_purchase
FROM orders
WHERE order_delivered_customer_date < order_purchase_timestamp;

------------------------------------------------------------
-- 2. Approval Before Purchase
------------------------------------------------------------

SELECT COUNT(*) AS approval_before_purchase
FROM orders
WHERE order_approved_at < order_purchase_timestamp;

------------------------------------------------------------
-- 3. Carrier Pickup Before Approval
------------------------------------------------------------

SELECT COUNT(*) AS carrier_before_approval
FROM orders
WHERE order_delivered_carrier_date < order_approved_at;

------------------------------------------------------------
-- 4. Customer Delivery Before Carrier Pickup
------------------------------------------------------------

SELECT COUNT(*) AS delivery_before_carrier
FROM orders
WHERE order_delivered_customer_date < order_delivered_carrier_date;

------------------------------------------------------------
-- 5. Estimated Delivery Before Purchase
------------------------------------------------------------

SELECT COUNT(*) AS estimated_before_purchase
FROM orders
WHERE order_estimated_delivery_date < order_purchase_timestamp;

------------------------------------------------------------
-- 6. Payment Validation
------------------------------------------------------------

SELECT COUNT(*) AS invalid_installments
FROM order_payments
WHERE payment_installments < 1;

------------------------------------------------------------
-- 7. Negative or Zero Product Prices
------------------------------------------------------------

SELECT COUNT(*) AS invalid_prices
FROM order_items
WHERE price <= 0;

------------------------------------------------------------
-- 8. Negative Freight Values
------------------------------------------------------------

SELECT COUNT(*) AS invalid_freight
FROM order_items
WHERE freight_value < 0;

------------------------------------------------------------
-- 9. Review Score Validation
------------------------------------------------------------

SELECT COUNT(*) AS invalid_review_scores
FROM order_reviews
WHERE review_score NOT BETWEEN 1 AND 5;

/*
====================================================================
Findings

• Most business rules were satisfied across the dataset.
• Date sequence checks identified a number of orders where
  carrier pickup occurred before approval or delivery occurred
  before carrier pickup.
• These records were investigated further and retained as
  legitimate transactions, but flagged during cleaning.
• Invalid payment installments were also identified and
  corrected during data cleaning.

====================================================================
*/

/*
====================================================================
End of Script
====================================================================
*/
