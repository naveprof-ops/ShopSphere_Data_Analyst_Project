-- ShopSphere SQL Analysis
-- Revenue definition: delivered/returned orders only, excluding cancelled orders.
-- Net revenue is gross order value minus refunds.

-- 1. Overall KPIs
SELECT COUNT(*) AS total_orders,
       COUNT(DISTINCT customer_id) AS customers
FROM orders;

SELECT ROUND(SUM(quantity * unit_price * (1-discount)),2) AS gross_order_value
FROM orders
WHERE order_status <> 'Cancelled';

SELECT ROUND(AVG(quantity * unit_price * (1-discount)),2) AS average_order_value
FROM orders
WHERE order_status <> 'Cancelled';

-- 2. Monthly revenue
SELECT substr(order_date,1,7) AS month,
       ROUND(SUM(quantity * unit_price * (1-discount)),2) AS revenue
FROM orders
WHERE order_status <> 'Cancelled'
GROUP BY month
ORDER BY month;

-- 3. Revenue by category
SELECT p.category,
       ROUND(SUM(o.quantity*o.unit_price*(1-o.discount)),2) AS revenue
FROM orders o JOIN products p ON o.product_id=p.product_id
WHERE o.order_status <> 'Cancelled'
GROUP BY p.category
ORDER BY revenue DESC;

-- 4. Top products
SELECT p.product_name,
       SUM(o.quantity) AS units,
       ROUND(SUM(o.quantity*o.unit_price*(1-o.discount)),2) AS revenue
FROM orders o JOIN products p ON o.product_id=p.product_id
WHERE o.order_status <> 'Cancelled'
GROUP BY p.product_id,p.product_name
ORDER BY revenue DESC
LIMIT 10;

-- 5. One-time vs repeat customers
WITH customer_orders AS (
 SELECT customer_id, COUNT(DISTINCT order_id) AS orders
 FROM orders WHERE order_status <> 'Cancelled'
 GROUP BY customer_id
)
SELECT CASE WHEN orders=1 THEN 'One-time' ELSE 'Repeat' END AS customer_type,
       COUNT(*) AS customers
FROM customer_orders
GROUP BY customer_type;

-- 6. Repeat purchase rate
WITH customer_orders AS (
 SELECT customer_id, COUNT(DISTINCT order_id) AS orders
 FROM orders WHERE order_status <> 'Cancelled'
 GROUP BY customer_id
)
SELECT ROUND(100.0*SUM(CASE WHEN orders>1 THEN 1 ELSE 0 END)/COUNT(*),2) AS repeat_purchase_rate
FROM customer_orders;

-- 7. Customer lifetime revenue
SELECT c.customer_id,c.customer_name,
       ROUND(SUM(o.quantity*o.unit_price*(1-o.discount)),2) AS lifetime_revenue
FROM customers c JOIN orders o ON c.customer_id=o.customer_id
WHERE o.order_status <> 'Cancelled'
GROUP BY c.customer_id,c.customer_name
ORDER BY lifetime_revenue DESC
LIMIT 20;

-- 8. RFM base table
WITH base AS (
 SELECT customer_id,
        MAX(order_date) AS last_purchase,
        COUNT(DISTINCT order_id) AS frequency,
        SUM(quantity*unit_price*(1-discount)) AS monetary
 FROM orders
 WHERE order_status <> 'Cancelled'
 GROUP BY customer_id
)
SELECT customer_id,last_purchase,frequency,ROUND(monetary,2) AS monetary
FROM base;

-- 9. Return rate by category
SELECT p.category,
       COUNT(DISTINCT CASE WHEN o.order_status='Returned' THEN o.order_id END)*100.0/
       COUNT(DISTINCT o.order_id) AS return_rate
FROM orders o JOIN products p ON o.product_id=p.product_id
GROUP BY p.category
ORDER BY return_rate DESC;

-- 10. Cancellation rate by region
SELECT region,
       ROUND(100.0*SUM(CASE WHEN order_status='Cancelled' THEN 1 ELSE 0 END)/COUNT(*),2) AS cancellation_rate
FROM orders
GROUP BY region
ORDER BY cancellation_rate DESC;

-- 11. Revenue leakage from cancellations
SELECT region,
       ROUND(SUM(CASE WHEN order_status='Cancelled'
                 THEN quantity*unit_price*(1-discount) ELSE 0 END),2) AS cancelled_order_value
FROM orders
GROUP BY region
ORDER BY cancelled_order_value DESC;

-- 12. New vs returning customers by month
WITH first_orders AS (
 SELECT customer_id, MIN(order_date) AS first_order_date
 FROM orders WHERE order_status <> 'Cancelled'
 GROUP BY customer_id
)
SELECT substr(o.order_date,1,7) AS month,
       COUNT(DISTINCT CASE WHEN o.order_date=f.first_order_date THEN o.customer_id END) AS new_customers,
       COUNT(DISTINCT CASE WHEN o.order_date>f.first_order_date THEN o.customer_id END) AS returning_customers
FROM orders o JOIN first_orders f ON o.customer_id=f.customer_id
WHERE o.order_status <> 'Cancelled'
GROUP BY month
ORDER BY month;

-- 13. Profit by category
SELECT p.category,
       ROUND(SUM(o.quantity*(o.unit_price*(1-o.discount)-p.cost_price)),2) AS estimated_profit,
       ROUND(100.0*SUM(o.quantity*(o.unit_price*(1-o.discount)-p.cost_price))/
             SUM(o.quantity*o.unit_price*(1-o.discount)),2) AS margin_pct
FROM orders o JOIN products p ON o.product_id=p.product_id
WHERE o.order_status <> 'Cancelled'
GROUP BY p.category
ORDER BY estimated_profit DESC;

-- 14. Marketing channel performance
SELECT m.channel,
       COUNT(DISTINCT m.customer_id) AS customers,
       ROUND(SUM(o.quantity*o.unit_price*(1-o.discount)),2) AS attributed_customer_revenue
FROM marketing m JOIN orders o ON m.customer_id=o.customer_id
WHERE o.order_status <> 'Cancelled'
GROUP BY m.channel
ORDER BY attributed_customer_revenue DESC;
