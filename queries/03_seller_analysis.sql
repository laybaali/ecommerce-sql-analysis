-- Seller Performance Analysis

-- 1. Seller Performance Overview
-- How much do sellers contribute individually?
WITH order_payments AS (
    SELECT order_id, SUM(total_payment) AS total_payment
    FROM payments_summary
    GROUP BY order_id
)

SELECT
    oi.seller_id,
    COUNT(DISTINCT oi.order_id) AS orders,
    ROUND(SUM(op.total_payment), 2) AS revenue,
    ROUND(SUM(op.total_payment) / COUNT(DISTINCT oi.order_id), 2) AS avg_order_value
FROM order_items oi
JOIN order_payments op
    ON oi.order_id = op.order_id
GROUP BY oi.seller_id
ORDER BY revenue DESC;


-- 2. Revenue Concentration (Pareto Analysis)
-- Do a small number of sellers drive most revenue?
WITH seller_revenue AS (
    SELECT
        oi.seller_id,
        SUM(p.total_payment) AS revenue
    FROM order_items oi
    JOIN payments_summary p
        ON oi.order_id = p.order_id
    GROUP BY oi.seller_id
),
ranked AS (
    SELECT
        seller_id,
        revenue,
        SUM(revenue) OVER (ORDER BY revenue DESC) AS cumulative_revenue,
        SUM(revenue) OVER () AS total_revenue
    FROM seller_revenue
)

SELECT
    seller_id,
    revenue,
    ROUND(cumulative_revenue * 100.0 / total_revenue, 2) AS cumulative_percentage
FROM ranked;


-- 3. Top 10 Sellers Contribution
-- How much revenue do top sellers generate?
WITH seller_sales AS (
    SELECT
        oi.seller_id,
        SUM(p.total_payment) AS seller_revenue
    FROM order_items oi
    JOIN payments_summary p
        ON oi.order_id = p.order_id
    GROUP BY oi.seller_id
),
ranked AS (
    SELECT *,
        ROW_NUMBER() OVER (ORDER BY seller_revenue DESC) AS seller_rank,
        SUM(seller_revenue) OVER () AS total_revenue
    FROM seller_sales
)

SELECT
    COUNT(*) AS total_sellers,
    ROUND(
        SUM(CASE WHEN seller_rank <= 10 THEN seller_revenue ELSE 0 END),
        2
    ) AS top_10_revenue,
    ROUND(
        SUM(CASE WHEN seller_rank <= 10 THEN seller_revenue ELSE 0 END)
        * 100.0 / MAX(total_revenue),
        2
    ) AS top_10_revenue_percentage
FROM ranked;


-- 4. Seller Order Volume Distribution
-- Do most sellers have very few orders?
WITH seller_orders AS (
    SELECT
        seller_id,
        COUNT(DISTINCT order_id) AS order_count
    FROM order_items
    GROUP BY seller_id
)

SELECT
    CASE
        WHEN order_count = 1 THEN '1 order'
        WHEN order_count BETWEEN 2 AND 5 THEN '2–5 orders'
        ELSE '5+ orders'
    END AS volume_bucket,
    COUNT(*) AS sellers,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(),
        2
    ) AS percentage
FROM seller_orders
GROUP BY volume_bucket
ORDER BY sellers DESC;


-- 5. Multi-Seller vs Single-Seller Orders
-- How complex are marketplace orders?
WITH order_sellers AS (
    SELECT
        order_id,
        COUNT(DISTINCT seller_id) AS seller_count
    FROM order_items
    GROUP BY order_id
)

SELECT
    CASE
        WHEN seller_count = 1 THEN 'Single Seller Order'
        ELSE 'Multi Seller Order'
    END AS order_type,
    COUNT(*) AS orders,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(),
        2
    ) AS percentage
FROM order_sellers
GROUP BY order_type;


-- 6. Seller Activity / Retention
-- Are sellers active or churned?
WITH seller_activity AS (
    SELECT
        oi.seller_id,
        COUNT(DISTINCT oi.order_id) AS total_orders,
        MAX(o.order_purchase_timestamp) AS last_order_date
    FROM order_items oi
    JOIN orders o
        ON oi.order_id = o.order_id
    GROUP BY oi.seller_id
)

SELECT
    CASE
        WHEN total_orders = 1 THEN 'One-time Seller'
        WHEN last_order_date >= (
            SELECT DATE_SUB(MAX(order_purchase_timestamp), INTERVAL 90 DAY)
            FROM orders
        ) THEN 'Active Seller'
        ELSE 'Churned / Inactive Seller'
    END AS seller_status,
    COUNT(*) AS sellers,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(),
        2
    ) AS percentage
FROM seller_activity
GROUP BY seller_status;