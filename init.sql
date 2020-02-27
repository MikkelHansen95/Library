/* SET searchpath to schema */
SET search_path TO libraryschema;
/* CREATE TYPES */
CREATE TYPE booktype as ENUM('Paperback','Ebook');
/* CREATE TABLES */
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
/* USERS + ROLE IN DB */
CREATE ROLE Librarian;
CREATE ROLE Customer;
CREATE ROLE Visitor;

CREATE USER Librarian1 LOGIN PASSWORD 'ostemad78';
CREATE USER Customer1 LOGIN PASSWORD 'rejemad78';
CREATE USER Visitor1 LOGIN PASSWORD 'laksemad78';

GRANT CONNECT ON DATABASE "Library" TO Librarian;
GRANT CONNECT ON DATABASE "Library" TO Customer;
GRANT CONNECT ON DATABASE "Library" TO Visitor;

GRANT USAGE ON SCHEMA "Library" TO Librarian;
GRANT USAGE ON SCHEMA "Library" TO Customer;
GRANT USAGE ON SCHEMA "Library" TO Visitor;

GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA "Library" TO Librarian;
GRANT SELECT ON TABLE book TO Visitor;
GRANT SELECT ON TABLE book,bookinstance,loans TO Customer;

GRANT UPDATE ON TABLE bookinstance TO Customer;
GRANT INSERT,UPDATE ON TABLE loans TO Customer;
GRANT UPDATE ON TABLE client TO Customer;

GRANT Customer TO Customer1;
GRANT Librarian TO Librarian1;
GRANT Visitor TO Visitor1;
/* BOOK */
INSERT INTO book (isbn,title,author,publisher,publishyear,type)
VALUES (9781111111111,'Book 1', 'Karen','GYLDENDAL',NOW(),'Paperback');
INSERT INTO book (isbn,title,author,publisher,publishyear,type)
VALUES (9781111111112,'Book 2', 'Karen','GYLDENDAL',NOW(),'Paperback');
INSERT INTO book (isbn,title,author,publisher,publishyear,type)
VALUES (9781111111113,'Book 3', 'Karen','GYLDENDAL',NOW(),'Paperback');
INSERT INTO book (isbn,title,author,publisher,publishyear,type)
VALUES (9781111111114,'Book 4', 'Karen','GYLDENDAL',NOW(),'Paperback');
INSERT INTO book (isbn,title,author,publisher,publishyear,type)
VALUES (9781111111115,'Book 5', 'Karen','GYLDENDAL',NOW(),'Paperback');
INSERT INTO book (isbn,title,author,publisher,publishyear,type)
VALUES (9781111111116,'Book 6', 'Karen','GYLDENDAL',NOW(),'Paperback');
INSERT INTO book (isbn,title,author,publisher,publishyear,type)
VALUES (9781111111117,'Book 7', 'Karen','GYLDENDAL',NOW(),'Paperback');
INSERT INTO book(isbn, title, author, publisher, publishyear, type)
VALUES ('9788776011232', '120 Fun Facts', 'Mikkel & Mathias', 'CPHBUSINESS', NOW(), 'Paperback');
INSERT INTO book(isbn, title, author, publisher, publishyear, type)
VALUES ('9788782031232', 'Databases for beginners', 'Mikkel & Mathias', 'CPHBUSINESS', NOW(), 'Paperback');
INSERT INTO book(isbn, title, author, publisher, publishyear, type)
VALUES ('9788782041232', 'Databases for beginners', 'Mikkel & Mathias', 'CPHBUSINESS', NOW(), 'Ebook');

/*     CLIENTTYPE     */
INSERT INTO libraryschema.clienttype(
	name, loanlength, loancapacity)
	VALUES ('Teacher', 21, 5);	
INSERT INTO libraryschema.clienttype(
	name, loanlength, loancapacity)
	VALUES ('Student', 28, 3);	
INSERT INTO libraryschema.clienttype(
	name, loanlength, loancapacity)
	VALUES ('Basic', 14, 2);

