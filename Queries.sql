-- IMPORTING DATASET: 

create table athlete_events(
	id int, 
	name varchar, 
	sex varchar,
	age varchar,
	height varchar, 
	weight varchar, 
	team varchar, 
	noc varchar, 
	games varchar, 
	year int,
	season varchar, 
	city varchar, 
	sport varchar, 
	event varchar, 
	medal varchar
	);
create table noc_regions(noc varchar, region varchar);
select * from athlete_events;
alter table noc_regions add column notes varchar;
select * from noc_regions;

-- SOLVING SQL QUERIES: 

--1) How many olympics games have been held?
select count(distinct games) as total_games from athlete_events;

--2) List down all Olympics games held so far.
select distinct games, year, season, city from athlete_events order by games;

--3) Mention the total no of nations who participated in each olympics game?
with gr (games,noc,region) as
	(select ae.games,ae.noc,nr.region from athlete_events as ae join noc_regions as nr on ae.noc = nr.noc group by ae.games,ae.noc,nr.region)
select games, count(region) as total_countries from gr group by games order by games;

--4) Which year saw the highest and lowest no of countries participating in olympics?
with gr (games,noc,region) as
	(select ae.games,ae.noc,nr.region from athlete_events as ae join noc_regions as nr on ae.noc = nr.noc 
		group by ae.games,ae.noc,nr.region),
	total_count as 
		(select games, count(region) as total_countries from gr group by games order by games),
	max_min as
		(select max(total_count.total_countries) as highest_countries, min(total_count.total_countries) as lowest_countries 
		from total_count),
	game_high as
		(select total_count.games as hg, max_min.highest_countries from total_count join max_min 
		on max_min.highest_countries= total_count.total_countries),
	game_low as
		(select total_count.games as lg, max_min.lowest_countries from total_count join max_min 
	on max_min.lowest_countries= total_count.total_countries)
select * from game_high, game_low;

----5) Which nation has participated in all of the olympic games?
with gr (games,region) as
		(select ae.games,nr.region from athlete_events as ae join noc_regions as nr on ae.noc = nr.noc 
		group by nr.region,ae.games order by ae.games),
	rg (regions,games) as 
		(select region, count(games) from gr group by region),
	total_games as 
		(select count(distinct games) as total_num_games from gr)
select rg.regions as countries_particpated_all_games from rg join total_games on rg.games = total_games.total_num_games 
	order by rg.regions;

-- 6) Identify the sport which was played in all summer olympics.
with summer_games_count as 
		(select count(distinct games) as count_summer_games from athlete_events where season = 'Summer'),
	sport_games as
		(select sport, count( distinct games) as sport_games_count from athlete_events where season = 'Summer' group by sport)
select sport_games.sport, sport_games.sport_games_count from summer_games_count 
	join sport_games on summer_games_count.count_summer_games = sport_games.sport_games_count order by sport_games.sport;

--7) Which Sports were just played only once in the olympics?
with sport_games as 
		(select sport, count( distinct games) as sport_games_count from athlete_events group by sport)
select * from sport_games where sport_games_count = 1 order by sport; 

-- 8) Fetch the total no of sports played in each olympic games.
select games, count(distinct sport) as total_sports from athlete_events group by games order by games;

-- 9) Fetch oldest athletes to win a gold medal
with t1 as 
	(select * from athlete_events where medal = 'Gold'),
	t2 as 
	(select max(age) as max_age from t1 where age != 'NA')
select * from t1 join t2 on t1.age = t2.max_age;

--10) Find the Ratio of male and female athletes participated in all olympic games.
with male_female as 
		(select sex, count(name) as count from athlete_events group by sex),
	male_count as 
		(select count from male_female where sex = 'M'),
	female_count as 
		(select count from male_female where sex = 'F')
select concat('1: ', cast(male_count.count /cast(female_count.count as decimal(10,5)) as decimal(10,2))) as ratio
	from male_count,female_count;

