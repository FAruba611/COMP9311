create type IntVal as ( val integer );

create or replace function iota(_hi integer) returns setof IntVal
as $$
declare
	i integer;
	v IntVal;
begin
	for i in 1 .. _hi
	loop
		v.val := i;
		return next v;
	end loop;
	return;
end;
$$ language plpgsql;
