select * from batting
select * from homegames
select * from teams

-- Q.1 What range of years for baseball games played does the provided database cover?
select 
		max(year) as max_year
	,	min(year) as min_year
from homegames

select  max(yearid) as max
	,	min(yearid) as min
from teams	

--year 1871 to 2016

--Q.2 Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?
select * from people
select * from appearances

select  p1.namegiven
	,	min(p1.height) as min_height
	,	p1.namefirst
	,	p1.namelast
--	,	p1.height
	,	a1.teamid
	,	a1.g_all
	,	t1.name
from people as p1
join appearances a1
using(playerid)
join teams as t1
using(teamid)
--where p1.height = (select min(height) from people)
group by p1.namegiven,a1.teamid,a1.g_all,	p1.namefirst
	,	p1.namelast,t1.name
order by min_height
limit 1

-- ans : Edward carl ,43 height ,team - SLA, games played - 1 

--Q.3 Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?

select * from schools
select schoolname from schools where schoolname ilike '%vander%'
select * from people
select * from collegeplaying
select * from salaries
where lgid = 'NL'--and lgid != 'AL'
order by playerid 

--using subquery not completed yet
select  namefirst
	,	namelast 
	,	(select sum(salary) 
		 from salaries 
		 where people.playerid = salaries.playerid
		) as total_sal
from people
where people.playerid in(select playerid from salaries)
order by total_sal desc

-- Query 
select  distinct p1.namefirst
	,	p1.namelast
	,	sum(sal.salary::integer)::money as  sum_sal
--	,	c1.yearid
from people p1
join salaries sal
using(playerid)
join collegeplaying c1
using(playerid)
join schools s1
on c1.schoolid = s1.schoolid
where s1.schoolname ilike '%vanderbilt university%'
group by p1.namefirst
	,	p1.namelast
	,	c1.yearid
order by sum_sal desc
limit 1

--Q.4 Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups in 2016.

select * from fielding  

select -- playerid	,	pos	,	yearid ,
		sum(po) as putouts
	,	(case when pos ilike 'OF' then 'outfield'
			  when pos In ('SS','1B','2B','3B') then 'infield'
			  when pos In ('P','C') then 'battery'
			  else null
		 end) as Positions
from fielding
where yearid = 2016
group by positions
--group by positions,playerid,pos,yearid

		
--Q.5 Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?

select * from batting
select * from pitching 
select * from teams -- so and soa
select * from battingpost
select * from pitchingpost

select  round(((sum(so)::float/sum(g))::numeric),2) as avg_strikeouts
	,	round((sum(hr)::float/sum(g))::numeric,2) as avg_homeruns
	,	(yearid/10)*10 as decade 
from teams
where yearid >=1920
group by decade
order by decade



-- Q.6 Find the player who had the most success stealing bases in 2016, where success is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted at least 20 stolen bases.

select * from batting
select * from teams
select * from people
select * from battingpost 

---stolen bases for year 2016
select  sb
	,	cs
	,	playerid
	,	yearid
from batting
where sb is not null and cs is not null  and yearid = 2016


select sb,cs,playerid from batting where yearid=2016 and (sb+cs) >=20
order by sb desc,cs desc


--success in stealing %
select  playerid
	,	sb
	,	cs
	,	round((sb*1.0/(sb+cs))*100,2) as per
from batting
where yearid =2016 and (sb+cs)>=20
order by per desc

--name of the player
select  namefirst
	,	namelast
from people
where playerid ilike 'owingch01'

-- final query
with players as (

		select  playerid
			,	sum(sb) stolen_base
			,	sum(cs) caught_stealing
			,	sum(sb)+sum(cs) attempted_steals
			,	round((sum(sb)*1.0/(sum(sb)+sum(cs)))*100,2) as sb_percentage
		from batting
		where yearid = 2016
		group by playerid 
--			  and (sb+cs) >= 20
		
)
select  p1.playerid
	,	p1.stolen_base
	,	p1.caught_stealing
	,	p1.sb_percentage
	,	p2.namefirst
	,	p2.namelast
from
	players p1
join
	people p2 on p1.playerid = p2.playerid 

group by p1.playerid,p2.namefirst,p2.namelast,p1.stolen_base,p1.caught_stealing,p1.sb_percentage,attempted_steals
having attempted_steals >=20
order by 
	p1.sb_percentage desc
