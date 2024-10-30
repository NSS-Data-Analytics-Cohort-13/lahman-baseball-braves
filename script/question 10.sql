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
SELECT *
FROM people
SELECT *
FROM batting

select * 
from salaries
select * 
from fielding
select * 
from teams
select * 
from parks
SELECT *
FROM AwardsManagers
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
	 , SUM(salaries.salary)::INT ::MONEY AS total_salary
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


	  -- 6. Find the player who had the most success stealing bases in 2016, where __success__ is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted _at least_ 20 stolen bases.


	  SELECT 
    people.playerid,
    people.namefirst,
    batting.SB,
    batting.CS,
   ROUND((SB * 1.0 / (SB + CS)) * 100 , 2 )AS success_rate
FROM  people
INNER JOIN batting
USING (playerid)
  
WHERE 
    (SB + CS) >= 20 AND yearid = 2016
ORDER BY 
    success_rate DESC
-- LIMIT 1;

-- ANSWER : josmil sb20 and cs 0 
OTher way of doing it 

select sb,cs, b.playerid, round(cast(sb as numeric)/(sb+cs) * 100,2) || '%' as success_rate,
		p.namefirst, p.namelast
from batting AS b
	INNER JOIN people AS p
	USING (playerid)--ON b.playerid = p.playerid
where yearid = '2016' and sb <> 0 and cs <> 0
		and (sb + cs) >= 20
order by success_rate desc

7.  From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? What is the smallest number of wins for a team that did win the world series? Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. Then redo your query, excluding the problem year. How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?

SELECT name,
       yearid,
       MAX(W) AS max_wins_non_champion
FROM teams
WHERE WSWin = 'N' AND yearid BETWEEN 1970 AND 2016

GROUP BY name,yearid 
ORDER BY max_wins_non_champion DESC;

SELECT MAX(W) AS max_wins_non_champion
FROM teams
WHERE WSWin = 'Y' AND yearid BETWEEN 1970 AND 2016;

SELECT MIN(w) AS min_wins_champion_excluding_1981
FROM teams
WHERE WSWin = 'Y' AND yearid BETWEEN 1970 AND 2016 AND yearid != 1981;

SELECT COUNT(*) AS times_most_wins_won_championship
FROM (
    SELECT yearid
    FROM teams AS t1
    WHERE WSWin = 'Y'
    AND W = (
        SELECT MAX(w)
        FROM teams AS t2
        WHERE t2.yearid = t1.yearid
    )
    AND yearid BETWEEN 1970 AND 2016
) AS champion_most_wins;

SELECT ROUND((COUNT(*) * 100.0 / 47),2) AS percentage_most_wins_championship
FROM (
    SELECT yearid
    FROM teams AS t1
    WHERE WSWin = 'Y'
    AND W = (
        SELECT MAX(W)
        FROM teams AS t2
        WHERE t2.yearid = t1.yearid
    )
    AND yearid BETWEEN 1970 AND 2016
) AS champion_most_wins;
  -- ANSWWER run the query for the final answers


  -- 8. Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games). Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.

  SELECT parks.park_name, homegames.team,
  (homegames.attendance / games) AS avg_attendance
FROM parks 
LEFT JOIN homegames 
USING(park)
WHERE year = 2016 AND games >= 10
ORDER BY avg_attendance DESC
LIMIT 5;


  SELECT parks.park_name, homegames.team,
  (homegames.attendance / games) AS avg_attendance
FROM parks 
LEFT JOIN homegames 
USING(park)
WHERE year = 2016 AND games >= 10
ORDER BY avg_attendance ASC
LIMIT 5;
-- OTHER WAY or STYLE 
-- SELECT park AS park_name
--      , team AS team_name
-- 	 , attendance/games AS avg_attendance
-- 	 FROM homegames
-- 	 WHERE year = 2016 AND games >= 10
-- 	 ORDER BY avg_attendance
-- 	 LIMIT 5;

-- 9. Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their full name and the teams that they were managing when they won the award.

 WITH t1 AS(
 SELECT playerid,yearid,lgid,awardid
 FROM awardsmanagers
 WHERE awardid ILIKE '%TSN%'
 AND lgid IN (SELECT lgid FROM awardsmanagers WHERE lgid IN ('AL'))
 ),

 t2 AS(
 SELECT playerid,yearid,lgid,awardid
 FROM awardsmanagers
 WHERE awardid ILIKE '%TSN%'
 AND lgid IN (SELECT lgid FROM awardsmanagers WHERE lgid IN ('NL'))
 ),
 T3 AS( SELECT t1.playerid,t1.yearid,t2.yearid
 FROM t1
 INNER JOIN t2
 ON t1.playerid = t2.playerid)
 
 SELECT DISTINCT p.namefirst,p.namelast,t.name AS team_name
 FROM t3 
 JOIN people AS p
 On t3.playerid = p.playerid
 INNER JOIN managers AS m 
 ON t3.playerid = m.playerid AND 
 INNER JOIN teams AS t
  ON m.teamid = t.teamid

  -- Run the query to get the answer 


-- 10. Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. Report the players' first and last names and the number of home runs they hit in 2016.







SELECT people.namefirst,people.namelast,b.hr AS hr_high
FROM batting AS b
JOIN people
ON  b.playerid = people.playerid
AND (SELECT COUNT (DISTINCT yearid)
    FROM batting 
	WHERE playerid = people.playerid) >= 10
-- WHERE batting.yearid = 2016
-- AND EXTRACT(YEAR FROM CAST(people.finalgame AS date)) - EXTRACT(YEAR FROM CAST(people.debut AS date)) >= 10
AND b.hr >=1
AND b.hr = (
        SELECT MAX(hr)
        FROM batting
        WHERE playerid = b.playerid
		AND b.yearid = 2016
		
    )
GROUP BY people.namefirst,people.namelast,b.hr
 ORDER BY hr_high DESC
--------

-- run the query to get the answer 