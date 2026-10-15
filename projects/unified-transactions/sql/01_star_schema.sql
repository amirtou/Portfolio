-- ============================================================
-- 01_star_schema.sql
-- Build a star schema from the staging tables.
--   fact_transaction  one row per transaction, both sources
--   dim_customer      one row per customer, with age and income bands
--   dim_date          calendar covering every transaction date
--
-- Key modelling decisions
--   * Amounts are stored positive, with a flow direction and a signed
--     amount, so inflows and outflows are never added together.
--   * Transfers have no direction in the source, so they are kept
--     but excluded from net-flow figures (signed_amount is NULL).
--   * Data-quality problems are flagged on each row, not deleted,
--     so every figure can be traced back to the source.
-- ============================================================

-- Reporting period: the window both sources fully cover
CREATE OR REPLACE TABLE cfg_period AS
SELECT DATE '2022-01-01' AS period_start, DATE '2024-12-31' AS period_end;

CREATE OR REPLACE TABLE dim_customer AS
SELECT
    customer_id,
    full_name,
    gender,
    home_city,
    join_date,
    age,
    CASE WHEN age < 30 THEN '18-29' WHEN age < 45 THEN '30-44'
         WHEN age < 60 THEN '45-59' ELSE '60+' END                    AS age_band,
    annual_income,
    CASE WHEN annual_income < 60000  THEN 'Under 60k'
         WHEN annual_income < 90000  THEN '60k-90k'
         WHEN annual_income < 120000 THEN '90k-120k'
         ELSE '120k+' END                                             AS income_band,
    account_type
FROM stg_customers;

CREATE OR REPLACE TABLE fact_transaction AS
WITH unioned AS (
    SELECT
        source_record_id                        AS transaction_id,   -- checking keeps 1-1,000
        'Checking'                              AS source,
        source_record_id,
        customer_id, txn_date,
        txn_type,
        NULL::VARCHAR                           AS spend_category,
        NULL::VARCHAR                           AS merchant,
        channel, txn_city, amount
    FROM stg_checking
    UNION ALL
    SELECT
        source_record_id + (SELECT max(source_record_id) FROM stg_checking),  -- card: 1,001-2,000
        'Credit Card', source_record_id,
        customer_id, txn_date,
        'Card purchase', category, merchant,
        'Card', txn_city, amount
    FROM stg_credit_card
)
SELECT
    u.*,
    CASE u.txn_type WHEN 'Deposit' THEN 'Inflow'
                    WHEN 'Transfer' THEN 'Transfer'
                    ELSE 'Outflow' END                               AS flow,
    CASE u.txn_type WHEN 'Deposit' THEN u.amount
                    WHEN 'Transfer' THEN NULL
                    ELSE -u.amount END                               AS signed_amount,
    -- data-quality flags
    u.txn_date < c.join_date                                         AS dq_before_join,
    (u.source = 'Checking' AND c.account_type = 'Savings')           AS dq_product_mismatch,
    u.txn_date NOT BETWEEN p.period_start AND p.period_end           AS dq_out_of_period
FROM unioned u
JOIN stg_customers c USING (customer_id)
CROSS JOIN cfg_period p;

CREATE OR REPLACE TABLE dim_date AS
SELECT
    d::DATE                                  AS date_key,
    year(d)                                  AS year,
    quarter(d)                               AS quarter,
    month(d)                                 AS month,
    strftime(d, '%b')                        AS month_name,
    date_trunc('month', d)::DATE             AS month_start,
    dayofweek(d) IN (0, 6)                   AS is_weekend
FROM range((SELECT min(txn_date) FROM fact_transaction),
           (SELECT max(txn_date) FROM fact_transaction) + INTERVAL 1 DAY,
           INTERVAL 1 DAY) t(d);

-- Analysis view: in-period rows whose dates are plausible
CREATE OR REPLACE VIEW v_fact_clean AS
SELECT * FROM fact_transaction
WHERE NOT dq_out_of_period AND NOT dq_before_join;
