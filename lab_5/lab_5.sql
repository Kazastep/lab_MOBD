-- пункт 1
begin;

insert into orders(user_id)
values (1)
RETURNING id;

SELECT id, user_id
FROM orders
ORDER BY id DESC
LIMIT 5;

INSERT INTO order_items (order_id, product_id, quantity, unit_price)
VALUES (1003, 1, 200, 200);

commit;

BEGIN;

INSERT INTO orders (user_id)
VALUES (1)
RETURNING id;

INSERT INTO order_items (order_id, product_id, quantity, unit_price)
VALUES (1006, -999, 2, 200);

ROLLBACK;

SELECT id, user_id
FROM orders
WHERE id = 1007;

-- пункт 2
CREATE OR REPLACE FUNCTION place_order(
    p_user BIGINT,
    p_product BIGINT,
    p_qty INTEGER
)
returns BIGINT as $$
declare
	v_order_id BIGINT;
	v_price NUMERIC(12,2);
	v_stock INTEGER;
begin
	Select price
	into v_price
	from products
	WHERE id = p_product;

	if v_price is null Then
		raise exception 'Товар не найден';
	end if;
	
	SELECT quantity
	INTO v_stock
	FROM stock
	WHERE product_id = p_product
	FOR UPDATE;

	if p_qty <= 0 Then
		raise exception 'Нет остатков';
	end if;

	if v_stock is Null or v_stock < p_qty Then
		raise exception 'Недостаточно товара';
	end if;

	INSERT INTO orders (user_id)
	VALUES (p_user)
	RETURNING id INTO v_order_id;

	Insert into order_items (order_id, product_id, quantity, unit_price)
	Values (v_order_id, p_product, p_qty, v_price);

	UPDATE stock
	SET quantity = quantity - p_qty
	WHERE product_id = p_product;

	return v_order_id;

end;
$$ LANGUAGE plpgsql;

SELECT place_order(1, 1, 2);

SELECT *
FROM orders
WHERE id = 1008;

SELECT *
FROM order_items
WHERE order_id = 1008;

SELECT place_order(1, 1, 999999);	



	

