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

select (yearid/10)*10 as decade,
		round(((Sum(so)::float / sum(g))::numeric),2) as avg_SO_score,
		round(((Sum(hr)::float / sum(g))::numeric),2) as avg_HR_score
	
	from teams
	where yearid >=1920
	group by decade
	order by decade
	
	

	

		
