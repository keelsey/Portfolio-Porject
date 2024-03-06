select * from customer;
select * from product;
select * from sales;

--Order by Commands

select * from customer
where state = 'California' 
order by customer_name ;

--SUM OF ALL SALES
select sum(sales) as "Sum of all sales"
from sales;

select * from sales;

--STATISTICS DASHBOARD

select product_id, 
sum(sales) as "Total Sales",
sum(quantity) as "Total Sales quantity",
count(order_id) as "Number of orders",
max(sales) as "Max Sales value",
min(sales) as "Min Sales value",
avg(sales) as "Average sales value"
from sales
group by product_id
order by "Total Sales" desc;

--JOINS
--SALES 2015
create table sales_2015 as select * from sales where ship_date between '2015-01-01' and '2015-12-31';
select count(*) from sales_2015;
select count(distinct customer_id) from sales_2015;
select * from sales_2015;

--CUSTOMER 20-60
create table customer_20_60 as select * from customer where age between 20 and 60;
select count(*) from customer_20_60;
select * from customer_20_60;


--INNER JOIN -Common values on both tables presented
select 
	a.order_line,
	a.product_id,
	a.customer_id,
	a.sales,
	b.customer_name,
	b.age
from sales_2015 as a
inner join customer_20_60 as b
on a.customer_id = b.customer_id
order by customer_id;

--LEFT JOIN -Common values from both tables with the complete left table in addition
select 
	a.order_line,
	a.product_id,
	a.customer_id,
	a.sales,
	b.customer_name,
	b.age
from sales_2015 as a
left join customer_20_60 as b
on a.customer_id = b.customer_id
order by customer_id;


--The total sales done in every state for customer_20_60 and sales_2015 table
select
sum(a.sales) as "Total Sales",
b.state
from sales_2015 as a
inner join customer_20_60 as b
on a.customer_id = b.customer_id
group by state;

--total sales and quantity
select
	a.product_id,
	a.product_name,
	a.category,
	sum(b.sales) as "Total Sales",
	sum(b.quantity) as "Total quantity"
from product as a
left join sales as b
on a.product_id = b.product_id
group by a.product_id;

--create view
select * from sales;

create view "Daily Billing" as
select order_line, product_id, sales, discount
from sales
where order_date = (select max(order_date) from sales);




