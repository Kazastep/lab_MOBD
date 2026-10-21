DROP TABLE IF EXISTS deliveries;
DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS payments;

DROP TABLE IF EXISTS cart_items;
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS stock;

DROP TABLE IF EXISTS addresses;
DROP TABLE IF EXISTS carts;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;

DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS sellers;
DROP TABLE IF EXISTS users;


CREATE TABLE users (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE
);

create table sellers (
	id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	user_id BIGINT not null unique references users(id),
	name TEXT not null,
	email TEXT not null unique
);

create table categories (
	id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	name TEXT NOT NULL UNIQUE,
	parent_id BIGINT REFERENCES categories(id)
);

create table products (
	id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 
	title TEXT not null,
	price Numeric(12,2) not null check (price>0),
	seller_id BIGINT not null references sellers(id) on delete restrict ON UPDATE CASCADE,
	is_active BOOLEAN NOT NULL DEFAULT true,
	created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
	category_id BigINT not null references categories(id)
);

create table stock(
	 product_id BIGINT PRIMARY key NOT NULL REFERENCES products(id) ON DELETE cascade ON UPDATE CASCADE,
	 quantity INTEGER NOT NULL DEFAULT 0 CHECK (quantity >= 0)
);

CREATE TABLE orders (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON UPDATE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

create table order_items(
	order_id BIGINT NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
	product_id BIGINT NOT NULL REFERENCES products(id)  ON DELETE restrict ON UPDATE CASCADE,	
	quantity INTEGER NOT NULL CHECK (quantity > 0),
	unit_price NUMERIC(12,2) NOT NULL CHECK (unit_price > 0),
	PRIMARY KEY (order_id, product_id)
);

create table carts (
	id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	user_id BIGINT NOT NULL unique REFERENCES users(id) ON DELETE cascade ON UPDATE CASCADE
);

create table cart_items(
	cart_id BIGINT not null references carts(id) ON DELETE CASCADE,
	product_id BIGINT not null references products(id) ON DELETE cascade ON UPDATE CASCADE,
	quantity INTEGER NOT NULL DEFAULT 1 CHECK (quantity > 0),
	PRIMARY KEY (cart_id, product_id)
);

create table payments(
	id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'completed', 'failed')),
    amount NUMERIC(12,2) NOT null CHECK (amount > 0),
	order_id BIGINT NOT NULL unique REFERENCES orders(id) ON DELETE restrict ON UPDATE CASCADE,
	created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

create table addresses (
	id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    city TEXT NOT NULL,
    street TEXT NOT NULL,
    house TEXT NOT NULL,
	user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE cascade ON UPDATE CASCADE
);

create table deliveries (
	id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN (
            'pending',
            'shipped',
            'delivered',
            'cancelled'
        )),
	order_id BIGINT NOT NULL unique REFERENCES orders(id) ON DELETE restrict ON UPDATE CASCADE,
	address_id BIGINT NOT NULL REFERENCES addresses(id) ON DELETE restrict ON UPDATE CASCADE
);

SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_type = 'BASE TABLE'
ORDER BY table_name;







