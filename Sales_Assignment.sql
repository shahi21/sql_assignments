

create table product(
productID serial primary key,
productname varchar(50) not null,
category varchar(50) not null
);

select * from product;


create table customers(
customerID serial primary key,
customername varchar(50) not null,
city varchar(20) not null
);

select * from customers;

create table sales(
saleID serial primary key,
productid int references product(productid),
customerid int references customers(customerid),
saleamount decimal(10,2) not null,
saledate date not null,
region varchar(50) not null,
paymentmethod varchar(50) check (paymentmethod in ('Cash','credit card','online'))
);

select * from sales;


insert into product(productname,category) values
('Laptop','Electronics'),
('Mobile Phone','Electronics'),
('Washing Machine', 'Home Appliances'),
('Refrigerator','Home Appliances'),
('Headphones','Accessories');

select * from product;

insert into customers(customername,city) values
('Alice','New York'),
('Bob','Los Angeles'),
('Charlie','Chicago'),
('David','Houston'),
('Emma','San Francisco');

select * from customers;

insert into sales(productid,customerid,saleamount,saledate,region,paymentmethod) values
(1,1,1200.50,'2024-01-10','North','credit card'),
(2,2,800,'2024-01-15','South','Cash'),
(1,3,1100,'2024-02-08','North','online'),
(3,4,950.25,'2024-02-20','West','credit card'),
(4,5,1400,'2024-03-05','East','online'),
(2,1,600,'2024-03-15','South','Cash'),
(1,3,1250,'2024-03-18','North','credit card'),
(5,4,450,'2024-04-02','East','online'),
(3,5,1300.75,'2024-04-10','West','credit card'),
(1,2,900,'2024-04-20','North','online');

select * from sales;

--get total sales amount for each region and paymentmethod

select sum(saleamount) as totalsales, region, paymentmethod
from sales
group by region,paymentmethod
order by region,paymentmethod;

--find avg sale amount per product,but only for products sold at least twice

select productid, avg(saleamount) as avgsaleamount
from sales
group by productid
having count(productid)>=2;

--count the number of sales made in each month, grouped by region

select region, extract(month from saledate) as Month,count(*) as salescount
from sales
group by region,month
order by region,month;

--find the region with the highest sales in each month

select distinct on(Month)
extract(month from saledate) as Month,region, sum(saleamount)as totalsales
from sales
group by Month,region
order by Month, totalsales desc;



--find the top 3 best selling products across all months

select p.productname, sum(s.saleamount)as totalrevenue
from sales s
join product p on s.productid=p.productid
group by p.productname
order by totalrevenue desc
limit 3;


--find the top 3 customers who spent the most in total

select c.customername, sum(s.saleamount) as totalspent
from sales s
join customers c on s.customerid=c.customerid
group by c.customername
order by totalspent desc
limit 3;


--identify the top 2 selling products in each region
 WITH productsales AS(
Select p.productname,s.region,SUM(s.saleamount) as totalsales,
    RANK() OVER (PARTITION BY s.region 
					order by sum(s.saleamount) desc) as salesrank
from product p
join sales s on s.productid=p.productid
group by s.region,p.productname
 )
select productname, region,totalsales
from productsales
where salesrank<=2;


--find the percentage contribution of each payment method in total sales

select paymentmethod,sum(saleamount) as totalsales,
	round((sum(saleamount) * 100.0)/(select sum(saleamount) from sales),2) as percentagecontribution
from sales
group by paymentmethod
order by totalsales desc;


--identify customers who made repeat purchases
select c.customername, count(s.saleid) as purchasecount
from sales s
join customers c on s.customerid=c.customerid
group by c.customername
having count(s.saleid)>1;


--rank products based on total revenue(using RANK and DENSE RANK)
select p.productname, sum(s.saleamount) as totalrevenue,
rank() over(order by sum(s.saleamount) desc ) as rankorder,
dense_rank() over(order by sum(saleamount) desc) as dense_Rankorder
from sales s
join product p on s.productid=p.productid
group by p.productname;




--identify the most and least profitable product category in each month

WITH categorysales as(
select extract(month from s.saledate) as Month,
		p.category,
		sum(s.saleamount) as totalsales
from sales s
join product p on s.productid=p.productid
group by Month,p.category
),
rankedsales as(
select *,
		rank() over (partition by Month order by totalsales desc) as maxrank,
		rank() over (partition by Month order by totalsales asc)as minrank
from categorysales
)

select Month,category,totalsales
from rankedsales
where maxrank=1 or minrank=1;




--find the products that were never sold

select productname
from product
where productid not in(select distinct productid from sales);

