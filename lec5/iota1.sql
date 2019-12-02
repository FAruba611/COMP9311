create type IntVal as ( val integer );

create or replace function
	iota(_lo int, _hi int, _step int) returns setof IntVal
as $$
declare
	i integer;
	v IntVal;
begin
	i := _lo;
	while (i <= _hi)
	loop
		v.val := i;
		return next v;
		i := i + _step;
	end loop;
	return;
end;
$$ language plpgsql;

create or replace function
	i(int,int) returns setof IntVal
as $$
select * from iota($1,$2,1);
$$ language sql;


create or replace function
	iota(_lo int, _hi int) returns setof IntVal
as $$
declare
	v IntVal;
begin
	for v in select * from iota(_lo, _hi, 1)
	loop
		return next v;
	end loop;
	return;
end;
$$ language plpgsql;

create or replace function
	iota(_hi int) returns setof IntVal
as $$
declare
	v IntVal;
begin
	for v in select * from iota(1, _hi, 1)
	loop
		return next v;
	end loop;
	return;
end;
$$ language plpgsql;
