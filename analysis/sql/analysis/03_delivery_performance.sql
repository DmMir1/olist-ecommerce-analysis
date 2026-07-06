/*
====================================================================
File: 03_delivery_performance.sql
====================================================================

Business Question
-----------------
How efficiently are customer orders delivered across Brazil?

This analysis evaluates overall delivery performance and
compares delivery metrics across customer states. The
results were used to build the Delivery Performance page
of the Power BI dashboard.

====================================================================
*/

------------------------------------------------------------
-- Overall Delivery Performance
------------------------------------------------------------
-- Evaluate delivery speed, promised delivery time,
-- early/late deliveries and late delivery rate.

SELECT
    COUNT(*) AS delivered_orders,
    ROUND(
        AVG(
            EXTRACT(EPOCH FROM (
                order_delivered_customer_date - order_purchase_timestamp
            )) / 86400
        )::numeric,
        1
    ) AS avg_days_to_deliver,
    ROUND(
        AVG(
            EXTRACT(EPOCH FROM (
                order_estimated_delivery_date - order_purchase_timestamp
            )) / 86400
        )::numeric,
        1
    ) AS avg_days_promised,
    ROUND(
        AVG(
            EXTRACT(EPOCH FROM (
                order_estimated_delivery_date - order_delivered_customer_date
            )) / 86400
        )::numeric,
        1
    ) AS avg_days_early_late,
    COUNT(*) FILTER (
        WHERE order_delivered_customer_date > order_estimated_delivery_date
    ) AS late_deliveries,
    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE order_delivered_customer_date > order_estimated_delivery_date
        ) / COUNT(*)::numeric,
        1
    ) AS late_pct
FROM orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL
  AND order_estimated_delivery_date IS NOT NULL
  AND is_date_sequence_valid = true
  AND order_purchase_timestamp >= '2016-10-01'
  AND order_purchase_timestamp < '2018-09-01'
  AND DATE_TRUNC('month', order_purchase_timestamp) <> '2016-12-01';

------------------------------------------------------------
-- Delivery Performance by Customer State
------------------------------------------------------------

SELECT
    c.customer_state,
    COUNT(*) AS delivered_orders,
    ROUND(
        AVG(
            EXTRACT(EPOCH FROM (
                o.order_delivered_customer_date - o.order_purchase_timestamp
            )) / 86400
        )::numeric,
        1
    ) AS avg_days_to_deliver,
    ROUND(
        AVG(
            EXTRACT(EPOCH FROM (
                o.order_estimated_delivery_date - o.order_delivered_customer_date
            )) / 86400
        )::numeric,
        1
    ) AS avg_days_early_late,
    COUNT(*) FILTER (
        WHERE o.order_delivered_customer_date > o.order_estimated_delivery_date
    ) AS late_deliveries,
    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE o.order_delivered_customer_date > o.order_estimated_delivery_date
        ) / COUNT(*)::numeric,
        1
    ) AS late_pct
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
  AND o.order_estimated_delivery_date IS NOT NULL
  AND o.is_date_sequence_valid = true
  AND o.order_purchase_timestamp >= '2016-10-01'
  AND o.order_purchase_timestamp < '2018-09-01'
  AND DATE_TRUNC('month', o.order_purchase_timestamp) <> '2016-12-01'
GROUP BY c.customer_state
ORDER BY avg_days_to_deliver DESC;

------------------------------------------------------------
-- Export Notes
------------------------------------------------------------
-- Export format : CSV
-- File name     : delivery_performance.csv
-- Destination   : analysis/exports/
-- Used in       : Power BI → Delivery Performance page

/*
====================================================================
Key Insights

• Most valid orders were delivered on or before the
  estimated delivery date.
• Average delivery time can be compared directly with the
  promised delivery time to evaluate logistics performance.
• Delivery speed varies across Brazilian states, reflecting
  regional logistical differences.
• Orders flagged during the cleaning phase were excluded to
  ensure accurate delivery performance metrics.

====================================================================
*/

/*
====================================================================
End of Script
====================================================================
*/