--find the first and last purchase date for each customer
select c.customername,
		min(s.saledate) as firstpurchasedate,
		max(s.saledate)as lastpurchasedate
from sales s
join customers c on c.customerid=s.customerid
group by c.customername;


--identify the seasonal trend in sales(quarterly analysis)
select extract(quarter from saledate) as quarter,
		sum(saleamount) as totalsales
from sales
group by quarter
order by quarter;


--find the average spending per customer per month

select c.customername,
		extract(month from s.saledate) as month,
		avg(s.saleamount) as avgspending
from sales s 
join customers c on s.customerid=c.customerid
group by c.customername,month
order by c.customername,month;


--find the sales contribution of each city
select c.city,
		sum(s.saleamount) as totalsales,
	round((sum(saleamount)*100.00)/(select sum(saleamount) from sales),2) as contribution
from sales s
join customers c on s.customerid=c.customerid
group by c.city
order by totalsales desc;




--find the customers who only used a single payment method

select customerid,customername
from customers
where customerid in(
select customerid
from sales
group by customerid
having count(distinct paymentmethod)=1
);

--find the month-over-month growth in sales
with monthlysales as(
SELECT 
        EXTRACT(MONTH FROM SaleDate) AS Month, 
        SUM(SaleAmount) AS TotalSales
    FROM Sales
    GROUP BY Month
	)
select Month,TotalSales,
		LAG(TotalSales) OVER (ORDER BY Month)as previousmonthsales,
		round(((TotalSales-LAG(TotalSales) over (order by Month))*100)/NULLIF(LAG(TotalSales) OVER (order by Month),0),2) as growthpercentage
from monthlysales;


--find the customer who spent the most in each region
select distinct on(s.region) s.region,c.customername,
		sum(s.saleamount) as totalspending
from sales s
join customers c on c.customerid=s.customerid
group by s.region,c.customername
order by s.region, totalspending desc;


--identify the region where each product sells the best
select distinct on (p.productname) 
		s.region, p.productname,
		sum(s.saleamount)as totalsales
from sales s
join product p on s.productid=p.productid
group by s.region, p.productname
order by p.productname,totalsales desc;


--find the customers who made a purchase every month
select c.customerid,c.customername
from sales s
join customers c on s.customerid=c.customerid
group by c.customerid,c.customername
having count(distinct extract(month from s.saledate))=12;


--BASIC QUERIES--

--1. RETRIVE ALL SALES TRANSACTIONS MADE IN LAST 30 DAYS
select *
from sales
where saledate>=current_date - interval '30 days';

--2.Get a list of all unique customers who have made a purchase.
select distinct  c.customername
from customers c
join sales s on c.customerid=s.customerid;
--3.Find the total number of products sold.
select count(productid)
from sales;
--4.Show all transactions where the sale amount is greater than 5000.
select *
from sales
where saleamount>5000;
--5.Retrieve all products along with their corresponding category names.
select productname,category
from product;


--AGGREGATION AND GROUPING

--6.Find the total revenue generated from sales.
select sum(saleamount) as totalrevenue
from sales;
--7.Calculate the average sale amount per transaction.
select avg(saleamount) as averageSaleAmount from sales;
--8.Find the total number of sales per product.
select p.productname, count(saleid) as totalsales
from sales s
join product p on s.productid=p.productid
group by productname;
--9.Retrieve the total sales amount per region.
select region,sum(saleamount)
from sales
group by region;
--10.Find the highest sale amount recorded in each month.
select extract(month from saledate) as month,max(saledate)
from sales
group by month;


--JOINS AND RELATIONSHIPS
--11.Retrieve the names of customers along with the products they purchased.
select c.customername, p.productname
from sales s
join customers c on c.customerid=s.customerid
join product p on p.productid=s.productid;
--12.Find the total amount spent by each customer.
select c.customername, SUM(s.saleamount) as total_spent
from sales s
join customers c on c.customerid=s.customerid
group by c.customername;
--13.Get the list of products along with the number of times they were sold.
select p.productname, count(s.saleid)
from sales s
join product p on s.productid=p.productid
group by p.productname;
--14.Retrieve the most popular product category based on sales volume.
select p.category, count(saleid)
from sales s
join product p on s.productid=p.productid
group by p.category;
--15.Find the customer who has made the most purchases.
select c.customername, count(saleid)as purchasecount
from sales s 
join customers c on c.customerid=s.customerid
group by c.customername
order by purchasecount desc
limit 1;


--ADVANCED QUERIES

