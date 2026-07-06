/*
====================================================================
File: 05_seller_performance.sql
====================================================================

Business Question
-----------------
Which sellers generate the highest business value, and how
can they be classified based on revenue and customer
satisfaction?

This analysis evaluates seller performance using revenue,
delivery quality and customer reviews, then groups sellers
into business performance quadrants.

====================================================================
*/

------------------------------------------------------------
-- 1. Seller Performance Analysis
------------------------------------------------------------

SELECT
    s.seller_id,
    s.seller_city,
    s.seller_state,
    COUNT(DISTINCT o.order_id) AS orders,
    ROUND(SUM(oi.price + oi.freight_value)::numeric, 2) AS revenue,
    ROUND(AVG(oi.price)::numeric, 2) AS avg_item_price,
    ROUND(AVG(
        EXTRACT(EPOCH FROM (o.order_delivered_customer_date - o.order_purchase_timestamp))
        / 86400
    )::numeric, 1) AS avg_days_to_deliver,
    ROUND(100.0 * COUNT(*) FILTER (
        WHERE o.order_delivered_customer_date > o.order_estimated_delivery_date
    ) / COUNT(*)::numeric, 1) AS late_pct,
    ROUND(AVG(r.review_score)::numeric, 2) AS avg_review_score,
    COUNT(DISTINCT r.review_id) AS reviews_received
FROM sellers s
JOIN order_items oi ON s.seller_id = oi.seller_id
JOIN orders o ON oi.order_id = o.order_id
LEFT JOIN order_reviews r ON o.order_id = r.order_id
WHERE o.order_status NOT IN ('canceled', 'unavailable')
  AND o.order_purchase_timestamp >= '2016-10-01'
  AND o.order_purchase_timestamp < '2018-09-01'
  AND DATE_TRUNC('month', o.order_purchase_timestamp) <> '2016-12-01'
  AND o.order_delivered_customer_date IS NOT NULL
  AND o.is_date_sequence_valid = true
GROUP BY s.seller_id, s.seller_city, s.seller_state
HAVING COUNT(DISTINCT o.order_id) >= 10
ORDER BY revenue DESC;

------------------------------------------------------------
-- 2. Seller Performance Quadrants
------------------------------------------------------------

WITH seller_stats AS (
    SELECT
        s.seller_id,
        s.seller_city,
        s.seller_state,
        COUNT(DISTINCT o.order_id) AS orders,
        ROUND(SUM(oi.price + oi.freight_value)::numeric, 2) AS revenue,
        ROUND(AVG(r.review_score)::numeric, 2) AS avg_review_score,
        ROUND(100.0 * COUNT(*) FILTER (
            WHERE o.order_delivered_customer_date > o.order_estimated_delivery_date
        ) / COUNT(*)::numeric, 1) AS late_pct
    FROM sellers s
    JOIN order_items oi ON s.seller_id = oi.seller_id
    JOIN orders o ON oi.order_id = o.order_id
    LEFT JOIN order_reviews r ON o.order_id = r.order_id
    WHERE o.order_status NOT IN ('canceled', 'unavailable')
      AND o.order_purchase_timestamp >= '2016-10-01'
      AND o.order_purchase_timestamp < '2018-09-01'
      AND DATE_TRUNC('month', o.order_purchase_timestamp) <> '2016-12-01'
      AND o.order_delivered_customer_date IS NOT NULL
      AND o.is_date_sequence_valid = true
    GROUP BY s.seller_id, s.seller_city, s.seller_state
    HAVING COUNT(DISTINCT o.order_id) >= 10
),
medians AS (
    SELECT
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY revenue) AS median_revenue,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY avg_review_score) AS median_review
    FROM seller_stats
)
SELECT
    ss.seller_id,
    ss.seller_city,
    ss.seller_state,
    ss.orders,
    ss.revenue,
    ss.avg_review_score,
    ss.late_pct,
    m.median_revenue,
    m.median_review,
    CASE
        WHEN ss.revenue >= m.median_revenue AND ss.avg_review_score >= m.median_review THEN 'Star'
        WHEN ss.revenue >= m.median_revenue AND ss.avg_review_score < m.median_review THEN 'Risk'
        WHEN ss.revenue < m.median_revenue AND ss.avg_review_score >= m.median_review THEN 'Niche'
        ELSE 'Underperformer'
    END AS quadrant
