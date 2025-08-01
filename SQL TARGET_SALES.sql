/* OBJECTIVE:
“To design a scalable MySQL data pipeline and derive actionable insights from the Target Sales dataset by performing 
relational joins, complex aggregations, window functions, and optimizing queries through indexes and stored procedures — simulating a real-world retail analytics system.”
*/

# DATA BASE CREATION.
create database 	Target_Sales;

# CALLING DATABASE.
use target_sales;

##  CREATE TABLES.

# 1.CREATE CUSTOMERS TABLE
create table customers(
customer_id varchar(50) primary key,
customer_unique_id	varchar(50) unique not null,
customer_zip_code_prefix	int not null,
customer_city	varchar(30),
customer_state varchar(10)
);

# 2.CREATE ORDERS TABLE 
create table orders(
order_id	varchar(50) primary key,
customer_id	 varchar(50),
order_status	varchar(20),
order_purchase_timestamp	timestamp,
order_approved_at	timestamp,
order_delivered_carrier_date	timestamp,
order_delivered_customer_date	timestamp,
order_estimated_delivery_date		timestamp,
foreign key (customer_id) REFERENCES customers(customer_id)
);

#3. CREATE TABLE PRODUCTS
create table products(
product_id	varchar(60) primary key,
product_category	varchar(50),
product_name_length	int,
product_description_length	int,
product_photos_qty	int,
product_weight_g	int,
product_length_cm	int,
product_height_cm	int,
product_width_cm int
);



#4.CREATE TABLE PAYMENTS
create table payments(
order_id	varchar(50),
payment_sequential	int,
payment_type	varchar(50),
payment_installments	int,
payment_value decimal(10,2),
FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

#5.CREATE TABLE SELLERS
create table sellers(
seller_id	VARCHAR(50) PRIMARY KEY,
seller_zip_code_prefix	int,
seller_city	varchar(30),
seller_state	varchar(10)
);

#6. CREATE TABLE GEOLOCATION
create table geolocation(
geolocation_zip_code_prefix int not null,
geolocation_lat	decimal(10,8),
geolocation_lng	decimal(10,8),
geolocation_city	varchar(30),
geolocation_state varchar(30)
);

#7. CREATE TABLE ORDER_ITEMS
create table order_items(
order_id	varchar(50),
order_item_id	int,
product_id	varchar(60),
seller_id	varchar(50),
shipping_limit_date	datetime,
price	decimal(10,2),
freight_value	decimal(10,2),
primary key(order_id, order_item_id),
foreign key  (order_id) REFERENCES orders(order_id),
FOREIGN KEY (product_id) REFERENCES products(product_id),
FOREIGN KEY (seller_id) REFERENCES sellers(seller_id)
);
drop table order_items
select count(*) from customers #81625
select count(*) from geolocation #88197
select count(*) from orders #40631
select count(*) from payments #9313
select count(*) from products #32340
select count(*) from sellers #3092
select count(*) from order_items #12875

#  1. Revenue by Month and Payment Type (CTE + Window Function)
WITH monthly_payments AS (
    SELECT 
        DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS order_month,
        p.payment_type,
        SUM(p.payment_value) AS total_revenue
    FROM payments p
    JOIN orders o ON p.order_id = o.order_id
    GROUP BY order_month, p.payment_type
)
SELECT *,
       RANK() OVER (PARTITION BY order_month ORDER BY total_revenue DESC) AS rank_by_month
FROM monthly_payments;

# 2. Most Sold Product Categories (Join + Aggregate)

SELECT 
    pr.product_category,
    COUNT(*) AS total_sold
FROM order_items oi
JOIN products pr ON oi.product_id = pr.product_id
GROUP BY pr.product_category
ORDER BY total_sold DESC
LIMIT 10;


# 3. Customers with Late Deliveries (CTE + Date Comparison)

WITH delivery_delays AS (
    SELECT 
        o.order_id,
        o.customer_id,
        DATEDIFF(o.order_delivered_customer_date, o.order_estimated_delivery_date) AS delay_days
    FROM orders o
    WHERE o.order_delivered_customer_date IS NOT NULL
)
SELECT * 
FROM delivery_delays
WHERE delay_days > 0
ORDER BY delay_days DESC;

# 4. Temporary Table: Sellers with Highest Freight Cost

CREATE TEMPORARY TABLE top_freight AS
SELECT 
    oi.seller_id,
    SUM(oi.freight_value) AS total_freight
FROM order_items oi
GROUP BY oi.seller_id
ORDER BY total_freight DESC
LIMIT 10;

SELECT * FROM top_freight;

# 5. Customer Lifetime Value (Join + Aggregation)
SELECT 
    c.customer_unique_id,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(p.payment_value) AS lifetime_value
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN payments p ON o.order_id = p.order_id
GROUP BY c.customer_unique_id
ORDER BY lifetime_value DESC
LIMIT 20;

#  6. Add Indexes for Performance
CREATE INDEX idx_orders_customer_id ON orders(customer_id);
CREATE INDEX idx_order_items_product_id ON order_items(product_id);
CREATE INDEX idx_payments_order_id ON payments(order_id);

#  7. Stored Procedure: Get Order Summary by Order ID

DELIMITER //

CREATE PROCEDURE GetOrderSummary(IN in_order_id VARCHAR(50))
BEGIN
    SELECT 
        o.order_id, 
        o.order_status, 
        o.order_purchase_timestamp,
        c.customer_city, 
        c.customer_state,
        p.payment_type, 
        p.payment_value,
        SUM(oi.price) AS total_items_price,
        SUM(oi.freight_value) AS total_freight
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    JOIN payments p ON o.order_id = p.order_id
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_id = in_order_id
    GROUP BY 
        o.order_id, 
        o.order_status, 
        o.order_purchase_timestamp,
        c.customer_city, 
        c.customer_state,
        p.payment_type, 
        p.payment_value;
END //

DELIMITER ;
CALL GetOrderSummary('47770eb9100c2d0c44946d9cf07ec65d');
