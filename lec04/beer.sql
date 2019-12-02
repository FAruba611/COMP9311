-- Q1

select name from Beers where manf = 'Toohey''s';


-- Q2

select name as "Beer", manf as "Brewer" from beers;


-- Q3

select distinct Beers.manf as brewer
from   Likes join Beers on (Likes.beer = Beers.name)
where  Likes.drinker = 'John';

-- alternatively

select distinct Beers.manf as brewer
from   Beers, Likes
where  Likes.drinker='John' and Likes.beer=Beers.name;


-- Q4

select b1.name, b2.name
from Beers b1 join Beers b2 on (b1.manf = b2.manf)
where b1.name < b2.name;

-- alternatively

select b1.name, b2.name
from   Beers b1, Beers b2
where  b1.manf=b2.manf and b1.name < b2.name;


-- Q5

-- using a non-correlated subquery
-- strategy:
-- * nested query finds brewers who make only one beer
-- * outer query selects beers made by those brewers

select name
from   Beers
where  manf in (select manf
			    from   beers
			    group by manf
			    having count(name) = 1)


-- or, using a correlated subquery
-- strategy:
-- * for each Beer b
-- * check for other beers made by b's brewer
-- * if none, then choose Beer b as a result

select b.name
from   Beers b
where  not exists (select *
                   from   Beers b1
                   where  b1.manf = b.manf and b1.name <> b.name);

				   
-- Q6

select distinct beer
from   Frequents f, Bars b, Sells s
where  f.drinker = 'John' and f.bar = b.name and b.name = s.bar;

-- or

select distinct beer
from   Frequents f
         join Bars b on (f.bar = b.name)
         join Sells s on (b.name = s.bar)
where  f.drinker = 'John';


-- Q7 How many different beers are there?

select count(*) from Beers;


-- Q8 How many different brewers are there?

select count(distinct manf) from Beers;
