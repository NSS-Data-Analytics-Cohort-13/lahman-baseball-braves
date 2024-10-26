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

6. Find the player who had the most success stealing bases in 2016, where __success__ is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted _at least_ 20 stolen bases.
	
SELECT playerid, namefirst, namelast, cs, sb, (cs+sb) as attempts, ROUND((sb::decimal/(cs::decimal+sb::decimal))*100, 2) as sb_success_percentage
FROM batting
LEFT JOIN people
USING(playerid)
WHERE yearid = 2016
and SB >= 20
ORDER BY sb_success_percentage DESC;


---USING FILDING TABLE----

-- SELECT playerid, namefirst, namelast, cs, sb, cs+sb as attempts
-- 	, ROUND((sb::float/(cs::float+sb::float))::numeric, 2)*100 as sb_success_percentage
-- FROM fielding
-- LEFT JOIN people
-- USING(playerid)
-- WHERE yearid = 2016
-- AND sb >= 20
-- ORDER BY sb_success_percentage DESC;


7.  From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? What is the smallest number of wins for a team that did win the world series? Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. Then redo your query, excluding the problem year. How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?

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


8. Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games). Only consider parks where there were at least 10 mgaes played. Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.

		
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



9. Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their full name and the teams that they were managing when they won the award.

select * from awardsmanagers
SELECT  * from managers

		