SET search_path TO libraryschema;

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
   AND loans.startDate >= $1
   AND loans.endDate <= $2
   GROUP BY 1
   ORDER BY popular DESC LIMIT 1;
END;
$BODY$
LANGUAGE plpgsql;

SELECT * FROM popularstudentbook('2020-02-26','2020-02-29');


