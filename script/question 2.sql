select * 
from allstarfull;
select * 
from homegames
select * 
from appearances
select * 
from allstarfull

-- 1. What range of years for baseball games played does the provided database cover? 
 SELECT
	   Max(year) AS max_year
	   ,Min(year) AS min_year
FROM homegames
lIMIT 1;

-- Answer 2016 and 1871

2. Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?
SELECT people.namegiven
      ,MIN(people.height) AS short_player
	 , appear.teamid
	 ,appear.g_all
FROM  people
	  INNER JOIN appearances AS appear
	  USING(playerid)
GROUP BY people.namefirst,appear.teamid,appear.g_all,people.namegiven
ORDER BY short_player
LIMIT 1

-- Answer Edward carl 43 sla 1

-- 3. Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?



