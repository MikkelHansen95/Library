CREATE ROLE Librarian;
CREATE ROLE Customer;
CREATE ROLE Visitor;

CREATE USER Librarian1 LOGIN PASSWORD 'ostemad78';
CREATE USER Customer1 LOGIN PASSWORD 'rejemad78';
CREATE USER Visitor1 LOGIN PASSWORD 'laksemad78';

GRANT CONNECT ON DATABASE "Library" TO Librarian;
GRANT CONNECT ON DATABASE "Library" TO Customer;
GRANT CONNECT ON DATABASE "Library" TO Visitor;

GRANT USAGE ON SCHEMA "libraryschema" TO Librarian;
GRANT USAGE ON SCHEMA "libraryschema" TO Customer;
GRANT USAGE ON SCHEMA "libraryschema" TO Visitor;

GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA "libraryschema" TO Librarian;
GRANT SELECT ON TABLE book TO Visitor;
GRANT SELECT ON TABLE book,bookinstance,loans TO Customer;

GRANT UPDATE ON TABLE bookinstance TO Customer;
GRANT INSERT,UPDATE ON TABLE loans TO Customer;
GRANT UPDATE ON TABLE client TO Customer;

GRANT Customer TO Customer1;
GRANT Librarian TO Librarian1;
GRANT Visitor TO Visitor1;