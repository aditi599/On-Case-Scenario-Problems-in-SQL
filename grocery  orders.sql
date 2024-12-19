show databases;
use classicmodels;

-- tables 
select * from customer_table;
select * from Product_table;
select * from Order_Table;
select * from Order_Items;
select * from Deliveries;



-- Starting with basics around dates

-- 1) How many customers registered in each year?

select year(RegistrationDate) as particular_year , count( distinct customerid) as total_registered_customers
from customer_table group by 1 order by 1;


-- 2) Find the number of customers who registered in the last 6 months of year 2022
select sum(customer_count) as total_customers  from
(select customerid, count( distinct customerid) as customer_count from 
(select * , year(registrationdate) as year from customer_table) sub
where sub.year = 2022 and registrationdate between '2022-01-01' and '2022-06-30'
group by 1) sub2;


-- 3) Identify the day of the week on which most customers registered.

select day_of_week  , total_count  from (
select  count(customerid) as total_count , dayofweek(registrationdate) as day_of_week 
 from customer_table
 group by 2) sub
 group by 1
 order by total_count desc
 limit 1;
 
 
 -- 4) How many orders were placed in each month of 2023?
select month(orderdate) as month , count(orderid) as total_order from Order_Table group by 1;


-- 5) Find the total revenue generated in each quarter of 2022.
with quarter as (
select * , case when month between '1' and '4' then 'first_quarter'
				when month between '5' and '8' then 'second_quarter'
                when month between '9' and '12' then 'third_quarter'
                end as quarters
from (
select * , month (orderdate) month from Order_Table) sub)

select quarters , sum(totalamount) as quarter_wise_amount from quarter group by 1;


-- 6) Calculate the average delivery time (in days) for all delivered orders.

with cte as (
select ot.orderid as orderid , ot.orderdate as orderdate , d.deliverydate  as deliverydate from Order_Table ot 
join Deliveries d on ot.orderid = d.orderid) 

select orderid , round(avg(datediff(deliverydate, orderdate))) as  diff_between_order_and_delivery   from cte group by 1;


-- 7) Find the percentage of deliveries that were completed within 3 days of the order date.

select  round(count(case when flag = 1 then flag end) * 100.00  / count(*),1) as percentage from
(select * , case when  diff_between_order_and_delivery = 3 then 1 else 0 end as flag from (
select orderid , datediff(deliverydate, orderdate) as  diff_between_order_and_delivery  from (
select ot.orderid as orderid , ot.orderdate as orderdate , d.deliverydate  as deliverydate from Order_Table ot 
join Deliveries d on ot.orderid = d.orderid) sub) sub2 
)sub3;

-- 8) Which product category generated the most revenue?

with tab as (
select pt.productid, pt.name, round(pt.price) as new_price , ot.quantity from product_table pt join order_items ot on pt.productid = ot.productid)
select name from (
select * , new_price*quantity as amount_generated from tab order by amount_generated desc limit 1) sub;














