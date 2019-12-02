-- COMP9311 17s2 Lab5 Exercise
-- Written by: YOUR NAME


-- Q1: AllRatings view 

create or replace view Q1(taster,beer,brewer,rating)
as
	select ta.given, be.name, br.name, ra.score
	from beer be, taster ta, brewer br, ratings ra
	where ra.taster = ta.id and ra.beer = be.id and be.brewer = br.id
	order by ta.given, ra.score desc
;


-- John's favourite beer

create or replace view Q2(brewer,beer)
as
	with score as (
		select ta.given as g, be.name as n, be.brewer as b, ra.score as s
		from taster ta, beer be, ratings ra
		where ra.taster = ta.id and ra.beer = be.id
	)
	,
		john_score as (
		select br.name as b, j.n as n, j.s
		from brewer br, score j
		where br.id = j.b and j.g = 'John'
		order by j.s desc
	)
	select jo.b,jo.n 
	from john_score jo
	order by jo.s desc limit 1
;

-- X's favourite beer
create type BeerInfo as (brewer text, beer text);

create or replace function Q3(taster text) returns setof BeerInfo
as $$
	with score as (
		select ta.given as g, be.name as n, be.brewer as b, ra.score as s
		from taster ta, beer be, ratings ra
		where ra.taster = ta.id and ra.beer = be.id
	)
	,
		X_score as (
		select br.name as b, j.n as n, j.s
		from brewer br, score j
		where br.id = j.b and j.g = $1
		order by j.s desc
	)
	select X.b,X.n 
	from X_score X
	order by X.s desc limit 1
$$ language sql
;


-- Beer style

create or replace function Q4_1(brewer text, beer text) returns text
as $$
	select be.name
	from beer be, brewer br
	where lower(br.name) = lower($1) and lower(be.name) = lower($2)
$$ language sql
;

/*
create or replace function Q5_2(brewer text, beer text) returns text
as $$
begin
	... replace this by your PLpgSQL code ...
end;
$$ language plpgsql
;


-- Taster address

create or replace function TasterAddress(taster text) returns text
as $$
	select loc.state||', '||loc.country
	from   Taster t, Location loc
	where  t.given = $1 and t.livesIn = loc.id
$$ language sql
;

create or replace function TasterAddress(taster text) returns text
as $$
begin
	... replace this by your PLpgSQL code ...
end;
$$ language plpgsql
;

*/
-- BeerSummary function

create or replace function BeerDisplay(_beer text, _rating float, _tasters text) returns text
as $$
begin
	return E'\n' ||
	       'Beer:    ' || _beer || E'\n' ||
	       'Rating: ' || to_char(_rating,'9.9') || E'\n' ||
	       'Tasters: ' || substr(_tasters,3,length(_tasters)) || E'\n';
end;
$$ language plpgsql;

create or replace function BeerSummary() returns text
as $$
declare
	r       record;
	out     text := '';
	curbeer text := '';
	tasters text;
	sum     integer;
	count   integer;
begin
	for r in select * from AllRatings order by beer,taster
	loop
		if (r.beer <> curbeer) then
			if (curbeer <> '') then
				out := out || BeerDisplay(curbeer,sum/count,tasters);
			end if;
			curbeer := r.beer;
			sum := 0; count := 0; tasters := '';
		end if;
		sum := sum + r.rating;
		count := count + 1;
		tasters := tasters || ', ' || r.taster;
	end loop;
	-- finish off the last beer
	out := out || beerDisplay(curbeer,sum/count,tasters);
	return out;
end;
$$ language plpgsql;


/*
-- Concat aggregate

create aggregate concat (... replace by base type ...)
(
	stype     = ... replace by state type ... ,
	initcond  = ... replace by initial state ... ,
	sfunc     = ... replace by name of state transition function ...,
	finalfunc = ... replace by name of finalisation function ...
);


-- BeerSummary view

create or replace view BeerSummary(beer,rating,tasters)
as
	... replace by SQL your query using concat() and AllRatings ...
;


-- TastersByCountry view

create or replace view TastersByCountry(country,tasters)
as
	... replace by SQL your query using concat() and Taster ...
;
*/