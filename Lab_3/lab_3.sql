-- Запрос соединяющий три таблицы	
SELECT p.title, s.name, c.name
FROM products AS p
INNER JOIN categories AS c
    ON p.category_id = c.id
INNER JOIN sellers AS s
    ON p.seller_id = s.id;

-- Запрос с left join
select o.id, p.id 
from orders as o
left join payments as p 
	on o.id = p.order_id 
where p.id is null 

-- group by и агригатные функции
select p.category_id, c."name" , count(p.id), avg(p.price)
from products as p 
inner join categories as c 
	on p.category_id = c.id 
group by p.category_id, c."name" 

-- having
select p.category_id, c."name" , count(p.id), avg(p.price)
from products as p 
inner join categories as c 
	on p.category_id = c.id 
group by p.category_id, c."name"
having AVG(p.price) >50000

-- Подзапрос
SELECT title, price
FROM products
WHERE price < (
    SELECT AVG(price)
    FROM products
);

-- Подзапрос с IN
SELECT title, price
FROM products
WHERE category_id IN (
    SELECT c.id
    FROM categories as c
    WHERE c."name"  = 'Электроника'
);

-- Подзапрос с exists
SELECT s."name" 
FROM sellers AS s
WHERE EXISTS (
    SELECT 1
    FROM products AS p
    WHERE p.seller_id = s.id 
);

-- CTE
with cte as (
	select p.title, s."name", p.price 
	from sellers as s 
	inner join products as p
		on s.id = p.id 
)
select cte."name"
from cte
where cte.price > 20000

-- CTE рекурсивно
WITH RECURSIVE category_tree AS (
    SELECT id, name, parent_id
    FROM categories
    WHERE name = 'Электроника'

    UNION ALL

    SELECT c.id, c.name, c.parent_id
    FROM categories AS c
    INNER JOIN category_tree AS ct
        ON c.parent_id = ct.id
)
SELECT * FROM category_tree;

-- View категорий
CREATE VIEW category_statistics AS
SELECT
    category_id,
    COUNT(id) AS product_count,
    AVG(price) AS avg_price
FROM products
GROUP BY category_id;

-- view продавцов
CREATE VIEW seller_statistics AS
SELECT
	s.name AS seller_name,
	COUNT(p.id) AS product_count,
	ROUND(AVG(p.price), 2) AS avg_price
FROM sellers AS s
LEFT JOIN products AS p
	ON p.seller_id = s.id
GROUP BY s.id, s.name

SELECT * FROM seller_statistics;
SELECT * FROM category_statistics;

