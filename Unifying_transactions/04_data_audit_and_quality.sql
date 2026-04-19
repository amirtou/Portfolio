-- ============================================================
-- 04_data_audit_and_quality.sql
-- Author: AmirReza Touraji
-- Description: Data integrity checks, discrepancy detection,
--              and reconciliation queries
--              (Relevant to CRM auditing and compliance work)
-- ============================================================


-- ----------------------------------------------------------
-- 1. Null / missing value audit across fact_transactions
-- ----------------------------------------------------------
SELECT
    'fact_transactions'                         AS table_name,
    COUNT(*)                                    AS total_rows,
    SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END)   AS null_customer_id,
    SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END)    AS null_product_id,
    SUM(CASE WHEN date_id IS NULL THEN 1 ELSE 0 END)       AS null_date_id,
    SUM(CASE WHEN total_amount IS NULL THEN 1 ELSE 0 END)  AS null_total_amount,
    SUM(CASE WHEN status IS NULL THEN 1 ELSE 0 END)        AS null_status
FROM fact_transactions;


-- ----------------------------------------------------------
-- 2. Detect transactions where total_amount doesn't match
--    quantity * unit_price * (1 - discount_pct/100)
--    i.e. find calculation discrepancies
-- ----------------------------------------------------------
SELECT
    transaction_id,
    customer_id,
    product_id,
    quantity,
    unit_price,
    discount_pct,
    total_amount                                AS recorded_amount,
    ROUND(quantity * unit_price * (1 - discount_pct / 100.0), 2) AS expected_amount,
    ROUND(
        total_amount - (quantity * unit_price * (1 - discount_pct / 100.0)), 2
    )                                           AS discrepancy
FROM fact_transactions
WHERE ABS(
    total_amount - (quantity * unit_price * (1 - discount_pct / 100.0))
) > 0.01                                        -- Allow 1-cent rounding tolerance
ORDER BY ABS(discrepancy) DESC;


-- ----------------------------------------------------------
-- 3. Orphaned records check
--    Transactions referencing non-existent customers/products
-- ----------------------------------------------------------
-- Orphaned customer references
SELECT 'Orphaned customer_id' AS issue_type, COUNT(*) AS affected_rows
FROM fact_transactions t
LEFT JOIN dim_customers c ON t.customer_id = c.customer_id
WHERE c.customer_id IS NULL

UNION ALL

-- Orphaned product references
SELECT 'Orphaned product_id', COUNT(*)
FROM fact_transactions t
LEFT JOIN dim_products p ON t.product_id = p.product_id
WHERE p.product_id IS NULL

UNION ALL

-- Orphaned date references
SELECT 'Orphaned date_id', COUNT(*)
FROM fact_transactions t
LEFT JOIN dim_date d ON t.date_id = d.date_id
WHERE d.date_id IS NULL;


-- ----------------------------------------------------------
-- 4. Duplicate transaction detection
-- ----------------------------------------------------------
SELECT
    customer_id,
    product_id,
    date_id,
    total_amount,
    COUNT(*)                                    AS duplicate_count
FROM fact_transactions
GROUP BY customer_id, product_id, date_id, total_amount
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;


-- ----------------------------------------------------------
-- 5. Refund rate by product and category (anomaly detection)
--    High refund rates flag potential data or product issues
-- ----------------------------------------------------------
SELECT
    p.category,
    p.product_name,
    COUNT(*)                                    AS total_transactions,
    SUM(CASE WHEN t.status = 'Refunded' THEN 1 ELSE 0 END) AS refunds,
    ROUND(
        SUM(CASE WHEN t.status = 'Refunded' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*), 2
    )                                           AS refund_rate_pct
FROM fact_transactions t
JOIN dim_products p ON t.product_id = p.product_id
GROUP BY p.category, p.product_id, p.product_name
HAVING refund_rate_pct > 10                    -- Flag anything above 10%
ORDER BY refund_rate_pct DESC;


-- ----------------------------------------------------------
-- 6. Month-end reconciliation summary
--    Cross-check: sum of completed transactions = expected revenue
-- ----------------------------------------------------------
SELECT
    d.year,
    d.month_name,
    COUNT(*)                                    AS total_transactions,
    SUM(CASE WHEN t.status = 'Completed' THEN 1 ELSE 0 END)  AS completed,
    SUM(CASE WHEN t.status = 'Refunded'  THEN 1 ELSE 0 END)  AS refunded,
    SUM(CASE WHEN t.status = 'Pending'   THEN 1 ELSE 0 END)  AS pending,
    SUM(CASE WHEN t.status = 'Completed' THEN t.total_amount ELSE 0 END) AS gross_revenue,
    SUM(CASE WHEN t.status = 'Refunded'  THEN t.total_amount ELSE 0 END) AS total_refunds,
    SUM(CASE WHEN t.status = 'Completed' THEN t.total_amount ELSE 0 END)
    - SUM(CASE WHEN t.status = 'Refunded' THEN t.total_amount ELSE 0 END) AS net_revenue
FROM fact_transactions t
JOIN dim_date d ON t.date_id = d.date_id
GROUP BY d.year, d.month, d.month_name
ORDER BY d.year, d.month;
