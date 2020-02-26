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



