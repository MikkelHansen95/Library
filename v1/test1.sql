SET search_path TO libraryschema;

select * from loans;

INSERT INTO loans (instanceid,clientid,startdate)
VALUES (2,2,NOW());

SELECT * FROM loans
INNER JOIN client ON loans.clientid = client.id 
INNER JOIN clienttype ON client.type = clienttype.id
INNER JOIN bookinstance ON loans.instanceid = bookinstance.id;