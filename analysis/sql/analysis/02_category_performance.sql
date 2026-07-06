/*
====================================================================
File: 02_category_performance.sql
====================================================================

Business Question
-----------------
Which product categories generate the most revenue and sales?

This analysis identifies the best-performing product
categories and produces the dataset used in the
Power BI Category Analysis dashboard.

====================================================================
*/

------------------------------------------------------------
-- 1. Final Export Dataset
------------------------------------------------------------
-- Rank product categories by revenue, number of orders
-- and average item price.

-- Output:
-- exports/category_performance.csv

-- This query was exported to CSV and used in the
-- Power BI Category Analysis dashboard.

SELECT
    COALESCE(t.product_category_name_english, 'unknown') AS category,
    COUNT(DISTINCT o.order_id) AS orders,
    ROUND(SUM(oi.price + oi.freight_value)::numeric, 2) AS revenue,
    ROUND(
        100.0 * SUM(oi.price + oi.freight_value)::numeric
        / SUM(SUM(oi.price + oi.freight_value)::numeric) OVER (),
        2
    ) AS revenue_pct,
    ROUND(AVG(oi.price)::numeric, 2) AS avg_item_price
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
JOIN products p
    ON oi.product_id = p.product_id
LEFT JOIN product_category_name_translation t
    ON p.product_category_name = t.product_category_name
WHERE o.order_status NOT IN ('canceled', 'unavailable')
  AND o.order_purchase_timestamp >= '2016-10-01'
  AND o.order_purchase_timestamp < '2018-09-01'
  AND DATE_TRUNC('month', o.order_purchase_timestamp) <> '2016-12-01'
GROUP BY
    COALESCE(t.product_category_name_english, 'unknown')
ORDER BY revenue DESC;

/*
====================================================================
Business Insight

• Revenue is concentrated in a relatively small number of
  product categories.
• Home, furniture and lifestyle-related categories dominate
  marketplace sales.
• The final query above was exported to CSV and used in the
  Power BI Category Analysis dashboard.

====================================================================
*/

/*
====================================================================
End of Script
====================================================================
*/
