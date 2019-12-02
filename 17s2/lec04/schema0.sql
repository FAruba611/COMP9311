create table R (
	id integer primary key,
	s char(1) references S(id)
);

create table S (
	id char(1) primary key,
	r integer references R(id)
);
