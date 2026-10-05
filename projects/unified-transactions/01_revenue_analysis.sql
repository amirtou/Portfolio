-- ============================================================
-- 01_revenue_analysis.sql
-- Author: AmirReza Touraji
-- Description: Revenue trends, top products, and monthly KPIs
-- ============================================================


-- ----------------------------------------------------------
-- 1. Total revenue, orders, and average order value by month
-- ----------------------------------------------------------
SELECT
    d.year,
    d.month_name,
    COUNT(DISTINCT t.transaction_id)            AS total_orders,
    SUM(t.total_amount)                         AS total_revenue,
    ROUND(AVG(t.total_amount), 2)               AS avg_order_value,
    SUM(t.total_amount) - LAG(SUM(t.total_amount))
        OVER (ORDER BY d.year, d.month)         AS revenue_mom_change
FROM fact_transactions t
JOIN dim_date d ON t.date_id = d.date_id
WHERE t.status = 'Completed'
GROUP BY d.year, d.month, d.month_name
ORDER BY d.year, d.month;


-- ----------------------------------------------------------
-- 2. Revenue by product category with margin calculation
-- ----------------------------------------------------------
SELECT
    p.category,
    COUNT(DISTINCT t.transaction_id)            AS orders,
    SUM(t.total_amount)                         AS gross_revenue,
    SUM(t.quantity * p.cost_price)              AS total_cost,
    SUM(t.total_amount) 
        - SUM(t.quantity * p.cost_price)        AS gross_profit,
    ROUND(
        (SUM(t.total_amount) - SUM(t.quantity * p.cost_price))
        / NULLIF(SUM(t.total_amount), 0) * 100, 2
    )                                           AS margin_pct
FROM fact_transactions t
JOIN dim_products p ON t.product_id = p.product_id
WHERE t.status = 'Completed'
GROUP BY p.category
ORDER BY gross_revenue DESC;


-- ----------------------------------------------------------
-- 3. Top 10 best-selling products (by revenue)
-- ----------------------------------------------------------
SELECT
    p.product_name,
    p.category,
    SUM(t.quantity)                             AS units_sold,
    SUM(t.total_amount)                         AS total_revenue,
    ROUND(AVG(t.discount_pct), 2)               AS avg_discount_pct
FROM fact_transactions t
JOIN dim_products p ON t.product_id = p.product_id
WHERE t.status = 'Completed'
GROUP BY p.product_id, p.product_name, p.category
ORDER BY total_revenue DESC
LIMIT 10;


-- ----------------------------------------------------------
-- 4. Quarter-over-quarter revenue comparison
-- ----------------------------------------------------------
SELECT
    d.year,
    d.quarter,
    SUM(t.total_amount)                         AS revenue,
    ROUND(
        (SUM(t.total_amount) - LAG(SUM(t.total_amount))
            OVER (ORDER BY d.year, d.quarter))
        / NULLIF(LAG(SUM(t.total_amount))
            OVER (ORDER BY d.year, d.quarter), 0) * 100, 2
    )                                           AS qoq_growth_pct
FROM fact_transactions t
JOIN dim_date d ON t.date_id = d.date_id
WHERE t.status = 'Completed'
GROUP BY d.year, d.quarter
ORDER BY d.year, d.quarter;


-- ----------------------------------------------------------
-- 5. Revenue split: weekday vs weekend
-- ----------------------------------------------------------
SELECT
    CASE WHEN d.is_weekend THEN 'Weekend' ELSE 'Weekday' END AS day_type,
    COUNT(t.transaction_id)                     AS num_transactions,
    SUM(t.total_amount)                         AS total_revenue,
    ROUND(AVG(t.total_amount), 2)               AS avg_transaction_value
FROM fact_transactions t
JOIN dim_date d ON t.date_id = d.date_id
WHERE t.status = 'Completed'
GROUP BY d.is_weekend
ORDER BY day_type;
