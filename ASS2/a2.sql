--------COMP9311 Assignment2
---
------- Description -->
---
--In this assignment, the schema for a simple ASX (The Australian Securities Exchange) database is provided to you. ASX is --Australia's primary securities exchange. Based on the provided schema: asx-schema.sql, you are required to answer the following questions by formulating SQL queries. You may create SQL functions or PLpgSQL to help you, if and only if the standard SQL query language is not expressive and powerful enough to satisfy a particular question. To enable auto-marking, your queries should be formulated as SQL views, using the view and attribute names provided.
--If any queries below require you to order/rank your result in a certain way, unless it is mentioned explicitly, they are supposed to be in ascending order. If order is specified, correctness of your solution will include the correct ordering of the output from your solution.
--Furthermore, if information from the previous day is needed for your calculation in any queries below, please disregard the first trading when you count the total number of trading days otherwise you should include the first day into your calculation. For example, suppose that there are totally 5 trading days in the database. To calculate the average price of a given stock, please sum its prices and then divide by 5 days. To calculate its average gain in percentage, please sum its gains (only 4 of them) and then divide by 4 days.

--Author: Frank LI (Changfeng LI)
--zID: z5137858
--recently modified: 2017.9.14 18:57

-- Q1: List all the company names and countries that are incorporated outside Australia.-->

CREATE OR REPLACE VIEW 
Q1(Name, Country) 
AS 
	select Name, Country
	from Company
	where Country != 'Australia'
;

-- Q2: List all the company codes that have more than five executive members on record (i.e., at least six).-->
CREATE OR REPLACE VIEW 
Q2(Code) 
AS
	select Code 
	from Executive
	group by Code
	having count(Code) >= 6
;

--Q3: List all the company names that are in the sector of "Technology" --> 
CREATE OR REPLACE VIEW 
Q3_Tech(Code, Sector)
AS
	select Code, Sector
	from Category
	where Sector = 'Technology'
;

CREATE OR REPLACE VIEW 
Q3(Name)
AS
	select b.Name
	from Q3_Tech a, Company b
	where a.Code = b.Code
;

--Q4: Find the number of Industries in each Sector -->
CREATE OR REPLACE VIEW
Q4(Sector, Number)
AS
	select Sector, count(distinct industry)
	from Category
	group by sector
;
	
-- Q5: Find all the executives (i.e., their names) that are affiliated with companies in the sector of "Technology". If an executive is affiliated with more than one company, he/she is counted if one of these companies is in the sector of "Technology".-->
CREATE OR REPLACE VIEW
Q5_Tech(Sector,Code)
AS
	select Sector,Code
	from Category
	where Category.Sector = 'Technology'
;

CREATE OR REPLACE VIEW
Q5_Allp(Name)
AS
	select Person
	from Executive, Q5_Tech x
	where Executive.Code = x.Code
;

CREATE OR REPLACE VIEW
Q5(Name)
AS
	select distinct Name
	from Q5_Allp
;
	
-- Q6: List all the company names in the sector of "Services" that are located in Australia with the first digit of their zip code being 2.-->
CREATE OR REPLACE VIEW
Q6_Australia_Zip2_Company(C,Z,Code)
AS
	select Name, Zip, Code
	from Company
	where Company.Country = 'Australia'
		and Company.Zip ~ '^2[0-9][0-9][0-9]$'
;

CREATE OR REPLACE VIEW
Q6_Service_Sector(S,Code)
AS
	select Sector, Code
	from Category
	where Category.Sector = 'Services'
;

CREATE OR REPLACE VIEW 
Q6(Name)
AS
	select a.C
	from Q6_Australia_Zip2_Company a, Q6_Service_Sector b
	where a.Code = b.Code
;
		

-- Q7: Create a database view of the ASX table that contains previous Price, Price change (in amount, can be negative) and Price gain (in percentage, can be negative). (Note that the first trading day should be excluded in your result.) For example, if the PrevPrice is 1.00, Price is 0.85; then Change is -0.15 and Gain is -15.00 (in percentage but you do not need to print out the percentage sign).-->
Create or replace view
Q7_D("Date")
AS
    select distinct "Date"
    from ASX
;
CREATE OR REPLACE VIEW
Q7_date(Row_n,"Date")
AS
    select row_number() over (order by a."Date"),a."Date"
    from Q7_D a
;
CREATE OR REPLACE VIEW 
Q7_Core_Info(Code,"Date",Volume)
AS   
    select b.Code,b."Date",b.Volume
    from ASX b
;

