
-- Один отдельный пользователь
INSERT INTO users (name, email)
SELECT 'Stepan', 'stepan@example.com'
WHERE NOT EXISTS (
    SELECT 1
    FROM users
    WHERE email = 'stepan@example.com'
);


-- Генерируем 100 пользователей
INSERT INTO users (name, email)
SELECT
    'User_' || g,
    'user_' || g || '@example.com'
FROM generate_series(1, 100) AS g
WHERE NOT EXISTS (
    SELECT 1
    FROM users AS u
    WHERE u.email = 'user_' || g || '@example.com'
);


-- =========================================================
-- 2. ПРОДАВЦЫ
-- =========================================================

-- Создаём продавца для каждого пользователя,
-- у которого продавца ещё нет
INSERT INTO sellers (user_id, name, email)
SELECT
    u.id,
    'Seller_' || u.id,
    'seller_' || u.id || '@example.com'
FROM users AS u
WHERE NOT EXISTS (
    SELECT 1
    FROM sellers AS s
    WHERE s.user_id = u.id
);


-- =========================================================
-- 3. КАТЕГОРИИ
-- =========================================================

-- Корневые категории
INSERT INTO categories (name, parent_id)
SELECT 'Электроника', NULL
WHERE NOT EXISTS (
    SELECT 1 FROM categories WHERE name = 'Электроника'
);

INSERT INTO categories (name, parent_id)
SELECT 'Одежда', NULL
WHERE NOT EXISTS (
    SELECT 1 FROM categories WHERE name = 'Одежда'
);

INSERT INTO categories (name, parent_id)
SELECT 'Книги', NULL
WHERE NOT EXISTS (
    SELECT 1 FROM categories WHERE name = 'Книги'
);

INSERT INTO categories (name, parent_id)
SELECT 'Бытовая техника', NULL
WHERE NOT EXISTS (
    SELECT 1 FROM categories WHERE name = 'Бытовая техника'
);

INSERT INTO categories (name, parent_id)
SELECT 'Спорт', NULL
WHERE NOT EXISTS (
    SELECT 1 FROM categories WHERE name = 'Спорт'
);


-- Подкатегории
INSERT INTO categories (name, parent_id)
SELECT
    'Смартфоны',
    (SELECT id FROM categories WHERE name = 'Электроника')
WHERE NOT EXISTS (
    SELECT 1 FROM categories WHERE name = 'Смартфоны'
);

INSERT INTO categories (name, parent_id)
SELECT
    'Ноутбуки',
    (SELECT id FROM categories WHERE name = 'Электроника')
WHERE NOT EXISTS (
    SELECT 1 FROM categories WHERE name = 'Ноутбуки'
);

INSERT INTO categories (name, parent_id)
SELECT
    'Футболки',
    (SELECT id FROM categories WHERE name = 'Одежда')
WHERE NOT EXISTS (
    SELECT 1 FROM categories WHERE name = 'Футболки'
);

INSERT INTO categories (name, parent_id)
SELECT
    'Художественная литература',
    (SELECT id FROM categories WHERE name = 'Книги')
WHERE NOT EXISTS (
    SELECT 1 FROM categories WHERE name = 'Художественная литература'
);


-- =========================================================
-- 4. ТОВАРЫ
-- =========================================================

-- Доводим количество товаров минимум до 1000.
-- Для каждого товара случайно выбирается продавец и категория.

INSERT INTO products (
    title,
    price,
    seller_id,
    category_id
)
SELECT
    'Product_' || g || '_' || (SELECT COUNT(*) FROM products),
    ROUND((random() * 99000 + 1000)::numeric, 2),

    sellers_ids.ids[
        1 + floor(
            random() * array_length(sellers_ids.ids, 1)
        )::int
    ],

    categories_ids.ids[
        1 + floor(
            random() * array_length(categories_ids.ids, 1)
        )::int
    ]
    
FROM generate_series(
    1,
    (
        SELECT GREATEST(
            0,
            1000 - COUNT(*)
        )::int
        FROM products
    )
) AS g

CROSS JOIN (
    SELECT array_agg(id) AS ids
    FROM sellers
) AS sellers_ids

CROSS JOIN (
    SELECT array_agg(id) AS ids
    FROM categories
) AS categories_ids;


-- =========================================================
-- 5. ЗАКАЗЫ
-- =========================================================

-- Доводим количество заказов минимум до 1000.
-- Покупатель выбирается случайно из существующих users.

