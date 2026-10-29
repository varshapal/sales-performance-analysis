/*
Purpose:
Check data completeness, duplicates,
relationships, valid values and dates.
*/

-- =================================================
--Check 1: Table Row Counts
-- =================================================
SELECT 'orders' AS table_name, COUNT(*) AS total_rows
FROM orders

UNION ALL

SELECT 'order_items', COUNT(*)
FROM order_items

UNION ALL

SELECT 'customers', COUNT(*)
FROM customers

UNION ALL

SELECT 'products', COUNT(*)
FROM products

UNION ALL

SELECT 'sellers', COUNT(*)
FROM sellers

UNION ALL

SELECT 'payments', COUNT(*)
FROM order_payments

UNION ALL

SELECT 'reviews', COUNT(*)
FROM order_reviews

UNION ALL

SELECT 'geolocation', COUNT(*)
FROM geolocation

UNION ALL

SELECT 'product_category_transalation', COUNT(*)
FROM product_category_name_translation

-- =================================================
--Check 2: Duplicate Order Ids
-- =================================================

SELECT order_id, COUNT(*) AS duplicate_count
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;


-- =================================================
--Check 3: Duplicate Order-item IDs
-- =================================================
SELECT order_id, order_item_id, COUNT(*) AS duplicate_count
FROM order_items
GROUP BY order_id, order_item_id
HAVING COUNT(*) > 1;


-- =================================================
--Check 4: Duplicate product, seller and customer IDs
-- =================================================
SELECT product_id, COUNT(*) AS duplicate_count
FROM products
GROUP BY product_id
HAVING COUNT(*) > 1;

SELECT seller_id, COUNT(*) AS duplicate_count
FROM sellers
GROUP BY seller_id
HAVING COUNT(*) > 1;

SELECT customer_id, COUNT(*) AS duplicate_count
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1;


-- =================================================
--Check 5: Missing value in orders
-- =================================================
SELECT COUNT(*) AS total_orders,
	COUNT(*) FILTER (
		WHERE order_id IS NULL
	) AS missing_order_id,
	COUNT(*) FILTER (
		WHERE customer_id IS NULL
	) AS missing_customer_id,
	COUNT(*) FILTER (
		WHERE order_status IS NULL
	) AS missing_order_status,
	COUNT(*) FILTER (
		WHERE order_purchase_timestamp IS NULL
	) AS missing_purchase_date
FROM orders;


-- =================================================
--Check 6: Missing value in order items
-- =================================================
SELECT COUNT(*) AS total_item_rows,
	COUNT(*) FILTER (
		WHERE order_id IS NULL
	) AS missing_order_id,
	COUNT(*) FILTER (
		WHERE product_id IS NULL
	) AS missing_product_id,
	COUNT(*) FILTER (
		WHERE seller_id IS NULL
	) AS missing_seller_id,
	COUNT(*) FILTER (
		WHERE price IS NULL
	) AS missing_price,
	COUNT(*) FILTER (
		WHERE freight_value IS NULL
	) AS missing_freight_value
FROM order_items;



-- =================================================
--Check 7: Relationships between tables
-- =================================================
--Order with no matching customer
SELECT o.order_id, o.customer_id
FROM orders o 
LEFT JOIN customers c
	ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL

--Order items with no matching order
SELECT i.order_id, i.order_item_id
FROM order_items i
LEFT JOIN orders o
	ON i.order_id = o.order_id
WHERE o.order_id IS NULL

--Order items with no matching product or seller
SELECT order_id, i.product_id, i.seller_id
FROM order_items i
LEFT JOIN products p
	ON i.product_id = p.product_id
LEFT JOIN sellers s
	ON i.seller_id = s.seller_id
WHERE p.product_id IS NULL OR
	s.seller_id IS NULL;
	

-- =================================================
--Check 8: Order status distribution
-- =================================================

SELECT order_status, COUNT(*) total_orders
FROM orders
GROUP BY order_status
ORDER BY total_orders DESC;



-- =================================================
--Check 9: Date inconsistencies
-- =================================================

SELECT order_id, order_status,
	order_purchase_timestamp, 
	order_delivered_customer_date,
	order_estimated_delivery_date
FROM orders
WHERE (order_delivered_customer_date IS NOT NULL
AND order_delivered_customer_date < order_purchase_timestamp)
OR (order_estimated_delivery_date IS NOT NULL
AND order_estimated_delivery_date < order_purchase_timestamp);



-- =================================================
--Check 10: Negative or unexpected numerical values
-- =================================================
--Invalid order item amounts
SELECT order_id, order_item_id, price, freight_value
FROM order_items 
WHERE price < 0 OR freight_value < 0
OR price IS NULL
OR freight_value IS NULL;

--Invalid payment values
SELECT order_id, payment_sequential,
payment_type, payment_installments,
payment_value
FROM order_payments
WHERE payment_value < 0
OR payment_value IS NULL;

-- =================================================
--Check 11: Payment method distribution
-- =================================================
SELECT payment_type, COUNT(*) AS payment_records,
SUM(payment_value) AS total_payment_value
FROM order_payments
GROUP BY payment_type
ORDER BY total_payment_value DESC;

--Payment without matching orders
SELECT p.order_id, p.payment_sequential
FROM order_payments p
LEFT JOIN orders o
	ON p.order_id = o.order_id
WHERE o.order_id IS NULL;



-- ======================================================================
--Check 12: Check product categories, review score 
-- ======================================================================
--Missing product category transalation
SELECT p.product_id, p.product_category_name
FROM products p
LEFT JOIN product_category_name_translation t
	ON p.product_category_name = t.product_category_name
WHERE p.product_category_name IS NOT NULL
AND t.product_category_name IS NULL;

--Handle missing translation (using COALESCE)
SELECT p.product_id, p.product_category_name AS origanal_category,
	COALESCE(
		t.product_category_name_english,
		p.product_category_name,
		'Unknown'
	) AS display_category
FROM products p
LEFT JOIN product_category_name_translation t
	ON p.product_category_name = t.product_category_name
WHERE p.product_category_name IS NOT NULL
AND t.product_category_name IS NULL;

-- Review scores outside the unexpected range
SELECT review_id, order_id, review_score
FROM order_reviews
WHERE review_score < 1 OR review_score > 5
OR review_score IS NULL;








