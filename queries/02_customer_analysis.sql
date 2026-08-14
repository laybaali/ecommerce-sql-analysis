-- Customer Behavior Analysis

-- Base customer view
CREATE VIEW customer_base AS
SELECT
    c.customer_unique_id,
    COUNT(DISTINCT o.order_id) AS order_count,
    ROUND(SUM(p.total_payment), 2) AS lifetime_value
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN payments_summary p
    ON o.order_id = p.order_id
GROUP BY c.customer_unique_id;


-- 1. Total Customers
SELECT
    COUNT(*) AS total_customers
FROM customer_base;


-- 2. Customer Order Frequency Distribution
-- How often do customers purchase?
SELECT
    order_count,
    COUNT(*) AS customers
FROM customer_base
GROUP BY order_count
ORDER BY order_count;


-- 3. Customer Value Distribution
-- How much do customers spend?
SELECT
    ROUND(AVG(lifetime_value), 2) AS avg_customer_value,
    ROUND(MIN(lifetime_value), 2) AS minimum_value,
    ROUND(MAX(lifetime_value), 2) AS maximum_value
FROM customer_base;


-- 4. Top Customers by Lifetime Value
-- Who are the highest value customers?
SELECT
    customer_unique_id,
    lifetime_value
FROM customer_base
ORDER BY lifetime_value DESC
LIMIT 10;


-- 5. Revenue Concentration (Top 100 Customers)
-- Do a small number of customers drive most revenue?
SELECT
    ROUND(
        SUM(lifetime_value) * 100 /
        (SELECT SUM(total_payment) FROM payments_summary),
        2
    ) AS top_customer_revenue_percentage
FROM (
    SELECT lifetime_value
    FROM customer_base
    ORDER BY lifetime_value DESC
    LIMIT 100
) t;


-- 6. One-time vs Repeat Customers
-- How many customers come back?
SELECT
    CASE
        WHEN order_count > 1 THEN 'Repeat'
        ELSE 'One-time'
    END AS customer_type,
    COUNT(*) AS customers,
    ROUND(SUM(lifetime_value), 2) AS revenue,
    ROUND(
        SUM(lifetime_value) * 100 /
        (SELECT SUM(total_payment) FROM payments_summary),
        2
    ) AS revenue_percentage
FROM customer_base
GROUP BY customer_type;


-- 7. Average Spend by Customer Type
-- Do repeat customers spend more?
SELECT
    CASE
        WHEN order_count > 1 THEN 'Repeat'
        ELSE 'One-time'
    END AS customer_type,
    COUNT(*) AS customers,
    ROUND(AVG(lifetime_value), 2) AS avg_customer_value
FROM customer_base
GROUP BY customer_type;


-- 8. RFM Segmentation
-- Segment customers based on behavior

WITH rfm AS (
    SELECT
        c.customer_unique_id,
        DATEDIFF(
            (SELECT MAX(order_purchase_timestamp) FROM orders),
            MAX(o.order_purchase_timestamp)
        ) AS recency,
        COUNT(DISTINCT o.order_id) AS frequency,
        ROUND(SUM(p.total_payment), 2) AS monetary
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN payments_summary p
        ON o.order_id = p.order_id
    GROUP BY c.customer_unique_id
),

rfm_scores AS (
    SELECT *,
        NTILE(5) OVER (ORDER BY recency DESC) AS r_score,
        NTILE(5) OVER (ORDER BY frequency ASC) AS f_score,
        NTILE(5) OVER (ORDER BY monetary ASC) AS m_score
    FROM rfm
),

segments AS (
    SELECT
        customer_unique_id,
        monetary,
        CASE
            WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4 THEN 'Champions'
            WHEN r_score >= 3 AND f_score >= 3 THEN 'Loyal Customers'
            WHEN r_score >= 4 AND f_score <= 2 THEN 'New / Promising Customers'
            WHEN r_score <= 2 AND m_score >= 4 THEN 'At Risk High Value'
            WHEN r_score <= 2 AND f_score <= 2 THEN 'Lost Customers'
            ELSE 'Others'
        END AS customer_segment
    FROM rfm_scores
)

SELECT
    customer_segment,
    COUNT(*) AS customers,
    ROUND(AVG(monetary), 2) AS avg_customer_value,
    ROUND(SUM(monetary), 2) AS total_revenue
FROM segments
GROUP BY customer_segment
ORDER BY total_revenue DESC;
