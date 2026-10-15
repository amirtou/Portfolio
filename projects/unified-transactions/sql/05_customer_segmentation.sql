-- ============================================================
-- 05_customer_segmentation.sql
-- RFM segmentation of card customers, measured at period end,
-- and card spend by income band.
-- ============================================================

CREATE OR REPLACE TABLE rpt_rfm AS
WITH base AS (
    SELECT
        customer_id,
        (SELECT period_end FROM cfg_period) - max(txn_date)  AS recency_days,
        count(*)                                             AS frequency,
        sum(amount)                                          AS monetary
    FROM v_fact_clean
    WHERE source = 'Credit Card'
    GROUP BY customer_id
),
scored AS (
    SELECT *,
        CASE WHEN recency_days <= 180 THEN 3 WHEN recency_days <= 365 THEN 2 ELSE 1 END AS r_score,
        CASE WHEN frequency >= 3 THEN 3 WHEN frequency = 2 THEN 2 ELSE 1 END             AS f_score,
        ntile(3) OVER (ORDER BY monetary)                                                AS m_score
    FROM base
)
SELECT *,
    CASE
        WHEN r_score = 3 AND f_score >= 2 AND m_score = 3 THEN 'Champions'
        WHEN r_score >= 2 AND f_score >= 2                THEN 'Loyal'
        WHEN r_score = 3                                  THEN 'Recent, one-off'
        WHEN r_score = 2                                  THEN 'Cooling'
        ELSE 'Lapsed (12+ months)'
    END AS segment
FROM scored;

CREATE OR REPLACE TABLE rpt_segments AS
SELECT
    segment,
    count(*)                                              AS customers,
    round(avg(recency_days), 0)                           AS avg_recency_days,
    round(avg(frequency), 1)                              AS avg_transactions,
    sum(monetary)                                         AS total_spend,
    round(100.0 * sum(monetary) / sum(sum(monetary)) OVER (), 1) AS share_of_spend_pct
FROM rpt_rfm
GROUP BY segment
ORDER BY total_spend DESC;

CREATE OR REPLACE TABLE rpt_income_bands AS
SELECT
    c.income_band,
    count(DISTINCT c.customer_id)                                        AS customers,
    count(DISTINCT f.customer_id)                                        AS card_users,
    round(100.0 * count(DISTINCT f.customer_id) / count(DISTINCT c.customer_id), 1) AS card_adoption_pct,
    round(sum(f.amount) / nullif(count(DISTINCT f.customer_id), 0), 0)   AS spend_per_card_user
FROM dim_customer c
LEFT JOIN v_fact_clean f ON f.customer_id = c.customer_id AND f.source = 'Credit Card'
GROUP BY c.income_band
ORDER BY min(c.annual_income);
