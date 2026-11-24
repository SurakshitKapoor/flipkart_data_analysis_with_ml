-- =====================================================================
-- clean_load_all.sql  |  Create database, tables and load the CLEAN Flipkart data
-- Database : flipkart_clean   (separate from your bronze / silver databases)
-- Tables   : customers, products, orders, order_items, returns
--
-- BEFORE RUNNING
--   1) Put the 5 clean CSVs in one folder and change the path in the 5 LOAD DATA
--      statements below (currently C:/flipkart_clean_data/ - use / slashes).
--   2) Enable local infile:  SET GLOBAL local_infile = 1;   (needs admin rights)
--      and connect with it on:
--        CLI      : mysql --local-infile=1 -u root -p
--        Workbench: Connection > Advanced > Others: OPT_LOCAL_INFILE=1
--
-- RUN: execute this whole file once. Takes about 1-2 minutes.
-- Empty CSV cells are loaded as NULL (they are the logically-true NULLs).
-- Foreign keys are added AFTER loading, so the load is fast and every key is validated.
-- =====================================================================

CREATE DATABASE IF NOT EXISTS flipkart_clean CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE flipkart_clean;
SET GLOBAL local_infile = 1;
SET FOREIGN_KEY_CHECKS = 0;

-- ---------------------------------------------------------------------
-- 1. TABLES
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS returns;
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;

CREATE TABLE customers (
    customer_id              VARCHAR(20)  NOT NULL,
    customer_name            VARCHAR(100) NOT NULL,
    gender                   VARCHAR(10),
    age                      TINYINT UNSIGNED,
    email                    VARCHAR(150),
    city                     VARCHAR(60),
    state                    VARCHAR(60),
    pincode                  CHAR(6),
    tier                     VARCHAR(10),
    signup_date              DATE         NOT NULL,
    is_plus_member           TINYINT(1)   NOT NULL,
    referred_by_customer_id  VARCHAR(20)  NULL,           -- NULL = not referred
    PRIMARY KEY (customer_id)
);

CREATE TABLE products (
    product_id     VARCHAR(30)   NOT NULL,
    product_name   VARCHAR(300)  NOT NULL,
    category       VARCHAR(50)   NOT NULL,
    brand          VARCHAR(80),
    seller_id      VARCHAR(20),
    mrp            DECIMAL(12,2) NOT NULL,
    selling_price  DECIMAL(12,2) NOT NULL,
    rating         DECIMAL(2,1)  NULL,                    -- NULL = no ratings yet
    stock_qty      INT,
    PRIMARY KEY (product_id)
);

CREATE TABLE orders (
    order_id         VARCHAR(30)   NOT NULL,
    customer_id      VARCHAR(20)   NOT NULL,
    order_date       DATE          NOT NULL,
    order_status     VARCHAR(20),
    payment_mode     VARCHAR(30),
    total_amount     DECIMAL(14,2) NOT NULL,              -- amount paid, after discount
    discount_amount  DECIMAL(14,2) NOT NULL,
    sale_event       VARCHAR(30)   NULL,                  -- NULL = no sale event
    PRIMARY KEY (order_id)
);

CREATE TABLE order_items (
    order_item_id   VARCHAR(30)   NOT NULL,
    order_id        VARCHAR(30)   NOT NULL,
    product_id      VARCHAR(30)   NOT NULL,
    seller_id       VARCHAR(20),
    quantity        SMALLINT      NOT NULL,
    unit_price      DECIMAL(12,2) NOT NULL,
    item_status     VARCHAR(20),
    delivered_date  DATE          NULL,                   -- NULL = cancelled / not yet delivered
    review_rating   TINYINT       NULL,                   -- NULL = no review
    review_text     VARCHAR(500)  NULL,
    PRIMARY KEY (order_item_id)
);

CREATE TABLE returns (
    return_id       VARCHAR(30)   NOT NULL,
    order_item_id   VARCHAR(30)   NOT NULL,
    return_date     DATE          NOT NULL,
    return_reason   VARCHAR(40),
    refund_amount   DECIMAL(12,2) NULL,                   -- NULL = refund pending
    return_status   VARCHAR(20),
    PRIMARY KEY (return_id)
);

-- ---------------------------------------------------------------------
-- 2. LOAD DATA   (change the folder path in each statement if needed)
-- ---------------------------------------------------------------------
LOAD DATA LOCAL INFILE "C:\\Users\\DELL\\Surakshit's Imarticus\\Data\\flipkart_data\\clean_data_files\\customers.csv"
INTO TABLE customers
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(customer_id, customer_name, gender, age, email, city, state, pincode, tier, signup_date, is_plus_member, @referred_by)
SET referred_by_customer_id = NULLIF(TRIM(TRAILING '\r' FROM @referred_by), '');