CREATE OR REPLACE VIEW
Q7("Date",Code,Volume,PrevPrice,Price,Change,Gain)
AS
	with temp as (
	select c."Date" as Da,
			c.Code as Co,
			c.Volume as Vo,
			lag(x.Price,1,null) over (partition by c.Code order by c."Date") as PPr,
			x.Price as Pr,
			x.Price - lag(x.Price,1,null) over (partition by c.Code order by c."Date") as Ch,
			(x.Price - lag(x.Price,1,null) over (partition by c.Code order by c."Date") * 100)/x.Price as Ga,
			v.Row_n as Ro
	from Q7_Core_Info c,ASX x,Q7_date v
	where c."Date" = x."Date" and c.Code = x.Code and c.Volume = x.Volume and v."Date" = c."Date"
	)
	select Da,Co,Vo,PPr,Pr,Ch,Ga from temp
	where Ro > 1
;

-- Q8: Find the most active trading stock (the one with the maximum trading volume; if more than one, output all of them) on every trading day. Order your output by "Date" and then by Code. -->
CREATE OR REPLACE VIEW 
Q8_Date("Date")
AS
	select distinct "Date"
	from ASX
	order by "Date"
;

CREATE OR REPLACE VIEW
Q8_Max_Volume(Volume)
AS
	select max(Volume)
	from ASX
	group by "Date";

CREATE OR REPLACE VIEW
Q8("Date", Code, Volume)
AS
	select d."Date", c.Code, v.Volume
	from ASX c, Q8_Date d, Q8_Max_Volume v
	where d."Date" = c."Date" and v.Volume = c.Volume
	order by "Date", Code
;

-- Q9: Find the number of companies per Industry. Order your result by Sector and then by Industry. -->
CREATE OR REPLACE VIEW 
Q9_Rough(Ind, Sec, N)
AS
	select c.Industry, c.Sector, count(c.Code)
	from Category c
	group by c.Industry, c.Sector
;

CREATE OR REPLACE VIEW
Q9(Sector, Industry, Number)
AS
	select c2.Sec, c2.Ind, c2.N
	from Q9_Rough c2
	order by c2.Sec, c2.Ind
;

-- Q10: List all the companies (by their Code) that are the only one in their Industry (i.e., no competitors).  
CREATE OR REPLACE VIEW 
Q10_cnt(N,Industry)
AS 
	select Count(Industry), Industry
	from Category
	group by Industry
;
	
CREATE OR REPLACE VIEW
Q10(Code,Industry)
AS
	select a.Code, b.Industry
	from Category a, Q10_cnt b
	where a.Industry = b.Industry
		and b.N = 1
	order by Code
;

-- Q11: List all sectors ranked by their average ratings in descending order. AvgRating is calculated by finding the average AvgCompanyRating for each sector (where AvgCompanyRating is the average rating of a company). -->
CREATE OR REPLACE VIEW
Q11_STAT(Code, Sector, AvrN)
AS
	select c.Code, c.Sector, avg(r.Star)
	from Rating r, Category c
	where r.code = c.code
	group by c.code, c.sector
;

CREATE OR REPLACE VIEW
Q11(Sector, AvgRating)
AS
	select s.Sector, avg(s.AvrN)
	from Q11_STAT s
	group by s.Sector
	order by avg(s.AvrN) desc
;

--Q12: Output the person names of the executives that are affiliated with more than one company. 
CREATE OR REPLACE VIEW
Q12(Name)
AS
	select person
	from executive
	group by person
	having count(person) >= 2
;

--Q13: Find all the companies with a registered address in Australia, in a Sector where there are no overseas companies in the same Sector. i.e., they are in a Sector that all companies there have local Australia address. -->
CREATE OR REPLACE VIEW 
Q13_Australia_Sector(Code,Name,Address,Zip) 
AS 
	select c.Code,c.Name,c.Address,c.Zip
	from Company c
	where Country = 'Australia'
;

CREATE OR REPLACE VIEW 
Q13_Not_Australia_Sector(Code) 
AS 
	select Code
	from Company
	where Country != 'Australia'
;

CREATE OR REPLACE VIEW 
Q13_Cnt_Australia_Sector(Sector, Cnt)
AS
	select m1.Sector, count(m1.Code)
	from Category m1, Q13_Australia_Sector m2
	where m1.Code = m2.Code
	group by m1.sector
;


CREATE OR REPLACE VIEW 
Q13_Another(Sector, code)
AS
	select q.sector, c.code
	from Q13_Cnt_Australia_Sector q, Q13_Not_Australia_Sector p,category c
	where q.sector = c.sector and p.code = c.code
;

CREATE OR REPLACE VIEW
Q13_Sector(Sector)
AS
	select Sector
	from Q13_Another
	group by Sector
;

CREATE OR REPLACE VIEW
Q13(Code, Name, Address, Zip, Sector)
AS
	select m.Code, n.Name, n.Address, n.Zip, m.Sector
	from Category m, Q13_Australia_Sector n
	where m.code = n.code 
		and m.sector not in (select * from Q13_Sector)
