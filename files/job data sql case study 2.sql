## weekly email engagement rate:
select extract(week from occurred_at_date) as weeks, 
count(distinct user_id) as no_of_users from events
where event_type= "engagement"
group by weeks order by weeks;

## Most common events among active users:
select event_name,count(event_name) as event_count from events e join user_data u using(user_id) 
group by event_name order by event_count desc;

## Linguistic and location wise distribution of users:
select language,location ,count(*) as user_count from user_data
join events using(user_id) 
group by language,location order by user_count desc;

## User activity by device type:
select device,count(user_id) as user_count from events group by device order by user_count desc;

## Monthly user growth percentage:
SELECT Months, Users, ROUND(((Users/LAG(Users, 1) OVER (ORDER BY Months) - 1) * 100), 2) AS "Growth in %"
FROM
(SELECT month(activated_at_date) AS Months, COUNT(activated_at_date) AS Users
FROM user_data  GROUP BY 1 ORDER BY 1) sub;


## Weekly Retention Analysis:
SELECT event_name, count(*) FROM events group by event_name;
SELECT WEEK(occurred_at_date) Weeks, count(*) Retention_of_users
FROM events 
where event_type = 'signup_flow' and event_name = 'complete_signup'
GROUP BY 1
ORDER BY 1;

## weekly email engagement rate by actions: 
select action from email_events;
SELECT Week,
ROUND((weekly_digest/total*100), 2) AS "Weekly Digest Rate",
ROUND((email_opens/total*100), 2) AS "Email Open Rate",
ROUND((email_clickthroughs/total*100), 2) AS "Email Clickthrough Rate",
ROUND((reengagement_emails/total*100), 2) AS "Reengagement Email Rate"
FROM 
(SELECT week(occurred_at_date) AS Week,
COUNT(CASE WHEN action = 'sent_weekly_digest' THEN user_id ELSE NULL END) AS weekly_digest,
COUNT(CASE WHEN action = 'email_open' THEN user_id ELSE NULL END) AS email_opens,
COUNT(CASE WHEN action = 'email_clickthrough' THEN user_id ELSE NULL END) AS email_clickthroughs,
COUNT(CASE WHEN action = 'sent_reengagement_email' THEN user_id ELSE NULL END) AS reengagement_emails,
COUNT(user_id) AS total FROM email_events GROUP BY 1) sub GROUP BY  1 ORDER BY 1;
