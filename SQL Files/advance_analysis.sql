/*---Advance Analysis ----*/

=========================================================
--1. Top performing product categories within each month
=========================================================
WITH category_monthly_sales AS (
	SELECT 
		DATE_TRUNC('month', order_purchase_timestamp::timestamp) AS sales_month,
		COALESCE(
			t.product_category_name_english,
			p.product_category_name,
			'Unknown'
		) AS product_category,
		ROUND(SUM(i.price)::numeric, 2) AS revenue
	FROM orders o
	JOIN order_items i
		ON o.order_id = i.order_id
	JOIN products p
		ON i.product_id = p.product_id
	LEFT JOIN product_category_name_translation t
		ON p.product_category_name = t.product_category_name
	GROUP BY 1, 2
),
ranked_categories AS (
	SELECT sales_month, product_category, revenue,
	DENSE_RANK() OVER(PARTITION BY sales_month ORDER BY revenue DESC) AS category_rank
FROM category_monthly_sales
)
SELECT sales_month, product_category, revenue, category_rank
FROM ranked_categories
WHERE category_rank <=3
ORDER BY sales_month, category_rank;


=========================================================
--2. Repeat Customer Analysis
=========================================================
WITH customer_orders AS (
	SELECT 
		c.customer_unique_id,
		COUNT(DISTINCT o.order_id) AS total_orders,
		SUM(i.price) AS total_spending
	FROM orders o
	JOIN customers c
		ON o.customer_id = c.customer_id
	JOIN order_items i
		ON o.order_id = i.order_id
	WHERE order_status = 'delivered'
	GROUP BY customer_unique_id
)
SELECT
    CASE
        WHEN total_orders = 1 THEN 'One-time customer'
        ELSE 'Repeat customer'
    END AS customer_type,
    COUNT(*) AS customer_count,
    ROUND(SUM(total_spending)::numeric, 2) AS total_revenue,
    ROUND(AVG(total_spending)::numeric, 2) AS avg_customer_spending
FROM customer_orders
GROUP BY 1
ORDER BY total_revenue DESC;



=========================================================
--3. Delivery delay analysis
=========================================================
SELECT
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS delivered_orders,
    ROUND(
        AVG(
            EXTRACT(
                EPOCH FROM (
                    o.order_delivered_customer_date::timestamp
                    - o.order_estimated_delivery_date::timestamp
                )
            ) / 86400
        )::numeric,
        2
    ) AS avg_days_late,
    COUNT(DISTINCT o.order_id) FILTER (
        WHERE o.order_delivered_customer_date::timestamp
            > o.order_estimated_delivery_date::timestamp
    ) AS late_orders
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
  AND o.order_estimated_delivery_date IS NOT NULL
GROUP BY c.customer_state
HAVING COUNT(DISTINCT o.order_id) >= 100
ORDER BY avg_days_late DESC;



=========================================================
--4. Revenue contribution and Pareto analysis
=========================================================
WITH category_revenue AS (
    SELECT
        COALESCE(
            t.product_category_name_english,
            p.product_category_name,
            'Unknown'
        ) AS category,
        SUM(oi.price) AS revenue
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    JOIN products p
        ON oi.product_id = p.product_id
    LEFT JOIN product_category_name_translation t
        ON p.product_category_name = t.product_category_name
    WHERE o.order_status = 'delivered'
    GROUP BY 1
),
category_contribution AS (
    SELECT
        category,
        revenue,
        SUM(revenue) OVER () AS total_revenue,
        SUM(revenue) OVER (
            ORDER BY revenue DESC, category
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS cumulative_revenue
    FROM category_revenue
)
SELECT
    category,
    ROUND(revenue::numeric, 2) AS category_revenue,
    ROUND(
        (100.0 * revenue / NULLIF(total_revenue, 0))::numeric,
        2
    ) AS revenue_percentage,
    ROUND(
        (100.0 * cumulative_revenue / NULLIF(total_revenue, 0))::numeric,
        2
    ) AS cumulative_revenue_percentage
FROM category_contribution
ORDER BY revenue DESC;


======================================
--5. Month-over-month revenue growth
======================================

WITH monthly_sales AS (
	SELECT 
		DATE_TRUNC('month',order_purchase_timestamp::timestamp) AS sales_month,
		ROUND(SUM(i.price)::numeric, 2) AS monthly_revenue
	FROM orders o
	JOIN order_items i
		ON o.order_id = i.order_id
	WHERE order_status = 'delivered'
	GROUP BY 1
),
previous_month AS (
	SELECT sales_month, monthly_revenue,
	LAG(monthly_revenue) OVER(ORDER BY sales_month) AS previous_monthly_revenue
	FROM monthly_sales
)
SELECT sales_month, monthly_revenue, previous_monthly_revenue,
	ROUND(
		((monthly_revenue - previous_monthly_revenue)/ 
		 NULLIF(previous_monthly_revenue, 0) * 100)::numeric, 2
	) AS growth_percentage
FROM previous_month
ORDER BY sales_month;


