
-- 1.Calculate the average rating given by students to each teacher for each session created. Also, provide the batch name for which session was conducted.

with cte1 as (
select s.id as session_id,  s.conducted_by , b.id , b.name from instructor_batch_maps i join sessions s on i.user_id = s.conducted_by
																					   join batches  b on s.batch_id = b.id)

select conducted_by, c.name, c.session_id, round(avg(rating),2) as avg_rating_for_session from attendances a join cte1 c on a.session_id = c.session_id 
group by 1,2,3;


-- 2.Find the attendance percentage  for each session for each batch. Also mention the batch name and users name who has conduct that session


-- with a as (
-- select s.id , 
-- s.batch_id, 
-- count( a.student_id ) as student_count_per_session 
-- from sessions s  join attendances a 
-- on a.session_id = s.id 
-- group by 1,2 order by 1) , 
-- b as (select batch_id , count(1) as students_per_batch from student_batch_maps
-- where active = True
-- group by 1) 

-- select a.batch_id ,
-- 			a.id as session_id ,
-- 			a.student_count_per_session ,
--             b.students_per_batch , 
--             (a.student_count_per_session / b.students_per_batch) * 100.00 as attendance 
-- from a join b
--  on a.batch_id = b.batch_id order by 1;

with students_in_batch as
		(select batch_id, count(1) as students_in_batch
		from student_batch_maps
		where active = true
		group by batch_id),
	multiple_batch_students as
		(select inactive.user_id, inactive.batch_id as inactive_batch, active.batch_id  as active_batch
		from student_batch_maps active
		join student_batch_maps inactive on active.user_id = inactive.user_id
		where active.active = true
		and inactive.active = false),
	students_present as
		(select session_id, count(1) as students_present
		from attendances a
		join sessions s on s.id = a.session_id
		where (a.student_id,s.batch_id) not in (select user_id, inactive_batch from multiple_batch_students)
		group by session_id)
select s.id as session_id, b.name as batch, u.name as teacher, SB.students_in_batch, SP.students_present
, round((SP.students_present/SB.students_in_batch) * 100,2) as attendance_percentage
from sessions s
join students_present SP on s.id = SP.session_id
join students_in_batch SB on s.batch_id = SB.batch_id
join batches b on b.id = s.batch_id
join user_table u on u.id = s.conducted_by;

-- 3) What is the average marks scored by each student in all the tests the student had appeared?

select  ts.user_id as student_id , round(avg(ts.score) ,2) as average_score from test_scores TS 
group by 1 order by 1 ;

--  4) A student is passed when she scores 40 percent of total marks in a test. Find out how many students passed in each test.

select * from (
select ts.user_id as student_id ,ts.test_id as test_id ,  round((ts.score  * 100.00 / t.total_mark ),2) as percentage_marks from test_scores ts join tests t on ts.test_id = t.id) sub 
where sub.percentage_marks > 40 
order by student_id;




