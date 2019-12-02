-- COMP9311 17s2 Assignment 1
-- Schema for OzCars
--
-- Date: 2017/8/19
-- Student Name:Changfeng Li 
-- Student ID: z5137858
--

-- Some useful domains; you can define more if needed.

create domain URLType as
	varchar(100) check (value like 'http://%');

create domain EmailType as
	varchar(100) check (value like '%@%.%');

create domain PhoneType as
	char(10) check (value ~ '[0-9]{10}');

create domain TFNType as
	char(9) check (value ~ '[0-9]{9}');
	
create domain ABNType as
	char(11) check (value ~ '[0-9]{11}');

-- EMPLOYEE

create table Employee (
	EID          serial not null,
    firstname    varchar(50) not null,
    lastname     varchar(50) not null,
    TFN          TFNType not null,      
    salary       integer not null check (salary > 0),
	primary key (EID)
);

create table Mechanic (
	EID          serial references Employee(EID),
    license      char(8) not null,
	primary key (EID)
);

create table Salesman (
	EID          serial references Employee(EID),
    commRate     integer not null check (between 5 && 20),
	primary key (EID)
);

create table Admin (
	EID          serial references Employee(EID),
	primary key (EID)
);

-- CLIENT

create table Client (
	CID          serial,
	phone        PhoneType,
    address      varchar[200],
    name         varchar[100],
    email        EmailType,
	primary key (CID)
);

create table Company (
	CID          serial references Client(CID),
	ABN          ABNType,
	url          URLType,
	primary key (CID)
);

-- CAR

create domain CarLicenseType as
        varchar(6) check (value ~ '[0-9A-Za-z]{1,6}');

create domain OptionType as varchar(12)
	check (value in ('sunroof','moonroof','GPS','alloy wheels','leather'));

create domain VINType as char(17)
	check (value ~ '[0-9A-HJ-NPR-Za-z]{17}');

create table Car (
    VIN          VINType,
    year       integer check (between 1970 && 2099),  
    model        varchar[40],
    manufacturer varchar[40],
	primary key (VIN)
);

create table CarOptions (
	car          VINType references Car(VIN),
	options      OptionType,
	primary key (car,options)
);

create table NewCar (
	VIN          VINType references Car(VIN),
	cost         integer check (between 10 && 999999),
	charges      integer check (between 10 && 999999),
    primary key (VIN)   
);

create table UsedCar (
	VIN          VINType references Car(VIN),
	plateNumber  CarLicenseType,
	primary key (VIN)
);

create table RepairJob ( 
	description  varchar[250],
	number       integer check (between 1 && 999),
	work         integer check (between 10 && 999999),
	parts        integer check (between 10 && 999999),
	date         date,
	-- RepairJob is a week Entity and repairs UsedCar
	usedcar      VINType,
	-- PaidBy
	PaidBy       serial not null references Client(CID),
	primary key (number,usedcar),
	foreign key (usedCar) references UsedCar(VIN)
);

--relationship
--seek Buys as a 3ary relationship
create table Buys (
	price        integer check (between 10 && 999999),
	date         date,
	commission   integer check (between 10 && 999999),
	--value      ???
	client       serial references Client(CID),
	usedcar      serial references UsedCar(VIN),
	salesman     serial references Salesman(SID),
	primary key (usedcar,salesman)
	
);

--seek Sells as a 3ary relationship
create table Sells (
	date         date,
	price        integer check (between 10 && 999999),
	commission   integer check (between 10 && 999999),
	--value      ???
	client       serial references Client(CID),
	usedcar      serial references UsedCar(VIN),
	salesman     serial references Salesman(SID),
	primary key (usedcar,client)
);
--seek SellsNew as a 3ary relationship
create table SellsNew (
	date         date,
	price        integer check (between 10 && 999999),
	commission   integer check (between 10 && 999999),
	plateNumber  CarLicenseType,
	--
	client       serial references Client(CID),
	newcar       serial references NewCar(VIN),
	salesman     serial references Salesman(SID),
	primary key (newcar,client)
);

create table Does (
	repairjob    integer check (between 1 && 999) references RepairJob(number),
	mechanic     serial references Mechanic(EID),
	primary key (repairjob,mechanic)
);
