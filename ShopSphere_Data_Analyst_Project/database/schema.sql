-- ShopSphere analytical database
-- Tables are loaded from the CSV files.
CREATE TABLE customers (...);
CREATE TABLE products (...);
CREATE TABLE orders (...);
CREATE TABLE returns (...);
CREATE TABLE marketing (...);

-- Logical relationships:
-- customers.customer_id -> orders.customer_id
-- products.product_id -> orders.product_id
-- orders.order_id -> returns.order_id
-- customers.customer_id -> marketing.customer_id
