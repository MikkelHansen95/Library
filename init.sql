/* SET searchpath to schema */
CREATE SCHEMA libraryschema;
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
	cpr varchar(11)
);
create table bookinstance(
	id serial PRIMARY KEY NOT NULL, 
	isbn bigint REFERENCES book(isbn),
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
/* USERS AND ROLES */
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

CREATE OR REPLACE FUNCTION getclientactiveloans(_clientid int) RETURNS integer as $$
	DECLARE
	 singleresult integer;
	BEGIN
	 SELECT count(*) into singleresult FROM loans
	  WHERE clientid = _clientid and activeloan = true;
	  RETURN singleresult;
	END; 
$$ LANGUAGE plpgsql;

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

CREATE OR REPLACE FUNCTION getclientloanlength(_clientid int) RETURNS integer as $$
	DECLARE
	 singleresult integer;
	BEGIN
	 SELECT clienttype.loanlength into singleresult FROM client
	  INNER JOIN clienttype ON client.type = clienttype.id 
	  WHERE client.id = _clientid;
	  RETURN singleresult;
	END; 
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION getbookavailability(_loanid int) RETURNS boolean as $$
	DECLARE
	 singleresult boolean;
	BEGIN
		SELECT bookinstance.available into singleresult FROM loans
	  		INNER JOIN bookinstance ON loans.instanceid = bookinstance.id 
	  		WHERE loans.id = _loanid;
	  	RETURN singleresult;
	END; 
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION getloanidfrombookandclient(_bookinstanceid int, _clientid int) RETURNS integer as $$
	DECLARE
	 singleresult integer;
	BEGIN
		SELECT loans.id into singleresult FROM loans
			INNER JOIN bookinstance ON loans.instanceid = bookinstance.id
			WHERE activeloan = true and bookinstance.id = _bookinstanceid;
	  	RETURN singleresult;
	END; 
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION getloanenddate(_loanid int) RETURNS date as $$
	DECLARE
	 singleresult date;
	BEGIN
		SELECT enddate into singleresult FROM loans WHERE id = _loanid;
	  	RETURN singleresult;
	END; 
$$ LANGUAGE plpgsql;



/* TRIGGER FUNCS */
CREATE OR REPLACE FUNCTION updateusernadbookinstance() RETURNS TRIGGER as $$
 DECLARE
	loanid integer := NEW.id;
	loanc int;
	cid int := NEW.clientid;
	loancap int;
	bookinstanceid int := NEW.instanceid;
	bookavailable boolean;
	loanlength int;
 BEGIN
 	loanc := getclientactiveloans(cid);
 	loancap := getclientloansize(loanid);
	loanlength := getclientloanlength(cid);
	bookavailable := getbookavailability(loanid);
	
	IF bookavailable = false THEN
		RAISE EXCEPTION 'BOOK IS ALREADY ON LOAN';
	END IF;
	
	IF loanc < loancap THEN
		UPDATE bookinstance SET available = false WHERE id = bookinstanceid;
		UPDATE loans SET enddate = NEW.startdate + loanlength WHERE id = loanid;
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

/* PROCEDURES */ 
CREATE PROCEDURE insert_loan(bookinstance_id integer, client_id integer) LANGUAGE plpgsql AS $$
	BEGIN
		INSERT INTO loans (instanceid,clientid) VALUES (bookinstance_id,client_id);
	END;
$$;

CREATE PROCEDURE return_loan(_bookinstanceid integer,_clientid integer) LANGUAGE plpgsql AS $$
	 DECLARE
	 	loanid int;
		loanenddate date;
	 BEGIN
	 	loanid := getloanidfrombookandclient(_bookinstanceid,_clientid);
		loanenddate := getloanenddate(loanid);
		IF loanid IS NULL THEN
			RAISE EXCEPTION 'BOOK ALREADY RETURNED';
		END IF;
		
	 	UPDATE loans SET activeloan = false where id = loanid;
		UPDATE bookinstance SET available = true where id = _bookinstanceid;
		
		IF loanenddate < NOW() THEN
			RAISE NOTICE 'YOU HAVE RETURNED THE BOOK AFTER DEADLINE, YOU WILL GET A FINE';
			UPDATE loans SET overdue = true WHERE id = loanid;
		END IF;
	 END;
$$;

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
INSERT INTO clienttype(name, loanlength, loancapacity)
VALUES ('Teacher', 21, 5);	
INSERT INTO clienttype(name, loanlength, loancapacity)
VALUES ('Student', 28, 3);	
INSERT INTO clienttype(name, loanlength, loancapacity)
VALUES ('Basic', 14, 2);

/*     CLIENT     */
INSERT INTO client(type, name, address, cpr)
VALUES (1, 'Mikkel','Julemandens vej 12', '100591-1375');
INSERT INTO client(type, name, address, cpr)
VALUES (2, 'Karl','Kaninvej 62', '120971-1891');
INSERT INTO client(type, name, address, cpr)
VALUES (3, 'John','Fiskervej 3', '020177-9240');
/*        BOOKINSTANCE         */
INSERT INTO bookinstance(isbn, available)
VALUES ('9788782031232', true);
INSERT INTO bookinstance(isbn,  available)
VALUES ('9788782041232',  true);
INSERT INTO bookinstance(isbn,  available)
VALUES ('9788776011232', true);
INSERT INTO bookinstance (isbn,available)
VALUES (9781111111111,true);
INSERT INTO bookinstance (isbn,available)
VALUES (9781111111112,true);
INSERT INTO bookinstance (isbn,available)
VALUES (9781111111113,true);
INSERT INTO bookinstance (isbn,available)
VALUES (9781111111114,true);
INSERT INTO bookinstance (isbn,available)
VALUES (9781111111115,true);
INSERT INTO bookinstance (isbn,available)
VALUES (9781111111116,true);
INSERT INTO bookinstance (isbn,available)
VALUES (9781111111117,true);

/* INSERT WITH PROCEDURES */
CALL insert_loan(7,2);
CALL insert_loan(6,2);
CALL insert_loan(5,2);
CALL insert_loan(4,2);
CALL insert_loan(3,2);

/* return procedure */
CALL return_loan(5,2);


