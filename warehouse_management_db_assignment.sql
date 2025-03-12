
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

-- creating tables
create table product(
product_id serial primary key,
product_name varchar(50) not null,
category varchar(50) not null,
price int not null
);
select * from product;

create table warehouse(
warehouse_id serial primary key,
warehouse_name varchar(50) not null,
location varchar(50) not null
);
select * from warehouse;

create table inventory(
inventory_id serial primary key,
product_id int references product(product_id) on delete set null,
warehouse_id int references warehouse(warehouse_id) on delete set null,
quantity int not null
);
select * from inventory;

create table orders(
order_id serial primary key,
product_id int references product(product_id) on delete set null,
warehouse_id int references warehouse(warehouse_id) on delete set null,
order_date date not null,
quantity int not null
);
select * from orders;

-- INSERTING VALUES INTO TABLE
insert into product(product_name,category,price) values
('Laptop','Electronics',800),
('Smartphone','Electronics',600),
('Tablet','Electronics',300),
('TV','Appliances',1000),
('Refrigerator','Appliances',1200),
('Washing Machine','Appliances',900),
('Headphones','Electronics',150),
('Air Conditioner','Appliances',1100),
('Smartwatch','Electronics',200),
('Microwave','Appliances',500);
select * from product;

insert into warehouse(warehouse_name,location) values
('Warehouse A','New York'),
('Warehouse B','Los Angeles'),
('Warehouse C','Chicago'),
('Warehouse D','Houston'),
('Warehouse E','San Francisco'),
('Warehouse F','Miami'),
('Warehouse G','Seattle'),
('Warehouse H','Denver'),
('Warehouse I','Boston'),
('Warehouse J','Atlanta');
select * from warehouse;


insert into inventory(product_id,warehouse_id,quantity) values
(1,1,50),
(2,1,30),
(3,2,40),
(4,2,20),
(5,3,25),
(6,3,15),
(7,4,60),
(8,5,35),
(9,6,45),
(10,7,10);
select * from inventory;


insert into orders(product_id,warehouse_id,order_date,quantity) values
(1,1,'2024-12-21',5),
(2,1,'2024-12-22',3),
(3,2,'2025-01-03',4),
(4,2,'2025-01-07',2),
(5,3,'2025-02-11',6),
(6,3,'2025-02-21',1),
(7,4,'2025-03-01',7),
(8,5,'2025-03-04',5),
(9,6,'2025-03-07',9),
(10,7,'2025-03-09',2);

select * from orders;



-- QUERIES

--1. add filters for each table (check what filters should be added)
-- filer for product table
select * from product;
-- 1.
select * from product
where category='Electronics';
-- 2.
select * from product 
where category='Appliances' and price <1000;

-- 3. 
select category from product
where product_name='Washing Machine';

-- 4.
select price
from product
where category='Electronics' and product_name='Smartphone' ;

-- 5.
select product_name,category
from product
where product_id=7;

-- filter for warehouse table
select * from warehouse;
-- 1.
select * from warehouse
where location='Miami';

-- 2.
select warehouse_name
from warehouse
where location='Boston';

-- 3.
select *
from warehouse
where warehouse_name='Warehouse D' or warehouse_name='Warehouse F';

-- 4.
select warehouse_name,location
from warehouse
where warehouse_id=8;

-- filter for inventory table
select * from inventory;
-- 1.
select * from inventory
where quantity>10;

-- 2. 
select product_id,quantity
from inventory
where inventory_id=9;

-- 3.
select p.product_name,i.quantity,p.category
from product p
join inventory i on p.product_id=i.product_id
where i.quantity > 30;

-- 4.
select w.warehouse_name,w.location
from warehouse w
join inventory i on w.warehouse_id=i.inventory_id
where i.inventory_id=4;

-- filter for orders table
select * from orders;
-- 1.
select * from orders
where quantity > 3;
-- 2.
select w.warehouse_name,p.product_name,o.order_date
from orders o
join warehouse w on w.warehouse_id=o.warehouse_id
join product p on p.product_id=o.product_id;
-- 3.
select * from orders
where order_date between '2024-12-21' and '2025-2-18';


--2. total quantity of a product in a warehouse
select * from warehouse;
select * from inventory;
select sum(quantity) from inventory
where warehouse_id=2 and product_id=3;

--3. total quantity of a product in all the warehouses 
select product_id, sum(quantity) as total_quantity
from inventory
where product_id=5
group by product_id;

--4. sort on product quantity in warehouse/inventory
-- highest quantity first
select p.product_name, w.warehouse_name,i.quantity
from inventory i
join product p on p.product_id=i.product_id
join warehouse w on w.warehouse_id=i.warehouse_id
order by i.quantity desc;

-- lowest first
select p.product_name, w.warehouse_name,i.quantity
from inventory i
join product p on p.product_id=i.product_id
join warehouse w on w.warehouse_id=i.warehouse_id
order by i.quantity;


--5. sort highest/lowest ordered product this month
select * from orders;
select * from product;
-- highest ordered
select p.product_name,o.order_date,sum(o.quantity) as total_orders
from orders o
join product p on o.product_id=p.product_id
where extract(month from order_date)= extract(month from current_date)
group by p.product_name,o.order_date
order by total_orders desc
limit 1;
-- lowest ordered
select p.product_name,o.order_date, sum(o.quantity) as total_orders
from orders o
join product p on o.product_id=p.product_id
where extract(month from order_date)= extract(month from current_date)
group by p.product_name, o.order_date
order by total_orders asc
limit 1;

--6. sort on order traffic based on warehouses
select * from warehouse;
select * from orders;
-- lowest 
select w.warehouse_name,count(o.order_id) as total_orders
from warehouse w
join orders o on w.warehouse_id=o.warehouse_id
group by w.warehouse_name
order by total_orders;
-- highest 
select w.warehouse_name, count(o.order_id) as total_orders
from warehouse w
join orders o on w.warehouse_id=o.warehouse_id
group by w.warehouse_name
order by total_orders desc;