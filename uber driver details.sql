-- Questions
-- 1) 1. Extract the third transaction of every user, displaying user ID, spend, and transaction date.
select user_id, spend, transaction_date from
(
select * , row_number() over(partition by user_id order by user_id) as rn
from transactions) sub
where sub.rn = 3;


-- 2) Calculate the average ratings for each driver across different cities using data from rides and ratings tables.

select ra.driver_id , ra.city , round(avg(ra.rating),2) as average_rating from ratings ra
join rides ri 
on ra.driver_id = ri.driver_id
group by 1,2;
        
        
-- 3) 3. Identify customers registered with Gmail addresses from the 'users' database.
select * from users 
where email like '%gmail%';

-- 4) Analyze click-through conversion rates using data from ad_clicks and cab_bookings tables.

select ac.user_id, count(ac.click_id) as total_clicks,
	   count(cb.booking_id) as total_bookings,
       count(cb.booking_id)  * 1.00 / count(ac.click_id) as conversion_rate
 from ad_clicks ac 
 left join cab_bookings cb on cb.user_id = ac.user_id and cb.booking_date >= ac.ad_date
 group by 1;
-- tables 
-- 1) users
-- 2) transactions
-- 3) rides
-- 4) ratings
-- 5) ad_clicks
-- 6) cab_bookings   

-- 5)  find user_id who have completed a ride at least 3 times consecutively? 
select user_id as user_ids_with_3_days_consecutive_bookings from
(
select user_id, transaction_date ,  lead(user_id,1,0) over(partition by user_id) as next_day_id ,
									lag(user_id,1,0) over(partition by user_id) as prev_day_id

from transactions) sub
where user_id = next_day_id and user_id = prev_day_id;


-- 6)  Find riders whose monthly income is more than their previous month
with cte as (
select t.user_id , date_format(transaction_date, '%Y-%m-%d') as date, t.spend as spend, r.ride_id, r.driver_id as driver_id from transactions t
join rides r on 
t.user_id = r.user_id) 

select date, driver_id , month from (
select * , (case when  sub.next_month_earning > sub.earning then 1 else 0  end) as flag from(
select date, spend as earning, lead(spend,1,spend) over(partition by driver_id) as next_month_earning, driver_id , month(date) as month from cte) sub)sub2
where sub2.flag=1;


-- 7) Top 2 drivers with most income 

select * from transactions;
select * from rides;

with cte as (
select r.ride_id as ride_id , r.driver_id as driver_id, t.spend as earning from transactions t
join rides r
on t.user_id = r.user_id) 
select * from
(select distinct ride_id, driver_id, total_earning , dense_rank () over(order by total_earning desc, driver_id) as income_rank from (
select * , round(sum(earning) over(partition by driver_id order by driver_id),0) as total_earning from cte ) sub
order by income_rank asc) sub2
where sub2.income_rank in (1,2);











