select * 
from allstarfull;
select * 
from homegames
select * 
from appearances
select * 
from allstarfull
select * 
from schools
where schoolname = 'Vanderbilt University'

select * 
from salaries
select * 
from fielding
select * 
from teams

-- 1. What range of years for baseball games played does the provided database cover? 
 SELECT
	   Max(year) AS max_year
	   ,Min(year) AS min_year
FROM homegames
lIMIT 1;

-- Answer 2016 and 1871

2. Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?

SELECT people.namegiven,namefirst 
      ,MIN(people.height) AS short_player
	  FROM people
	  GROUP BY people.namegiven,namefirst
	  ORDER BY short_player 
	  LIMIT 1





SELECT people.namegiven,teams.name
      ,MIN(people.height) AS short_player
	 , appear.teamid
	 ,appear.g_all
FROM  people
	  INNER JOIN appearances AS appear
	  USING(playerid)
	  INNER JOIN teams
	  USING (teamid)
	  
GROUP BY people.namefirst,appear.teamid,appear.g_all,people.namegiven,teams.name
ORDER BY short_player
LIMIT 1

SELECT 
     MIN(people.height/12) AS min_height
  ,  people.namegiven
  ,  appearances.g_all AS total_games
  ,  teams.teamid
  FROM people
  INNER JOIN appearances
  USING (playerid)
INNER JOIN teams
USING (teamid)
GROUP BY namegiven,teams.teamid,total_games
ORDER BY min_height
LIMIT 1

-- Answer Edward carl 43 sla 1

-- 3. Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?



SELECT DISTINCT people.namefirst
      
	 , people.namelast 
	 , SUM(salaries.salary) AS total_salary
FROM people
INNER JOIN salaries
USING(playerid)
INNER JOIN collegeplaying
USING(playerid)
INNER JOIN schools
USING (schoolid)
WHERE schools.schoolname = 'Vanderbilt University'
GROUP BY people.namefirst,people.namelast

ORDER BY total_salary DESC
LIMIT 1

 Answers David price 81851296


 -- 4. Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups in 2016.


 SELECT SUM(PO) AS total_putouts,
	  (CASE WHEN pos ILIKE 'OF' THEN 'outfield '
	  WHEN pos IN ('SS','1B','2B','3B') THEN 'infield'
	  WHEN pos  IN  ('P','C') THEN 'Battery'
	  END) AS Position
	  FROM fielding 
	 
	  WHERE yearid = 2016 AND pos IS NOT NULL
	  GROUP BY Position
	  
	  ANSWER run the query 

-- 5. Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?	  

SELECT yearid/10*10 AS decade,
ROUND(((SUM(SO)::float / SUM(g))::numeric),2) AS average_so,
ROUND(((SUM(hr)::float / SUM(g))::numeric),2) AS average_hr
FROM teams
WHERE yearid >= 1920
GROUP BY decade

ORDER BY decade 
	  
