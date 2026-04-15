-- ──  Running Total per Account ─
SELECT
    accountid, transactiondate, transactionamount, transactiontype,
    SUM(transactionamount) OVER (
        PARTITION BY accountid
        ORDER BY transactiondate
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total,
    -- How many transactions has this account done so far?
    COUNT(*) OVER (
        PARTITION BY accountid
        ORDER BY transactiondate
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS txn_number,
    -- What % of this account's TOTAL spend is this transaction?
    ROUND(
        transactionamount * 100.0
        / SUM(transactionamount) OVER (PARTITION BY accountid)
    , 2)  AS pct_of_account_total
FROM vw_transactions_clean
ORDER BY accountid, transactiondate
LIMIT 200;

-- 7-Day Rolling Average ──────────
SELECT
    DATE(transactiondate)  AS trade_date,
    channel,
    ROUND(AVG(transactionamount), 2)  AS daily_avg,
    ROUND(AVG(AVG(transactionamount)) OVER (
        PARTITION BY channel
        ORDER BY DATE(transactiondate)
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ), 2)  AS rolling_7day_avg,
    COUNT(*)  AS daily_count
FROM vw_transactions_clean
GROUP BY DATE(transactiondate), channel
ORDER BY channel, trade_date;

-- ── LAG and LEAD  ────────────────────
SELECT
    accountid,
    transactiondate,
    transactionamount,
    -- Previous transaction amount for this same account
    LAG(transactionamount, 1) OVER (
        PARTITION BY accountid
        ORDER BY transactiondate
    ) AS prev_amount,
    -- Amount change from previous transaction
    ROUND(
        transactionamount
        - LAG(transactionamount, 1) OVER (
            PARTITION BY accountid ORDER BY transactiondate)
    , 2) AS amount_change,
    -- Days since last transaction for this account
    DATEDIFF(
        DATE(transactiondate), 
        LAG(DATE(transactiondate), 1) OVER (
            PARTITION BY accountid ORDER BY transactiondate)
    ) AS days_since_last,
    -- Next transaction (for forward-looking analysis)
    LEAD(transactionamount, 1) OVER (
        PARTITION BY accountid ORDER BY transactiondate
    ) AS next_amount
FROM vw_transactions_clean
ORDER BY accountid, transactiondate;

-- ──RANK, DENSE_RANK, NTILE, PERCENT_RANK ──
SELECT
    accountid,
    customeroccupation,
    location,
    ROUND(SUM(transactionamount), 2) AS lifetime_spend,
    ROUND(AVG(accountbalance), 2) AS avg_balance,
    COUNT(*) AS total_transactions,
    -- Global rank (1 = biggest spender)
    RANK() OVER (ORDER BY SUM(transactionamount) DESC) AS global_spend_rank,
    -- Rank within their occupation
    RANK() OVER (
        PARTITION BY customeroccupation
        ORDER BY SUM(transactionamount) DESC
    ) AS rank_in_occupation,
    -- Divide all customers into 4 tiers (1=top, 4=bottom)
    NTILE(4) OVER (ORDER BY SUM(transactionamount) DESC) AS spending_quartile,
    -- Assign naming to those tiers
    CASE NTILE(4) OVER (ORDER BY SUM(transactionamount) DESC)
        WHEN 1 THEN 'Platinum'
        WHEN 2 THEN 'Gold'
        WHEN 3 THEN 'Silver'
        WHEN 4 THEN 'Standard'
    END AS customer_tier
FROM vw_transactions_clean
GROUP BY accountid, customeroccupation, location
ORDER BY lifetime_spend DESC
LIMIT 30;

-- ──Month-over-Month Growth Rate ──────
WITH monthly_totals AS (
    SELECT
        txn_year,
        txn_month,
        channel,
        SUM(transactionamount)  AS monthly_vol,
        COUNT(*)  AS monthly_count
    FROM vw_transactions_clean
    GROUP BY txn_year, txn_month, channel
)
SELECT
    txn_year,
    txn_month,
    channel,
    ROUND(monthly_vol, 2)   AS volume,
    -- Previous month's volume for this same channel
    LAG(monthly_vol) OVER (
        PARTITION BY channel
        ORDER BY txn_year, txn_month
    ) AS prev_month_vol,
    -- Month-over-month growth percentage
    ROUND(
        100.0 * (monthly_vol - LAG(monthly_vol) OVER (
            PARTITION BY channel ORDER BY txn_year, txn_month))
        / NULLIF(LAG(monthly_vol) OVER (
            PARTITION BY channel ORDER BY txn_year, txn_month), 0)
    , 2) AS mom_growth_pct
FROM monthly_totals
ORDER BY channel, txn_year, txn_month;