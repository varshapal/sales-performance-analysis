
/*
--Sales Analysis
*/

===================================
--1. Overall Sales Performance
===================================
SELECT 
	ROUND(SUM(i.price)::numeric, 2) AS total_sales,
	COUNT(DISTINCT o.order_id) AS total_order,
	ROUND(
		(SUM(i.price)/ NULLIF(COUNT(DISTINCT o.order_id), 0))::numeric, 2
	) AS avg_order_value
FROM orders o
JOIN order_items i
	ON o.order_id = i.order_id
WHERE order_status = 'delivered';


===================================
--2. Monthly Sales Trends
===================================
SELECT 
	DATE_TRUNC('month',order_purchase_timestamp::timestamp) AS sales_month,
	SUM(i.price) AS monthly_sales,
	COUNT(DISTINCT o.order_id) AS total_orders
FROM orders o
JOIN order_items i
	ON o.order_id = i.order_id
WHERE order_status = 'delivered'
GROUP BY 1
ORDER BY 1;



===================================
--3. Yearly Sales Performance
===================================
SELECT 
	DATE_TRUNC('year',order_purchase_timestamp::timestamp) AS sales_year,
	SUM(i.price) AS yearly_sales,
	COUNT(DISTINCT o.order_id) AS total_orders
FROM orders o
JOIN order_items i
	ON o.order_id = i.order_id
WHERE order_status = 'delivered'
GROUP BY 1
ORDER BY 1;


===================================
--4. Product Category Performance
===================================
SELECT
	COALESCE(
		t.product_category_name_english,
		p.product_category_name,
		'Unknown'
	) AS product_category,
	SUM(i.price) AS total_sales
FROM products p
JOIN order_items i
	ON p.product_id = i.product_id
LEFT JOIN product_category_name_translation t
	ON p.product_category_name = t.product_category_name
GROUP BY product_category
ORDER BY total_sales DESC;



==================================================
--5. What are the top 10 products by sales value?
==================================================
SELECT 
	COALESCE(
		t.product_category_name_english,
		p.product_category_name,
		'Unknown'
	) AS product_category,
	SUM(price) total_sales
FROM products p 
JOIN order_items i 
	ON p.product_id = i.product_id
LEFT JOIN product_category_name_translation t 
	ON p.product_category_name = t.product_category_name
GROUP BY product_category
ORDER BY total_sales DESC
LIMIT 10;



===================================
--6. State-wise Sales Performance
===================================
SELECT 
	customer_state,
	ROUND(SUM(i.price)::numeric, 2) AS total_sales
FROM customers c
JOIN orders o
	ON c.customer_id = o.customer_id
JOIN order_items i
	ON o.order_id = i.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY total_sales DESC;




===================================
--7. Payment Method Analysis
===================================

SELECT 
	payment_type,
	SUM(payment_value) AS total_payment_value,
	COUNT(DISTINCT order_id) AS total_orders
FROM order_payments
GROUP BY payment_type
ORDER BY total_orders DESC;



===================================
--8. Order Status Analysis
===================================

SELECT 
	order_status, 
	COUNT(DISTINCT order_id) AS total_orders 
FROM orders
GROUP BY order_status
ORDER BY total_orders DESC;


===================================
--9. Average order value by month
===================================
SELECT DATE_TRUNC('month',order_purchase_timestamp::timestamp) AS monthly_order,
	ROUND(
		(SUM(price)/ NULLIF(COUNT(DISTINCT o.order_id), 0))::numeric, 2
	) AS avg_order_value
FROM orders o
JOIN order_items i
	ON o.order_id = i.order_id
GROUP BY monthly_order;

===================================================
--10. What is the average freight charge per order?
===================================================
SELECT 
	SUM(i.freight_value) / 
	NULLIF(COUNT(DISTINCT o.order_id), 0) 
	AS  avg_freight_per_order
FROM orders o
JOIN order_items i
	ON o.order_id = i.order_id
WHERE o.order_status = 'delivered';


===============================================
--11. What percentage of orders were delivered?
===============================================
SELECT
    COUNT(*) AS total_orders,
    COUNT(*) FILTER (
        WHERE order_status = 'delivered'
    ) AS delivered_orders,
    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE order_status = 'delivered'
        ) / NULLIF(COUNT(*), 0),
        2
    ) AS delivered_order_percentage
FROM orders;


========================================================
--12. What percentage of delivered orders arrived late?
========================================================
SELECT
    COUNT(*) AS delivered_orders,
    COUNT(*) FILTER (
        WHERE order_delivered_customer_date >
              order_estimated_delivery_date
    ) AS late_orders,
    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE order_delivered_customer_date >
                  order_estimated_delivery_date
        ) / NULLIF(COUNT(*), 0),
        2
    ) AS late_delivery_percentage
FROM orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL
  AND order_estimated_delivery_date IS NOT NULL;