--11) Fetch the top 5 athletes who have won the most gold medals.
with t1 as 
		(select name, count(medal) as num_gold_medal from athlete_events where medal = 'Gold'
	group by name order by num_gold_medal desc),
	t2 as 
		(select *, dense_rank() over (order by num_gold_medal desc) as rank from t1)
select * from t2 where rank <=5;

--12) Fetch the top 5 athletes who have won the most medals (gold/silver/bronze).
with t1 as 
		(select name, count(medal) as num_medal from athlete_events where medal in ('Gold','Silver','Bronze')
			group by name order by num_medal desc),
	t2 as 
		(select *, dense_rank() over (order by num_medal desc) as rank from t1)
select * from t2 where rank <=5;

--13) Fetch the top 5 most successful countries in olympics. Success is defined by no of medals won.
with t1 as 
		(select ae.games, nr.region, ae.medal from athlete_events ae join noc_regions nr on ae.noc = nr.noc),
	t2 as 
		(select region, count(medal) as total_medals_won from t1 where medal in ('Gold','Silver','Bronze') 
			group by region)
select *, dense_rank() over (order by t2.total_medals_won desc) from t2 limit 5;

--14) List down total gold, silver and bronze medals won by each country.
with t1 as
		(select ae.games, nr.region, ae.medal from athlete_events ae join noc_regions nr on ae.noc = nr.noc 
			where medal in ('Gold','Silver','Bronze')),
		t2 as
			(select region,count(medal) as gold_medals_count from t1 where medal = 'Gold' group by region),
		t3 as
			(select region,count(medal) as silver_medals_count from t1 where medal = 'Silver' group by region),
		t4 as
			(select region,count(medal) as bronze_medals_count from t1 where medal = 'Bronze' group by region)
select t2.region,t2.gold_medals_count,t3.silver_medals_count,t4.bronze_medals_count 
	from t2 join t3 on t2.region = t3.region join t4 on t3.region = t4.region order by region;

--WITH CROSSTAB: 

CREATE EXTENSION TABLEFUNC;

select country, 
	coalesce(bronze,0) as Bronze,
	coalesce(silver,0) as Silver,
	coalesce(gold,0) as Gold
	from crosstab('select nr.region as country, ae.medal, count(1) as count_medals 
	from athlete_events ae join noc_regions nr on ae.noc=nr.noc 
	where ae.medal != ''NA''
	group by country, ae.medal
	order by country, ae.medal', 
	'values (''Bronze''),(''Gold''),(''Silver'')')
	as result(country varchar, Bronze bigint, Gold bigint, Silver bigint)
	order by gold desc, silver desc, bronze desc;

--15) List down total gold, silver and bronze medals won by each country corresponding to each olympic games.
	
select
	substring(games,1,position(' - ' in games)-1 ) as games,
    substring(games,position(' - ' in games) + 3) as country,
	coalesce(bronze,0) as bronze,
	coalesce(silver,0) as silver,
	coalesce(gold,0) as gold
from crosstab('select concat(ae.games,'' - '', nr.region) as games , ae.medal, count(1) as count_medals 
	from athlete_events ae join noc_regions nr on ae.noc=nr.noc 
	where ae.medal != ''NA''
	group by games, nr.region, ae.medal
	order by games, ae.medal',
	'values (''Bronze''),(''Gold''),(''Silver'')')
as result(games varchar, Bronze bigint, Gold bigint, Silver bigint);

--16)  Identify which country won the most gold, most silver and most bronze medals in each olympic games.
with t1 as 
		(select
			substring(games,1,position(' - ' in games)-1 ) as games,
		    substring(games,position(' - ' in games) + 3) as country,
			coalesce(bronze,0) as bronze,
			coalesce(silver,0) as silver,
			coalesce(gold,0) as gold
			from crosstab('select concat(ae.games,'' - '', nr.region) as games , ae.medal, count(1) as count_medals 
						from athlete_events ae join noc_regions nr on ae.noc=nr.noc 
						where ae.medal != ''NA''
						group by games, nr.region, ae.medal
						order by games, ae.medal',
						'values (''Bronze''),(''Gold''),(''Silver'')')
					as result(games varchar, Bronze bigint, Gold bigint, Silver bigint))
