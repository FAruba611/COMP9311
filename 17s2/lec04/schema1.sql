create table R (
	id integer primary key,
	s char(1)
);

create table S (
	id char(1) primary key,
	r integer references R(id)
);

alter table R add foreign key (s) references S(id);
