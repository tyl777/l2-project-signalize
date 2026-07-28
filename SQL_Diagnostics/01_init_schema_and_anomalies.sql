-- DDL: Cleanup and Tables Initialization
DROP TABLE IF EXISTS payment_logs CASCADE;
DROP TABLE IF EXISTS event_logs CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS users CASCADE;

CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP - INTERVAL '10 days',
    region VARCHAR(50),
    device_type VARCHAR(20)
);

CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(user_id),
    amount NUMERIC(10, 2),
    status VARCHAR(20),
    promo_code VARCHAR(30),
    ip_address VARCHAR(45),
    created_at TIMESTAMP
);

CREATE TABLE payment_logs (
    log_id SERIAL PRIMARY KEY,
    order_id INT REFERENCES orders(order_id),
    gateway_status VARCHAR(20),
    error_code VARCHAR(50),
    response_time_ms INT,
    created_at TIMESTAMP
);

CREATE TABLE event_logs (
    event_id SERIAL PRIMARY KEY,
    user_id INT,
    event_type VARCHAR(50),
    ip_address VARCHAR(45),
    created_at TIMESTAMP
);

-- Seed Data: Генерация юзеров и успешных транзакций (200 records)
INSERT INTO users (region, device_type, created_at)
SELECT 
    (ARRAY['Almaty', 'Astana', 'Shymkent', 'Karaganda'])[FLOOR(RANDOM() * 4 + 1)],
    (ARRAY['iOS', 'Android', 'Web'])[FLOOR(RANDOM() * 3 + 1)],
    NOW() - (RANDOM() * INTERVAL '7 days')
FROM generate_series(1, 200);

INSERT INTO orders (user_id, amount, status, promo_code, ip_address, created_at)
SELECT 
    u.user_id,
    ROUND((RANDOM() * 5000 + 1000)::numeric, 2),
    'completed',
    NULL,
    '192.168.1.' || (FLOOR(RANDOM() * 250 + 1))::text,
    NOW() - (RANDOM() * INTERVAL '5 days')
FROM users u;

INSERT INTO payment_logs (order_id, gateway_status, error_code, response_time_ms, created_at)
SELECT 
    order_id,
    'SUCCESS',
    NULL,
    FLOOR(RANDOM() * 200 + 50),
    created_at + INTERVAL '2 seconds'
FROM orders;


-- Mocking Synthetic Anomalies & Test Cases

-- Anomaly 1: Money Leak (Рассинхрон статусов заказа и эквайринга)
WITH new_users AS (
    INSERT INTO users (region, device_type, created_at) VALUES 
    ('Tele2_Zone', 'Android', NOW() - INTERVAL '2 days'),
    ('Tele2_Zone', 'Android', NOW() - INTERVAL '2 days'),
    ('Tele2_Zone', 'Android', NOW() - INTERVAL '2 days')
    RETURNING user_id
),
new_orders AS (
    INSERT INTO orders (user_id, amount, status, ip_address, created_at)
    SELECT user_id, 15000.00, 'cancelled', '10.0.0.1', NOW() - INTERVAL '1 day' FROM new_users
    RETURNING order_id
)
INSERT INTO payment_logs (order_id, gateway_status, response_time_ms, created_at)
SELECT order_id, 'SUCCESS', 120, NOW() - INTERVAL '1 day' FROM new_orders;


-- Anomaly 2: Performance Timeout (Зависшие транзакции / Gateway 504)
WITH perf_orders AS (
    INSERT INTO orders (user_id, amount, status, ip_address, created_at)
    SELECT user_id, 45000.00, 'in_progress', '192.168.1.10', NOW() - INTERVAL '3 hours'
    FROM users LIMIT 2
    RETURNING order_id
)
INSERT INTO payment_logs (order_id, gateway_status, error_code, response_time_ms, created_at)
SELECT order_id, 'TIMEOUT', 'GATEWAY_TIMEOUT_504', 12500, NOW() - INTERVAL '3 hours' FROM perf_orders;


-- Anomaly 3: Fraud / Promo Abuse (Множественные попытки с разных IP)
INSERT INTO event_logs (user_id, event_type, ip_address, created_at) VALUES 
(1, 'promo_activation', '185.220.101.1', NOW() - INTERVAL '30 mins'),
(1, 'promo_activation', '185.220.101.2', NOW() - INTERVAL '29 mins'),
(1, 'promo_activation', '185.220.101.3', NOW() - INTERVAL '28 mins'),
(1, 'promo_activation', '185.220.101.4', NOW() - INTERVAL '27 mins'),
(1, 'promo_activation', '185.220.101.5', NOW() - INTERVAL '26 mins');


-- Anomaly 4: Data Integrity Breach (Orphaned Record Test Case)
ALTER TABLE orders DROP CONSTRAINT orders_user_id_fkey;

INSERT INTO orders (user_id, amount, status, ip_address, created_at) VALUES 
(99999, 12000.00, 'completed', '192.168.1.99', NOW() - INTERVAL '1 hour');
