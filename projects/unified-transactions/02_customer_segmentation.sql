-- ============================================================
-- 02_customer_segmentation.sql
-- Author: AmirReza Touraji
-- Description: RFM analysis, customer tiers, and spend segments
--              Replicates segmentation logic from Power BI dashboard
-- ============================================================


-- ----------------------------------------------------------
-- 1. RFM Scoring (Recency, Frequency, Monetary)
--    Scores each customer 1-5 on each dimension
-- ----------------------------------------------------------
WITH rfm_base AS (
    SELECT
        c.customer_id,
        c.full_name,
        c.segment,
        c.region,
        CURRENT_DATE - MAX(d.full_date)         AS recency_days,
        COUNT(DISTINCT t.transaction_id)         AS frequency,
        SUM(t.total_amount)                      AS monetary
    FROM fact_transactions t
    JOIN dim_customers c ON t.customer_id = c.customer_id
    JOIN dim_date d ON t.date_id = d.date_id
    WHERE t.status = 'Completed'
    GROUP BY c.customer_id, c.full_name, c.segment, c.region
),
rfm_scored AS (
    SELECT *,
        NTILE(5) OVER (ORDER BY recency_days ASC)   AS r_score,  -- lower days = better
        NTILE(5) OVER (ORDER BY frequency DESC)      AS f_score,
        NTILE(5) OVER (ORDER BY monetary DESC)       AS m_score
    FROM rfm_base
)
SELECT
    customer_id,
    full_name,
    segment,
    region,
    recency_days,
    frequency,
    ROUND(monetary, 2)                          AS lifetime_value,
    r_score,
    f_score,
    m_score,
    ROUND((r_score + f_score + m_score) / 3.0, 2) AS rfm_avg_score,
    CASE
        WHEN (r_score + f_score + m_score) >= 13 THEN 'Champions'
        WHEN (r_score + f_score + m_score) >= 10 THEN 'Loyal'
        WHEN (r_score + f_score + m_score) >= 7  THEN 'At Risk'
        ELSE 'Lapsed'
    END                                         AS customer_label
FROM rfm_scored
ORDER BY rfm_avg_score DESC;


-- ----------------------------------------------------------
-- 2. The 80/20 rule: revenue share by customer percentile
--    Validates: do top 20% generate ~60-80% of revenue?
-- ----------------------------------------------------------
WITH customer_revenue AS (
    SELECT
        t.customer_id,
        SUM(t.total_amount)                     AS total_spend
    FROM fact_transactions t
    WHERE t.status = 'Completed'
    GROUP BY t.customer_id
),
percentile_buckets AS (
    SELECT
        customer_id,
        total_spend,
        NTILE(10) OVER (ORDER BY total_spend DESC) AS decile  -- 1 = top 10%
    FROM customer_revenue
)
SELECT
    decile,
    COUNT(*)                                    AS num_customers,
    SUM(total_spend)                            AS segment_revenue,
    ROUND(
        SUM(total_spend) / SUM(SUM(total_spend)) OVER () * 100, 2
    )                                           AS revenue_share_pct,
    ROUND(
        SUM(SUM(total_spend)) OVER (ORDER BY decile) 
        / SUM(SUM(total_spend)) OVER () * 100, 2
    )                                           AS cumulative_revenue_pct
FROM percentile_buckets
GROUP BY decile
ORDER BY decile;


-- ----------------------------------------------------------
-- 3. Customer spend distribution across product categories
-- ----------------------------------------------------------
SELECT
    c.segment                                   AS customer_segment,
    p.category                                  AS product_category,
    COUNT(DISTINCT t.customer_id)               AS unique_buyers,
    SUM(t.total_amount)                         AS total_revenue,
    ROUND(AVG(t.total_amount), 2)               AS avg_order_value
FROM fact_transactions t
JOIN dim_customers c ON t.customer_id = c.customer_id
JOIN dim_products p ON t.product_id = p.product_id
WHERE t.status = 'Completed'
GROUP BY c.segment, p.category
ORDER BY c.segment, total_revenue DESC;


-- ----------------------------------------------------------
-- 4. New vs returning customer revenue split by month
-- ----------------------------------------------------------
WITH first_purchase AS (
    SELECT
        customer_id,
        MIN(date_id)                            AS first_date_id
    FROM fact_transactions
    WHERE status = 'Completed'
    GROUP BY customer_id
)
SELECT
    d.year,
    d.month_name,
    SUM(CASE WHEN t.date_id = fp.first_date_id THEN t.total_amount ELSE 0 END) AS new_customer_revenue,
    SUM(CASE WHEN t.date_id > fp.first_date_id  THEN t.total_amount ELSE 0 END) AS returning_customer_revenue,
    COUNT(DISTINCT CASE WHEN t.date_id = fp.first_date_id THEN t.customer_id END) AS new_customers,
    COUNT(DISTINCT CASE WHEN t.date_id > fp.first_date_id  THEN t.customer_id END) AS returning_customers
FROM fact_transactions t
JOIN dim_date d ON t.date_id = d.date_id
JOIN first_purchase fp ON t.customer_id = fp.customer_id
WHERE t.status = 'Completed'
GROUP BY d.year, d.month, d.month_name
ORDER BY d.year, d.month;
