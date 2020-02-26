SET search_path TO libraryschema

/* CREATE TYPE booktype as ENUM('Paperback','Ebook');*/

Drop table book CASCADE;
Drop table client CASCADE;
Drop table loans CASCADE;
Drop table clienttype CASCADE;
Drop table bookinstance CASCADE;

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
	loancount int
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
	startDate date,
	endDate date check (endDate > startDate),
	overdue boolean check (endDate > NOW()), 
	activeLoan boolean
);