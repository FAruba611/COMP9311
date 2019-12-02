-- lab4

-- Q1: how many page accesses on March 2?
CREATE OR REPLACE VIEW Q1(nacc)
AS
	select count(*)
	from Accesses a
	where a.acctime >= '2005-03-02 00:00:00' 
	  and a.acctime <= '2005-03-02 23:59:59'
;

-- Q2: How many times was the main WebCMS MessageBoard 
-- search facility used? You can recognise this by the fact 
-- that the page contains messageboard 
-- and the parameters string contains state=search. 
CREATE OR REPLACE VIEW Q2(nsearches)
AS
	select count(*)
	from Accesses a
	where a.page ~ '^messageboard'
	  and a.params ~ 'state=search'
;

-- Q3:
CREATE OR REPLACE VIEW Q3(hostname)
AS
	select distinct h.hostname
	from Sessions s, hosts h
	where h.hostname ~ 'tuba' and s.host = h.id and s.complete = 'f'
	order by h.hostname
;

-- Q4:
CREATE OR REPLACE VIEW Q4(min, avg, max)
AS
	--select min(m.nbytes), avg(m.nbytes)::numeric(2,1), max(m.nbytes)
	select min(m.nbytes), avg(m.nbytes)::integer, max(m.nbytes)
	from Accesses m
;

-- Q5:
CREATE OR REPLACE VIEW Q5(nhosts)
AS
	with CSEHosts as (
		select id as "iid"
		from Hosts
		where hostname ~ 'cse.unsw.edu.au$'
	)
	select count(*)
	from Sessions s, CSEHosts c
	where s.host = c.iid
;

--Q6:
/* -- method 1
CREATE OR REPLACE VIEW Q6(nhosts)
AS
	with CSEHosts as (
		select id as "iid"
		from Hosts
		where hostname !~ 'cse.unsw.edu.au$'
	)
	
	select count(*)
	from Sessions s, CSEHosts c
	where s.host = c.iid
;
*/
CREATE OR REPLACE VIEW Q6(nhosts)
AS
	with CSEHosts as (
		select count(h.id)
		from Hosts h, Sessions s
		where h.hostname ~ 'cse.unsw.edu.au$' and h.id = s.host
	)
	,
		ALLHosts as (
		select count(h.id)
		from Hosts h, Sessions s
		where h.hostname ~ '.' and h.id = s.host
	)
	select (count(a0) - count(c0))
	from ALLHosts a0, CSEHosts c0
	--from   Sessions s, CSEHosts c
	--where  s.host = c.cse_id
;

CREATE OR REPLACE VIEW Q7(session,length)
AS
	with tmp_session as (
		select session, count(*) as length
		from   Accesses
		group by session
	)
	select t.session, t.length
	from tmp_session t
	where t.length = (select max(length) from tmp_session)
;

CREATE OR REPLACE VIEW Q8(page, freq)
AS
	select page, count(page)
	from   Accesses
	group by page
	order by count(page) desc
;

CREATE OR REPLACE VIEW Q9(module, freq)
AS
	
;