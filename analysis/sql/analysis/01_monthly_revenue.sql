/*
====================================================================
File: 01_monthly_revenue.sql
====================================================================

Business Question
-----------------
How did the Olist marketplace grow over time in terms of
orders, revenue and average order value?

This script documents the analytical process used to build
the monthly revenue dataset for the Power BI dashboard.

====================================================================
*/

------------------------------------------------------------
-- 1. Initial Exploration
-- What time period does the dataset cover?
------------------------------------------------------------

SELECT
    DATE_TRUNC('month', order_purchase_timestamp) AS month,
    COUNT(*) AS orders,
    ROUND(SUM(oi.price + oi.freight_value)::numeric, 2) AS revenue
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status NOT IN ('canceled', 'unavailable')
GROUP BY DATE_TRUNC('month', order_purchase_timestamp)
ORDER BY month;

------------------------------------------------------------
-- 2. Monthly Revenue Analysis
-- Add items sold, average order value and MoM growth
------------------------------------------------------------

WITH monthly AS (
    SELECT
        DATE_TRUNC('month', o.order_purchase_timestamp) AS month,
        COUNT(DISTINCT o.order_id) AS orders,
        COUNT(oi.order_item_id) AS items_sold,
        ROUND(SUM(oi.price + oi.freight_value)::numeric, 2) AS revenue,
        ROUND(AVG(oi.price + oi.freight_value)::numeric, 2) AS avg_order_value
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    WHERE o.order_status NOT IN ('canceled', 'unavailable')
      AND o.order_purchase_timestamp >= '2016-10-01'
      AND o.order_purchase_timestamp < '2018-09-01'
    GROUP BY DATE_TRUNC('month', o.order_purchase_timestamp)
)
SELECT
    month,
    orders,
    items_sold,
    revenue,
    avg_order_value,
    ROUND(
        100.0 * (revenue - LAG(revenue) OVER (ORDER BY month))
        / NULLIF(LAG(revenue) OVER (ORDER BY month), 0),
        1
    ) AS revenue_mom_pct
FROM monthly
ORDER BY month;

------------------------------------------------------------
-- 3. Final Export Dataset
-- Used for the Executive Overview dashboard
------------------------------------------------------------

WITH monthly AS (
    SELECT
        DATE_TRUNC('month', o.order_purchase_timestamp) AS month,
        COUNT(DISTINCT o.order_id) AS orders,
        ROUND(SUM(oi.price + oi.freight_value)::numeric, 2) AS revenue
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    WHERE o.order_status NOT IN ('canceled', 'unavailable')
      AND o.order_purchase_timestamp >= '2016-10-01'
      AND o.order_purchase_timestamp < '2018-09-01'
      AND DATE_TRUNC('month', o.order_purchase_timestamp) <> '2016-12-01'
    GROUP BY DATE_TRUNC('month', o.order_purchase_timestamp)
)
SELECT
    month,
    orders,
    revenue,
    ROUND(revenue / orders, 2) AS avg_order_value_true
FROM monthly
ORDER BY month;

/*
====================================================================
Business Insight

• The marketplace experienced rapid growth throughout 2017.
• November 2017 shows a clear revenue spike driven by Black Friday.
• Revenue stabilized at around R$1M per month during 2018.
• December 2016 was excluded from the final export because it
  represents an incomplete month and would distort trend analysis.

The final query above was exported to CSV and used in the
Power BI Executive Overview dashboard.

====================================================================
*/

/*
====================================================================
End of Script
====================================================================
*/
