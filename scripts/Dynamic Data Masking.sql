/*
DDM LAB STEPS:
*/

/* Authenticate to the DW with your user, either using SSMS or the Fabric UI in the browser window.
In the script replace the following user:
-  "user02@MngEnv12345678.onmicrosoft.com" with the user retrieved in task 1 following the Word doc.
*/

/* 1) Connect to the Fabric DW using your user and query all the Masked Columns.
There are no masked columns, but you can re-run this query later on. */
SELECT 
	c.name, tbl.name as table_name, c.is_masked, c.masking_function
FROM 
	sys.masked_columns AS c
	JOIN sys.tables AS tbl 
		ON c.[object_id] = tbl.[object_id]
WHERE 
	is_masked = 1;

/* 2) Create a test table. Note that the EMAIL and USERPWD fields are MASKED: */
CREATE TABLE dbo.DDMExample 
(UserID	INT,
Firstname VARCHAR(40), 
Lastname VARCHAR(40), 
Username VARCHAR(40), 
UserLoginID bigint MASKED WITH (FUNCTION = 'random(50000, 75000)'), 
Email VARCHAR(50) MASKED WITH (FUNCTION = 'email()'), -- OXXX@XXXX.com
UserPwd VARCHAR(50) MASKED WITH (FUNCTION = 'default()'));  --XXXX
GO

/* 3) Insert test data: */
INSERT INTO dbo.DDMExample (UserID, Firstname, Lastname, Username, UserLoginID, Email, UserPwd) 
VALUES (1, 'John','Smith','JSmith', 372036854775808, 'johnsmith@gmail.com','123456ABCDE');
 
INSERT INTO dbo.DDMExample (UserID, Firstname, Lastname, Username, UserLoginID, Email, UserPwd) 
VALUES (2, 'Jane','Doe','JDoe', 372032254855106, 'janedoe@gmail.com','112233ZYXWV');
 
INSERT INTO dbo.DDMExample (UserID, Firstname, Lastname, Username, UserLoginID, Email, UserPwd) 
VALUES (3, 'Walt','Disney','WDisney', 372031114679991, 'waltdisney@gmail.com','998877AZBYC'); 

/* 4) Select the data */
SELECT * FROM dbo.DDMExample

/* 5) Assign permissions on the table to the test user */
GRANT SELECT ON dbo.DDMExample TO [user02@MngEnv12345678.onmicrosoft.com]; 
GO  

/* 6) Open a new Query Window and connect to the DW using your test user. Or, use the Fabric UI in the browser and connect with the test user.
Paste the next 2 queries (query 1 and query 2) in the new query window and run the code.
After running the 2 queries, come back to this query window.
*/
-- query 1: select the data
SELECT * FROM dbo.DDMExample ;

-- query 2: can the user INFER any data from it?
SELECT *
FROM 
	DDMExample
WHERE
	Email LIKE 'j%'

/* 7) Ensure you are running the query while connected as your user. 
Remove masking on the email column. */
ALTER TABLE dbo.DDMExample ALTER COLUMN [Email] DROP MASKED

/* 8) Switch to the query window where you are connected as the test user.
Run the select against after masking has been removed from email and know you will be able to see complete email address.
After running the query, come back to this query window.
*/
SELECT * FROM dbo.DDMExample ;   

/* 9) Admin and users with UNMASK priviledge can see the data.
Now, you will GRANT UNMASK to the test user.
Ensure you are running the query while connected as your user. */
GRANT UNMASK TO [user02@MngEnv12345678.onmicrosoft.com];

/* 10) Switch to the query window where you are connected as the test user.
After running the query, come back to this query window. */
SELECT * FROM DDMExample;

/* 11) Removing the UNMASK permission
Ensure you are running the query while connected as your user. */
REVOKE UNMASK TO [user02@MngEnv12345678.onmicrosoft.com];

/* 12) Cleanup */
DROP TABLE DDMExample

