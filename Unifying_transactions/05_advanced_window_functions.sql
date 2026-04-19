-- ============================================================
-- 05_advanced_window_functions.sql
-- Author: AmirReza Touraji
-- Description: Window functions, running totals, rankings,
--              and moving averages for trend analysis
-- ============================================================


-- ----------------------------------------------------------
-- 1. Running total revenue with % of annual target
--    (Assumes annual target = 1,000,000)
-- ----------------------------------------------------------
SELECT
    d.year,
    d.month_name,
    SUM(t.total_amount)                         AS monthly_revenue,
    SUM(SUM(t.total_amount))
        OVER (PARTITION BY d.year ORDER BY d.month) AS ytd_revenue,
    ROUND(
        SUM(SUM(t.total_amount))
            OVER (PARTITION BY d.year ORDER BY d.month)
        / 1000000.0 * 100, 2
    )                                           AS pct_of_annual_target
FROM fact_transactions t
JOIN dim_date d ON t.date_id = d.date_id
WHERE t.status = 'Completed'
GROUP BY d.year, d.month, d.month_name
ORDER BY d.year, d.month;


-- ----------------------------------------------------------
-- 2. 3-month rolling average revenue (smooths out spikes)
-- ----------------------------------------------------------
WITH monthly AS (
    SELECT
        d.year,
        d.month,
        d.month_name,
        SUM(t.total_amount)                     AS monthly_revenue
    FROM fact_transactions t
    JOIN dim_date d ON t.date_id = d.date_id
    WHERE t.status = 'Completed'
    GROUP BY d.year, d.month, d.month_name
)
SELECT
    year,
    month_name,
    monthly_revenue,
    ROUND(AVG(monthly_revenue)
        OVER (ORDER BY year, month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2
    )                                           AS rolling_3mo_avg
FROM monthly
ORDER BY year, month;


-- ----------------------------------------------------------
-- 3. Customer purchase rank within their region
--    (Who are the top spenders per region?)
-- ----------------------------------------------------------
SELECT
    c.region,
    c.full_name,
    c.segment,
    SUM(t.total_amount)                         AS total_spend,
    RANK() OVER (
        PARTITION BY c.region ORDER BY SUM(t.total_amount) DESC
    )                                           AS spend_rank_in_region,
    ROUND(
        SUM(t.total_amount) / SUM(SUM(t.total_amount))
            OVER (PARTITION BY c.region) * 100, 2
    )                                           AS pct_of_region_revenue
FROM fact_transactions t
JOIN dim_customers c ON t.customer_id = c.customer_id
WHERE t.status = 'Completed'
GROUP BY c.customer_id, c.region, c.full_name, c.segment
ORDER BY c.region, spend_rank_in_region;


-- ----------------------------------------------------------
-- 4. Product revenue rank per category with dense rank
-- ----------------------------------------------------------
SELECT
    p.category,
    p.product_name,
    SUM(t.total_amount)                         AS revenue,
    SUM(t.quantity)                             AS units_sold,
    DENSE_RANK() OVER (
        PARTITION BY p.category ORDER BY SUM(t.total_amount) DESC
    )                                           AS revenue_rank
FROM fact_transactions t
JOIN dim_products p ON t.product_id = p.product_id
WHERE t.status = 'Completed'
GROUP BY p.category, p.product_id, p.product_name
ORDER BY p.category, revenue_rank;


-- ----------------------------------------------------------
-- 5. Lead/lag: compare each customer's orders over time
--    How much did each customer spend vs their prior order?
-- ----------------------------------------------------------
WITH customer_orders AS (
    SELECT
        t.customer_id,
        c.full_name,
        d.full_date,
        t.total_amount,
        ROW_NUMBER() OVER (
            PARTITION BY t.customer_id ORDER BY d.full_date
        )                                       AS order_num
    FROM fact_transactions t
    JOIN dim_customers c ON t.customer_id = c.customer_id
    JOIN dim_date d ON t.date_id = d.date_id
    WHERE t.status = 'Completed'
)
SELECT
    customer_id,
    full_name,
    full_date,
    order_num,
    total_amount,
    LAG(total_amount) OVER (
        PARTITION BY customer_id ORDER BY full_date
    )                                           AS prev_order_amount,
    total_amount - LAG(total_amount) OVER (
        PARTITION BY customer_id ORDER BY full_date
    )                                           AS spend_change
FROM customer_orders
ORDER BY customer_id, order_num;


-- ----------------------------------------------------------
-- 6. Percentile benchmarks for transaction values
--    Useful for setting tier thresholds
-- ----------------------------------------------------------
SELECT
    ROUND(PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY total_amount), 2) AS p25,
    ROUND(PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY total_amount), 2) AS median,
    ROUND(PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY total_amount), 2) AS p75,
    ROUND(PERCENTILE_CONT(0.90) WITHIN GROUP (ORDER BY total_amount), 2) AS p90,
    ROUND(PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY total_amount), 2) AS p95,
    ROUND(AVG(total_amount), 2)                 AS mean,
    ROUND(STDDEV(total_amount), 2)              AS std_dev
FROM fact_transactions
WHERE status = 'Completed';
