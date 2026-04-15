-- ── Three-Step Customer Risk Scoring ──────────

WITH account_signals AS (
    SELECT
        accountid,
        customeroccupation,
        location,
        COUNT(*) AS total_txns,
        ROUND(SUM(transactionamount), 2) AS lifetime_value,
        ROUND(AVG(accountbalance), 2) AS avg_balance,
        MAX(loginattempts)   AS max_logins,
        SUM(CASE WHEN loginattempts >= 3 THEN 1 ELSE 0 END) AS high_login_count,
        SUM(CASE WHEN is_suspicious = 1 THEN 1 ELSE 0 END)   AS suspicious_count,
        COUNT(DISTINCT location) AS locations_used,
        COUNT(DISTINCT channel)  AS channels_used
    FROM vw_transactions_clean
    GROUP BY accountid, customeroccupation, location
),
risk_scored AS (
    SELECT *,
        (CASE WHEN max_logins >= 4       THEN 4 ELSE 0 END) +
        (CASE WHEN high_login_count >= 3 THEN 3 ELSE 0 END) +
        (CASE WHEN suspicious_count > 0  THEN 3 ELSE 0 END) +
        (CASE WHEN locations_used > 5    THEN 2 ELSE 0 END) +
        (CASE WHEN lifetime_value / NULLIF(avg_balance, 0) > 1.5 THEN 1 ELSE 0 END) AS risk_score
    FROM account_signals
),
risk_classified AS (
    SELECT *,
        CASE
            WHEN risk_score >= 8 THEN 'Critical'
            WHEN risk_score >= 5 THEN 'High'
            WHEN risk_score >= 3 THEN 'Medium'
            WHEN risk_score >= 1 THEN 'Low'
            ELSE 'Clean'
        END AS risk_tier
    FROM risk_scored
)
SELECT
    accountid, customeroccupation, location,
    total_txns, lifetime_value, avg_balance,
    max_logins, high_login_count, suspicious_count,
    risk_score, risk_tier
FROM risk_classified
WHERE risk_tier IN ('Critical', 'High', 'Medium')
ORDER BY risk_score DESC;

-- ── Customer Lifetime Value (CLV) Segmentation ──

WITH customer_clv AS (
    SELECT
        accountid,
        customeroccupation,
        MIN(DATE(transactiondate)) AS first_seen,
        MAX(DATE(transactiondate)) AS last_seen,
        DATEDIFF(MAX(DATE(transactiondate)), MIN(DATE(transactiondate))) AS tenure_days,
        COUNT(*)  AS total_transactions,
        ROUND(SUM(transactionamount), 2)  AS lifetime_volume,
        ROUND(AVG(accountbalance), 2) AS avg_balance,
        COUNT(DISTINCT channel) AS channels_used
    FROM vw_transactions_clean
    GROUP BY accountid, customeroccupation
),
clv_scored AS (
    SELECT *,
        ROUND(lifetime_volume / NULLIF(tenure_days, 0), 2) AS daily_value,
        NTILE(5) OVER (ORDER BY lifetime_volume DESC) AS clv_quintile
    FROM customer_clv
)
SELECT
    clv_quintile,
    CASE clv_quintile
        WHEN 1 THEN 'Platinum (Top 20%)'
        WHEN 2 THEN 'Gold (Top 40%)'
        WHEN 3 THEN 'Silver (Mid 20%)'
        WHEN 4 THEN 'Bronze (Low 20%)'
        WHEN 5 THEN 'Standard (Bottom 20%)'
    END  AS segment_name,
    COUNT(*)  AS customers,
    ROUND(AVG(lifetime_volume), 2)   AS avg_lifetime_volume,
    ROUND(AVG(avg_balance), 2) AS avg_balance,
    ROUND(AVG(total_transactions), 1)    AS avg_transactions,
    ROUND(AVG(tenure_days), 0)  AS avg_tenure_days
FROM clv_scored
GROUP BY clv_quintile
ORDER BY clv_quintile;