show databases;
use app;

drop table if exists sales;

create table sales (
	saleid int ,
	saledate date,
    revenue decimal 
);


INSERT INTO sales (saleid, saledate, revenue) VALUES (1, '2022-04-02', 278.03);
INSERT INTO sales (saleid, saledate, revenue) VALUES (2, '2022-02-09', 683.52);
INSERT INTO sales (saleid, saledate, revenue) VALUES (3, '2023-09-01', 646.66);
INSERT INTO sales (saleid, saledate, revenue) VALUES (4, '2022-04-30', 420.75);
INSERT INTO sales (saleid, saledate, revenue) VALUES (5, '2022-10-07', 247.59);
INSERT INTO sales (saleid, saledate, revenue) VALUES (6, '2023-07-15', 681.51);
INSERT INTO sales (saleid, saledate, revenue) VALUES (7, '2023-04-02', 572.67);
INSERT INTO sales (saleid, saledate, revenue) VALUES (8, '2022-10-13', 330.44);
INSERT INTO sales (saleid, saledate, revenue) VALUES (9, '2022-08-16', 181.50);
INSERT INTO sales (saleid, saledate, revenue) VALUES (10, '2022-05-25', 577.30);
INSERT INTO sales (saleid, saledate, revenue) VALUES (11, '2022-11-30', 475.53);
INSERT INTO sales (saleid, saledate, revenue) VALUES (12, '2022-04-09', 138.54);
INSERT INTO sales (saleid, saledate, revenue) VALUES (13, '2022-12-13', 128.16);
INSERT INTO sales (saleid, saledate, revenue) VALUES (14, '2023-01-03', 398.65);
INSERT INTO sales (saleid, saledate, revenue) VALUES (15, '2023-11-20', 507.56);


-- month over month revenue growth 
-- compare each month revenue to the previous month and express the growth percentage
with mon as (
select  month(saledate) as month , sum(revenue) as total_revenue from sales group by 1 order by 1),
mon2 as (select * , lag(total_revenue,1,total_revenue) over(order by month) as prev_mon from mon), 
mon3 as (select * , (prev_mon-total_revenue) as revenue_compare from mon2)

select * , round((revenue_compare*100.00 / prev_mon),2) as growth_percentage from mon3;




drop table if exists emp;
create table emp (empid int , empname varchar(30), deptid int , perfscore int);
drop table if exists dept;
create table dept (deptid int , deptname varchar(30));



INSERT INTO dept (deptid, deptname) VALUES
(1, 'Human Resources'),
(2, 'Finance'),
(3, 'Engineering'),
(4, 'Sales'),
(5, 'Marketing');


INSERT INTO emp (empid, empname, deptid, perfscore) VALUES
(1, 'Alice', 1, 85),
(2, 'Bob', 2, 90),
(3, 'Charlie', 3, 70),
(4, 'David', 4, 88),
(5, 'Eve', 5, 95),
(6, 'Frank', 1, 78),
(7, 'Grace', 2, 84),
(8, 'Hank', 3, 73),
(9, 'Ivy', 4, 80),
(10, 'Jack', 5, 92),
(11, 'Karen', 1, 67),
(12, 'Leo', 2, 79),
(13, 'Mona', 3, 81),
(14, 'Nina', 4, 89),
(15, 'Oscar', 5, 77);

-- ranking emp performance in each department using dense rank 
with cte as (
select e.empname as name , e.deptid , e.perfscore as score , d.deptname as department_name from emp e left 
join dept d on e.deptid = d.deptid) 

select * , dense_rank() over(partition by department_name order by score desc) as rnk from cte order by 2;



drop table if exists transactions;

create table transactions( transaction_id int , customerid int , transactiondate date , amount decimal);

INSERT INTO transactions (transaction_id, customerid, transactiondate, amount) VALUES
(1, 101, '2024-01-01', 150.75),
(2, 102, '2024-01-02', 200.50),
(3, 103, '2024-01-03', 300.00),
(4, 101, '2024-01-04', 120.00),
(5, 101, '2024-01-05', 450.25),
(6, 102, '2024-01-06', 75.00),
(7, 102, '2024-01-07', 90.00),
(8, 102, '2024-01-08', 240.75),
(9, 103, '2024-01-09', 320.50),
(10, 104, '2024-01-10', 180.00),
(11, 103, '2024-01-11', 510.00),
(12, 103, '2024-01-12', 60.00),
(13, 104, '2024-01-13', 100.00),
(14, 105, '2024-01-14', 275.50),
(15, 105, '2024-01-15', 310.75),
(16, 107, '2024-01-16', 190.00),
(17, 106, '2024-01-17', 400.00),
(18, 106, '2024-01-18', 85.00);

-- cummulative spending for each customer over time. Include cummulative sums of their spendings upto each transaction , order by date.
with cte1 as (
select customerid , transactiondate , amount , sum(amount) over(partition by customerid order by transactiondate) as cum_sum  from transactions order by 1,2) 

select * from cte1;


drop table if exists sales;

create table sales (
		saleid int, 
        saledate date, 
        saleamount decimal
        );
        
INSERT INTO sales (saleid, saledate, saleamount) VALUES
(1, '2024-01-01', 150.75),
(2, '2024-02-02', 200.50),
(3, '2024-03-03', 300.00),
(4, '2024-01-04', 120.00),
(5, '2024-02-05', 450.25),
(6, '2024-03-06', 75.00),
(7, '2024-03-07', 90.00),
(8, '2024-03-08', 100.00),
(9, '2024-04-09', 240.75),
(10, '2024-04-10', 320.50),
(11, '2024-02-11', 180.00),
(12, '2024-05-12', 150.00),
(13, '2024-06-13', 170.00),
(14, '2024-05-14', 190.00),
(15, '2024-05-15', 200.00);
        
-- calculating 3 month moving average ordered by date
with cte2 as (
select saledate , month , saleamount from (
select * , month(saledate) as month from sales) sub
where month between 1 and 3
order by month) 

select * , round(avg(saleamount) over(partition by month order by saledate),2) as average from cte2 ;

drop table if exists emp_structure;
create table emp_structure (
		employeeId int , 
        empname varchar(30),
        managerid int
        );
        
INSERT INTO emp_structure (employeeId, empname, managerid) VALUES
(1, 'Alice', NULL),      -- Top-level manager (no manager)
(2, 'Bob', 1),           -- Reports to Alice
(3, 'Charlie', 1),       -- Reports to Alice
(4, 'David', 2),         -- Reports to Bob
(5, 'Eve', 2),           -- Reports to Bob
(6, 'Frank', 3),         -- Reports to Charlie
(7, 'Grace', 3),         -- Reports to Charlie
(8, 'Hank', 4),          -- Reports to David
(9, 'Ivy', 4),           -- Reports to David
(10, 'Jack', 5);         -- Reports to Eve


-- retriving the hierarchical list of employees from table.
--  the result should show the emp hierarchy from top to bottom,
--  including each employee's level in the hierarchy
with recursive emp_hei as
 (
select employeeid , empname , managerid , 1 as level from emp_structure where managerid is null
union all 
select e.employeeid , e.empname , e.managerid , eh.level+1 as level from emp_structure e join emp_hei on e.managerid = eh.employeeid) 

SELECT 
    employeeId, empname, managerid, level
FROM 
    emp_hei
ORDER BY 
    level, managerid, employeeId;
    



