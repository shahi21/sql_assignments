
-- -- assignment:
-- Sql assignment:
-- Create 4 tables - Product, Inventory, Warehouse, Orders
 
-- where quantity will be present in Inventory and Warehouse
 
-- product is foreign key for all other tables
 
-- 1. add filters for each table (check what filters should be added)
-- 2. total quantity of a product in a warehouse
-- 3. total quantity of a product in all the warehouses
-- 4. sort on product quantity in warehouse/inventory
-- 5. sort highest/lowest ordered product this month
-- 6. sort on order traffic based on warehouses


-- table creation

create table product(
product_id serial primary key,
product_name varchar(100) not null,
price decimal(10,2) not null
);

create table inventory(
inventory_id serial primary key,
product_id int references product(product_id) on delete cascade,
quantity int not null check(quantity >=0),

);



create table warehouse(
warehouse_id serial primary key,
product_id int references product(product_id) on delete cascade,
quantity int not null check(quantity>=0),
location varchar(25) not null check(location <> '')
);

create table orders(
order_id serial primary key,
product_id int references product(product_id) on delete cascade,
order_date timestamp default current_timestamp,
quantity int not null check(quantity>0)
);

-- insertions
INSERT INTO Product (product_name, price) VALUES 
('Laptop', 75000.00),
('Smartphone', 30000.00),
('Tablet', 20000.00),
('Smartwatch', 10000.00),
('Headphones', 5000.00);

INSERT INTO Inventory (product_id, quantity) VALUES 
(1, 50), -- Laptop
(2, 100), -- Smartphone
(3, 75), -- Tablet
(4, 120), -- Smartwatch
(5, 200); -- Headphones

INSERT INTO Warehouse (product_id, quantity, location) VALUES 
(1, 30, 'New York Warehouse'),
(1, 20, 'Los Angeles Warehouse'),
(2, 50, 'Chicago Warehouse'),
(2, 50, 'Houston Warehouse'),
(3, 75, 'San Francisco Warehouse'),
(4, 60, 'Boston Warehouse'),
(4, 60, 'Seattle Warehouse'),
(5, 100, 'Miami Warehouse'),
(5, 100, 'Dallas Warehouse');

INSERT INTO Orders (product_id, order_date, quantity) VALUES 
(1, '2025-03-01 10:30:00', 5),
(2, '2025-03-02 14:45:00', 10),
(3, '2025-03-03 09:15:00', 7),
(4, '2025-03-05 12:00:00', 15),
(5, '2025-03-06 16:30:00', 20),
(1, '2025-03-07 11:00:00', 8),
(2, '2025-03-08 15:20:00', 12),
(3, '2025-03-10 13:10:00', 10),
(4, '2025-03-12 17:00:00', 5),
(5, '2025-03-14 19:45:00', 18);





-- queries
-- 2. total quantity of a product in a warehouse
select product_id,sum(quantity) as total_product
from warehouse
where warehouse_id=1
group by product_id;


-- 3.total quantity of a product in all the warehouses
select product_id,sum(quantity) as total
from warehouse
where product_id=5
group by product_id;

-- 4.sort on product quantity in warehouse/inventory
-- in warehouse
-- highest first
select product_id,warehouse_id,quantity
from warehouse
order by quantity desc;
-- lowest first
select product_id,warehouse_id,quantity
from warehouse
order by quantity asc;

-- in inventory
-- highest first
select product_id,quantity
from inventory
order by quantity desc;
-- lowest first
select product_id,quantity
from inventory
order by quantity asc;

-- 5. sort highest/lowest ordered product this month
-- highest
select product_id,sum(quantity) as total_orders
from orders
where extract(month from order_date)=extract(month from current_date)
and extract(year from order_Date)=extract(year from current_date)
group by product_id
order by total_orders desc
limit 1;

-- lowest
select product_id,sum(quantity) as total_orders
from orders
where extract(month from order_date)=extract(month from current_date)
and extract(year from order_Date)=extract(year from current_date)
group by product_id
order by total_orders asc
limit 1;

-- 6. sort on order traffic based on warehouses
select w.warehouse_id,sum(o.quantity) as total_orders
from orders o
join warehouse w on o.product_id=w.product_id
group by w.warehouse_id
order by total_orders desc;