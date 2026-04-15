-- ── Overall Business KPIs ──────
SELECT
    COUNT(*) AS total_transactions,
    COUNT(DISTINCT accountid)  AS unique_customers,
    ROUND(SUM(transactionamount), 2) AS total_volume_usd,
    ROUND(AVG(transactionamount), 2)  AS avg_transaction_usd,
    
    (SELECT transactionamount 
     FROM vw_transactions_clean 
     ORDER BY transactionamount 
     LIMIT 1 OFFSET 25000) AS median_approx,
    
    ROUND(STDDEV_SAMP(transactionamount), 2) AS std_dev_amount,
    
    SUM(transactiontype = 'Debit') AS total_debits,
    SUM(transactiontype = 'Credit')  AS total_credits,
    SUM(is_suspicious = 1)  AS suspicious_flags,
    SUM(loginattempts >= 3) AS high_risk_sessions
FROM vw_transactions_clean;

-- ── Channel Performance KPIs  ──────
-- Channels = ATM, Online, Branch
SELECT
    channel,
    COUNT(*)  AS txn_count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct_of_total,
    ROUND(SUM(transactionamount), 2) AS total_volume,
    ROUND(AVG(transactionamount), 2) AS avg_amount,
    ROUND(STDDEV_SAMP(transactionamount), 2) AS volatility,
    ROUND(AVG(transactionduration), 1) AS avg_duration_secs,
    ROUND(AVG(loginattempts * 1.0), 3) AS avg_login_attempts,
    SUM(is_suspicious = 1)   AS suspicious_count,
    ROUND(100.0 * SUM(is_suspicious = 1) / COUNT(*), 3) AS fraud_risk_pct
FROM vw_transactions_clean
GROUP BY channel
ORDER BY total_volume DESC;

-- ──  Occupation × Channel Matrix ─────────

SELECT
    customeroccupation,
    ROUND(AVG(CASE WHEN channel = 'Online' THEN transactionamount ELSE NULL END), 2) AS avg_online,
    ROUND(AVG(CASE WHEN channel = 'ATM'    THEN transactionamount ELSE NULL END), 2) AS avg_atm,
    ROUND(AVG(CASE WHEN channel = 'Branch' THEN transactionamount ELSE NULL END), 2) AS avg_branch,
    COUNT(DISTINCT accountid)  AS unique_accounts,
    ROUND(AVG(accountbalance), 2) AS avg_balance,
    ROUND(AVG(transactionamount), 2) AS overall_avg
FROM vw_transactions_clean
GROUP BY customeroccupation
ORDER BY avg_balance DESC;

-- ── Monthly Trend — all channels─────────────
SELECT
    txn_year,
    txn_month,
    channel,
    COUNT(*) AS monthly_txns,
    ROUND(SUM(transactionamount), 2) AS monthly_volume,
    ROUND(AVG(transactionamount), 2) AS avg_amount,
    SUM(is_suspicious = 1) AS suspicious_count
FROM vw_transactions_clean
GROUP BY txn_year, txn_month, channel
ORDER BY txn_year, txn_month, channel;

-- ──  Top 10 Highest Risk Accounts ──────────────────────

SELECT
    accountid,
    customeroccupation,
    location,
    COUNT(*)  AS total_txns,
    ROUND(SUM(transactionamount), 2) AS total_spent,
    ROUND(AVG(accountbalance), 2) AS avg_balance,
    MAX(loginattempts) AS max_logins,
    SUM(CASE WHEN loginattempts >= 3 THEN 1 ELSE 0 END)   AS high_login_events,
    SUM(CASE WHEN is_suspicious THEN 1 ELSE 0 END)  AS suspicious_txns,
    SUM(CASE WHEN loginattempts >= 3 THEN 2 ELSE 0 END) +
    SUM(CASE WHEN is_suspicious        THEN 3 ELSE 0 END) +
    SUM(CASE WHEN transactionamount > 1500 THEN 1 ELSE 0 END) AS risk_score
FROM vw_transactions_clean
GROUP BY accountid, customeroccupation, location
HAVING SUM(CASE WHEN loginattempts >= 3 THEN 1 ELSE 0 END) > 0
    OR SUM(CASE WHEN is_suspicious THEN 1 ELSE 0 END) > 0
ORDER BY risk_score DESC
LIMIT 20;

