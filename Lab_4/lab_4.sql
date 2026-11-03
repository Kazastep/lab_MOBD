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
order by o.created_at::date DESC