--16.Find the product that has generated the highest revenue.
select p.productname,sum(s.saleamount) as totalrevenue
from sales s
join product p on s.productid=p.productid
group by p.productname
order by totalrevenue desc
limit 1;
--17.Retrieve customers who have purchased products from multiple categories.
select c.customername
from sales s
join product p on s.productid=p.productid
join customers c on c.customerid=s.customerid
group by c.customername
having count(distinct p.category)>1;
--18.Identify customers who have only made a single purchase.
select c.customername
from sales s
join customers c on c.customerid=s.customerid
group by c.customername
having count(s.saleid)=1;
--19.Find the longest time gap between two purchases for each customer.
select customerid,max(saledate)-min(saledate) as gap
from sales
group by customerid;
--20.Identify the most frequently used payment method.
select paymentmethod, count(*) 
from sales
group by paymentmethod
order by count(*) desc
limit 1;


--RANKING AND WINDOW FUNCTIONS
--21.Rank products based on the number of sales transactions.
select p.productname, count(s.saleid) as total_Sales,
rank() over (order by count(s.saleid)desc) as sales_rank
from sales s
join product p on s.productid=p.productid
group by p.productname;
--22.Find the second-highest revenue-generating product.
select productname,totalrevenue
from(
select p.productname, sum(s.saleamount) as totalrevenue,
rank() over(order by sum(s.saleamount) desc ) as revenuerank
from sales s
join product p on s.productid=p.productid
group by p.productname
) ranked 
where revenuerank=2;
--23.Retrieve the top 3 customers with the highest spending.
select c.customername, sum(s.saleamount) as total_spent
from sales s
join customers c on s.customerid=c.customerid
group by c.customername
order by total_spent desc
limit 3;
--24.Identify the month with the highest sales.
select extract(month from saledate) as month, sum(saleamount) as total_sales
from sales
group by month
order by total_sales desc
limit 1;
--25.Find the top-selling product in each region.
select region, productname,total_sales from(
select s.region,p.productname, sum(s.saleamount) as total_sales,
rank() over(partition by s.region order by sum(s.saleamount)desc ) as rank
from sales s
join  product p on s.productid=p.productid
group by s.region, p.productname
)ranked
where rank=1;









--04/03/2025

--ADDING MORE TABLES AND QUERIES

--SUPPLIERS TABLE

create table Suppliers(
SupplierID SERIAL primary key,
SupplierName varchar(25) not null,
ContactName varchar(25) ,
Phone varchar(15),
Email varchar(25) unique,
Adress varchar(100),
City varchar(20),
Country varchar(20)
);

select * from suppliers;


--EMPLOYEES TABLE

create table Employees(
EmployeeID SERIAL primary key,
FirstName varchar(25) not null,
LastName varchar(25) not null,
Position varchar(100),
Email varchar(25) unique,
Phone varchar(20),
HireDate DATE,
StoreID INT
);
select * from employees;

--STORES TABLE
create table stores(
StoreID SERIAL PRIMARY KEY,
StoreName varchar(25) not null,
Location varchar(25),
ManagerID INT,
constraint fk_manager foreign key (ManagerID) references employees(employeeID) on delete set null
);

select * from stores;

--adding foreign key for stores table in employees table
alter table employees add constraint fk_store foreign key(storeID) references Stores(StoreID) on delete set null;

select * from employees;

--MODIFYING PRODUCT TABLE
alter table product add column supplierID int;
alter table product add constraint fk_supplier foreign key(supplierID) references Suppliers(SupplierID) on delete set null;
select * from product;

--MODIFYING SALES TABLE
alter table Sales add column StoreID int;
select * from sales;
alter table Sales add constraint fk_store foreign key(StoreID) references Stores(StoreID) on delete set null;

--INSERTING DATA INTO SUPPLIERS TABLE
insert into suppliers(SupplierName, ContactName, Phone,Email,Adress,City,Country) values
('ABC Suppliers','John Doe','+1726377','john@abc.com','123 Street,NY','New York','USA'),
('Global Traders','Henry David','+373828','henry@global.com','45 Avenue,London','London','UK'),
('EcoGoods','Emma Mary','+7656584','emma@ecogoods.com','Calle Mayor,Madrid','Madrid','Spain');

select * from suppliers;

--INSERTING DATA INTO STORES TABLE 
select * from stores;

insert into stores(StoreName,Location,ManagerID) values
('DownTown Store','123 Main St,New York, USA',NULL),
('Central Plaza','45 Oxford St,London,UK',NULL),
('Madrid Outlet','Plaza Mayor,Madrid,Spain',NULL);

--INSERTING DATA INTO EMPLOYEES TABLE
select * from employees;