limit 1

--- method -2
select  p.playerid
	,	p.namefirst
	,	p.namelast
	,	sum(sb) stolenbase
	,	sum(cs) caught_stealing
	,	sum(sb)+sum(cs) attempted
	,	round(sum(sb::numeric)*100/(sum(sb::numeric)+sum(cs::numeric)),2) as percentage
from  batting as b
join people p
on b.playerid = p.playerid
and yearid = 2016
group by 1,2,3
having sum(sb)+sum(cs) >=20
order by percentage desc


--Q.7 From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? What is the smallest number of wins for a team that did win the world series? Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. Then redo your query, excluding the problem year. How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?
select * from seriespost 
select * from teams 

--Q1. largest no of win no ws won
select name
	,	w 
	,   yearid
	,   'largest' as win
from teams 
where wswin ilike '%n%' and yearid between 1970 and 2016
order by w desc
limit 1
-- ans -2001 , 116 wins , seattle mariners

-- Q2.smallest no of win yes ws won
select name
	,	w 
	,	yearid
	,  'smalest' as win
from teams where wswin ilike '%y%' and yearid between 1970 and 2016
order by w
limit 1  
-- year 1981 ,63 w , los angeles dodgers

-- Q3
select name
	,	w 
	,	yearid
	,  'smalest' as win
from teams where wswin ilike '%y%' and yearid between 1970 and 2016
and yearid != 1981  -- exclude year 1981
order by w
limit 1
-- ans St.Louis Cardinals , 83, 2006

-- ----
-- select  yearid
-- 	,	max(w) as max_win--,name,w,wswin 
-- from teams 
-- where yearid between 1970 and 2016 and yearid != 1981 and wswin ilike '%y%'
-- group by yearid
-- order by max_win 
-- -- max_wins 83

-- --world series win (wswin) yes 1970 -2016
-- select  yearid --,wswin,name
-- from teams 
-- where yearid between 1970 and 2016 and wswin ilike '%y%'



----Q.3 query to find min and max wins and excluding min win year
--------  Then redo your query, excluding the problem year.
with team_wins as(
		select 
			max(case when wswin ilike '%n%' then w end) as max_win ,
			min(case when wswin ilike '%y%' then w end) as min_win 
			--name
		from teams
		where yearid between 1970 and 2016 
		             and yearid != 1981 --excluding problem year
					--and yearid not in (select )

)
select 
	  max_win
	, min_win

from team_wins


-----------Q.4 query most team wins and world series wins
--------------How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?
with mostwins as(
		select  
			yearid ,-- name ,
			max(w) as max_wins
		from teams
		where yearid between 1970 and 2016 
	    group by yearid --,name    --ans is 47 
),
ws_wins as (
		select yearid
		from teams
		where yearid between 1970 and 2016 
					 and wswin ilike '%y%'	 --- ans 46			

),
winners as(
		select yearid
			,  max(w)
		from teams
		where yearid between 1970 and 2016 and wswin ilike '%y%'
		group by yearid
		
		intersect
		
		select yearid
			,  max(w)
		from teams
		where yearid between 1970 and 2016 
		group by yearid
		order by yearid
)
select 
	  round(count(winners.yearid)/(select count(mostwins.yearid) from mostwins ):: decimal *100,2)
from winners 


--Q.8.Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games). Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.

select * from homegames
select * from  parks
select * from teams

select  team , park ,games
from homegames 
where year =2016 and games >=10    --- ans 30 

select count(games) from homegames where year =2016 and games >=10   -- ans 30



------ Q.1 team and park top 5 avg attendance 
select  distinct p1.park_name
	,	t1.name
	,	h.attendance/h.games as avg_attendance
from homegames h
join parks  p1 
using(park)
join teams t1
on h.year = t1.yearid  and h.team = t1.teamid
where year = 2016 and h.games >=10 --and games is not null
order by avg_attendance desc  --- ans total  30 rows
limit 5


----- Q.2 lowest 5
select  distinct p1.park_name
	,	t1.name
	,	h.attendance/h.games as avg_attendance
