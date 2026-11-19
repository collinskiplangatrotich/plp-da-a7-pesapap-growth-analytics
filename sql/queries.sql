-- Validation Question: Identify and quantify transactions occurring before a user's signup_date (signup-date / pre-signup transaction anomaly).
SELECT
    COUNT(*) AS pre_signup_txn_count,
    COUNT(DISTINCT t.user_id) AS affected_users,
    ROUND(SUM(t.amount), 2) AS pre_signup_volume,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM transactions), 2) AS pct_of_all_txns
FROM transactions AS t
INNER JOIN users AS u
    ON t.user_id = u.user_id
WHERE t.txn_date < u.signup_date;

-- Question a: What are the overall transaction volume, transaction count, active transacting users, and average transaction amount on PesaPap?
SELECT
    COUNT(*) AS total_txns,
    COUNT(DISTINCT user_id) AS active_users,
    ROUND(SUM(amount), 2) AS total_volume,
    ROUND(AVG(amount), 2) AS avg_txn_amount
FROM transactions;

-- Question b: How do transaction count, total volume, and average transaction amount break down by product?
SELECT
    product,
    COUNT(*) AS txn_count,
    ROUND(SUM(amount), 2) AS total_volume,
    ROUND(AVG(amount), 2) AS avg_amount,
    ROUND(100.0 * SUM(amount) / (SELECT SUM(amount) FROM transactions), 2) AS volume_share_pct
FROM transactions
GROUP BY product
ORDER BY total_volume DESC;

-- Question c: How do user counts, active transacting users, and total transaction volume compare across counties?
SELECT
    u.county,
    COUNT(DISTINCT u.user_id) AS registered_users,
    COUNT(DISTINCT t.user_id) AS active_users,
    COUNT(t.txn_id) AS txn_count,
    ROUND(COALESCE(SUM(t.amount), 0), 2) AS total_volume
FROM users AS u
LEFT JOIN transactions AS t
    ON u.user_id = t.user_id
GROUP BY u.county
ORDER BY total_volume DESC;

-- Question d: How do registered users, active transacting users, and total transaction volume vary by acquisition channel?
SELECT
    u.acquisition_channel,
    COUNT(DISTINCT u.user_id) AS registered_users,
    COUNT(DISTINCT t.user_id) AS active_users,
    COUNT(t.txn_id) AS txn_count,
    ROUND(COALESCE(SUM(t.amount), 0), 2) AS total_volume
FROM users AS u
LEFT JOIN transactions AS t
    ON u.user_id = t.user_id
GROUP BY u.acquisition_channel
ORDER BY total_volume DESC;

-- Question e: What are the top 10 users by total transaction volume, and how many transactions do they complete?
SELECT
    u.user_id,
    u.county,
    u.acquisition_channel,
    COUNT(t.txn_id) AS txn_count,
    ROUND(SUM(t.amount), 2) AS total_volume
FROM users AS u
INNER JOIN transactions AS t
    ON u.user_id = t.user_id
GROUP BY u.user_id, u.county, u.acquisition_channel
ORDER BY total_volume DESC
LIMIT 10;

-- Question f: How does monthly transaction volume and transaction count trend across the observation period?
SELECT
    SUBSTR(txn_date, 1, 7) AS txn_month,
    COUNT(*) AS txn_count,
    COUNT(DISTINCT user_id) AS active_users,
    ROUND(SUM(amount), 2) AS monthly_volume
FROM transactions
GROUP BY SUBSTR(txn_date, 1, 7)
ORDER BY txn_month;

-- Question g: Using a CTE, CASE WHEN, and LAG, how does monthly transaction volume change month-over-month and classify growth momentum?
WITH monthly_metrics AS (
    SELECT
        SUBSTR(txn_date, 1, 7) AS txn_month,
        ROUND(SUM(amount), 2) AS monthly_volume,
        COUNT(*) AS txn_count
    FROM transactions
    GROUP BY SUBSTR(txn_date, 1, 7)
),
lagged_monthly AS (
    SELECT
        txn_month,
        txn_count,
        monthly_volume,
        LAG(monthly_volume) OVER (ORDER BY txn_month) AS prev_month_volume
    FROM monthly_metrics
)
SELECT
    txn_month,
    txn_count,
    monthly_volume,
    prev_month_volume,
    ROUND(monthly_volume - prev_month_volume, 2) AS mom_volume_change,
    CASE
        WHEN prev_month_volume IS NULL THEN 'Baseline Month'
        WHEN monthly_volume > prev_month_volume THEN 'Expansion'
        WHEN monthly_volume < prev_month_volume THEN 'Contraction'
        ELSE 'Flat'
    END AS mom_status
FROM lagged_monthly
ORDER BY txn_month;

-- Question h: Using a CTE, CASE WHEN, and LAG, how does monthly transaction volume for Send Money change month-over-month with period-over-period flags?
WITH send_money_monthly AS (
    SELECT
        SUBSTR(txn_date, 1, 7) AS txn_month,
        ROUND(SUM(amount), 2) AS send_money_volume
    FROM transactions
    WHERE product = 'Send Money'
    GROUP BY SUBSTR(txn_date, 1, 7)
),
send_money_lag AS (
    SELECT
        txn_month,
        send_money_volume,
        LAG(send_money_volume) OVER (ORDER BY txn_month) AS prev_send_money_volume
    FROM send_money_monthly
)
SELECT
    txn_month,
    send_money_volume,
    prev_send_money_volume,
    ROUND(
        CASE
            WHEN prev_send_money_volume IS NULL OR prev_send_money_volume = 0 THEN NULL
            ELSE 100.0 * (send_money_volume - prev_send_money_volume) / prev_send_money_volume
        END,
        2
    ) AS mom_growth_pct,
    CASE
        WHEN prev_send_money_volume IS NULL THEN 'First Month'
        WHEN send_money_volume >= prev_send_money_volume * 1.05 THEN 'Strong Growth (>=5%)'
        WHEN send_money_volume > prev_send_money_volume THEN 'Modest Growth'
        ELSE 'Slowdown / Decline'
    END AS growth_tier
FROM send_money_lag
ORDER BY txn_month;
