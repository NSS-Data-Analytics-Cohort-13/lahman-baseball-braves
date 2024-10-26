--Q1 What range of years for baseball games played does the provided database cover?
SELECT 
	 MIN(year) AS start_year
	,MAX(year) AS max_year
FROM homegames;
/*Answer : The database contains the entries from year 1871 to 2016*/

--Q2 Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?
SELECT 
	t.name AS team_name,
	a.g_all As game_count,
	p.namefirst || p.namelast AS player_name,
	p.height
FROM people AS p
INNER JOIN appearances AS a
	USING(playerid)
INNER JOIN teams AS t
	USING(teamid)
WHERE p.height = (SELECT MIN(height) FROM people)
LIMIT 1;

/* Answer: Player "Eddie Gaedel" is the shortest player with height 43 inches in a team ST. Louis Browns, played 1 game in total */

--Q3 Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?

--This query is generating the names of players who played for Vanderbilt university, year they played and total salary
SELECT 
	DISTINCT p.namefirst
	,	p.namelast
	,	SUM(s.salary::integer)::money as total_salary
FROM people p
	INNER JOIN salaries s
		USING(playerid)
	INNER JOIN collegeplaying c
		USING(playerid)
	INNER JOIN schools s1
		ON c.schoolid = s1.schoolid
WHERE s1.schoolname ILIKE '%vanderbilt university%'
GROUP BY p.namefirst ,p.namelast ,c.yearid
ORDER BY total_salary DESC
LIMIT 1

/* Answer: There are 15 players listed who played for Vanderbilt University. Out of all the players "David Price"	earned the most money in the majors which is $81,851,296 in total over 3 years.*/

--Q4. Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups in 2016.

SELECT
  SUM(CASE When f.pos LIKE 'OF' THEN f.po ELSE 0 END) AS Outfield,
  SUM(CASE When f.pos IN ('SS', '1B', '2B', '3B') THEN f.po ELSE 0 END) AS Infield,
  SUM(CASE WHEN f.pos IN ('P', 'C') THEN f.po ELSE 0 END) AS Battery
FROM fielding AS f
	WHERE f.yearid = 2016 

/* Answer : 3 new fielding positions with it’s total number of putouts are "Battery" = 41424, "Infield" = 58934, "Outfield" = 29560 */

--Q5. Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?

SELECT yearid/10 * 10 AS decade, 
	ROUND(((SUM(so)::float/SUM(g))::numeric), 2) AS avg_strikeout,
	ROUND(((SUM(hr)::float/SUM(g))::numeric), 2) AS avg_homerun
FROM teams
WHERE yearid >= 1920 
GROUP BY decade
ORDER BY decade

--Q6. Find the player who had the most success stealing bases in 2016, where __success__ is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted _at least_ 20 stolen bases.

SELECT 
	p.namefirst || p.namelast AS player_name
	, ROUND((b.sb::DECIMAL/(b.sb::DECIMAL + b.cs::DECIMAL)*100),2) AS sb_success_percentage
FROM batting as b
	LEFT JOIN people as p
		using(playerid)
WHERE b.yearid = 2016
	AND (b.sb+b.cs)>=20
ORDER BY sb_success_percentage desc
LIMIT 1;

/*Q7 From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? 
What is the smallest number of wins for a team that did win the world series? Doing this will 
probably result in an unusually small number of wins for a world series champion – determine why 
this is the case. Then redo your query, excluding the problem year. How often from 1970 – 2016 was 
it the case that a team with the most wins also won the world series? What percentage of the time?*/

--Query returns largest number of wins for a team that did not win the world series between 1970 – 2016
SELECT name AS team, yearid AS year, w AS wins
FROM teams 
WHERE 
	yearid BETWEEN 1970 AND 2016
	AND WSWin = 'N'
ORDER BY wins DESC
LIMIT 1
/*Answer: "Seattle Mariners"	2001	116*/

--Query returns smallest number of wins for a team that did not win the world series between 1970 – 2016
SELECT name AS team, yearid AS year, w AS wins
FROM teams 
WHERE 
	yearid BETWEEN 1970 AND 2016
	AND WSWin = 'N'