from homegames h
join parks  p1 
using(park)
join teams t1
on h.year = t1.yearid  and h.team = t1.teamid
where year = 2016 and h.games >=10 
order by avg_attendance   
limit 5


----Q.9.Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their full name and the teams that they were managing when they won the award.
select * from awardsmanagers
select * from teams
select playerid,namegiven,namefirst,namelast from people where playerid = 'larusto01'

--method 1
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


---------- 2nd method
WITH al_nl_manager AS
	(
		SELECT playerid
		FROM AwardsManagers
		WHERE lgid IN ('AL', 'NL') AND awardid ILIKE '%tsn%'
		GROUP BY playerid
		HAVING COUNT(DISTINCT lgid) = 2
	)
--Below query is fetching manager name and team names managed by managers generated from CTE
SELECT
		DISTINCT(p.namefirst || p.namelast) AS manager_name
		, t.name AS team_name
	FROM AwardsManagers AS am
		LEFT JOIN people AS p
			USING(playerid )
		LEFT JOIN managers AS m
			on am.playerid = m.playerid AND am.yearid = m.yearid
		LEFT JOIN teams AS t
			ON m.teamid = t.teamid AND am.yearid = t.yearid
	WHERE am.playerid IN (SELECT playerid FROM al_nl_manager);




-- 10. Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. Report the players' first and last names and the number of home runs they hit in 2016.

select * from people
select * from batting


select playerid, hr
from batting 
where yearid = 2016 and hr >=1



select 
    playerid,extract(year from cast(finalgame AS date)),extract(year from cast(debut AS date)),extract(year from cast(finalgame AS date)) - extract(year from cast(debut AS date)) as years_played
from 
    people
where 
    extract(year from cast(finalgame AS date)) - extract(year from cast(debut AS date)) >= 10 

order by years_played 

--Query
/*select p1.namefirst,p1.namelast,b1.hr as hr_high 
from batting as b1
join people p1 on  b1.playerid = p1.playerid
where b1.yearid = 2016 
and extract(year from cast(p1.finalgame AS date)) - extract(year from cast(p1.debut AS date)) >= 10 
and b1.hr >=1 
and b1.hr = (
        select max(hr) 
        from batting 
        where playerid = b1.playerid 
		
    )
group by p1.namefirst,p1.namelast,b1.hr
order by hr_high desc  */

---correct query
select p1.namefirst,p1.namelast,b1.hr as hr_high 
from batting as b1
join people p1 on  b1.playerid = p1.playerid
--where b1.yearid = 2016 
and (select count(distinct yearid) 
     from batting 
     where playerid = p1.playerid) >= 10 
and b1.hr >=1 
and b1.hr = (
        select max(hr) 
        from batting 
        where playerid = b1.playerid 
		and  b1.yearid = 2016 
    )
group by p1.namefirst,p1.namelast,b1.hr
order by hr_high desc




--11. Is there any correlation between number of wins and team salary? Use data from 2000 and later to answer this question. As you do this analysis, keep in mind that salaries across the whole league tend to increase together, so you may want to look on a year-by-year basis.

select * from  salaries
select * from  teams

select teamid,count(playerid) as teamcount ,yearid
from salaries
where yearid>2000
group by teamid,yearid

select w,yearid from teams
where yearid >2000

select sum(salary) as team_sal,yearid,teamid
from salaries
where yearid >2000
group by yearid,teamid    

select  s.yearid ,s.teamid,count(s.playerid) as players_inteam
	,	sum(s.salary) as team_sal 
	,	t.w
from  salaries as s
right join teams t on s.yearid=t.yearid and s.teamid=t.teamid
where s.yearid >2000
group by s.yearid,s.teamid,t.w
order by teamid 


/*--12.In this question, you will explore the connection between number of wins and attendance.
Does there appear to be any correlation between attendance at home games and number of wins?
Do teams that win the world series see a boost in attendance the following year? What about teams that made the playoffs? Making the playoffs means either being a division winner or a wild card winner.  */

select * from teams
select * from homegames

select attendance,teamid,yearid from teams where teamid ='DET' and yearid =1911

select attendance,team,year from homegames where team = 'DET' and year = 1911


select t.w,h.attendance
from teams as t
join homegames hVankam#374

on t.teamid = h.team
--group by  t.teamid,t.yearid,t.w,h.attendance 

