# Library

### creating appropriate data model  

ER Diagram:  
![ER](./images/ER.png)  

### creating and populating the database with sufficient test data  
    We created only a little bit of test data but it is sufficent to test all the functionality  
    Run the insert.sql script  
### programming the requested functionality in SQL    
#### Bookavailability:  
![bookavailability](/images/bookavailability.PNG)  

#### Popularbook among highschool student:  
![popularbook](/images/popularbook.PNG)  

#### Notice when returning book too late:  

![returnbook](/images/bookreturn.PNG)  

### add constrains reflecting the business rules

    We have made trigger to make sure all functionality happens when a simple call is made.

    We also added contraint in the createtable to make sure data is valid.

### add constrains ensuring referential integrity
    We made foreign keys to reference to the correct objects and not using any varchar references.
### keeping transactions ACID and protected against blocking and deadlocks
    We didn't really do this. But we should have implemented transaction with our triggers to ensure that the action happens. So that a loan cant be inserted if the trigger to update the clients loan count fails.
### considering optimization of the queries
    Alot of our queries have many inner joins which is very performance heavy and slow. But considering the setup it is hard to change it.
###  protecting the use of the database with user account management, and control of privileges.
    We have made different privileges for different user of the system.   
    Users can loan and therefore they can insert and update their loan but not delete it or do anything in the book table at all.

    We also have a user for the librarian who can do anything regarding the books.