;


--Q14: Calculate stock gains based on their prices of the first trading day and last trading day (i.e., the oldest "Date" and the most recent "Date" of the records stored in the ASX table). Order your result by Gain in descending order and then by Code in ascending order.-->
CREATE OR REPLACE VIEW
Q14_All_Code(Code)
AS
	select distinct Code
	from ASX
;

CREATE OR REPLACE VIEW
Q14_Price_Date(Code, minPrice, minDate, maxPrice, maxDate, Minus_Change, Cal_Gain)
AS
	with min_date as (
		select distinct min("Date") as minD
		from ASX
	)
	,
	     max_date as (
		select distinct max("Date") as maxD
		from ASX
	)
	select c.Code, 
		xmin.Price, 
		xmin."Date", 
		xmax.Price, 
		xmax."Date", 
		xmax.Price - xmin.Price, 
		((xmax.price - xmin.price)/xmin.price)*100
	from Q14_All_Code c, min_date, ASX xmin ,max_date, ASX xmax
	where xmin."Date" = minD and xmax."Date" = maxD and xmin.Code = c.Code and xmax.Code = c.Code
	group by c.Code, xmin.Price, xmin."Date", xmax.Price ,xmax."Date"
;

CREATE OR REPLACE VIEW
Q14(Code, BeginPrice, EndPrice, Change, Gain)
AS
	select o.Code, o.minPrice, o.maxPrice, o.Minus_Change, o.Cal_Gain
	from Q14_Price_Date o
	order by o.Cal_Gain desc, o.Code
;

--Q15: For all the trading records in the ASX table, produce the following statistics as a database view (where Gain is measured in percentage). AvgDayGain is defined as the summation of all the daily gains (in percentage) then divided by the number of trading days (as noted above, the total number of days here should exclude the first trading day).
CREATE OR REPLACE VIEW 
Q15_Q7_Info(Code,Ming,Avgg,Maxg)
AS
	select a.Code, min(a.gain), avg(a.Gain), max(a.Gain)
	from Q7 a
	group by a.Code
;
CREATE OR REPLACE VIEW
Q15_ASX_Info(Code,Minp,Avgp,Maxp)
AS
	select b.code, min(b.price), avg(b.price), max(b.price)
	from ASX b
	group by b.code
;
CREATE OR REPLACE VIEW
Q15(Code, MinPrice, AvgPrice,MaxPrice, MinDayGain, AvgDayGain, MaxDayGain) 
AS

	select a.code, 
			a.Minp, a.Avgp, a.Maxp,
			b.Ming, b.Avgg, b.Maxg
	from Q15_Q7_Info b,Q15_ASX_Info a
	where b.code = a.code
;

--Q16: Create a trigger on the Executive table, to check and disallow any insert or update of a Person in the Executive table to be an executive of more than one company.

CREATE function Judgement() returns TRIGGER
AS 
$$
declare
	cnt integer;
begin	
	cnt := count(Code) from Executive where Person = new.Person;	
	if (cnt >= 2) 
	then	
		raise exception '%: More than one company', new.Person;
	end if;
	return new;
end;
$$ language plpgsql;

CREATE TRIGGER Q16 after INSERT OR UPDATE ON Executive FOR each ROW
execute procedure Judgement()
;

--Q17: Suppose more stock trading data are incoming into the ASX table. Create a trigger to increase the stock's rating (as Star's) to 5 when the stock has made a maximum daily price gain (when compared with the price on the previous trading day) in percentage within its sector. For example, for a given day and a given sector, if Stock A has the maximum price gain in the sector, its rating should then be updated to 5. If it happens to have more than one stock with the same maximum price gain, update all these stocks' ratings to 5. Otherwise, decrease the stock's rating to 1 when the stock has performed the worst in the sector in terms of daily percentage price gain. If there are more than one record of rating for a given stock that need to be updated, update (not insert) all these records.
CREATE TRIGGER Q17 after INSERT OR UPDATE ON ASX FOR each ROW
execute procedure Q17_Fcn()
;
--Q18: Stock price and trading volume data are usually incoming data and seldom involve updating existing data. However, updates are allowed in order to correct data errors. All such updates (instead of data insertion) are logged and stored in the ASXLog table. Create a trigger to log any updates on Price and/or Voume in the ASX table and log these updates (only for update, not inserts) into the ASXLog table. Here we assume that Date and Code cannot be corrected and will be the same as their original, old values. Timestamp is the date and time that the correction takes place. Note that it is also possible that a record is corrected more than once, i.e., same Date and Code but different Timestamp. 
CREATE TRIGGER Q18 after INSERT OR UPDATE ON ASX FOR each ROW
execute procedure Q18_Fcn()
;
