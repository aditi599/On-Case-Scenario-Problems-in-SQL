


 -- 1. Identify customers who have invested in at least two funds with opposite performance trends (one increasing and the other decreasing) over the last 6 months.
 with cte as  (
 select c.client_id , c.client_name , t.fund_id , t.amount , t.units, f.performance_change  from clients c
 join transactions t on c.client_id = t.client_id 
 left join fund_performance f on f.fund_id=t.fund_id
 where t.transaction_type ='buy'  )
 
select sub.fund_id , sub.client_name , sub.owned_fund , case when sub.performance_change < 0 then performance_change end as negative_performance_change ,
										case when sub.performance_change > 0 then performance_change end as positive_performance_change
from
 (select fp.fund_id, cte.client_name , cte.client_id , fp.performance_change , count(fp.fund_id) as owned_fund from fund_performance fp
 join cte on fp.fund_id = cte.fund_id
 where fp.performance_change > 0 or fp.performance_change < 0
 group by 1,2,3,4)sub
 where sub.owned_fund >=2 ;
 

 -- 2. Write a query to calculate the year-to-date portfolio returns for each client, ensuring that the query can handle daily transactions across multiple funds.
 
 with 
	  latest_price as (select fund_id , max(date) as latest_date from fund_performance group by 1) ,
 
	  current_holdings as (select 
							fh.client_id, fh.fund_id, fh.units_held, fh.amount_invested, fp.closing_price AS latest_price
						from fund_holdings fh
                        join latest_price lp on fh.fund_id = lp.fund_id
                        join fund_performance fp on lp.fund_id = lp.fund_id and lp.latest_date = fp.date),
	  profile_summary as (
							select c.client_id ,
                                    sum(c.amount_invested) as total_investment,
                                    sum(units_held * latest_price) as current_market_value
                                    from current_holdings c
                                    group by 1
							)
select 
    c.client_id,
    c.client_name,
    ps.total_investment,
    ps.current_market_value,
    round((ps.current_market_value - ps.total_investment) / ps.total_investment * 100, 2) as ytd_return_percentage
from 
    profile_summary ps
join 
    clients c on ps.client_id = c.client_id
order by 
    ytd_return_percentage desc; 
 

 -- 3. Find the top 5 performing funds within each region based on their weighted average returns, accounting for the size of investments in each fund.
 


with total_investment as(
select f.region , fh.fund_id, sum(fh.amount_invested) as total_amount_invested from fund_holdings fh
join funds f on f.fund_id = fh.fund_id
group by 1,2
order by 1 ) , 

weighted_average_return as (
	select ti.region , ti.fund_id , fp.performance_change , ti.total_amount_invested,
    (fp.performance_change * ti.total_amount_invested) as weighted_return
    from total_investment ti
    join fund_performance fp on fp.fund_id = ti.fund_id 
),

average_return_per_region as(
	select region , fund_id, sum(weighted_return)/sum(total_amount_invested) as avg_return_per_region
    from weighted_average_return
    group by 1,2
) , 
ranked_funds as (
		select region , fund_id , avg_return_per_region, 
        rank() over(partition by region order by avg_return_per_region desc ) as rank_region_wise
        from average_return_per_region
)

select 
rf.region , 
rf.fund_id,
f.fund_name,
rf.avg_return_per_region
from ranked_funds rf
join funds f on f.fund_id = rf.fund_id
where rf.rank_region_wise <= 5
order by rf.region , rf.rank_region_wise ;