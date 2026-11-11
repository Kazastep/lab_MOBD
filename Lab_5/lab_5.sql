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

-- Пункт 3
create OR REPLACE FUNCTION get_seller_revenue(
	p_seller_id BIGINT,
	p_data_start TIMESTAMP,
	p_data_end TIMESTAMP)
returns Numeric(12,2) as $$
declare
	v_total_reveneu Numeric(12,2);
begin
	select Sum(oi.quantity * oi.unit_price)	
	into v_total_reveneu
	from order_items oi
	join orders as o on o.id = oi.order_id
	join products as p on p.id = oi.product_id
	where p.seller_id = p_seller_id
		and o.created_at BETWEEN p_data_start AND p_data_end;
	if v_total_reveneu is null then
		v_total_reveneu := 0.00;
	end if;

	return v_total_reveneu;
end;
$$ LANGUAGE plpgsql;


SELECT get_seller_revenue(
    1, 
    '2026-01-01 00:00:00'::timestamp, 
    '2026-12-31 23:59:59'::timestamp
);


SELECT get_seller_revenue(
    999, 
    '2025-01-01 00:00:00'::timestamp, 
    '2025-01-31 23:59:59'::timestamp
);	

-- Пункт 4
CREATE TABLE product_price_audit (
    id SERIAL PRIMARY KEY,
    product_id BIGINT,
    old_price NUMERIC(12,2),
    new_price NUMERIC(12,2),
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION log_product_price_change()
RETURNS TRIGGER AS $$
BEGIN

    IF OLD.price IS DISTINCT FROM NEW.price THEN
        INSERT INTO product_price_audit (product_id, old_price, new_price)
        VALUES (OLD.id, OLD.price, NEW.price);
    END IF;
    
    RETURN NEW; 
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_product_price_audit
AFTER UPDATE OF price ON products
FOR EACH ROW
EXECUTE FUNCTION log_product_price_change();

update products p 
set price =1
where id = 1

select * from product_price_audit

-- Пункт 5
ALTER TABLE products
ADD rating NUMERIC(3,2);

CREATE TABLE reviews (
    id SERIAL PRIMARY KEY,
    product_id BIGINT NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    user_id BIGINT NOT null references user(id) on delete cascade,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

create or replace function product_rating()
returns trigger as $$
begin
UPDATE products
    SET rating = (
        SELECT AVG(rating)
        FROM reviews
        WHERE product_id = NEW.product_id
    )
    WHERE id = NEW.product_id;
	return new;
end;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_rating
AFTER INSERT ON reviews
FOR EACH ROW
EXECUTE FUNCTION product_rating();

SELECT * 
FROM products 
ORDER BY id ASC;

insert into reviews (product_id ,user_id ,rating)
values(3,1,4)

INSERT INTO reviews (product_id, user_id, rating)
VALUES (4, 1, 5);





