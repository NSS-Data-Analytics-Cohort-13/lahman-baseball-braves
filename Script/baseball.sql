1. What range of years for baseball games played does the provided database cover? 

Select min(year) as year_begening, max(year) as year_end 

	from homegames;


2. Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?

	

	
	select p.namefirst, p.namelast, min(p.height) as height, count(a.g_all) as Number_of_game, a.teamid as Team
	 from people as p
	 inner join appearances as a
	 on p.playerid = a.playerid
	 group by namefirst, namelast, teamid
	 order by height
     limit 1
	

3.	Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?


	

	
select * from homegames