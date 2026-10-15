-- ============================================================
-- 03_reconciliation.sql
-- Control totals: prove that no row or dollar was lost or duplicated
-- between the source files, the star schema and the CSV that feeds
-- the Power BI dashboard.
-- ============================================================

CREATE OR REPLACE TABLE rpt_reconciliation AS
WITH src AS (
    SELECT 'Checking' AS source, count(*) AS rows, sum(amount) AS total FROM stg_checking
    UNION ALL
    SELECT 'Credit Card', count(*), sum(amount) FROM stg_credit_card
),
model AS (
    SELECT source, count(*) AS rows, sum(amount) AS total FROM fact_transaction GROUP BY source
),
feed AS (
    SELECT Source AS source, count(*) AS rows, sum(Amount::DOUBLE) AS total
    FROM read_csv('Unified_Transactions.csv', header = true, all_varchar = true)
    GROUP BY Source
)
SELECT
    s.source,
    s.rows AS source_rows, m.rows AS model_rows, f.rows AS dashboard_rows,
    s.total AS source_amount, m.total AS model_amount, f.total AS dashboard_amount,
    CASE WHEN s.rows = m.rows AND m.rows = f.rows
          AND s.total = m.total AND m.total = f.total
         THEN 'Reconciled' ELSE 'BREAK' END AS status
FROM src s
JOIN model m USING (source)
JOIN feed f USING (source)
ORDER BY s.source;