LOAD DATA LOCAL INFILE "C:\\Users\\DELL\\Surakshit's Imarticus\\Data\\flipkart_data\\clean_data_files\\products.csv"
INTO TABLE products
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(product_id, product_name, category, brand, seller_id, mrp, selling_price, @rating, @stock_qty)
SET rating    = NULLIF(@rating, ''),
    stock_qty = NULLIF(TRIM(TRAILING '\r' FROM @stock_qty), '');

LOAD DATA LOCAL INFILE "C:\\Users\\DELL\\Surakshit's Imarticus\\Data\\flipkart_data\\clean_data_files\\orders.csv"
INTO TABLE orders
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(order_id, customer_id, order_date, order_status, payment_mode, total_amount, discount_amount, @sale_event)
SET sale_event = NULLIF(TRIM(TRAILING '\r' FROM @sale_event), '');

LOAD DATA LOCAL INFILE "C:\\Users\\DELL\\Surakshit's Imarticus\\Data\\flipkart_data\\clean_data_files\\order_items.csv"
INTO TABLE order_items
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(order_item_id, order_id, product_id, seller_id, quantity, unit_price, item_status, @delivered_date, @review_rating, @review_text)
SET delivered_date = NULLIF(@delivered_date, ''),
    review_rating  = NULLIF(@review_rating, ''),
    review_text    = NULLIF(TRIM(TRAILING '\r' FROM @review_text), '');


LOAD DATA LOCAL INFILE "C:\\Users\\DELL\\Surakshit's Imarticus\\Data\\flipkart_data\\clean_data_files\\returns
.csv"
INTO TABLE returns
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(return_id, order_item_id, return_date, return_reason, @refund_amount, @return_status)
SET refund_amount = NULLIF(@refund_amount, ''),
    return_status = TRIM(TRAILING '\r' FROM @return_status);

-- ---------------------------------------------------------------------
-- 3. FOREIGN KEYS + INDEXES (added after the load; this also validates every key)
-- ---------------------------------------------------------------------
SET FOREIGN_KEY_CHECKS = 1;

ALTER TABLE customers   ADD CONSTRAINT fk_cust_referrer   FOREIGN KEY (referred_by_customer_id) REFERENCES customers(customer_id);
ALTER TABLE orders      ADD CONSTRAINT fk_orders_customer FOREIGN KEY (customer_id)   REFERENCES customers(customer_id);
ALTER TABLE order_items ADD CONSTRAINT fk_items_order     FOREIGN KEY (order_id)      REFERENCES orders(order_id);



ALTER TABLE order_items ADD CONSTRAINT fk_items_product   FOREIGN KEY (product_id)    REFERENCES products(product_id);


ALTER TABLE returns     ADD CONSTRAINT fk_returns_item    FOREIGN KEY (order_item_id) REFERENCES order_items(order_item_id);



CREATE INDEX idx_orders_date    ON orders(order_date);

CREATE INDEX idx_orders_status  ON orders(order_status);
CREATE INDEX idx_customers_city ON customers(city);
CREATE INDEX idx_products_cat   ON products(category);
CREATE INDEX idx_returns_date   ON returns(return_date);

-- ---------------------------------------------------------------------
-- 4. VERIFY  (expected: 25000 / 5000 / 300000 / 585245 / 59827)
-- ---------------------------------------------------------------------
SELECT 'customers'   AS tbl, COUNT(*) AS row_count FROM customers
UNION ALL SELECT 'products',    COUNT(*) FROM products
UNION ALL SELECT 'orders',      COUNT(*) FROM orders
UNION ALL SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL SELECT 'returns',     COUNT(*) FROM returns;

-- logically-true NULLs (expected: 21957 / 253 / 238803 / 42197 / 426535 / 2038)
SELECT SUM(referred_by_customer_id IS NULL) AS not_referred FROM customers;
SELECT SUM(rating IS NULL)                  AS no_rating_yet FROM products;
SELECT SUM(sale_event IS NULL)              AS no_sale_event FROM orders;
SELECT SUM(delivered_date IS NULL) AS not_delivered, SUM(review_rating IS NULL) AS no_review FROM order_items;
SELECT SUM(refund_amount IS NULL)           AS refund_pending FROM returns;


select * from customers;

select distinct(monthname(signup_date)) from customers;
