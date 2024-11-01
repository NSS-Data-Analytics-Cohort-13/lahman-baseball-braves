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
LIMIT 1;

/* Answer: There are 15 players listed who played for Vanderbilt University. Out of all the players "David Price"	earned the most money in the majors which is $81,851,296 in total over 3 years.*/

--Q4. Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups in 2016.

/* Method 1: Following query will generate 3 columns with new fielding positions along with their total sum of putouts in the year 2016*/
SELECT
  SUM(CASE When f.pos LIKE 'OF' THEN f.po ELSE 0 END) AS Outfield,
  SUM(CASE When f.pos IN ('SS', '1B', '2B', '3B') THEN f.po ELSE 0 END) AS Infield,
  SUM(CASE WHEN f.pos IN ('P', 'C') THEN f.po ELSE 0 END) AS Battery
FROM fielding AS f
	WHERE f.yearid = 2016;

/* Answer : 3 new fielding positions columns with it’s total number of putouts are "Battery" = 41424, "Infield" = 58934, "Outfield" = 29560 */

/*Method 2: 
Part 1 - Create a CTE to hold player and fielding data along with its putouts for the year 2016*/
WITH player_fielding AS
(
--Following query will retrieve 2016 fielding data along with name of player
	SELECT 
		concat(p.namefirst,' ', p.namelast) AS player_name
		, f.po
		--Given condition based new fielding positions
		, CASE 
			When f.pos LIKE 'OF' THEN 'Outfield'
			When f.pos IN ('SS', '1B', '2B', '3B') THEN  'Infield'
			WHEN f.pos IN ('P', 'C') THEN 'Battery'
		  END AS new_position
	FROM fielding AS f
	   left JOIN people AS p
	USING(playerid)
	WHERE f.yearid = 2016 
)
-- Part 2- following query is generating the total number of putouts made by each of these three groups in 2016
SELECT 
	SUM(po) AS total_putouts
	, new_position
FROM player_fielding
GROUP BY new_position;

/* Answer : 
41424	"Battery"
58934	"Infield"
29560	"Outfield"*/

--Q5. Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?

SELECT yearid/10 * 10 AS decade, 
	ROUND(((SUM(so)::float/SUM(g))::numeric), 2) AS avg_strikeout,
	ROUND(((SUM(hr)::float/SUM(g))::numeric), 2) AS avg_homerun
FROM teams
WHERE yearid >= 1920 
GROUP BY decade
ORDER BY decade;

--Q6. Find the player who had the most success stealing bases in 2016, where __success__ is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted _at least_ 20 stolen bases.

SELECT 
	CONCAT(p.namefirst,' ',p.namelast) AS player_name
	, SUM(b.sb::DECIMAL) AS stolen_bases
	, SUM(b.cs::DECIMAL) AS caught_stolen
	, SUM(b.sb::DECIMAL) + SUM(b.cs::DECIMAL) as total_attempts
	, ROUND((SUM(b.sb)::DECIMAL/(SUM(b.sb)::DECIMAL + SUM(b.cs)::DECIMAL))*100,2) AS sb_success_percentage
FROM batting as b
	INNER JOIN people AS p
		ON b.playerid = p.playerid
		AND b.yearid = 2016
GROUP BY p.namefirst, p.namelast
HAVING SUM(b.sb) + SUM(b.cs) >= 20
ORDER BY sb_success_percentage DESC;

/*Answer: "Chris Owings" with 91.30% had the most success stealing bases in 2016. The query return list of total 50 players*/

/*Q7 From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? 
What is the smallest number of wins for a team that did win the world series? Doing this will 
probably result in an unusually small number of wins for a world series champion – determine why 
this is the case. Then redo your query, excluding the problem year. How often from 1970 – 2016 was 
it the case that a team with the most wins also won the world series? What percentage of the time?*/

--Query returns largest number of wins for a team that "did not win" the world series between 1970 – 2016
SELECT name AS team, yearid AS year, w AS wins
FROM teams 
WHERE 
	yearid BETWEEN 1970 AND 2016
	AND WSWin = 'N'
ORDER BY wins DESC
LIMIT 1;
/*Answer: "Seattle Mariners"	2001	116*/

--Query returns smallest number of wins for a team that "did win" the world series between 1970 – 2016
SELECT name AS team, yearid AS year, w AS wins
FROM teams 
WHERE 
	yearid BETWEEN 1970 AND 2016
	AND WSWin = 'Y'
ORDER BY wins 
LIMIT 1;
/*Answer: "Los Angeles Dodgers"	1981	63. */

--Query returns smallest number of wins for a team that "did win" the world series between 1970 – 2016 after excluding problem year 1981, because players go on strike that year which forced the cancellation of 713 games.
SELECT name AS team, yearid AS year, w AS wins
FROM teams 
WHERE 
	yearid BETWEEN 1970 AND 2016
	AND WSWin = 'Y'
	AND yearid!=1981
ORDER BY wins 
LIMIT 1;
/*Answer:"St. Louis Cardinals"	2006	83*/

