select awardid,yearid ,lgid,playerid
from awardsmanagers 
where awardid ilike '%tsn manager%'  and playerid = 'johnsda02'


select playerid,namegiven,namefirst,namelast from people where playerid = 'johnsda02'
select  name from teams where 

select * from teams
select teamid from salaries where playerid = 'johnsda02'



select playerid
from awardsmanagers 
where awardid ilike '%tsn manager%' and lgid = 'NL'

INTERSECT

select playerid
from awardsmanagers 
where awardid ilike '%tsn manager%' and lgid = 'AL'
--- leylaji99 - jim leyland  , johnsda02  --davey johnson


with nl_award as(
		select playerid,yearid
		from awardsmanagers 
		where awardid ilike '%tsn manager%' and lgid = 'NL' -- count 30
),
al_award as(
		select playerid,yearid
		from awardsmanagers 
		where awardid ilike '%tsn manager%' and lgid = 'AL' -- count 30
),
both_awards as(
		 select distinct nl.playerid , nl.yearid as nl_year, al.yearid as al_year
    from nl_award nl
    join al_award al on nl.playerid = al.playerid
)
--select * from both_awards
-- display year and names
/*
select p.playerid, p.namefirst, p.namelast, ba.nl_year, ba.al_year
from both_awards ba
join people p on ba.playerid = p.playerid; */

/*
select  ba.nl_year, p.namefirst, p.namelast, t.name AS team_name
from both_awards ba
join people p on ba.playerid = p.playerid
join managers m on p.playerid = m.playerid
join teams t on m.teamid = t.teamid
order by ba.nl_year, p.namefirst, p.namelast
*/
select  p.namefirst, p.namelast, t.name as team_name
from both_awards ba
join people p on ba.playerid = p.playerid
join managers m on p.playerid = m.playerid and ba.yearid = m.yearid
join teams t on m.teamid = t.teamid and m.yearid = t.yearid

order by p.namefirst, p.namelast










select teamid from appearances where playerid = 'johnsda02'
select teamid from appearances where playerid = 'leylaji99'


select * from people where playerid = 'leylaji99' 

select * from managers where playerid = 'leylaji99' 
select * from managers where playerid = 'johnsda02'

(select playerid,lgid
from awardsmanagers 
where awardid ilike '%tsn manager%' and lgid = 'NL'
group by lgid,playerid)

union

(select playerid ,lgid
from awardsmanagers 
where awardid ilike '%tsn manager%' and lgid = 'AL'
group by lgid,playerid )
order by playerid;

-------q
select p1.namefirst,p1.namelast,b1.hr as hr_high 
from batting as b1
join people p1 on  b1.playerid = p1.playerid
--where b1.yearid = 2016 
and (select count(distinct yearid) 
     from batting 
     where playerid = p1.playerid) >= 10 
and b1.hr >=1 
and b1.hr = (
        select max(hr) 
        from batting 
        where playerid = b1.playerid 
		and  b1.yearid = 2016 
    )
group by p1.namefirst,p1.namelast,b1.hr
order by hr_high desc

