create table Branch (
	branchName  text,
	address     text,
	assets      integer,
	primary key (branchName)
);

create table Account (
	accountNo   text,
	branchName  text,
	balance     integer,
	primary key (accountNo),
	foreign key (branchName) references Branch(branchName)
);

create table Customer (
	customerNo  integer,
	name        text,
	address     text,
	homeBranch  text,
	primary key (customerNo),
	foreign key (homeBranch) references Branch(branchName)
);

create table HeldBy (
	account     text,
	customer    integer,
	primary key (account,customer),
	foreign key (account) references Account(accountNo),
	foreign key (customer) references Customer(customerNo)
);
