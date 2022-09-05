-- Hometask 5
--
-- 1. Try out transactions in three modes:
--        - Auto-commit mode ✅
--        - Implicit mode ✅
--        - Explicit mode ✅
-- 2. Deadlocking ✅
-- 3. Reproduce: 
--        - Dirty Read ✅
--        - Non-repeatable Read ✅
--        - Phantom Read ✅0


-- 1 --

-- Auto-commit mode
CREATE TABLE Person (
	Id	INT PRIMARY KEY, 
	LastName	VARCHAR(20) NOT NULL, 
	FirstName	VARCHAR(20) NOT NULL, 
	[Address]   VARCHAR(50) NOT NULL, 
	City		VARCHAR(255) NOT NULL, 
	Age			INT NOT NULL DEFAULT(18),
	Gender		VARCHAR(1) NOT NULL CHECK(Gender IN ('M', 'F'))
);

INSERT INTO Person VALUES (0, 'Smith', 'John', 'Main Street', 'Chisinau', 26, 'M');

INSERT INTO Person VALUES (0, 'Smith', 'John', 'Main Street', 'Chisinau', 26, 'M');

DROP TABLE Person

-- Implicit mode
SET IMPLICIT_TRANSACTIONS ON 
UPDATE 
    Person 
SET 
    Lastname = 'Sawyer', 
    Firstname = 'Tom' 
WHERE 
    Id = 0
COMMIT TRAN

-- Explicit mode
SET IMPLICIT_TRANSACTIONS OFF
BEGIN TRANSACTION 

INSERT INTO Person VALUES (1, 'Angel', 'Mia', 'Baker Street', 'London', 32, 'F');
    
ROLLBACK TRAN
    
SELECT * FROM Person WHERE PersonID = 1


-- 2 --

-- Deadlock

CREATE TABLE Car (
	Id INT NOT NULL,
	Color NVARCHAR(20) NOT NULL
)

INSERT INTO Car VALUES(1, 'Black');
INSERT INTO Car VALUES(2, 'White');
INSERT INTO Car VALUES(3, 'Yellow');
DROP TABLE Car


--BEGIN TRANSACTION
--UPDATE Person SET FirstName = 'JJJ'
--WHERE PersonID = 0
--WAITFOR DELAY '00:00:01'

--UPDATE Car SET Color = 'Red'
--WHERE Id = 2

--BEGIN TRANSACTION
--UPDATE Car SET Color = 'Red'
--WHERE Id = 2

--UPDATE Person SET FirstName = 'JJJ'
--WHERE PersonID = 0


-- 3 --

-- Dirty Read --

BEGIN TRANSACTION
	UPDATE Person SET Age = 9
	WHERE FirstName = 'John'
	WAITFOR DELAY '00:00:04'
ROLLBACK TRANSACTION
SELECT * FROM Person

--SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
--BEGIN TRANSACTION
--	SELECT * FROM Person
--	WHERE FirstName = 'John'
--COMMIT TRANSACTION;



-- Non-repeatable Read --

SET TRANSACTION ISOLATION LEVEL READ COMMITTED
	BEGIN TRANSACTION
		SELECT * FROM Person WHERE FirstName = 'John'
		WAITFOR DELAY '00:00:04'
		SELECT * FROM Person WHERE FirstName = 'John'
COMMIT TRANSACTION
SELECT * FROM Person

--SET TRANSACTION ISOLATION LEVEL READ COMMITTED
--BEGIN TRANSACTION
--	UPDATE Person SET Age = 22 WHERE FirstName = 'John'		
--COMMIT;

-- Phantom Read --
INSERT INTO Person VALUES (1, 'Angel', 'Mia', 'Law Street', 'London', 21, 'F');
INSERT INTO Person VALUES (2, 'Banks', 'Nick', 'Lomonosov Street', 'Moscow', 27, 'M');
INSERT INTO Person VALUES (3, 'Nicholas', 'Nat', 'Draudestraat Street', 'Amsterdam', 43, 'F');

SET TRANSACTION ISOLATION LEVEL REPEATABLE READ

BEGIN TRANSACTION
SELECT * FROM Person where Gender = 'M'
WAITFOR DELAY '00:00:05'
SELECT * FROM Person where Gender = 'M'
COMMIT TRANSACTION


--SET TRANSACTION ISOLATION LEVEL REPEATABLE READ

--BEGIN TRANSACTION
--INSERT INTO Person VALUES (5, 'Mike', 'Wazovski', 'Jorja Street', 'Portugal', 31, 'M');
--COMMIT TRANSACTION