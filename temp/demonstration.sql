SET search_path TO libraryschema;

SELECT * FROM bookavailability(9781111111117);

SELECT * FROM bookinstance;

SELECT * FROM popularstudentbook('2020-02-27','2020-03-15');

SELECT * FROM loans;

/* view returnbook */

SELECT * FROM bookinstance;

INSERT INTO loans (instanceid, clientid)
VALUES (9,3)


SELECT * FROM loans
	INNER JOIN client ON loans.clientid = client.id 
	INNER JOIN clienttype ON client.type = clienttype.id
	INNER JOIN bookinstance ON loans.instanceid = bookinstance.id