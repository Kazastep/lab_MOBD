

SELECT 'users' AS table_name, COUNT(*) AS total
FROM users

UNION ALL

SELECT 'sellers', COUNT(*)
FROM sellers

UNION ALL

SELECT 'categories', COUNT(*)
FROM categories

UNION ALL

SELECT 'products', COUNT(*)
FROM products

UNION ALL

SELECT 'orders', COUNT(*)
FROM orders

UNION ALL

SELECT 'order_items', COUNT(*)
FROM order_items

UNION ALL

SELECT 'stock', COUNT(*)
FROM stock

UNION ALL

SELECT 'payments', COUNT(*)
FROM payments

UNION ALL

SELECT 'carts', COUNT(*)
FROM carts

UNION ALL

SELECT 'cart_items', COUNT(*)
FROM cart_items

UNION ALL

SELECT 'addresses', COUNT(*)
FROM addresses

UNION ALL

SELECT 'deliveries', COUNT(*)
FROM deliveries

ORDER BY table_name;