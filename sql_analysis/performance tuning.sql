-- ── Measure query cost BEFORE indexes ───────────────────
EXPLAIN ANALYZE
SELECT * FROM bank_transactions_data_
WHERE channel = 'Online'
  AND transactiondate >= '2023-01-01'
  AND transactiondate <  '2024-01-01';
  
-- ── Create strategic indexes ───────────────────────────
-- 1. Index for the most common filter: channel
CREATE INDEX idx_btx_channel
    ON bank_transactions_data_ (channel);
-- 2. Index for date range queries
CREATE INDEX idx_btx_date
    ON bank_transactions_data_ (transactiondate);
-- 3. Composite index for channel and date
CREATE INDEX idx_btx_channel_date
    ON bank_transactions_data_ (channel, transactiondate);
-- 4. Index for account lookups
CREATE INDEX idx_btx_account
    ON bank_transactions_data_ (accountid);
-- 5. High-risk index
CREATE INDEX idx_btx_high_risk
    ON bank_transactions_data_ (accountid, transactiondate, loginattempts, transactionamount);