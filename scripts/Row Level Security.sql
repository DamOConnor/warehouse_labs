/*
RLS LAB STEPS:
*/

/* Authenticate to the DW with your user, either using SSMS or the Fabric UI in the browser window.
In the script replace the following users:
-  "user01@MngEnv12345678.onmicrosoft.com" with your user
-  "user02@MngEnv12345678.onmicrosoft.com" with the user retrieved in task 1 following the Word doc.
*/

/* 1) Run the following query to create a Sales table: */

CREATE TABLE Sales  
    (  
    OrderID int,  
    SalesRep varchar(50),   
    Product varchar(10),  
    Qty int  
    );

/* 2) Run the following query to insert some records: */

INSERT INTO Sales VALUES (1, 'user01@MngEnv12345678.onmicrosoft.com', 'Valve', 5);
INSERT INTO Sales VALUES (2, 'user01@MngEnv12345678.onmicrosoft.com', 'Wheel', 2);
INSERT INTO Sales VALUES (3, 'user02@MngEnv12345678.onmicrosoft.com', 'Valve', 4);
INSERT INTO Sales VALUES (4, 'user02@MngEnv12345678.onmicrosoft.com', 'Bracket', 2);
INSERT INTO Sales VALUES (5, 'user02@MngEnv12345678.onmicrosoft.com', 'Wheel', 5);
INSERT INTO Sales VALUES (6, 'user01@MngEnv12345678.onmicrosoft.com', 'Seat', 5);

-- View the 6 rows in the table  
SELECT * FROM Sales;


/* 3) Run the following query to grant SELECT on table for each of the users.
The ReadData permission from the prerequistes only gives the user CONNECT permissions. You must explicitly use GRANT SELECT to query the Sales table
*/

GRANT SELECT ON Sales TO [user02@MngEnv12345678.onmicrosoft.com];  


/* 4) Run the following query to create the security function. 
The function returns 1 when a row in the SalesRep column is the same as the user executing the query 
(@SalesRep = USER_NAME()) 
or if the user executing the query is the Manager user (USER_NAME() = 'user01@MngEnv12345678.onmicrosoft.com'): */

CREATE SCHEMA Security;  
GO  
  
CREATE FUNCTION Security.tvf_securitypredicate(@SalesRep AS nvarchar(50))
    RETURNS TABLE
WITH SCHEMABINDING
AS
    RETURN SELECT 1 AS tvf_securitypredicate_result
WHERE @SalesRep = USER_NAME() OR USER_NAME() = 'user01@MngEnv12345678.onmicrosoft.com';
GO


/* 5) Run the following query to create a security policy adding the function as a filter predicate: */

CREATE SECURITY POLICY SalesFilter
ADD FILTER PREDICATE Security.tvf_securitypredicate(SalesRep)
ON dbo.Sales
WITH (STATE = ON);
GO

/* 6) Allow SELECT permissions to the [tvf_securitypredicate] function to the test user*/
 
GRANT SELECT ON [Security].[tvf_securitypredicate] TO [user02@MngEnv12345678.onmicrosoft.com];  


/* 7) In SSMS open a new Query Window and connect to the DW using your test user (created in the prerequisites).
Or if using the browser, go to fabric.microsoft.com and log in using the test user.
Paste the following query on the new connection and run the code.

After running the query, come back to this query window.
*/

SELECT * FROM Sales;

/* You will see only 3 rows:

OrderID	SalesRep	Product	Qty
5	user02@MngEnv12345678.onmicrosoft.com	Wheel	5
4	user02@MngEnv12345678.onmicrosoft.com	Bracket	2
3	user02@MngEnv12345678.onmicrosoft.com	Valve	4
*/


/* 8) Disable the policy and re-run SELECT query. 
Ensure you are running the query while connected as admin.
*/

ALTER SECURITY POLICY SalesFilter  
WITH (STATE = OFF);

/* 9) Go to the query window where you are connected with the test user and run the follwing query.
You will see all the rows */
SELECT * FROM Sales;

/* 10) Cleanup objects. */

DROP SECURITY POLICY SalesFilter;
DROP TABLE Sales;
DROP FUNCTION Security.tvf_securitypredicate;
DROP SCHEMA Security;