/*     CLIENT     */
INSERT INTO libraryschema.client(type, name, address, cpr, loancount)
VALUES (1, 'Mikkel','Julemandens vej 12', '100591-1375', 0);
INSERT INTO libraryschema.client(type, name, address, cpr, loancount)
VALUES (2, 'Karl','Kaninvej 62', '120971-1891', 0);
INSERT INTO libraryschema.client(type, name, address, cpr, loancount)
VALUES (3, 'John','Fiskervej 3', '020177-9240', 0);
/*        BOOKINSTANCE         */
INSERT INTO bookinstance(isbn, available)
VALUES ('9788782031232', true);
INSERT INTO bookinstance(isbn, location, available)
VALUES ('9788782041232',  true);
INSERT INTO bookinstance(isbn, location, available)
VALUES ('9788776011232', true);
INSERT INTO bookinstance (isbn,location,available)
VALUES (9781111111111,true);
INSERT INTO bookinstance (isbn,location,available)
VALUES (9781111111112,true);
INSERT INTO bookinstance (isbn,location,available)
VALUES (9781111111113,true);
INSERT INTO bookinstance (isbn,location,available)
VALUES (9781111111114,true);
INSERT INTO bookinstance (isbn,location,available)
VALUES (9781111111115,true);
INSERT INTO bookinstance (isbn,location,available)
VALUES (9781111111116,true);
INSERT INTO bookinstance (isbn,location,available)
VALUES (9781111111117,true);
/* FUNCTIONS */
CREATE FUNCTION popularstudentbook (date, date)
 RETURNS TABLE( title varchar, amount bigint ) as
$BODY$
BEGIN
   RETURN QUERY SELECT book.title, COUNT(book.title) as popular FROM loans
   INNER JOIN bookinstance ON loans.instanceid = bookinstance.id
   INNER JOIN book ON bookinstance.isbn = book.isbn
   INNER JOIN client ON loans.clientid = client.id
   INNER JOIN clienttype ON client.type = clienttype.id
   WHERE clienttype.name = 'Student'
   AND loans.startDate between $1 and $2
   GROUP BY 1
   ORDER BY popular DESC LIMIT 1;
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION getclientloansize(loanid int) RETURNS integer as $$
	DECLARE
	 singleresult integer;
	BEGIN
	 SELECT clienttype.loanlength into singleresult FROM loans
	  INNER JOIN client ON loans.clientid = client.id 
	  INNER JOIN clienttype ON client.type = clienttype.id 
	  WHERE loans.id = loanid;
	  RETURN singleresult;
	END; 
$$ LANGUAGE plpgsql;

/* TRIGGER FUNCS */

CREATE OR REPLACE FUNCTION updateusernadbookinstance() RETURNS TRIGGER as $$
 DECLARE
	loanid integer := NEW.id;
	loanc int;
	cid int;
	loancap int;
	loansbookid int;
	bookinstavailable boolean;
 BEGIN
 	SELECT client.loancount, clienttype.loancapacity, loans.instanceid, client.id, bookinstance.available into loanc,loancap,loansbookid,cid,bookinstavailable FROM loans
	  INNER JOIN client ON loans.clientid = client.id 
	  INNER JOIN clienttype ON client.type = clienttype.id
	  INNER JOIN bookinstance ON loans.instanceid = bookinstance.id
	  WHERE loans.id = loanid;
	
	IF bookinstavailable = false THEN
		RAISE EXCEPTION 'BOOK IS ALREADY ON LOAN';
	END IF;
	IF loanc < loancap THEN
		UPDATE client SET loancount = loancount + 1 WHERE id = cid;
		UPDATE bookinstance SET available = false, location = cid WHERE id = loansbookid;
	ELSE
		RAISE EXCEPTION 'YOU HAVE TOO MANY BOOKS ON LOAN, YOU NEED TO RETURN ONE BEFORE YOU CAN BORROW AGAIN';
	END IF;
   RETURN NEW;
 END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER updatebookandclienttrigger
AFTER INSERT ON loans
FOR EACH ROW
EXECUTE PROCEDURE updateusernadbookinstance();

CREATE OR REPLACE FUNCTION createenddate() RETURNS TRIGGER as $$
 DECLARE
 	tempval integer;
	loanid integer := NEW.id;
 BEGIN
 	SELECT getclientloansize(loanid) INTO tempval;
	IF (tempval > 0) THEN
		UPDATE loans SET enddate = NEW.startdate + tempVal WHERE id = loanid;
	ELSE
		RAISE EXCEPTION 'DOES NOT WORK val: %  --- id:  %', tempval,NEW.id;
	END IF;
   RETURN NEW;
 END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER enddatecreation
AFTER INSERT ON loans
FOR EACH ROW
EXECUTE PROCEDURE createenddate();