FROM seller_stats ss
CROSS JOIN medians m
ORDER BY ss.revenue DESC;

------------------------------------------------------------
-- 3. Seller Quadrant Summary
------------------------------------------------------------

WITH seller_stats AS (
    SELECT
        s.seller_id,
        COUNT(DISTINCT o.order_id) AS orders,
        ROUND(SUM(oi.price + oi.freight_value)::numeric, 2) AS revenue,
        ROUND(AVG(r.review_score)::numeric, 2) AS avg_review_score,
        ROUND(100.0 * COUNT(*) FILTER (
            WHERE o.order_delivered_customer_date > o.order_estimated_delivery_date
        ) / COUNT(*)::numeric, 1) AS late_pct
    FROM sellers s
    JOIN order_items oi ON s.seller_id = oi.seller_id
    JOIN orders o ON oi.order_id = o.order_id
    LEFT JOIN order_reviews r ON o.order_id = r.order_id
    WHERE o.order_status NOT IN ('canceled', 'unavailable')
      AND o.order_purchase_timestamp >= '2016-10-01'
      AND o.order_purchase_timestamp < '2018-09-01'
      AND DATE_TRUNC('month', o.order_purchase_timestamp) <> '2016-12-01'
      AND o.order_delivered_customer_date IS NOT NULL
      AND o.is_date_sequence_valid = true
    GROUP BY s.seller_id
    HAVING COUNT(DISTINCT o.order_id) >= 10
),
medians AS (
    SELECT
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY revenue) AS median_revenue,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY avg_review_score) AS median_review
    FROM seller_stats
),
quadrants AS (
    SELECT
        ss.*,
        CASE
            WHEN ss.revenue >= m.median_revenue AND ss.avg_review_score >= m.median_review THEN 'Star'
            WHEN ss.revenue >= m.median_revenue AND ss.avg_review_score < m.median_review THEN 'Risk'
            WHEN ss.revenue < m.median_revenue AND ss.avg_review_score >= m.median_review THEN 'Niche'
            ELSE 'Underperformer'
        END AS quadrant
    FROM seller_stats ss
    CROSS JOIN medians m
)
SELECT
    quadrant,
    COUNT(*) AS sellers,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER ()::numeric, 1) AS pct_of_sellers,
    ROUND(SUM(revenue)::numeric, 2) AS total_revenue,
    ROUND(100.0 * SUM(revenue) / SUM(SUM(revenue)) OVER ()::numeric, 1) AS pct_of_revenue,
    ROUND(AVG(revenue)::numeric, 2) AS avg_revenue,
    ROUND(AVG(avg_review_score)::numeric, 2) AS avg_review_score,
    ROUND(AVG(late_pct)::numeric, 1) AS avg_late_pct,
    ROUND(AVG(orders)::numeric, 0) AS avg_orders
FROM quadrants
GROUP BY quadrant
ORDER BY total_revenue DESC;

------------------------------------------------------------
-- Export Notes
------------------------------------------------------------
-- Export format : CSV
-- File name     : seller_performance.csv
-- Destination   : analysis/exports/
-- Used in       : Power BI → Customer & Seller Analysis page

/*
====================================================================
Key Insights

• Seller performance was evaluated using revenue, delivery
  reliability and customer review scores.
• Median-based quadrants classify sellers into Star, Risk,
  Niche and Underperformer segments.
• Micro-sellers with fewer than 10 completed orders were
  excluded to improve statistical reliability.
• The exported dataset supports the Customer & Seller
  Analysis page in the Power BI dashboard.

====================================================================
*/

/*
====================================================================
End of Script
====================================================================
