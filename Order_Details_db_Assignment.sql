-- CREATING TABLES

--CUSTOMER TABLE
create table customer(
customer_id serial primary key,
customer_name varchar(50) not null
);
select * from customer;

--PRODUCT TABLE
create table product(
product_id serial primary key,
product_name varchar(50) not null,
product_price int not null
);
select *from product;

--ORDER TABLE
create table orders(
order_id serial primary key,
customer_id int references customer(customer_id) on delete set null,
ordered_date date not null
);
select * from orders;

--ORDER DETAILS TABLE
create table order_details(
order_detail_id serial primary key,
order_id int references orders(order_id) on delete set null,
product_id int references product(product_id) on delete set null,
quantity int not null
);
select * from order_details;

--	INSERTING VALUES INTO TABLES

insert into customer(customer_name) values
('John'),('Smith'),('Ricky'), ('Walsh'), ('Stefen'),('Fleming'),('Thomson'),('David');
select * from customer;

insert into product(product_name,product_price) values
('Television',19000),
('DVD',3600),
('Washing Machine',7600),
('Computer',35900),
('Ipod',3210),
('Panasonic Phone',2100),
('Chair',360),
('Table',490),
('Sound System',12050),
('Home Theatre',19350);
select * from product;

insert into orders(customer_id,ordered_date) values
(4,'10-Jan-05');
select * from orders;
insert into orders(customer_id,ordered_date) values
(2,'10-Feb-06'),
(3,'20-Mar-05'),
(3,'10-Mar-06'),
(1,'5-Apr-07'),
(7,'13-Dec-06'),
(6,'13-Mar-08'),
(6,'29-Nov-04'),
(5,'13-Jan-05'),
(1,'12-Dec-2007');

insert into order_details(order_id,product_id,quantity) values
(1,3,1),
(1,2,3),
(2,10,2),
(3,7,10),
(3,4,2),
(3,5,4),
(4,3,1),
(5,1,2),
(5,2,1),
(6,5,1),
(7,6,1),
(8,10,2),
(8,3,1),
(9,10,3),
(10,1,1);
select * from order_details;

-- QUERIES

-- 1.fetch all the customer details along with the product names that the customer has ordered.
select c.customer_id, c.customer_name, p.product_name
from customer c
join orders o on c.customer_id=o.customer_id
join order_details od on o.order_id=od.order_id
join product p on p.product_id=od.product_id;
-- 2. fetch Order_Id, Ordered_Date, Total Price of the order (product price*qty). 
select o.order_id, o.ordered_date, sum(p.product_price * od.quantity) as total_price
from orders o
join order_details od on o.order_id=od.order_id
join product p on p.product_id=od.product_id
group by o.order_id, o.ordered_date;

-- 3.Fetch the Customer Name, who has not placed any order 
select c.customer_name
from customer c
join orders o on c.customer_id=o.customer_id
where o.customer_id is null;
-- 4. Fetch the Product Details without any order(purchase) 
select p.product_id, p.product_name,p.product_price
from product p
join order_details od on od.product_id=p.product_id
where od.product_id is null;
-- 5.Fetch the Customer name along with the total Purchase Amount 
select c.customer_name,sum(p.product_price * od.quantity) as total_purchase_amount
from customer c
join orders o on o.customer_id=c.customer_id
join order_details od on od.order_id=o.order_id
join product p on od.product_id=p.product_id
group by c.customer_name;
-- 6. Fetch the Customer details, who has placed the first and last order .
select c.*,o.ordered_date
from customer c
join orders o on c.customer_id=o.customer_id
where ordered_date=(select min(ordered_date) as first_order from orders)
or ordered_date=(select max(ordered_date) as last_order from orders);

-- 7. Fetch the customer details , who has placed more number of orders 
select c.customer_id,c.customer_name,count(o.order_id) as total_orders
from customer c
join orders o on o.customer_id=c.customer_id
group by c.customer_id
order by total_orders desc
limit 1;
-- 8.  Fetch the customer details, who has placed multiple orders in the same year
select c.customer_id,c.customer_name, extract(year from o.ordered_date) as year,count(o.order_id) as total_orders
from customer c
join orders o on c.customer_id=o.customer_id
group by c.customer_id,c.customer_name,year
having count(o.order_id) >1;

-- 9.Fetch the name of the month, in which more number of orders has been placed
select to_char(ordered_date,'Month')as month, count(order_id) as order_count
from orders
group by month
order by order_count desc
limit 1;

-- 10.Fetch the maximum priced Ordered Product
select p.product_id,p.product_name,p.product_price
from product p
where product_price=(select max(product_price) from product);
