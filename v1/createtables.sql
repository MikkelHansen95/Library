SET search_path TO libraryschema;
create table book(
    isbn bigint UNIQUE PRIMARY KEY check (isbn > 999999999999 and isbn < 10000000000000),
    title varchar(99),
	author varchar(99),
	publisher varchar(99),
	publishYear date,
	type booktype NOT NULL
);
create table clienttype (
	id serial PRIMARY KEY,
	name varchar(30),
	loanlength int,
	loancapacity int
);
create table client (
    id serial PRIMARY KEY,
	type int REFERENCES clienttype(id),
	name text,
	address varchar(99),
	cpr varchar(11),
	loancount int check (loancount > -1)
);
create table bookinstance(
	id serial PRIMARY KEY NOT NULL, 
	isbn bigint REFERENCES book(isbn),
	location int REFERENCES client(id),
	available boolean
);

create table loans (
	id serial PRIMARY KEY,
	instanceid serial REFERENCES bookinstance(id),
	clientid serial REFERENCES client(id),
	startDate date default NOW(),
	endDate date check (endDate > startDate),
	overdue boolean check (endDate > NOW()) default false, 
	activeLoan boolean default true
);