-- number of wins for a world series champions between 1970 – 2016
	SELECT name AS team, yearid AS year, w AS wins
	FROM teams 
	WHERE 
		yearid BETWEEN 1970 AND 2016
		AND WSWin = 'Y'
	ORDER BY yearid;  
/*Answer: Year 1994 is missing from the answer, the year where players were on strike and world series championship didn't happened that year*/

--Following CTE returns a list of teams from 1970 – 2016, that with the most wins also won the world series. The answer the 12 teams.
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
--Following query generates percentage of the time of teams from 1970 – 2016, that with the most wins also won the world series.
 SELECT 
  ROUND
	(
--the subquery in denominator part genarates count as 46 instead od 47, because in the year 1994 world series championship didn't happen because of player strike. 
	   (COUNT(w.yearid)/(SELECT COUNT(yearid) FROM teams 
	 	WHERE yearid BETWEEN 1970 AND 2016 
			AND wswin = 'Y')::DECIMAL * 100),2
	) AS win_ws_percent
 FROM winners AS w;

/*Answer: 26.09%*/

/*Alternate approach: Praveena’s method..
query most team wins and world series wins How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?*/
WITH mostwins AS(
SELECT
yearid ,-- name ,
MAX(w) AS max_wins
FROM teams
WHERE yearid BETWEEN 1970 AND 2016
    GROUP BY yearid --,name    --ans is 47
),
ws_wins AS (
SELECT yearid
FROM teams
WHERE yearid BETWEEN 1970 AND 2016
 AND wswin ILIKE '%y%'),  --- ans 46 ),
winners AS(
SELECT yearid
,  MAX(w)
FROM teams
WHERE yearid BETWEEN 1970 AND 2016 AND wswin ILIKE '%y%'
GROUP BY yearid

INTERSECT

SELECT yearid
,  MAX(w)
FROM teams
WHERE yearid BETWEEN 1970 AND 2016
GROUP BY yearid
ORDER BY yearid
)
SELECT
  round(COUNT(winners.yearid)/(SELECT COUNT(mostwins.yearid) FROM mostwins ):: decimal *100,2)
FROM winners;

/*Answer with Praveena's approach: 25.53%. Because the count in denominator is 47. Her query is including the year 1994, when even if world series got cancelled, but still teams played in leagues.*/
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

--Q9. Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their full name and the teams that they were managing when they won the award.

--Following CTE is generating manager ids who won TSN Manager of the Year award in both NL and AL category.
WITH al_nl_manager AS
	(
		SELECT playerid  
		FROM AwardsManagers
		WHERE lgid IN ('AL', 'NL') AND awardid ILIKE '%tsn%'
		GROUP BY playerid
		HAVING COUNT(DISTINCT lgid) = 2
	)
--Below query is fetching manager name and team names managed by managers generated from CTE
SELECT 
		DISTINCT(p.namefirst || p.namelast) AS manager_name
		, t.name AS team_name
	FROM AwardsManagers AS am
		LEFT JOIN people AS p 
			USING(playerid )
		LEFT JOIN managers AS m
			on am.playerid = m.playerid AND am.yearid = m.yearid
		LEFT JOIN teams AS t
			ON m.teamid = t.teamid AND am.yearid = t.yearid
-- Following subquery in where clause is making sure the data has been retrieved only for those managers mentioned in CTE-al_nl_manager
	WHERE am.playerid IN (SELECT playerid FROM al_nl_manager);

/*Answer: 
"DaveyJohnson"	"Baltimore Orioles"
"DaveyJohnson"	"Washington Nationals"
"JimLeyland"	"Detroit Tigers"
"JimLeyland"	"Pittsburgh Pirates"
--ADDITIONAL ANALYSIS: Above answer is removing duplicate values and reducing the resulting number of rows to 4 from 6. The answer can return 6 rows if we add yearid in select statement and the answer will be as follows;
"DaveyJohnson"	"Baltimore Orioles"		1997
"DaveyJohnson"	"Washington Nationals"	2012
"JimLeyland"	"Detroit Tigers"		2006
"JimLeyland"	"Pittsburgh Pirates"	1988
"JimLeyland"	"Pittsburgh Pirates"	1990
"JimLeyland"	"Pittsburgh Pirates"	1992
*/

/* Q10. Find all players who hit their career highest number of home runs in 2016. 
Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. 
Report the players' first and last names and the number of home runs they hit in 2016.*/

SELECT 
	p1.namefirst
	, p1.namelast
	, b1.hr AS hr_high
FROM batting AS b1
	JOIN people p1 ON  b1.playerid = p1.playerid
--Following subquery is checking a condition, that a player must have played at least for 10 years
		AND ( SELECT COUNT(DISTINCT yearid) 
			  FROM batting
			  WHERE playerid =p1.playerid
			 )>=10
		AND b1.hr >=1
--following subquery making sure, that a player has scored his highest number of home runs in the year 2016
		AND b1.hr = ( SELECT MAX(hr)
					  FROM batting
					  WHERE playerid = b1.playerid
						AND b1.yearid = 2016
	    			)
GROUP BY p1.namefirst,p1.namelast,b1.hr
ORDER BY hr_high DESC;

/*Answer: This will return back 9 rows in total*/