INSERT INTO orders (user_id)
SELECT
    users_ids.ids[
        1 + floor(
            random() * array_length(users_ids.ids, 1)
        )::int
    ]

FROM generate_series(
    1,
    (
        SELECT GREATEST(
            0,
            1000 - COUNT(*)
        )::int
        FROM orders
    )
) AS g

CROSS JOIN (
    SELECT array_agg(id) AS ids
    FROM users
) AS users_ids;


-- =========================================================
-- 6. ПОЗИЦИИ ЗАКАЗОВ
-- =========================================================

-- Каждому заказу без позиций добавляем один случайный товар.
-- quantity будет от 1 до 5.
-- unit_price сохраняет цену товара на момент заказа.

INSERT INTO order_items (
    order_id,
    product_id,
    quantity,
    unit_price
)
SELECT
    o.id,
    p.id,
    1 + floor(random() * 5)::int,
    p.price

FROM orders AS o

CROSS JOIN LATERAL (
    SELECT
        pr.id,
        pr.price
    FROM products AS pr
    WHERE o.id IS NOT NULL
    ORDER BY random() + o.id * 0
    LIMIT 1
) AS p

WHERE NOT EXISTS (
    SELECT 1
    FROM order_items AS oi
    WHERE oi.order_id = o.id
);


-- =========================================================
-- 7. СКЛАДСКИЕ ОСТАТКИ
-- =========================================================

-- Для каждого товара создаём запись stock.
-- Количество от 0 до 100.

INSERT INTO stock (
    product_id,
    quantity
)
SELECT
    p.id,
    floor(random() * 101)::int

FROM products AS p

WHERE NOT EXISTS (
    SELECT 1
    FROM stock AS s
    WHERE s.product_id = p.id
);


-- =========================================================
-- 8. ПЛАТЕЖИ
-- =========================================================

-- Для каждого заказа без платежа создаём платёж.
-- Сумма = сумма всех позиций заказа.

INSERT INTO payments (
    order_id,
    amount,
    status
)
SELECT
    o.id,
    SUM(oi.quantity * oi.unit_price),
    'completed'

FROM orders AS o

JOIN order_items AS oi
    ON oi.order_id = o.id

WHERE NOT EXISTS (
    SELECT 1
    FROM payments AS p
    WHERE p.order_id = o.id
)

GROUP BY o.id;


-- =========================================================
-- 9. КОРЗИНЫ
-- =========================================================

-- Для каждого пользователя создаём корзину,
-- если её ещё нет.

INSERT INTO carts (user_id)
SELECT
    u.id

FROM users AS u

WHERE NOT EXISTS (
    SELECT 1
    FROM carts AS c
    WHERE c.user_id = u.id
);


-- =========================================================
-- 10. ПОЗИЦИИ КОРЗИН
-- =========================================================

-- В каждую пустую корзину добавляем один случайный товар.

INSERT INTO cart_items (
    cart_id,
    product_id,
    quantity
)
SELECT
    c.id,
    p.id,
    1 + floor(random() * 5)::int

FROM carts AS c

CROSS JOIN LATERAL (
    SELECT pr.id
    FROM products AS pr
    WHERE c.id IS NOT NULL
    ORDER BY random() + c.id * 0
    LIMIT 1
) AS p

WHERE NOT EXISTS (
    SELECT 1
    FROM cart_items AS ci
    WHERE ci.cart_id = c.id
);


-- =========================================================
-- 11. АДРЕСА
-- =========================================================

-- Каждому пользователю без адреса создаём один адрес.

INSERT INTO addresses (
    city,
    street,
    house,
    user_id
)
SELECT
    'Москва',
    'Улица_' || u.id,
    (1 + floor(random() * 100)::int)::text,
    u.id

FROM users AS u

WHERE NOT EXISTS (
    SELECT 1
    FROM addresses AS a
    WHERE a.user_id = u.id
);


-- =========================================================
-- 12. ДОСТАВКИ
-- =========================================================

-- Для заказа берём адрес именно того пользователя,
-- которому принадлежит заказ.

INSERT INTO deliveries (
    order_id,
    address_id,
    status
)
SELECT
    o.id,
    a.id,
    'pending'

FROM orders AS o

JOIN LATERAL (
    SELECT ad.id
    FROM addresses AS ad
    WHERE ad.user_id = o.user_id
    ORDER BY ad.id
    LIMIT 1
) AS a ON TRUE

WHERE NOT EXISTS (
    SELECT 1
    FROM deliveries AS d
    WHERE d.order_id = o.id
);

