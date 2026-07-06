/*
====================================================================
File: 04_customer_segmentation.sql
====================================================================

Business Question
-----------------
Who are Olist's most valuable customers, and how can they
be segmented based on purchasing behaviour?

This analysis applies the RFM (Recency, Frequency, Monetary)
framework to classify customers into actionable business
segments and evaluates customer purchase behaviour.

====================================================================
*/

------------------------------------------------------------
-- 1. Customer-Level RFM Analysis
------------------------------------------------------------

WITH rfm_base AS (
    SELECT
        c.customer_unique_id,
        MAX(o.order_purchase_timestamp) AS last_order_date,
        COUNT(DISTINCT o.order_id) AS frequency,
        ROUND(SUM(oi.price + oi.freight_value)::numeric, 2) AS monetary
    FROM orders o
    JOIN customers c
        ON o.customer_id = c.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    WHERE o.order_status NOT IN ('canceled', 'unavailable')
      AND o.order_purchase_timestamp >= '2016-10-01'
      AND o.order_purchase_timestamp < '2018-09-01'
      AND DATE_TRUNC('month', o.order_purchase_timestamp) <> '2016-12-01'
    GROUP BY c.customer_unique_id
),
rfm_scored AS (
    SELECT
        customer_unique_id,
        last_order_date,
        frequency,
        monetary,
        EXTRACT(DAY FROM (TIMESTAMP '2018-09-01' - last_order_date))::int AS recency_days,
        NTILE(5) OVER (ORDER BY last_order_date DESC) AS r_score,
        NTILE(5) OVER (ORDER BY frequency ASC, monetary ASC) AS f_score,
        NTILE(5) OVER (ORDER BY monetary ASC) AS m_score
    FROM rfm_base
)
SELECT
    customer_unique_id,
    recency_days,
    frequency,
    monetary,
    r_score,
    f_score,
    m_score,
    r_score + f_score + m_score AS rfm_total,
    CASE
        WHEN r_score >= 4 AND f_score >= 4 THEN 'Champion'
        WHEN r_score >= 3 AND f_score >= 3 THEN 'Loyal'
        WHEN r_score >= 4 AND f_score < 3 THEN 'Recent'
        WHEN r_score < 3 AND f_score >= 3 THEN 'At Risk'
        WHEN r_score <= 2 AND f_score <= 2 THEN 'Lost'
        ELSE 'Potential'
    END AS segment
FROM rfm_scored
ORDER BY rfm_total DESC;

------------------------------------------------------------
-- 2. RFM Segment Summary
------------------------------------------------------------

WITH rfm_base AS (
    SELECT
        c.customer_unique_id,
        MAX(o.order_purchase_timestamp) AS last_order_date,
        COUNT(DISTINCT o.order_id) AS frequency,
        ROUND(SUM(oi.price + oi.freight_value)::numeric, 2) AS monetary
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status NOT IN ('canceled', 'unavailable')
      AND o.order_purchase_timestamp >= '2016-10-01'
      AND o.order_purchase_timestamp < '2018-09-01'
      AND DATE_TRUNC('month', o.order_purchase_timestamp) <> '2016-12-01'
    GROUP BY c.customer_unique_id
),
rfm_scored AS (
    SELECT
        customer_unique_id,
        frequency,
        monetary,
        EXTRACT(DAY FROM (TIMESTAMP '2018-09-01' - last_order_date))::int AS recency_days,
        NTILE(5) OVER (ORDER BY last_order_date DESC) AS r_score,
        NTILE(5) OVER (ORDER BY frequency ASC, monetary ASC) AS f_score,
        NTILE(5) OVER (ORDER BY monetary ASC) AS m_score
    FROM rfm_base
),
rfm_segmented AS (
    SELECT
        customer_unique_id,
        recency_days,
        frequency,
        monetary,
        CASE
            WHEN r_score >= 4 AND f_score >= 4 THEN 'Champion'
            WHEN r_score >= 3 AND f_score >= 3 THEN 'Loyal'
            WHEN r_score >= 4 AND f_score < 3 THEN 'Recent'
            WHEN r_score < 3 AND f_score >= 3 THEN 'At Risk'
            WHEN r_score <= 2 AND f_score <= 2 THEN 'Lost'
            ELSE 'Potential'
        END AS segment
    FROM rfm_scored
)
SELECT
    segment,
    COUNT(*) AS customers,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER ()::numeric, 1) AS pct_of_customers,
    ROUND(AVG(monetary)::numeric, 2) AS avg_monetary,
    ROUND(SUM(monetary)::numeric, 2) AS total_revenue,
    ROUND(100.0 * SUM(monetary) / SUM(SUM(monetary)) OVER ()::numeric, 1) AS pct_of_revenue,
    ROUND(AVG(frequency)::numeric, 2) AS avg_orders,
    ROUND(AVG(recency_days)::numeric, 0) AS avg_recency_days
FROM rfm_segmented
GROUP BY segment
ORDER BY total_revenue DESC;

------------------------------------------------------------
-- 3. Repeat Purchase Analysis
------------------------------------------------------------

SELECT
    frequency,
    COUNT(*) AS customers,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER ()::numeric, 1) AS pct
FROM (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS frequency
    FROM orders o
    JOIN customers c
        ON o.customer_id = c.customer_id
    WHERE o.order_status NOT IN ('canceled', 'unavailable')
      AND o.order_purchase_timestamp >= '2016-10-01'
      AND o.order_purchase_timestamp < '2018-09-01'
      AND DATE_TRUNC('month', o.order_purchase_timestamp) <> '2016-12-01'
    GROUP BY c.customer_unique_id
) freq_dist
GROUP BY frequency
ORDER BY frequency;

------------------------------------------------------------
-- Export Notes
------------------------------------------------------------
-- Export format : CSV
-- File name     : customer_segmentation.csv
-- Destination   : analysis/exports/
-- Used in       : Power BI → Customer & Seller Analysis page

/*
====================================================================
Key Insights

• RFM segmentation identifies high-value customers based on
  recency, purchase frequency and monetary value.
• Champion and Loyal customers contribute a significant share
  of marketplace revenue.
• Most customers placed only a single order, indicating that
  customer retention is a key opportunity for business growth.
• The exported dataset supports the Customer & Seller Analysis
  page in the Power BI dashboard.

====================================================================
*/

/*
====================================================================
End of Script
====================================================================
*/
