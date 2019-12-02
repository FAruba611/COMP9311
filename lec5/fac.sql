create or replace function
	fac(n integer) returns integer
as $$
declare
	i integer;
	f integer := 1;
begin
	if (n < 1) then
		raise exception 'Invalid fac(%)',n;
	end if;
	i := 1;
	while (i <= n) loop
		f := f * i;
		i := i + 1;
	end loop;
	return f;
end;
$$ language plpgsql;