select distinct games, 
	concat(first_value(country)over(partition by games order by gold desc),' - ',
	first_value(gold)over(partition by games order by gold desc)) as gold,
	concat(first_value(country)over(partition by games order by silver desc),' - ',
	first_value(silver)over(partition by games order by silver desc)) as silver,
	concat(first_value(country)over(partition by games order by bronze desc),' - ',
	first_value(bronze)over(partition by games order by bronze desc)) as bronze	
from t1 order by games; 

--17) Identify which country won the most gold, most silver, most bronze medals and the most medals in each olympic games.
with t1 as 
		(select
			substring(games,1,position(' - ' in games)-1 ) as games,
		    substring(games,position(' - ' in games) + 3) as country,
			coalesce(bronze,0) as bronze,
			coalesce(silver,0) as silver,
			coalesce(gold,0) as gold
			from crosstab('select concat(ae.games,'' - '', nr.region) as games , ae.medal, count(1) as count_medals 
						from athlete_events ae join noc_regions nr on ae.noc=nr.noc 
						where ae.medal != ''NA''
						group by games, nr.region, ae.medal
						order by games, ae.medal',
						'values (''Bronze''),(''Gold''),(''Silver'')')
					as result(games varchar, Bronze bigint, Gold bigint, Silver bigint)),
		t2 as 
			(select games,nr.region as country, count(1)as total_medals 
				from athlete_events ae
				join noc_regions nr on ae.noc = nr.noc 
				where medal != 'NA'
				group by games,nr.region
				order by games,nr.region)
select distinct t1.games, 
	concat(first_value(t1.country)over(partition by t1.games order by gold desc),' - ',
	first_value(t1.gold)over(partition by t1.games order by gold desc)) as gold,
	concat(first_value(t1.country)over(partition by t1.games order by silver desc),' - ',
	first_value(t1.silver)over(partition by t1.games order by silver desc)) as silver,
	concat(first_value(t1.country)over(partition by t1.games order by bronze desc),' - ',
	first_value(t1.bronze)over(partition by t1.games order by bronze desc)) as bronze,
	concat(first_value(t2.country)over(partition by t2.games order by total_medals desc nulls last),
	' - ',
	first_value(t2.total_medals)over(partition by t2.games order by total_medals desc)) as total_medals
from t1 join t2 on t1.games = t2.games and t1.country = t2.country
	order by t1.games; 

--18) Which countries have never won gold medal but have won silver/bronze medals?

select * 
		from(select country, 
					coalesce(gold,0) as gold,
					coalesce(silver,0) as silver,
					coalesce(bronze,0) as bronze
					from crosstab('select nr.region as country, medal, count(1) as total_medals 
					from athlete_events ae join noc_regions nr on ae.noc=nr.noc
					where medal != ''NA''
					group by nr.region, medal
					order by nr.region, medal',
					'values (''Bronze''),(''Gold''),(''Silver'')')
					as result(country varchar, bronze bigint, gold bigint, silver bigint)) 
where Gold = 0 and (Silver >0 or Bronze >0 )
order by Gold desc, Silver desc, Bronze desc; 

--19) In which Sport/event, India has won highest medals.
with t1 as 
		(select nr.region, ae.sport, count(medal) as total_medals from athlete_events ae join noc_regions nr on ae.noc=nr.noc 
		 where nr.region = 'India' and medal != 'NA' group by nr.region, ae.sport),
	t2 as
		(select max(total_medals) as max_medals from t1)
select t1.sport, t2.max_medals from t1 join t2 on t1.total_medals = t2.max_medals; 

--20) Break down all olympic games where India won medal for Hockey and how many medals in each olympic games.
select nr.region, ae.sport, ae.games, count(medal) as total_medals 
from athlete_events ae join noc_regions nr on ae.noc=nr.noc 
where nr.region = 'India' and medal != 'NA' and sport = 'Hockey'
group by nr.region, ae.sport, ae.games
order by total_medals desc














	


   









