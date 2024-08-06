## creating database and importing the data by using load infile query:

create database jobdatacs1;
use jobdatacs1;
create table jobdata(ds	date ,job_id int , actor_id int	,event varchar(20),	language varchar(20) ,time_spent int,org varchar (15));
SHOW VARIABLES LIKE 'secure_file_priv';
LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/job_data (1).csv"
INTO TABLE jobdata
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

# described the data to check the data structure and data types:
desc jobdata;
select * from jobdata;

## Jobs reviewed over time:
SELECT ds AS Date, COUNT(job_id) AS Cnt_JID, ROUND((SUM(time_spent)/3600),4) AS totaljobsreviewedpersecond,
ROUND((COUNT(job_id)/(SUM(time_spent)/3600)),4) AS Job_Rev_PHr_PDy 
FROM jobdata 
WHERE ds BETWEEN '2020-11-01'AND '2020-11-30' 
GROUP BY ds 
ORDER BY ds;
 
 ## 7-day rolling average of throughput (number of events per second):
 WITH cte AS (
 SELECT ds, round(CAST(COUNT(job_id) AS FLOAT)/CAST(SUM(time_spent) AS FLOAT),2) AS c_by_s
 FROM jobdata
 WHERE ds BETWEEN '2020-11-01'AND '2020-11-30'
 GROUP BY 1 )
SELECT ds AS Date, c_by_s AS Job_Rev_PSec_PDy, AVG(c_by_s) OVER(ORDER BY ds ROWS BETWEEN 6 PRECEDING AND  CURRENT ROW) AS 7_Dy_Roll_Avg 
FROM cte;

## Language Share Analysis: percentage share of each language in the last 30 days:
WITH langCount as (
SELECT language, count(language) as c
FROM jobdata
WHERE ds BETWEEN "2020-10-30" and "2020-11-30"
GROUP BY language
),
totalJobs as(
	SELECT COUNT(*) as total
	FROM jobdata
    WHERE ds BETWEEN "2020-10-30" and "2020-11-30"
)
SELECT language, ROUND(c/total,2) * 100 percent
FROM langCount CROSS JOIN totalJobs;

##  duplicate rows in the data:
select actor_id ,count(*) as id_count from jobdata group by actor_id having id_count>1;

## Event analysis:
# 1. Most common types of events :
select event ,count(event) as eventcount from jobdata group by event ;

# 2. How do the frequencies of different event types vary by date?
select ds as date , event , count(event) as event_count from jobdata group by  ds,event order by event_count desc;

## Time allocation:
# 1. Average seconds spent on each event 
select event,round(avg(time_spent)) as avg_time_spent from jobdata group by event;

## Actor performance:
# 1. Actor most frequently doing events:
select ds as eventdate ,actor_id ,count(event) from jobdata group by eventdate,actor_id ;

## Language distribution:
# 1. Distribution of events by language:
select language,count(event) as number_of_events from jobdata group by language;

# 2. time spent variation across different languages:
select language,sum(time_spent) as hours from jobdata group by language;

## Comparitive analysis :
# 1. How do metrics compare across different organizations , languages , actors?
SELECT org, language, actor_id, event, COUNT(*) as event_count, AVG(time_spent) as avg_time_spent,SUM(time_spent) as total_time_spent
FROM jobdata
GROUP BY org, language, actor_id, event
ORDER BY org, language, actor_id, event_count DESC;














