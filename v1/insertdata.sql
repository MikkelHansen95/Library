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
INSERT INTO libraryschema.book(
	isbn, title, author, publisher, publishyear, type)
	VALUES ('9788712041232', 'Cook book', 'John den store', 'Cooking school', NOW(), 'Paperback');
INSERT INTO libraryschema.book(
	isbn, title, author, publisher, publishyear, type)
	VALUES ('9788732041232', 'Learn to code', 'Kasper ','CPHBUSINESS', NOW(), 'Paperback');
INSERT INTO libraryschema.book(
	isbn, title, author, publisher, publishyear, type)
	VALUES ('9788742041232', 'IoT for beginners', 'Tobias', 'CPHBUSINESS', NOW(), 'Paperback');
/*     CLIENT     */
INSERT INTO libraryschema.client(
	type, name, address, cpr, loancount)
	VALUES (2, 'Mikkel','Gl. køge landevej 148', '100591-1375', 0);
INSERT INTO libraryschema.client(
	type, name, address, cpr, loancount)
	VALUES (2, 'Mathias','Et sted i Hillerød 43', '120971-1891', 0);
INSERT INTO libraryschema.client(
	type, name, address, cpr, loancount)
	VALUES (3, 'John den lokale','Fiskervej 3', '020177-9240', 0);
INSERT INTO libraryschema.client(
	type, name, address, cpr, loancount)
	VALUES (1, 'Arne','Den kloge vej 3', '060265-9240', 0);
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
INSERT INTO libraryschema.bookinstance(
	isbn, location, available)
	VALUES ('9788712041232', null, true);
INSERT INTO libraryschema.bookinstance(
	isbn, location, available)
	VALUES ('9788732041232', null, true);
INSERT INTO libraryschema.bookinstance(
	isbn, location, available)
	VALUES ('9788732041232', null, true);
INSERT INTO libraryschema.bookinstance(
	isbn, location, available)
	VALUES ('9788742041232', null, true);