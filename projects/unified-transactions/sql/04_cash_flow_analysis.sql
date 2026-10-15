-- ============================================================
-- 04_cash_flow_analysis.sql
-- Where money comes in and goes out, using clean in-period rows.
-- ============================================================

-- Monthly inflows, outflows and net flow, with a running total
CREATE OR REPLACE TABLE rpt_monthly_flow AS
SELECT
    d.month_start,
    sum(f.amount) FILTER (WHERE f.txn_type = 'Deposit')        AS deposits,
    sum(f.amount) FILTER (WHERE f.txn_type = 'Withdrawal')     AS withdrawals,
    sum(f.amount) FILTER (WHERE f.txn_type = 'Card purchase')  AS card_spend,
    sum(f.amount) FILTER (WHERE f.txn_type = 'Transfer')       AS transfers,
    sum(f.signed_amount)                                       AS net_flow,
    sum(sum(f.signed_amount)) OVER (ORDER BY d.month_start)    AS cumulative_net_flow
FROM v_fact_clean f
JOIN dim_date d ON d.date_key = f.txn_date
GROUP BY d.month_start
ORDER BY d.month_start;

-- Yearly summary with year-over-year change
CREATE OR REPLACE TABLE rpt_yearly_flow AS
WITH y AS (
    SELECT d.year,
           count(*)                                                 AS transactions,
           sum(f.amount) FILTER (WHERE f.flow = 'Inflow')           AS inflow,
           sum(f.amount) FILTER (WHERE f.flow = 'Outflow')          AS outflow,
           sum(f.signed_amount)                                     AS net_flow
    FROM v_fact_clean f JOIN dim_date d ON d.date_key = f.txn_date
    GROUP BY d.year
)
SELECT *,
       round(100.0 * (outflow / lag(outflow) OVER (ORDER BY year) - 1), 1) AS outflow_yoy_pct
FROM y ORDER BY year;

-- Card spending mix by category
CREATE OR REPLACE TABLE rpt_card_categories AS
SELECT
    spend_category,
    count(*)                                              AS transactions,
    sum(amount)                                           AS spend,
    round(avg(amount), 0)                                 AS avg_ticket,
    round(100.0 * sum(amount) / sum(sum(amount)) OVER (), 1) AS share_of_spend_pct
FROM v_fact_clean
WHERE source = 'Credit Card'
GROUP BY spend_category
ORDER BY spend DESC;

-- Checking activity by channel
CREATE OR REPLACE TABLE rpt_channels AS
SELECT
    channel,
    count(*)                                                 AS transactions,
    sum(amount)                                              AS amount,
    round(avg(amount), 0)                                    AS avg_amount,
    round(100.0 * count(*) / sum(count(*)) OVER (), 1)       AS share_of_txns_pct
FROM v_fact_clean
WHERE source = 'Checking'
GROUP BY channel
ORDER BY transactions DESC;
