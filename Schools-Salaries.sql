

-- visualize data

select *
from engineering , ivies, liberal_arts, state 


-- merge the four school type table into one table

-- create table 

drop table if exists school_type_combined

create table school_type_combined(
school_name varchar(255),
school_type varchar(50),
starting_median_salary money,
mid_career_median_salary money
)

--insert values

insert into school_type_combined
select *
from engineering 
union
select *
from ivies 
union
select *
from liberal_arts 
union
select *
from state 

--view data

select *
from school_type_combined
order by school_name 


--search for duplicates

select  school_name ,count(school_name)
from school_type_combined 
group by school_name 
having  count(school_name) > 1

-- remove duplicates

with RowNumCTE as(
select *
,row_number () over(
partition by school_name,
		school_type,
		starting_median_salary,
		mid_career_median_salary
		order by school_name ) row_num
from school_type_combined 
)
delete
from RowNumCTE
where row_num > 1


-- find the average starting and mid salary for every school type

select school_type, round(avg(starting_median_salary ::money::numeric::float8)) as Average_starting_salary
, round(avg(mid_career_median_salary ::money::numeric::float8)) as Average_mid_salary
from school_type_combined 
group by school_type 


-- top 3 Liberal Arts that produce the highest mid career earnings graduates

select school_name, mid_career_median_salary 
from school_type_combined  
where school_type = 'Liberal Arts'
order by mid_career_median_salary desc
limit 3


--top 10 schools with highest salaries

select school_name, max(starting_median_salary) as max_salarie,max(mid_career_median_salary) as max_sa
from school_type_combined 
where starting_median_salary is not null 
group by school_name 
order by max_salarie desc
limit 10

--create a temporary table with school_type_combined and regions

drop table if exists schools_and_regions

create temporary table schools_and_regions
(school_name varchar(255),
school_type varchar(50),
region varchar(50),
starting_median_salary money,
mid_career_median_salary money
)


insert into schools_and_regions
select s.school_name, s.school_type, r."Region", s.starting_median_salary, s.mid_career_median_salary 
from school_type_combined s
inner join regions r 
	on s.school_name = r.school_name 


select *
from schools_and_regions

--remove duplicates

with RowNumCTE2 as(
select school_name
,row_number() over( 
partition by school_type,
		region,
		starting_median_salary,
	    mid_career_median_salary
	    order by school_name) as row_num
from schools_and_regions)
delete
from schools_and_regions
where school_name in (select school_name from RowNumCTE2 where row_num > 1)

--find how many universities, colleges, institutes are in total

with total_category as
(select school_name,
case
	when school_name ilike '%universit%' then 'University'
	when school_name ilike '%colleg%' then 'College'
	when school_name ilike '%institu%' then 'Institute'
	else 'Others'
end as category
from schools_and_regions)
select category, count(category) as total
from total_category
group by category
order by total desc


--find how many universities, colleges, institutes are per region

with total_category as
(select school_name,
case
	when school_name ilike '%universit%' then 'University'
	when school_name ilike '%colleg%' then 'College'
	when school_name ilike '%institu%' then 'Institute'
	else 'Others'
end as category
from schools_and_regions)
select r."Region" ,tc.category , count(category) as total
from total_category as tc
inner join regions as r
	on tc.school_name = r.school_name 
group by r."Region", tc.category  
order by tc.category  desc


-- find how many missing values are in percentage-mid-career for 10th percentile

select distinct("Mid_Career_10th_Percentile_Salary"), count("Mid_Career_10th_Percentile_Salary") 
from percentage_mid_career_salaries 
where "Mid_Career_10th_Percentile_Salary" = 'N/A'
group by "Mid_Career_10th_Percentile_Salary" 


-- join schools with percentage mid career salaries and regions

select s.school_name ,s.school_type ,r."Region" ,s.starting_median_salary ,s.mid_career_median_salary
,p."Mid_Career_10th_Percentile_Salary" ,p."Mid_Career_25th_Percentile_Salary" ,p."Mid_Career_75th_Percentile_Salary" ,p."Mid_Career_90th_Percentile_Salary" 
from school_type_combined s
join regions r
on s.school_name = r.school_name 
join percentage_mid_career_salaries  p
on s.school_name =p.school_name 


-- count how many Liberal Arts are in every region

with complete_data as
(select s.school_name ,s.school_type ,r."Region" ,s.starting_median_salary ,s.mid_career_median_salary
,p."Mid_Career_10th_Percentile_Salary" ,p."Mid_Career_25th_Percentile_Salary" ,p."Mid_Career_75th_Percentile_Salary" ,p."Mid_Career_90th_Percentile_Salary" 
from school_type_combined s
join regions r
on s.school_name = r.school_name 
join percentage_mid_career_salaries  p
on s.school_name =p.school_name 
)
select  "Region", count(school_name) as total_schools
from complete_data
where school_type = 'Liberal Arts'
group by "Region"
order by total_schools desc


-- average, min, max salaries in every region

with region_salaries as
(select s.school_name ,s.school_type ,r."Region" ,s.starting_median_salary ,s.mid_career_median_salary
from school_type_combined s
join regions r
on s.school_name = r.school_name 
)
select  "Region", round(avg(starting_median_salary::money::numeric),2) as average_starting_salary
,round(avg(mid_career_median_salary::money::numeric),2) as average_mid_salary
,max(starting_median_salary) as max_starting_salary
,max(mid_career_median_salary) as max_mid_salary
,min(starting_median_salary) as min_starting_salary
,min(mid_career_median_salary) as min_mid_salary
from region_salaries
group by "Region"
order by average_mid_salary desc

with university as(
select school_name 
from school_type_combined
where school_name ilike '%universit%'
)
select count(school_name)
from university
