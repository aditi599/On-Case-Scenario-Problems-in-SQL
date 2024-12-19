
-- tables 1) Bookings
-- 		  2) Search_events
-- 		  3) Properties

select * from bookings;
select * from search_events;
select * from properties;

-- 1) Calculate the cancellation rate for each room type over the last 6 months, considering only bookings with a minimum stay of 2 nights.
select sub.room_type , round(sub.cancel * 100.00 / sub.total,2) as cancellation_rate from 
(select room_type , count(booking_status) as total ,count(case when booking_status = 'cancelled' then booking_status end ) as cancel from bookings 
where booking_timestamp >= curdate() - interval 6 month
group by 1) sub;


-- 2)  Determine the average conversion rate (confirmed bookings vs. search events) for users grouped by their country.
select sub2.country,  sub2.x / sub2.y as conversion_rate from 
(
select sub.country , count(case when booking_status='confirmed' then booking_status end) as x , count(booking_status) as y from (
select se.user_country  as country , se.device_type as device_type  , b.booking_status as booking_status, count(se.user_country) , count(se.device_type) from search_events se
join bookings b 
on se.search_id = b.booking_id and b.user_country = se.user_country
group by 1,2,3) sub
group by sub.country)sub2;

select * from bookings;
select * from search_events;
select * from properties;
-- 3)   Identify properties that underperformed compared to the regional average booking rate in the last 12 months 
with regional_performance as(
select region , round(avg(average_booking_rate),2) as avg_booking_rate
from properties 
group by 1
)
select * from properties p
left join regional_performance rp 
on p.region = rp.region
where p.average_booking_rate < rp.avg_booking_rate;


-- 4. Detect demand surges where bookings in an hour exceed the hourly average by more than 50%
with hourly_stats as (
    select 
	date_format(booking_timestamp, '%Y-%m-%d %H:00:00') AS booking_hour,
	count(*) AS hourly_bookings
    from bookings
    group by booking_hour
),
average_hourly as (
    select avg(hourly_bookings) AS avg_hourly_bookings from hourly_stats
)
select
	h.booking_hour,
    h.hourly_bookings,
    a.avg_hourly_bookings,
    (h.hourly_bookings - a.avg_hourly_bookings) / a.avg_hourly_bookings * 100 AS surge_percentage
from hourly_stats h
cross join average_hourly a
where h.hourly_bookings > a.avg_hourly_bookings * 1.5;


-- 5 Handle booking timestamps from different time zones for global daily booking patterns

select convert_tz(booking_timestamp , 'UTC',"+00:00") as utc_time_booking , 
		date(convert_tz(booking_timestamp,'UTC',"+00:00")) as booking_date_utc,
        count(*) as total_bookings
from bookings
group by 1,2;



select * from bookings;

-- 6. Rolling sum of all the stay duration where booking status is 'cancelled'
with cancelled_status as (
select * from bookings 
where booking_status = 'cancelled')

select stay_duration , 
		booking_timestamp,
	   sum(stay_duration) over(order by booking_timestamp rows between unbounded preceding and current row) as rolling_sum
from cancelled_status;

