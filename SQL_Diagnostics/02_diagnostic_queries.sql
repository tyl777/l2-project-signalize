
-- ========================================================
-- L2 Incident Triage & Anomaly Detection Queries
-- ========================================================

-- Query 1: Money Leak Detection (Cancelled orders with successful payment)
SELECT 
    u.region,
    o.order_id,
    o.amount AS lost_revenue,
    o.status AS order_status,
    p.gateway_status,
    o.created_at
FROM orders o
JOIN payment_logs p ON o.order_id = p.order_id
JOIN users u ON o.user_id = u.user_id
WHERE o.status = 'cancelled' 
  AND p.gateway_status = 'SUCCESS';


-- Query 2: Performance & Timeout Audit (High latency > 10s and stuck orders)
SELECT 
    o.order_id,
    o.status,
    p.gateway_status,
    p.error_code,
    p.response_time_ms / 1000.0 AS response_time_seconds,
    o.amount AS frozen_amount
FROM orders o
JOIN payment_logs p ON o.order_id = p.order_id
WHERE o.status = 'in_progress' 
   OR p.response_time_ms > 10000;


-- Query 3: Security & Fraud Audit (Promo code abuse rate-limiting)
SELECT 
    user_id,
    COUNT(event_id) AS total_promo_attempts,
    COUNT(DISTINCT ip_address) AS unique_ips_used
FROM event_logs
WHERE event_type = 'promo_activation'
GROUP BY user_id
HAVING COUNT(event_id) >= 5;


-- Query 4: Data Integrity Audit (Orphaned orders without valid user_id)
SELECT 
    o.order_id,
    o.user_id AS invalid_user_id,
    o.amount,
    o.created_at
FROM orders o
LEFT JOIN users u ON o.user_id = u.user_id
WHERE u.user_id IS NULL;
