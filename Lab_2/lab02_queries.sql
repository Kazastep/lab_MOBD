-- Запрос с удалением дубликатов
SELECT DISTINCT
    seller_id AS seller,
    category_id AS category
FROM products
ORDER BY seller, category;

-- Фильтрация по нескольким условиям
SELECT
    id,
    title,
    price,
    seller_id,
    category_id,
    is_active
FROM products
WHERE
    is_active = TRUE
    AND (
        category_id = 1
        OR category_id = 2
    )
    AND price > 10000
ORDER BY price;

-- Запросы с предикатами 
SELECT
    id,
    title,
    price
FROM products
WHERE price BETWEEN 20000 AND 50000
ORDER BY price;

SELECT
    id,
    title,
    price,
    category_id
FROM products
WHERE category_id IN (1, 2, 3)
ORDER BY category_id, price;

SELECT
    id,
    title,
    price
FROM products
WHERE title ILIKE '%product_1%'
ORDER BY id;

SELECT
    id,
    name,
    parent_id
FROM categories
WHERE parent_id IS NULL
ORDER BY id;

-- Сортировка по двум столбцам в раздных направлениях
SELECT
    id,
    title,
    price,
    category_id
FROM products
ORDER BY
    category_id ASC,
    price DESC;

-- Постраничный вывод товаров
SELECT
    id,
    title,
    price,
    category_id
FROM products
ORDER BY id
LIMIT 20
OFFSET 20;