insert into employees(FirstName, LastName, Position,Email,Phone,HireDate,StoreID) values
('Alice','Brown','Store Manager','alice@company.com','+2373828','2023-05-15',1),
('Michael', 'Johnson', 'Sales Associate', 'michael@company.com', '+1-555-7890', '2022-08-10', 1),
('Sophie', 'Miller', 'Store Manager', 'sophie@company.com', '+44-20-8765432', '2023-02-20', 2);

--UPDATING STORES TABLE
SELECT * FROM STORES;
UPDATE STORES SET MANAGERID=(SELECT EMPLOYEEID FROM EMPLOYEES WHERE EMAIL='alice@company.com') where storeid=1;
UPDATE STORES SET MANAGERID=(SELECT EMPLOYEEID FROM EMPLOYEES WHERE EMAIL='sophie@company.com') where storeid=2;

--INSERTING DATA INTO PRODUCT TABLE
SELECT * FROM PRODUCT;
INSERT INTO Product (ProductName, Category, SupplierID) VALUES
('Organic Shampoo', 'Personal Care', 1),
('Handmade Soap', 'Personal Care', 2),
('Reusable Water Bottle', 'Accessories', 3);

--INSERTING DATA INTO SALES TABLE
SELECT * FROM SALES;
INSERT INTO Sales (ProductID, StoreID, SaleAmount, SaleDate, Region, PaymentMethod) VALUES
(1, 1, 800, '2024-02-25', 'North', 'Cash'),
(2, 2, 1100, '2024-02-26', 'South', 'online'),
(3, 3, 950.25, '2024-02-27', 'West', 'credit card');


--QUERIES

--find the total sales per store
select sales.storeid,stores.storename,sum(saleamount) as totalsales
from sales 
join stores on sales.storeid=stores.storeid
group by sales.storeid, stores.storename
order by totalsales desc;

--list all employees with their respective store names
select * from employees;
select * from stores;

select e.employeeid, e.firstname, e.lastname,e.position, st.storename
from employees e
join stores st on e.storeid=st.storeid
group by st.storename, e.employeeid;

--find the best performing store in terms of total revenue
select * from sales;
select  st.storename, sum(s.saleamount) as totalsales
from sales s 
join stores st on s.storeid=st.storeid
group by st.storename
order by totalsales desc
limit 1;

--identify the most popular product in each store
with productsales as(
select s.storeid,p.productname, count(s.saleid) as salecount
from sales s
join product p on s.productid=p.productid
group by s.storeid,p.productname
)
select st.storename,ps.productname, ps.salecount
from productsales ps
join stores st on ps.storeid=st.storeid
where ps.salecount=(select max(salecount) from productsales ps1 where ps.storeid=ps1.storeid);

--find the supplier with highest number of products supplied
select * from suppliers;
select * from stores;
select * from sales;
select * from product; --has supplierid

select sup.suppliername, count(p.productid) as totalproducts
from suppliers sup
join product p on sup.supplierid=p.supplierid
group by sup.suppliername
order by totalproducts desc
limit 1;

--list employees who are store managers along with their stores
select * from employees;
select e.employeeid, e.firstname,e.lastname, e.position, e.storeid, st.storename
from employees e
join stores st on e.storeid=st.storeid
where e.position LIKE '%Manager%';

--get the number of sales per store along with store managers name
select st.storename, count(s.saleid) as totalsales, concat(e.firstname,' ',e.lastname) as manager
from sales s
join stores st on s.storeid=st.storeid
join employees e on st.managerid=e.employeeid
group by  st.storename, e.firstname,e.lastname
order by totalsales desc;

--find employees who were hired in last 6 months
select employeeid,firstname,lastname,hiredate
from employees
where hiredate >= current_date - interval '6 months';


--identify the most commonly used payment method per store
select st.storename, s.paymentmethod, count(paymentmethod)as countpaymentmethod
from stores st
join sales s on st.storeid=s.storeid
group by st.storename, s.paymentmethod
order by st.storename,countpaymentmethod;

--find stores that do not have manager assigned

select storename,location
from stores
where managerid is null;

--get total sales per store with revenue
select st.storename, count(s.saleid) as totalsales, sum(s.saleamount) as totalrevenue
from sales s 
join stores st on s.storeid=st.storeid
group by st.storename
order by totalrevenue desc;

--find stores without sales

select st.storename
from stores st
join sales s on s.storeid=st.storeid
where s.storeid is null;

--find employees without store assignment
select * from employees;
select employeeid
from employees
where storeid is null;

--find stores where a specific product is selling
select * from stores;
select * from product;
select distinct st.storename
from sales s
join stores st on s.storeid=st.storeid
join product p on s.productid= p.productid
where p.productname='Organic Shampoo' ;


