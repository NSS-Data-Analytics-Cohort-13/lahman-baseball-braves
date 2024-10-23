--Q1 What range of years for baseball games played does the provided database cover?
SELECT 
	 MIN(year) AS start_year
	,MAX(year) AS max_year
FROM homegames;

/*Answer: The database covers baseball games played between 1871 and 2016: */

--Q2 Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?
SELECT 
	a.teamid AS team,
	a.g_all As game_count,
	concat(p.namefirst,' ', p.namelast) AS player_name,
	p.namegiven,
	p.height
FROM people AS p
INNER JOIN appearances AS a
USING(playerid)
WHERE height = (SELECT MIN(height) FROM people);

/* Answer: Player "Eddie Gaedel" is the shortest player with height 43 inches in a team "SLA" played 1 game in total */
