-- Rank, row_number, dense_rank
select price,
DENSE_RANK() over(
	partition by category_id
	order by price Desc
) as dense_rank,
row_number() over(
	partition by category_id
	order by price Desc 
) as row_num,
RANK() over(
	partition by category_id
	order by price Desc
) as rank
from products
ORDER BY category_id, price DESC;

-- CTE top_3
with top_3_in_category as (
	select price, category_id,
	row_number () over(
		partition by category_id
		order by price desc
		) as row_num
	from products
)
select *
from top_3_in_category 
where row_num <= 3

-- Выручка по дням
select o.created_at::date, SUM(oi.quantity * oi.unit_price) AS day_revenue
from order_items oi
inner join orders as o
	on oi.order_id = o.id
group by o.created_at::date
order by o.created_at::date desc

-- Нарастающий итог выручки
WITH daily_sales(day, day_revenue) AS (
    VALUES
        (DATE '2026-10-01', 1000),
        (DATE '2026-10-02', 1500),
        (DATE '2026-10-03', 1200),
        (DATE '2026-10-04', 2000)
)
SELECT
    day,
    day_revenue,
    SUM(day_revenue) OVER (
    ORDER BY day
	) AS running_total
FROM daily_sales
ORDER BY day;

-- Доля выручки
WITH seller_sales AS (
    SELECT
    p.seller_id,
    p.category_id,
    SUM(oi.quantity * oi.unit_price) AS seller_revenue
FROM products AS p
JOIN order_items AS oi
    ON p.id = oi.product_id
GROUP BY p.seller_id, p.category_id
)
SELECT
    seller_id,
    category_id,
    seller_revenue,
    SUM(seller_revenue) OVER (
        PARTITION BY category_id
    ) AS category_revenue,
    ROUND(
    seller_revenue * 100.0 /
    SUM(seller_revenue) OVER (
        PARTITION BY category_id),2) AS revenue_share
FROM seller_sales;

-- LAG LEAD
WITH daily_sales(day, day_revenue) AS (
    VALUES
        (DATE '2026-10-01', 1000),
        (DATE '2026-10-02', 1500),
        (DATE '2026-10-03', 1200),
        (DATE '2026-10-04', 2000)
)
SELECT
    day,
    day_revenue,
    lag(day_revenue) over (order by day),
    LEAD(day_revenue) OVER (
    ORDER BY day) AS next_revenue,
    day_revenue - LAG(day_revenue) OVER (
    ORDER BY day) as revenue_growth
FROM daily_sales;

-- Group by
select AVG(p.price), p.category_id 
from products p 
group by p.category_id 
order by p.category_id desc 

-- OVER
select p.title, p.category_id, p.price,
	AVG(price) Over(
	 PARTITION by p.category_id) as avg_price
from products p 
ORDER BY p.category_id, price



