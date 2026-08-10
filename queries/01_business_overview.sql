-- Business Overview Analysis

-- 1. Average Order Value
-- What is the average revenue per order?
SELECT
    ROUND(SUM(total_payment) / COUNT(DISTINCT order_id), 2) AS avg_order_value
FROM payments_summary;


-- 2. Monthly Revenue Trend
-- How is revenue changing over time?
SELECT
    DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS month,
    ROUND(SUM(p.total_payment), 2) AS revenue
FROM orders o
JOIN payments_summary p
    ON o.order_id = p.order_id
GROUP BY month
ORDER BY month;


-- 3. Revenue by Customer State
-- Which regions generate the most revenue?
SELECT
    c.customer_state,
    ROUND(SUM(p.total_payment), 2) AS revenue
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
JOIN payments_summary p
    ON o.order_id = p.order_id
GROUP BY c.customer_state
ORDER BY revenue DESC;


-- 4. Revenue Concentration by State (%)
-- How concentrated is revenue geographically?
SELECT
    c.customer_state,
    ROUND(
        SUM(p.total_payment) * 100 /
        (SELECT SUM(total_payment) FROM payments_summary),
        2
    ) AS revenue_percentage
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
JOIN payments_summary p
    ON o.order_id = p.order_id
GROUP BY c.customer_state
ORDER BY revenue_percentage DESC;


-- 5. Top Product Categories by Revenue
-- Which categories drive the most revenue?
SELECT
    pr.product_category_name,
    ROUND(SUM(oi.total_item_value), 2) AS revenue
FROM order_items oi
JOIN products pr
    ON oi.product_id = pr.product_id
GROUP BY pr.product_category_name
ORDER BY revenue DESC
LIMIT 10;


-- 6. Top Categories by Number of Orders
-- Which categories are most popular?
SELECT
    pr.product_category_name,
    COUNT(DISTINCT oi.order_id) AS total_orders
FROM order_items oi
JOIN products pr
    ON oi.product_id = pr.product_id
GROUP BY pr.product_category_name
ORDER BY total_orders DESC
LIMIT 10;


-- 7. Average Review Score
-- What is overall customer satisfaction?
SELECT
    ROUND(AVG(review_score), 2) AS avg_rating
FROM reviews;


-- 8. Average Rating by Category
-- Which categories have higher/lower satisfaction?
SELECT
    pr.product_category_name,
    ROUND(AVG(r.review_score), 2) AS avg_rating
FROM order_items oi
JOIN products pr
    ON oi.product_id = pr.product_id
JOIN reviews r
    ON oi.order_id = r.order_id
GROUP BY pr.product_category_name
ORDER BY avg_rating DESC;

