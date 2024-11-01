1. What range of years for baseball games played does the provided database cover? 

Select min(year) as year_begening, max(year) as year_end 

from homegames;

--Alternatively--

-- Select min(yearid) as year_begening, max(yearid) as year_end 

-- 	from collegeplaying;

-- select * from collegeplaying


2. Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?

	
	
	select p.namefirst
	, p.namelast
	, min(p.height) as height
	, a.g_all as Number_of_game
	, a.teamid as Team, t.name
	
	 from people as p
	 
	inner join appearances as a
	 on p.playerid = a.playerid
	
	inner join teams as t
	using(teamid)
	 group by namefirst, namelast, teamid, t.name, a.g_all
	 order by height
     limit 1
	

3.	Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?

	

	-- select *
	-- from schools
	-- --where schoolname ilike '%Vanderbilt University%'
	-- order by schoolname desc

	
	
	Select distinct p.namefirst, p.namelast, sum(s.salary::int)::money as salary
	from people as p
	
	inner join salaries  s
	using(playerid)
	
	inner join collegeplaying c
	using(playerid)
	
	inner join schools  sc
	using(schoolid)
	
	where sc.schoolname ilike 'Vanderbilt University'
	group by  p.namefirst, p.namelast, c.yearid
	order by salary desc
	limit 1
	

4.  Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups in 2016.

	
Select sum(PO) as Total_putouts,
	(case when pos in('OF') then 'Outfield'
	 when pos  in('SS', '1B', '2B', '3B') then 'Infield'
	 when pos  in('P', 'C') then 'Battery'
	end) as position
	from fielding
	where yearid=2016 and pos is not null
	group by position
	

	
	5. Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?

SELECT (yearid/10)*10 AS decade,
		round(((SUM(so)::float / SUM(g))::numeric),2) AS avg_SO_score,
		round(((SUM(hr)::float / SUM(g))::numeric),2) AS avg_HR_score
	
	FROM teams
	WHERE yearid >=1920
	GROUP BY decade
	ORDER BY decade

-- 6. Find the player who had the most success stealing bases in 2016, where __success__ is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted _at least_ 20 stolen bases.
	
SELECT playerid
	, namefirst
	, namelast, sum(cs) as stolen_caught, sum(sb) as stolen_base
	, (sum(cs) +sum(sb)) as attempts
	, ROUND((sum(sb::decimal)/sum((cs::decimal+sb::decimal)))*100, 2) as sb_success_percentage

FROM batting
LEFT JOIN people
USING(playerid)
WHERE yearid = 2016
group by playerid, namefirst, namelast
having (sum(SB)+ sum(cs)) >= 20
ORDER BY sb_success_percentage DESC;




-- 7.  From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? What is the smallest number of wins for a team that did win the world series? Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. Then redo your query, excluding the problem year. How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?

--largest number of win that did not win the world series---
	
SELECT name as team_name, yearid as year, w as wins, wswin as world_series_win
FROM teams
WHERE wswin IS NOT null
AND yearid BETWEEN 1970 AND 2016
AND wswin = 'N'
ORDER BY wins desc

	--smallest number of win that did win the world series---
	
SELECT name as team_name, yearid as year, w as wins, wswin as world_series_win
FROM teams
WHERE wswin IS NOT null
AND yearid BETWEEN 1970 AND 2016
AND wswin = 'Y'
ORDER BY wins

	--Excluding problem year largest number of win that did not win the world series---
	
SELECT name as team_name, yearid as year, w as wins, wswin as world_series_win
FROM teams
WHERE wswin IS NOT null
AND yearid BETWEEN
AND yearid <> 1981
AND wswin = 'N'
ORDER BY wins desc

	--Excluding smallest number of win that did win the world series---
	
SELECT name as team_name, yearid as year, w as wins, wswin as world_series_win
FROM teams
WHERE wswin IS NOT null
AND yearid BETWEEN 1970 AND 2016
AND yearid <>1981
AND wswin = 'Y'
ORDER BY wins;




WITH T1 AS (SELECT yearid,
					MAX(w)
					FROM teams
					WHERE yearid BETWEEN 1970 and 2016
					AND wswin = 'Y'
					GROUP BY yearid
	
					INTERSECT
	
					SELECT yearid,
						MAX(w)
					FROM teams
					WHERE yearid BETWEEN 1970 and 2016
					GROUP BY yearid
					ORDER BY yearid)
	
SELECT (COUNT(ws.yearid)/COUNT(t.yearid)::float)*100 AS percentage
	
FROM teams as t 
LEFT JOIN T1 AS ws ON t.yearid = ws.yearid
WHERE t.wswin IS NOT NULL
AND t.yearid BETWEEN 1970 AND 2016;


-- with t1 AS (
-- 	SELECT yearid, max(w), wswin AS Twin
-- 	FROM teams
-- 	WHERE yearid BETWEEN 1970 AND 2016
-- 	group by yearid, Twin
-- 	order by yearid
-- ),
	
-- WITH T1 AS (
	
-- 	SELECT yearid, max(w) as maxwin
-- 	FROM teams
-- 	WHERE yearid BETWEEN 1970 AND 2016
-- 	group by yearid
-- 	order by yearid
-- ),
	
