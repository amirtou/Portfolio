-- ============================================================
-- 02_data_quality_audit.sql
-- Every check returns how many rows fail and what was done about it.
-- ============================================================

CREATE OR REPLACE TABLE rpt_data_quality AS
WITH n AS (SELECT count(*) AS total FROM fact_transaction)
SELECT check_name, scope, rows_affected,
       round(100.0 * rows_affected / denominator, 1) AS pct_of_scope,
       action
FROM (
    SELECT 'Account balance is blank' AS check_name, 'Checking rows' AS scope,
           count(*) FILTER (WHERE account_balance IS NULL) AS rows_affected,
           count(*) AS denominator,
           'Column dropped from the model' AS action
    FROM stg_checking
    UNION ALL
    SELECT 'Transaction dated before customer joined', 'All transactions',
           count(*) FILTER (WHERE dq_before_join), (SELECT total FROM n),
           'Flagged; excluded from analysis'
    FROM fact_transaction
    UNION ALL
    SELECT 'Checking activity on a savings-only customer', 'Checking rows',
           count(*) FILTER (WHERE dq_product_mismatch), count(*) FILTER (WHERE source = 'Checking'),
           'Flagged for review; kept in analysis'
    FROM fact_transaction
    UNION ALL
    SELECT 'Transaction outside the reporting period', 'All transactions',
           count(*) FILTER (WHERE dq_out_of_period), (SELECT total FROM n),
           'Flagged; excluded from 2022-2024 figures'
    FROM fact_transaction
    UNION ALL
    SELECT 'Duplicate transaction (same customer, date, amount)', 'All transactions',
           (SELECT count(*) - count(DISTINCT (customer_id, txn_date, amount, source)) FROM fact_transaction),
           (SELECT total FROM n), 'None found'
    UNION ALL
    SELECT 'Transaction with no matching customer', 'All transactions',
           (SELECT count(*) FROM (SELECT customer_id FROM stg_checking UNION ALL SELECT customer_id FROM stg_credit_card) t
            WHERE customer_id NOT IN (SELECT customer_id FROM stg_customers)),
           (SELECT total FROM n), 'None found'
    UNION ALL
    SELECT 'Zero or negative amount', 'All transactions',
           count(*) FILTER (WHERE amount <= 0), (SELECT total FROM n), 'None found'
    FROM fact_transaction
)
ORDER BY rows_affected DESC;
