-- Logistics & Delivery Analysis

-- 1. On-Time vs Delayed Orders
-- How reliable is delivery?

WITH delivery_base AS (
    SELECT
        order_id,
        order_delivered_customer_date,
        order_estimated_delivery_date,
        CASE
            WHEN order_delivered_customer_date > order_estimated_delivery_date
            THEN 'Delayed'
            ELSE 'On Time'
        END AS delivery_status
    FROM orders
    WHERE order_status = 'delivered'
)

SELECT
    delivery_status,
    COUNT(*) AS orders,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(),
        2
    ) AS percentage
FROM delivery_base
GROUP BY delivery_status;



-- 2. Delivery Efficiency
-- Are deliveries faster or slower than estimated?

WITH delivery_base AS (
    SELECT
        order_id,
        order_purchase_timestamp,
        order_delivered_customer_date,
        order_estimated_delivery_date
    FROM orders
    WHERE order_status = 'delivered'
)

SELECT
    ROUND(
        AVG(DATEDIFF(order_delivered_customer_date, order_purchase_timestamp)),
        2
    ) AS avg_actual_delivery_days,
    ROUND(
        AVG(DATEDIFF(order_estimated_delivery_date, order_purchase_timestamp)),
        2
    ) AS avg_estimated_delivery_days
FROM delivery_base;



-- 3. Multi-Seller Impact on Delivery
-- Do complex orders lead to delays?

WITH order_sellers AS (
    SELECT
        order_id,
        COUNT(DISTINCT seller_id) AS seller_count
    FROM order_items
    GROUP BY order_id
),

delivery_base AS (
    SELECT
        order_id,
        CASE
            WHEN order_delivered_customer_date > order_estimated_delivery_date
            THEN 'Delayed'
            ELSE 'On Time'
        END AS delivery_status
    FROM orders
    WHERE order_status = 'delivered'
)

SELECT
    CASE
        WHEN os.seller_count = 1 THEN 'Single Seller'
        ELSE 'Multi Seller'
    END AS order_type,
    db.delivery_status,
    COUNT(*) AS orders,
    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (
            PARTITION BY
                CASE
                    WHEN os.seller_count = 1 THEN 'Single Seller'
                    ELSE 'Multi Seller'
                END
        ),
        2
    ) AS percentage
FROM order_sellers os
JOIN delivery_base db
    ON os.order_id = db.order_id
GROUP BY order_type, db.delivery_status;



-- 4. Impact of Delays on Revenue
-- Do delayed orders have higher/lower value?

WITH delivery_base AS (
    SELECT
        order_id,
        CASE
            WHEN order_delivered_customer_date > order_estimated_delivery_date
            THEN 'Delayed'
            ELSE 'On Time'
        END AS delivery_status
    FROM orders
    WHERE order_status = 'delivered'
)

SELECT
    db.delivery_status,
    COUNT(*) AS orders,
    ROUND(AVG(p.total_payment), 2) AS avg_order_value,
    ROUND(SUM(p.total_payment), 2) AS total_revenue
FROM delivery_base db
JOIN payments_summary p
    ON db.order_id = p.order_id
GROUP BY db.delivery_status;



-- 5. Average Delay Duration
-- How severe are delays?

WITH delivery_base AS (
    SELECT
        order_delivered_customer_date,
        order_estimated_delivery_date
    FROM orders
    WHERE order_status = 'delivered'
      AND order_delivered_customer_date > order_estimated_delivery_date
)

SELECT
    ROUND(
        AVG(
            DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date)
        ),
        2
    ) AS avg_delay_days
FROM delivery_base;


-- 6. Product Weight vs Delivery
SELECT 
    CASE 
        WHEN p.product_weight_g < 500 THEN 'Light'
        WHEN p.product_weight_g < 2000 THEN 'Medium'
        ELSE 'Heavy'
    END AS weight_category,
    COUNT(*) AS orders,
    AVG(DATEDIFF(o.order_delivered_customer_date, o.order_purchase_timestamp)) AS avg_delivery_days
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY weight_category;
