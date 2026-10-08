-- ============================================================
-- 03_churn_analysis.sql
-- Author: AmirReza Touraji
-- Description: Churn indicators, at-risk customers, and 
--              retention signals — mirrors dashboard churn model
-- ============================================================


-- ----------------------------------------------------------
-- 1. Days since last purchase per active customer
--    Core churn signal: no activity in 90+ days = at risk
-- ----------------------------------------------------------
SELECT
    c.customer_id,
    c.full_name,
    c.segment,
    c.region,
    MAX(d.full_date)                            AS last_purchase_date,
    CURRENT_DATE - MAX(d.full_date)             AS days_since_last_purchase,
    COUNT(DISTINCT t.transaction_id)            AS total_orders,
    SUM(t.total_amount)                         AS lifetime_value,
    CASE
        WHEN CURRENT_DATE - MAX(d.full_date) <= 30  THEN 'Active'
        WHEN CURRENT_DATE - MAX(d.full_date) <= 90  THEN 'At Risk'
        WHEN CURRENT_DATE - MAX(d.full_date) <= 180 THEN 'Churning'
        ELSE 'Churned'
    END                                         AS churn_status
FROM fact_transactions t
JOIN dim_customers c ON t.customer_id = c.customer_id
JOIN dim_date d ON t.date_id = d.date_id
WHERE t.status = 'Completed'
  AND c.is_active = TRUE
GROUP BY c.customer_id, c.full_name, c.segment, c.region
ORDER BY days_since_last_purchase DESC;


-- ----------------------------------------------------------
-- 2. Churn rate by customer segment
-- ----------------------------------------------------------
WITH churn_flags AS (
    SELECT
        c.customer_id,
        c.segment,
        CASE
            WHEN CURRENT_DATE - MAX(d.full_date) > 90 THEN 1 ELSE 0
        END                                     AS is_churned
    FROM fact_transactions t
    JOIN dim_customers c ON t.customer_id = c.customer_id
    JOIN dim_date d ON t.date_id = d.date_id
    WHERE t.status = 'Completed'
    GROUP BY c.customer_id, c.segment
)
SELECT
    segment,
    COUNT(*)                                    AS total_customers,
    SUM(is_churned)                             AS churned_customers,
    ROUND(SUM(is_churned) * 100.0 / COUNT(*), 2) AS churn_rate_pct
FROM churn_flags
GROUP BY segment
ORDER BY churn_rate_pct DESC;


-- ----------------------------------------------------------
-- 3. High-value customers currently at risk of churning
--    Priority list for retention outreach
-- ----------------------------------------------------------
WITH customer_stats AS (
    SELECT
        c.customer_id,
        c.full_name,
        c.email,
        c.segment,
        MAX(d.full_date)                        AS last_purchase_date,
        CURRENT_DATE - MAX(d.full_date)         AS days_inactive,
        COUNT(DISTINCT t.transaction_id)        AS total_orders,
        SUM(t.total_amount)                     AS lifetime_value,
        ROUND(AVG(t.total_amount), 2)           AS avg_order_value
    FROM fact_transactions t
    JOIN dim_customers c ON t.customer_id = c.customer_id
    JOIN dim_date d ON t.date_id = d.date_id
    WHERE t.status = 'Completed'
    GROUP BY c.customer_id, c.full_name, c.email, c.segment
)
SELECT *
FROM customer_stats
WHERE days_inactive BETWEEN 60 AND 180       -- At risk window
  AND lifetime_value > (                     -- Above-average spenders
      SELECT AVG(s.lifetime_value)
      FROM customer_stats s
  )
ORDER BY lifetime_value DESC;


-- ----------------------------------------------------------
-- 4. Month-over-month active customer count (retention trend)
-- ----------------------------------------------------------
WITH monthly_active AS (
    SELECT
        d.year,
        d.month,
        d.month_name,
        COUNT(DISTINCT t.customer_id)           AS active_customers
    FROM fact_transactions t
    JOIN dim_date d ON t.date_id = d.date_id
    WHERE t.status = 'Completed'
    GROUP BY d.year, d.month, d.month_name
)
SELECT
    year,
    month_name,
    active_customers,
    LAG(active_customers) OVER (ORDER BY year, month)   AS prev_month_active,
    active_customers - LAG(active_customers)
        OVER (ORDER BY year, month)                     AS customer_change,
    ROUND(
        (active_customers - LAG(active_customers) OVER (ORDER BY year, month))
        * 100.0 / NULLIF(LAG(active_customers) OVER (ORDER BY year, month), 0), 2
    )                                                   AS retention_change_pct
FROM monthly_active
ORDER BY year, month;


-- ----------------------------------------------------------
-- 5. Discount sensitivity: do discounts reduce churn risk?
--    Compare avg discount received by churned vs active customers
-- ----------------------------------------------------------
WITH churn_flags AS (
    SELECT
        t.customer_id,
        ROUND(AVG(t.discount_pct), 2)           AS avg_discount_received,
        CASE
            WHEN CURRENT_DATE - MAX(d.full_date) > 90 THEN 'Churned'
            ELSE 'Active'
        END                                     AS churn_status
    FROM fact_transactions t
    JOIN dim_date d ON t.date_id = d.date_id
    WHERE t.status = 'Completed'
    GROUP BY t.customer_id
)
SELECT
    churn_status,
    COUNT(*)                                    AS num_customers,
    ROUND(AVG(avg_discount_received), 2)        AS avg_discount_pct,
    ROUND(MIN(avg_discount_received), 2)        AS min_discount_pct,
    ROUND(MAX(avg_discount_received), 2)        AS max_discount_pct
FROM churn_flags
GROUP BY churn_status;