-- t2 as (
-- select t1.yearid, t.wswin
-- 	from teams as t
-- 	inner join t1
-- 	using(yearid)
-- 	 where t1.maxwin = t.w
-- 	 and t1.yearid=t.yearid
-- 	and wswin is not null
-- 	group by t1.yearid, t.wswin
-- ),	
	--select * from t2

	
-- 	Final as (

-- 		select ((select count(yearid) from t1) /(select count(yearid) from t2)) as percentage
-- 	)
-- select * from final


-- 8. Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games). Only consider parks where there were at least 10 mgaes played. Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.

		
		Select h.team,t.name, p.park_name, (h.attendance/h.games) as avg_atten  
		from homegames as h
		inner join parks as p
		using(park)
		left join teams as t
		on h.team=t.teamid and h.year=t.yearid
		where h.year=2016
		and games>=10
		order by avg_atten desc
		limit 5

Select h.team,t.name, p.park_name, (h.attendance/h.games) as avg_atten  
		from homegames as h
		inner join parks as p
		using(park)
		left join teams as t
		on h.team=t.teamid and h.year=t.yearid
		where h.year=2016
		and games>=10
		order by avg_atten 
		limit 5



-- 9. Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their full name and the teams that they were managing when they won the award.

-- SELECT * from awardsmanagers
-- SELECT  * from people
-- SELECT  * from teams

	
WITH T1 AS (
Select playerid, yearid, lgid, awardid
FROM awardsmanagers
WHERE awardid ILIKE '%TSN%'
AND lgid in (select lgid from awardsmanagers where lgid in ('AL') )
),
	--select * from T1

 T2 AS (
Select playerid, yearid, lgid, awardid
FROM awardsmanagers
WHERE awardid ILIKE '%TSN%'
AND lgid in (select lgid from awardsmanagers where lgid in ('NL') )
),
	
T3 as
	(	
	select t1.playerid, t1.yearid, t2.yearid as year
	from t1
	inner join t2
	on t1.playerid=t2.playerid 
	)
	select distinct p.namefirst, p.namelast, t.name as team_name--, t3.year
	from T3
	inner join people as P
	on T3.playerid = p.playerid 
	inner join managers as m
	on t3.playerid=m.playerid 
	inner join teams as t
	on m.teamid=t.teamid
	
---Alternatively ------

	WITH nl_award AS (
    SELECT playerid, yearid
    FROM AwardsManagers
    WHERE awardid ILIKE '%tsn manager%' AND lgid = 'NL'
),
al_award AS (
    SELECT playerid, yearid
    FROM AwardsManagers
    WHERE awardid ILIKE '%tsn manager%' AND lgid = 'AL'
),
both_awards AS (
    SELECT nl.playerid
    FROM nl_award nl
    JOIN al_award al ON nl.playerid = al.playerid
)
SELECT DISTINCT
    (p.namefirst || ' ' || p.namelast) AS manager_name,
    t.name AS team_name
FROM
    AwardsManagers am
JOIN
    both_awards ba ON am.playerid = ba.playerid
JOIN
    people p ON am.playerid = p.playerid
JOIN
    managers m ON am.playerid = m.playerid AND am.yearid = m.yearid
JOIN
    teams t ON m.teamid = t.teamid AND am.yearid = t.yearid
ORDER BY
    manager_name;


---alternative approach---

WITH manager_both AS (SELECT playerid, al.lgid AS al_lg, nl.lgid AS nl_lg,
					  al.yearid AS al_year, nl.yearid AS nl_year,
					  al.awardid AS al_award, nl.awardid AS nl_award
	FROM awardsmanagers AS al INNER JOIN awardsmanagers AS nl
	USING(playerid)
	WHERE al.awardid LIKE 'TSN%'
	AND nl.awardid LIKE 'TSN%'
	AND al.lgid LIKE 'AL'
	AND nl.lgid LIKE 'NL')
	
SELECT DISTINCT(people.playerid), namefirst, namelast, managers.teamid,
		managers.yearid AS year, managers.lgid
FROM manager_both AS mb LEFT JOIN people USING(playerid)
LEFT JOIN salaries USING(playerid)
LEFT JOIN managers USING(playerid)
WHERE managers.yearid = al_year OR managers.yearid = nl_year;

	-- 10. Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. Report the players' first and last names and the number of home runs they hit in 2016.


-- SELECT * FROM batting
-- SELECT * FROM people


	
with T1 as 
	(
	select playerid, count(distinct yearid) as num_yr
	from batting
	group by playerid
	having count(distinct yearid)>=10
	order by num_yr desc
	)

select p1.namefirst,p1.namelast,b1.hr as hr_high
	from batting as b1
	join people p1 
	on  b1.playerid = p1.playerid
	inner join t1 
	on b1.playerid = t1.playerid 
	where b1.yearid = 2016
--and extract(year from cast(p1.finalgame AS date)) - extract(year from cast(p1.debut AS date)) >= 10
and b1.hr >=1
and b1.hr = (
       		 select max(hr)
        	from batting
        	where playerid = b1.playerid
    		)
group by p1.namefirst, p1.namelast,b1.hr
order by hr_high desc


11. Is there any correlation between number of wins and team salary? Use data from 2000 and later to answer this question. As you do this analysis, keep in mind that salaries across the whole league tend to increase together, so you may want to look on a year-by-year basis.


