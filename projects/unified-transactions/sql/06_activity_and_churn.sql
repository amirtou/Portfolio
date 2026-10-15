-- ============================================================
-- 06_activity_and_churn.sql
-- Who has gone quiet? Days since each customer's last activity
-- at period end, and the typical gap between card purchases.
-- ============================================================

CREATE OR REPLACE TABLE rpt_inactivity AS
WITH last_seen AS (
    SELECT c.customer_id, c.account_type,
           (SELECT period_end FROM cfg_period) - max(f.txn_date) AS days_inactive
    FROM dim_customer c
    LEFT JOIN v_fact_clean f USING (customer_id)
    GROUP BY c.customer_id, c.account_type
)
SELECT
    CASE WHEN days_inactive IS NULL THEN 'No clean activity'
         WHEN days_inactive <= 90   THEN '0-90 days'
         WHEN days_inactive <= 180  THEN '91-180 days'
         WHEN days_inactive <= 365  THEN '181-365 days'
         ELSE 'Over a year' END                                  AS inactivity_band,
    count(*)                                                     AS customers,
    round(100.0 * count(*) / sum(count(*)) OVER (), 1)           AS share_pct
FROM last_seen
GROUP BY inactivity_band
ORDER BY min(coalesce(days_inactive, 99999));

-- Gap between consecutive card purchases, per customer (LAG window)
CREATE OR REPLACE TABLE rpt_purchase_gaps AS
WITH ordered AS (
    SELECT customer_id, txn_date,
           txn_date - lag(txn_date) OVER (PARTITION BY customer_id ORDER BY txn_date) AS gap_days
    FROM v_fact_clean
    WHERE source = 'Credit Card'
)
SELECT
    count(gap_days)                         AS repeat_purchases,
    round(median(gap_days), 0)              AS median_gap_days,
    round(quantile_cont(gap_days, 0.25), 0) AS p25_gap_days,
    round(quantile_cont(gap_days, 0.75), 0) AS p75_gap_days
FROM ordered;
