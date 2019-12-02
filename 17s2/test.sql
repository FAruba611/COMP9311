CREATE TABLE test (
	id integer,
	r  text,
	tmp serial,
	foreign key(tmp) references a,
	primary key(r)
);