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

