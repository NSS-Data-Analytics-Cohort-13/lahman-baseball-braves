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

