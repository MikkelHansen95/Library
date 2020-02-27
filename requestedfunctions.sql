CREATE OR REPLACE FUNCTION bookavailability(isbnpara bigint) RETURNS integer as $$
	DECLARE
	 singleresult integer; 
	BEGIN
     SELECT COUNT(*) into singleresult FROM BOOKINSTANCE WHERE ISBN = $1 and available = true;
	RETURN singleresult;
	END;
	$$ LANGUAGE plpgsql;
	
CREATE FUNCTION popularstudentbook (date, date)
 RETURNS TABLE( title varchar, amount bigint ) as $BODY$
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