ORDER BY wins 
LIMIT 1
/*Answer: The smallest number wins which is 37 recorded in the year 1981 because players go on strike which forced the cancellation of 713 games */

-- number of wins for a world series champions between 1970 – 2016
	SELECT name AS team, yearid AS year, w AS wins
	FROM teams 
	WHERE 
		yearid BETWEEN 1970 AND 2016
		AND WSWin = 'Y'
	ORDER BY yearid  
/*Answer: Year 1994 is missing from the answer, the year where players were on strike and world series championship didn't happened that year*/

WITH winners AS (SELECT yearid, MAX(w) AS most_wins
						FROM teams
							WHERE yearid BETWEEN 1970 and 2016
								AND wswin = 'Y'
							GROUP BY yearid
					INTERSECT
					SELECT yearid, MAX(w) AS most_wins
						FROM teams
							WHERE yearid BETWEEN 1970 and 2016
						GROUP BY yearid
						ORDER BY yearid)
--Following query generates the denominator as 46 excluding the year 1994 when world series championship didn't happen because of player strike.
 SELECT ROUND((COUNT(w.yearid)/(SELECT COUNT(yearid) FROM teams WHERE yearid BETWEEN 1970 and 2016 AND wswin = 'Y')::DECIMAL * 100),2) AS win_ws_percent
 FROM winners AS w

/*Answer: 26.09%*/

--Q8. Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games). Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.

--Below query generates the data with the teams and parks which had the top 5 average attendance per game in 2016
SELECT 
	DISTINCT(parks.park_name)
	, homegames.team 
	, teams.name
	, homegames.Attendance / homegames .games as avg_attendance
FROM homegames
	INNER JOIN parks USING(park) 
	LEFT JOIN teams 
		ON homegames.team = teams.teamid 
		AND homegames.year = teams.yearid
WHERE homegames .year = 2016 
		AND homegames.games >= 10
ORDER BY avg_attendance DESC
LIMIT 5;

/* Answer:
"Dodger Stadium"	"Los Angeles Dodgers"	45719
"Busch Stadium III"	"St. Louis Cardinals"	42524
"Rogers Centre"	"Toronto Blue Jays"	41877
"AT&T Park"	"San Francisco Giants"	41546
"Wrigley Field"	"Chicago Cubs"	39906*/

--Below query generates the data with the teams and parks which had the lowest 5 average attendance per game in 2016
SELECT 
	DISTINCT(parks.park_name)
	, homegames.team 
	, teams.name
	, homegames.Attendance / homegames .games as avg_attendance
FROM homegames
	INNER JOIN parks USING(park) 
	LEFT JOIN teams 
		ON homegames.team = teams.teamid 
		AND homegames.year = teams.yearid
WHERE homegames .year = 2016 
		AND homegames.games >= 10
ORDER BY avg_attendance 
LIMIT 5;

/* Answer: 
"Tropicana Field"	"Tampa Bay Rays"	15878
"Oakland-Alameda County Coliseum"	"Oakland Athletics"	18784
"Progressive Field"	"Cleveland Indians"	19650
"Marlins Park"	"Miami Marlins"	21405
"U.S. Cellular Field"	"Chicago White Sox"	21559*/

--9. Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their full name and the teams that they were managing when they won the award.

-- Below CTE retrieves managers who have won the TSN Manager of the Year award in both NL and AL
WITH tsn_manager AS
	(SELECT 
		p.namefirst || p.namelast AS manager_name
		, am.playerid AS manager_id
		, am.awardid, am.yearid
		, am.lgid, m.teamid
	FROM AwardsManagers AS am
		LEFT JOIN people AS p 
			USING(playerid)
		LEFT JOIN managers AS m
			ON am.playerid = m.playerid AND am.yearid = m.yearid
	WHERE (am.lgid = 'NL' OR am.lgid = 'AL')
		AND am.awardid ILIKE '%TSN Manager%')
-- Query to find team names managed by managers who have won the TSN Manager of the Year award in both NL and AL
SELECT *, t.name AS team_name
	FROM tsn_manager AS tm
		LEFT JOIN teams AS t
		ON tm.teamid = t.teamid AND tm.yearid = t.yearid