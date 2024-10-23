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
--	,	min(p1.height) as min_height
	,	p1.height
	,	a1.teamid
	,	a1.g_all
from people as p1
join appearances a1
using(playerid)
where p1.height = (select min(height) from people)
group by p1.namegiven,a1.teamid,a1.g_all
order by min_height
limit 1

-- ans : Edward carl ,43 height ,team - SLA, games played - 1 

--Q.3 Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?

select 