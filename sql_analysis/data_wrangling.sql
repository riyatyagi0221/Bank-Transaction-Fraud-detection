select count(*) as total_logs from bank_transactions_data_;

-- 1a. Check for NULL values in every column 
SELECT
    SUM(transactionid IS NULL)        AS null_txn_id,
    SUM(transactionamount IS NULL)    AS null_amount,
    SUM(transactiondate IS NULL)      AS null_date,
    SUM(channel IS NULL)               AS null_channel,
    SUM(accountbalance IS NULL)       AS null_balance,
    SUM(loginattempts IS NULL)        AS null_logins
FROM bank_transactions_data_;

-- 1b. Check for duplicate transaction IDs
SELECT transactionid, COUNT(*) AS occurrences
FROM bank_transactions_data_
GROUP BY transactionid
HAVING COUNT(*) > 1;

-- 1c. Check for impossible/invalid values 
SELECT
    SUM(transactionamount <= 0)  AS invalid_amounts,
    SUM(customerage < 18 OR customerage > 100) AS invalid_ages,
    SUM(loginattempts < 1) AS invalid_logins,
    SUM(TransactionType NOT IN ('Debit', 'Credit')) AS unknown_types,
    SUM(channel NOT IN ('ATM', 'Online', 'Branch')) AS unknown_channels
FROM bank_transactions_data_;


-- 1d. Distribution check — are our categorical values as expected?
SELECT channel, COUNT(*), ROUND(100.0*COUNT(*)/50000, 2) AS pct
FROM bank_transactions_data_ GROUP BY channel ORDER BY 2 DESC;

SELECT customeroccupation, COUNT(*), ROUND(100.0*COUNT(*)/50000, 2) AS pct
FROM bank_transactions_data_ GROUP BY customeroccupation ORDER BY 2 DESC;

-- Step 2 
CREATE OR REPLACE VIEW vw_transactions_clean AS
SELECT
    transactionid,
    accountid,
    transactionamount,
    transactiondate,
    transactiontype,
    location,
    deviceid,
    merchantid,
    channel,
    customerage,
    customeroccupation,
    transactionduration,
    loginattempts,
    accountbalance,

    CAST(YEAR(transactiondate) AS SIGNED)    AS txn_year,
    CAST(MONTH(transactiondate) AS SIGNED)  AS txn_month,
    CAST(QUARTER(transactiondate) AS SIGNED)  AS txn_quarter,
    CAST(DAYOFWEEK(transactiondate) - 1 AS SIGNED) AS day_of_week, 
    MONTHNAME(transactiondate) AS month_name,
    CASE
        WHEN DAYOFWEEK(transactiondate) IN (1, 7) THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_type,

    -- ── Transaction amount buckets ───
    CASE
        WHEN transactionamount < 50    THEN '1_Micro (<$50)'
        WHEN transactionamount < 200   THEN '2_Small ($50-200)'
        WHEN transactionamount < 500   THEN '3_Medium ($200-500)'
        WHEN transactionamount < 1000  THEN '4_Large ($500-1000)'
        ELSE                                 '5_High Value (>$1000)'
    END AS amount_band,

    -- ── Customer age group ─────────
    CASE
        WHEN customerage < 25  THEN 'Gen Z (18-24)'
        WHEN customerage < 40  THEN 'Millennial (25-39)'
        WHEN customerage < 55  THEN 'Gen X (40-54)'
        WHEN customerage < 65  THEN 'Boomer (55-64)'
        ELSE  'Senior (65+)'
    END  AS age_group,

    -- ── Login risk classification ──────────
    CASE
        WHEN loginattempts >= 4 THEN 'Critical'
        WHEN loginattempts = 3  THEN 'High'
        WHEN loginattempts = 2  THEN 'Medium'
        ELSE                          'Normal'
    END  AS login_risk,

    -- ── Fraud flag: Boolean handling ───────
    CASE
        WHEN transactiontype = 'Debit'
         AND transactionamount > 1000
         AND loginattempts > 1
        THEN 1 ELSE 0
    END  AS is_suspicious,

    -- ── Account balance segment ───────────
    CASE
        WHEN accountbalance <  1000  THEN 'Low (<$1K)'
        WHEN accountbalance <  5000  THEN 'Mid ($1K-5K)'
        WHEN accountbalance < 10000  THEN 'High ($5K-10K)'
        ELSE  'Premium (>$10K)'
    END  AS balance_tier,

    -- ── Real interest rate proxy ────────────
    ROUND(transactionamount / NULLIF(accountbalance, 0) * 100, 4) AS balance_utilisation_pct

FROM bank_transactions_data_
WHERE
    transactionamount > 0 
    AND customerage BETWEEN 18 AND 100 
    AND loginattempts >= 1;
    
    
-- ── STEP 3: Verify the view ───────────────
SELECT COUNT(*), MIN(txn_year), MAX(txn_year) FROM vw_transactions_clean;

-- Check derived columns look right
SELECT amount_band, COUNT(*), ROUND(AVG(transactionamount),2) AS avg_amt
FROM vw_transactions_clean
GROUP BY amount_band ORDER BY amount_band;

SELECT 
    login_risk, 
    COUNT(*) AS total_count, 
    ROUND(100.0 * COUNT(*) / 50000, 2) AS pct
FROM vw_transactions_clean
GROUP BY login_risk 
ORDER BY total_count DESC;
