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

CREATE OR REPLACE FUNCTION createenddate() RETURNS TRIGGER as $$
 DECLARE
 	tempval integer;
	loanid integer := NEW.id;
 BEGIN
 	SELECT getclientloansize(loanid) INTO tempval;
	IF (tempval > 0) THEN
		UPDATE loans SET enddate = NEW.startdate + tempVal WHERE id = loanid;
		UPDATE client SET
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

CREATE OR REPLACE FUNCTION updateusernadbookinstance() RETURNS TRIGGER as $$
 DECLARE
	loanid integer := NEW.id;
	loanc int;
	cid int;
	loancap int;
	loansbookid int;
 BEGIN
 	SELECT client.loancount, clienttype.loancapacity, loans.instanceid, client.id into loanc,loancap,loansbookid,cid FROM loans
	  INNER JOIN client ON loans.clientid = client.id 
	  INNER JOIN clienttype ON client.type = clienttype.id
	  INNER JOIN bookinstance ON loans.instanceid = bookinstance.id
	  WHERE loans.id = loanid;
	
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

 SELECT * FROM loans
	  INNER JOIN client ON loans.clientid = client.id 
	  INNER JOIN clienttype ON client.type = clienttype.id 
	  INNER JOIN bookinstance ON loans.instanceid = bookinstance.id
	  WHERE loans.id = 78;
	  
INSERT INTO loans(instanceid,clientid,startdate)
VALUES (2,2,NOW());

SELECT * FROM clienttype;

SELECT * FROM loans
INNER JOIN client ON loans.clientid = client.id 
INNER JOIN clienttype ON client.type = clienttype.id
INNER JOIN bookinstance ON loans.instanceid = bookinstance.id
WHERE loans.id = 83;

CREATE OR REPLACE FUNCTION returnbook() RETURNS TRIGGER as $$
 DECLARE
	loanid integer := NEW.id;
	loanc int;
	cid int;
	loansbookid int;
	lenddate date;
	aloan boolean;
 BEGIN
 	SELECT client.loancount, loans.instanceid, client.id, loans.enddate,loans.activeloan into loanc,loansbookid,cid,lenddate,aloan FROM loans
	  INNER JOIN client ON loans.clientid = client.id 
	  INNER JOIN clienttype ON client.type = clienttype.id
	  INNER JOIN bookinstance ON loans.instanceid = bookinstance.id
	  WHERE loans.id = loanid;
	IF (loanc > 0) THEN
		UPDATE client SET loancount = loancount - 1 WHERE id = cid;
		UPDATE bookinstance SET available = true, location = null WHERE id = loansbookid;
	ELSE
		RAISE EXCEPTION 'YOU DONT HAVE ANY LOANS';
	END IF;
	IF lenddate < NOW() THEN
		RAISE NOTICE 'YOU HAVE RETURNED THE BOOK TOO LATE';
	END IF;
	IF aloan = true THEN
		UPDATE loans SET activeloan = false WHERE id = loanid; 
	END IF;
   RETURN NEW;
 END;
$$ LANGUAGE plpgsql;

SET search_path TO libraryschema;

CREATE TRIGGER bookreturn
AFTER UPDATE ON loans
FOR EACH ROW
EXECUTE PROCEDURE returnbook();






