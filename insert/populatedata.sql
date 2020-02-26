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
/*     BOOK     */
INSERT INTO libraryschema.book(
	isbn, title, author, publisher, publishyear, type)
	VALUES ('9788776011232', '120 Fun Facts', 'Mikkel & Mathias', 'CPHBUSINESS', NOW(), 'Paperback');
INSERT INTO libraryschema.book(
	isbn, title, author, publisher, publishyear, type)
	VALUES ('9788782031232', 'Databases for beginners', 'Mikkel & Mathias', 'CPHBUSINESS', NOW(), 'Paperback');
INSERT INTO libraryschema.book(
	isbn, title, author, publisher, publishyear, type)
	VALUES ('9788782041232', 'Databases for beginners', 'Mikkel & Mathias', 'CPHBUSINESS', NOW(), 'Ebook');
/*     CLIENT     */
INSERT INTO libraryschema.client(
	type, name, address, cpr, loancount)
	VALUES (1, 'Mikkel','Julemandens vej 12', '100591-1375', 0);
INSERT INTO libraryschema.client(
	type, name, address, cpr, loancount)
	VALUES (2, 'Karl','Kaninvej 62', '120971-1891', 0);
INSERT INTO libraryschema.client(
	type, name, address, cpr, loancount)
	VALUES (3, 'John','Fiskervej 3', '020177-9240', 0);
	SELECT * FROM clienttype;
/*        BOOKINSTANCE         */
INSERT INTO libraryschema.bookinstance(
	isbn, location, available)
	VALUES ('9788782031232', null, true);
INSERT INTO libraryschema.bookinstance(
	isbn, location, available)
	VALUES ('9788782041232', null, true);
INSERT INTO libraryschema.bookinstance(
	isbn, location, available)
	VALUES ('9788776011232', null, true);
/*      LOANS     */
INSERT INTO libraryschema.loans(
	instanceid, clientid, startdate, enddate, overdue, activeloan)
	VALUES (3, 2, NOW(), '2020-02-26', false, true);
INSERT INTO libraryschema.loans(
	instanceid, clientid, startdate, enddate, overdue, activeloan)
	VALUES (2, 2, NOW(), '2020-02-26', false, true);
INSERT INTO libraryschema.loans(
	instanceid, clientid, startdate, enddate, overdue, activeloan)
	VALUES (1, 2, NOW(), '2020-02-26', false, true);