SELECT * FROM Product WHERE ProductName = 'Organic Shampoo';

SELECT * FROM Sales WHERE ProductID IN (SELECT ProductID FROM Product WHERE ProductName = 'Organic Shampoo');

INSERT INTO Sales (ProductID, StoreID, SaleAmount, SaleDate, Region, PaymentMethod)
VALUES ((SELECT ProductID FROM Product WHERE ProductName = 'Organic Shampoo'), 1, 500, '2024-02-28', 'North', 'Cash');


select distinct st.storename
from sales s
join stores st on s.storeid=st.storeid
join product p on s.productid= p.productid
where p.productname='Organic Shampoo' ;


--find the employee with largest tenure in the company
select employeeid, firstname,lastname,position,hiredate
from employees
order by hiredate asc
limit 1;

--get the number of employees working at each store

select st.storename, count(e.employeeid) as employeecount
from stores st
join employees e on st.storeid=e.storeid
group by st.storename;

--find all suppliers located in the USA
select * from suppliers;
select suppliername,country
from suppliers
where country='USA';

--get the number of unique products sold
select count(distinct productid) as countofuniqueproducts
from sales;

--get the number of sales per payment methods
select paymentmethod, count(saleid)
from sales
group by paymentmethod;

--find the month with the highest sales revenue
select extract(month from saledate) as month, sum(saleamount) as revenue
from sales
group by month
order by revenue desc
limit 1;

--find the product with highest revenue across all stores
select p.productname, sum(s.saleamount) as revenue
from sales s
join product p on s.productid=p.productid
group by p.productname
order by revenue desc
limit 1;



--get the number of suppliers from each country

select country, count(supplierid) as supplierscount
from suppliers
group by country;

--list all the products along with their suppliers name
select p.productname, sup.suppliername
from product p
join suppliers sup on p.supplierid=sup.supplierid
group by  productname,suppliername;


--find average sale amount per store
select st.storename, avg(s.saleamount) as averagesaleamount
from stores st
join sales s on s.storeid=st.storeid
group by storename
order by averagesaleamount desc;

--rank stores by total revenue
select storename, totalrevenue,
rank() over(order by totalrevenue) as revenuerank
from(
select st.storename, sum(s.saleamount) as totalrevenue
from stores st
join sales s on st.storeid=s.storeid
group by storename
) as storesales;

--retrieve all products supplied by 'Global Traders'
select p.productname, sup.suppliername
from product p
join suppliers sup on p.supplierid=sup.supplierid
where suppliername='Global Traders';

--find employees who do not have a phone number registered
select * from employees;

select employeeid
from employees
where phone is null;

--find the most expensive product sold
select p.productname, max(s.saleamount) as expensive
from product p
join sales s on p.productid=s.productid
group by productname
order by expensive desc
limit 1;

--rank employees based on their hirinf date
select employeeid, firstname,lastname,hiredate,
rank() over(order by hiredate) as ranking
from employees;


--find average number of sales per store
select st.storename, (select count(*) from sales s where st.storeid=storeid)/(select count(*) from stores st) as avgsales
from stores st;

--find stores where more than 50% payment were made in cash
select storeid, count(*) as totalsales,
sum(case when paymentmethod='Cash' then 1 else 0 end)*100.0/count(*) as cashpercentage
from sales
group by storeid
having sum(case when paymentmethod='Cash' then 1 else 0 end)*100.0/count(*)>50;


--find average sale per product category
select p.category, avg(s.saleamount) as avgsale
from product p
join sales s on p.productid=s.productid
group by p.category;

--find number of products sold per region
select region, count(saleid) as totalproductssold
from sales
group by region
order by totalproductssold desc;

--find most popular payment method
SELECT PaymentMethod, COUNT(*) AS usedcount
FROM Sales
GROUP BY PaymentMethod
ORDER BY usedcount DESC
LIMIT 1;

--most popular payment method in each store
select s.storeid, st.storename, s.paymentmethod, count(s.paymentmethod) as paymentcount
from sales s 
join stores st on st.storeid=s.storeid
 group by s.storeid,st.storename,s.paymentmethod
order by storeid, paymentcount desc;

select * from customers;
--find customers who only shop at one store
select c.customerid, c.customername, count(distinct s.storeid)as storecount
from sales s
join customers c on s.customerid=c.customerid
group by c.customerid,c.customername
having count(distinct s.storeid)=1;

--find total revenue per month
select extract(month from saledate) as month, sum(saleamount) as revenue
from sales
group by month
order by month;



