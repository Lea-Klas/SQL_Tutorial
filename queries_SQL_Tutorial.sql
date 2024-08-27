-- SQL Tutorial 
-- Beginner to Advanced


-- ############################ BEGINNER #########################

/* Covered Concepts:
CREATE
INSERT
SELECT
WHERE
GROUP BY
ORDER BY
*/

-- CREATE ----------------------------------------------

CREATE TABLE employee_demographics (
	EmployeeID int,
	FirstName varchar(50),
	LastName varchar(50),
	Age int,
	Gender varchar(20)
);

CREATE TABLE employee_salary (
	EmployeeID int,
	JobTitle varchar(50),
	Salary int
);

CREATE TABLE warehouse_employee_demographics (
	EmployeeID int, 
	FirstName varchar(50), 
	LastName varchar(50), 
	Age int, 
	Gender varchar(50)
);

CREATE TABLE employee_errors (
	EmployeeID varchar(50),
	FirstName varchar(50),
	LastName varchar(50)
);



-- INSERT -------------------------------------------
-- insert values into tables

INSERT INTO employee_demographics VALUES
(1001, 'Jim', 'Halpert', 30, 'Male'),
(1002, 'Pam', 'Beasley', 30, 'Female'),
(1003, 'Dwight', 'Schrute', 29, 'Male'),
(1004, 'Angela', 'Martin', 31, 'Female'),
(1005, 'Toby', 'Flenderson', 32, 'Male'),
(1006, 'Michael', 'Scott', 35, 'Male'),
(1007, 'Meredith', 'Palmer', 32, 'Female'),
(1008, 'Stanley', 'Hudson', 38, 'Male'),
(1009, 'Kevin', 'Malone', 31, 'Male'),
(1011, 'Ryan', 'Howard', 26, 'Male'),
(NULL, 'Holly', 'Flax', NULL, NULL),
(1013, 'Darryl', 'Philibin', NULL, 'Male');

INSERT INTO employee_salary VALUES
(1001, 'Salesman', 45000),
(1002, 'Receptionist', 36000),
(1003, 'Salesman', 63000),
(1004, 'Accountant', 47000),
(1005, 'HR', 50000),
(1006, 'Regional Manager', 65000),
(1007, 'Supplier Relations', 41000),
(1008, 'Salesman', 48000),
(1009, 'Accountant', 42000),
(1010, NULL, 47000),
(NULL, 'Salesman', 43000);

INSERT INTO warehouse_employee_demographics VALUES
(1013, 'Darryl', 'Philibin', NULL, 'Male'),
(1050, 'Roy', 'Anderson', 31, 'Male'),
(1051, 'Hidetoshi', 'Hasagawa', 40, 'Male'),
(1052, 'Val', 'Johnson', 31, 'Female');

INSERT INTO employee_errors VALUES
('1001  ', 'Jimbo', 'Halbert'),
('  1002', 'Pamela', 'Beasley'),
('1009', 'KeVin', 'Malone - Fired');


-- SELECT Statements ----------------------------------
-- Limit, Distinct, Count, As, Max, Min, Avg

-- Limit
SELECT FirstName, LastName 
FROM employee_demographics
LIMIT 3;

-- Distinct
SELECT DISTINCT(Gender)
FROM employee_demographics;

-- Count
-- AS
SELECT COUNT(LastName) AS LastNameCount
FROM employee_demographics;

-- Min, Max, Avg
SELECT MIN(Salary), MAX(Salary), AVG(Salary)
FROM employee_salary;


-- WHERE Statement ------------------------------------
-- =, <>, <, >, And, Or, Like, Null, Not Null, In

-- =
SELECT *
FROM employee_demographics
WHERE FirstName = 'Jim';

-- <>
SELECT *
FROM employee_demographics
WHERE FirstName <> 'Jim';

-- <
-- AND
SELECT *
FROM employee_demographics
WHERE Age < 30 AND Gender = 'Male';

-- >
-- OR
SELECT *
FROM employee_demographics
WHERE Age > 30 OR Gender = 'Male';

-- LIKE
SELECT *
FROM employee_demographics
WHERE LastName LIKE 'S%r%';

-- IS NULL
SELECT * 
FROM employee_demographics
WHERE Gender IS NULL;

-- IS NOT NULL
SELECT * 
FROM employee_demographics
WHERE Gender IS NOT NULL;

-- IN
SELECT * 
FROM employee_demographics
WHERE FirstName IN ('Jim', 'Michael');


-- GROUP BY, ORDER BY -------------------------

-- Group By
-- Order By
SELECT Gender, COUNT(Gender) AS count
FROM employee_demographics
WHERE Gender IS NOT NULL
GROUP BY Gender
ORDER BY count DESC;

-- Order By
SELECT *
FROM employee_demographics
ORDER BY Age DESC, Gender DESC;
-- same: ORDER BY 4 DESC, 5 DESC;

-- what is the avg salary for salesman
SELECT JobTitle, AVG(Salary) AS AverageSalary
FROM employee_salary
WHERE JobTitle = 'Salesman'
GROUP BY JobTitle;



-- ######################### INTERMEDIATE ##########################################

/* Covered Concepts:
JOINS
UNIONS
CASE Statements
Having vs. Group by
Updating / Deleting Data
Aliasing
PARTITION BY
*/

-- JOINS ----------------------------------------------------------------------
-- Inner Joins, Full/Left/Right Outer Joins 

-- inner join
SELECT * 
FROM employee_demographics AS demo
JOIN employee_salary AS sal
	ON demo.EmployeeID = sal.EmployeeID;

-- full outer join
-- not directly supported in MySQL -> need to do a union of left join and right join 
SELECT *
FROM employee_demographics demo
LEFT JOIN employee_salary sal
	ON demo.EmployeeID = sal.EmployeeID
UNION
SELECT * 
FROM employee_demographics demo
RIGHT JOIN employee_salary sal 
	ON demo.EmployeeID = sal.EmployeeID;

-- left join
SELECT *
FROM employee_demographics demo
LEFT JOIN employee_salary sal
	ON demo.EmployeeID = sal.EmployeeID;
    
-- right join
SELECT *
FROM employee_demographics demo
RIGHT JOIN employee_salary sal
	ON demo.EmployeeID = sal.EmployeeID;

-- example: who has the highest salary after michael scott
SELECT demo.EmployeeID, FirstName, LastName, Salary
FROM employee_demographics demo
JOIN employee_salary sal
	ON demo.EmployeeID = sal.EmployeeID
WHERE FirstName <> 'Michael' AND LastName <> 'Scott'
ORDER BY Salary DESC;    


-- UNION, UNION ALL -----------------------------------------------
-- combine results of multiple SELECT statements

-- UNION (removes duplicates)
SELECT * 
FROM employee_demographics
UNION
SELECT * 
FROM warehouse_employee_demographics;

-- UNION ALL 
SELECT * 
FROM employee_demographics
UNION
SELECT * 
FROM warehouse_employee_demographics
ORDER BY EmployeeID;


-- CASE Statement ------------------------------------------------------

SELECT FirstName, LastName, Age,
CASE
	WHEN Age > 30 THEN 'Over 30'
    ELSE 'Under 30'
END AS AgeRange
FROM employee_demographics
WHERE Age IS NOT NULL
ORDER BY Age;

-- add raising to salary
SELECT FirstName, LastName, JobTitle, Salary,
CASE
	WHEN JobTitle = 'Salesman' THEN Salary + (Salary * .10)
    WHEN JobTitle = 'Accountant' THEN Salary + (Salary * .05)
    WHEN JobTitle = 'HR' THEN Salary + (Salary * .000001)
    ELSE Salary + (Salary * .03)
END AS SalaryAfterRaise
FROM employee_demographics demo
JOIN employee_salary sal
	ON demo.EmployeeID = sal.EmployeeID;
    
-- HAVING Clause -----------------------------------------------------
-- used after aggregated functions or group by -> WHERE cannot be used after aggregation
SELECT JobTitle, COUNT(JobTitle) AS count
FROM employee_salary
GROUP BY JobTitle
HAVING count > 1;

SELECT JobTitle, AVG(Salary) AS AvgSalary
FROM employee_salary
GROUP BY JobTitle
HAVING AvgSalary > 45000
ORDER BY AvgSalary DESC;

-- Updating / Deleting Data --------------------------------------------

-- Update
UPDATE employee_demographics
SET EmployeeID = 1012, Age =31, Gender = 'Female'
WHERE FirstName = 'Holly' AND LastName = 'Flax';

-- Delete
DELETE FROM employee_demographics
WHERE EmployeeID = 1005;


-- Aliasing ---------------------------------------------------------------
SELECT CONCAT(FirstName, ' ', LastName)  AS FullName
FROM employee_demographics;
    
    
-- Partition By ----------------------------------------------------------
SELECT FirstName, LastName, Gender, Salary, 
COUNT(Gender) OVER (PARTITION BY Gender) AS TotalGender
FROM employee_demographics demo
JOIN employee_salary sal
	ON demo.EmployeeID = sal.EmployeeID;
    
    
-- ------------------------------------------ADVANCED------------------------------------------------------------
/* Covered Concepts:
CTEs
Temp Tables
Subqueries
String Functions (TRIM, LTRIM, RTRIM, Replace, Substring, Upper, Lower)
Stored Procedures
*/
    
-- CTEs (Common Table Expression) -----------------------------------------------
WITH CTE_Employee AS 
	(SELECT FirstName, LastName, Gender, Salary
	, COUNT(Gender) OVER (PARTITION BY Gender) AS TotalGender
	, AVG(Salary) OVER (PARTITION BY Gender) AS AvgSalaryGender
	FROM employee_demographics demo
	JOIN employee_salary sal
		ON demo.EmployeeID = sal.EmployeeID
	WHERE Salary > 45000
	)
SELECT *
FROM CTE_Employee;

-- Temp Tables ----------------------------------------------------------------
/*used to store intermediate results temporarily during the execution of a query or a batch of queries.
They exist only for the duration of a session and they are automatically dropped when the session ends. */
CREATE TEMPORARY TABLE temp_employee(
EmployeeID int,
JobTitle varchar(50),
Salary int
);

INSERT INTO temp_employee
SELECT *
FROM employee_salary;

CREATE TEMPORARY TABLE temp_employee2(
JobTitle varchar(50),
EmployeesPerJob int,
AvgAge int,
AvgSalary int
);

INSERT INTO temp_employee2
SELECT JobTitle, COUNT(JobTitle), AVG(Age), AVG(Salary)
FROM employee_demographics demo
JOIN employee_salary sal
	ON demo.EmployeeID = sal.EmployeeID
GROUP BY JobTitle;

-- Subqueries ----------------------
SELECT EmployeeID, Salary, (SELECT AVG(Salary) FROM employee_salary) AS AllAvgSalary
FROM employee_salary;

SELECT sub.EmployeeID, AllAvgSalary
FROM (SELECT EmployeeID, Salary, AVG(Salary) OVER() AS AllAvgSalary
FROM employee_salary) sub;

SELECT EmployeeID, JobTitle, Salary
FROM employee_salary
WHERE EmployeeID IN (
	SELECT EmployeeID
    FROM employee_demographics
    WHERE Age > 30);


-- STRING Functions ---------------------------------------------------------
-- TRIM, LTRIM, RTRIM, Replace, Substring, Upper, Lower

-- TRIM
SELECT EmployeeID, TRIM(EmployeeID) AS IDTrim
FROM employee_errors;

-- LTRIM
SELECT EmployeeID, LTRIM(EmployeeID) AS IDLTrim
FROM employee_errors;

-- RTRIM
SELECT EmployeeID, RTRIM(EmployeeID) AS IDRTrim
FROM employee_errors;

-- Replace
SELECT LastName, REPLACE(LastName, '- Fired', '') AS LastNameFixed
FROM employee_errors;

-- Substring
SELECT err.FirstName, SUBSTRING(err.FirstName,1,3), demo.FirstName, SUBSTRING(demo.FirstName,1,3)
FROM employee_errors err
JOIN employee_demographics demo
	ON SUBSTRING(err.FirstName,1,3) = SUBSTRING(demo.FirstName,1,3);
    
-- UPPER 
SELECT FirstName, LOWER(FirstName) AS FirstNameLower
FROM employee_errors;

-- LOWER
SELECT FirstName, UPPER(FirstName) AS FirstNameUpper
FROM employee_errors;


-- Stored Procedure -------------------------------------

DELIMITER $$

CREATE PROCEDURE test()
BEGIN
	SELECT *
	FROM employee_demographics;
END $$

DELIMITER ; 

CALL test();

DELIMITER $$
CREATE PROCEDURE temp_employee()
BEGIN
	CREATE TEMPORARY TABLE temp_employee_table (
    JobTitle varchar(50),
    EmployeesPerJob int,
    AvgAge int,
    AvgSalary int);
    INSERT INTO temp_employee_table
    SELECT JobTitle, COUNT(JobTitle), AVG(Age), AVG(Salary)
    FROM employee_demographics demo
    JOIN employee_salary sal
		ON demo.EmployeeID = sal.EmployeeID
	GROUP BY JobTitle;
    SELECT * FROM temp_employee_table;
END $$

DELIMITER ;

CALL temp_employee();

DELIMITER $$

CREATE PROCEDURE test3(IN emp_id INT)
BEGIN
    SELECT *
    FROM employee_demographics
    WHERE EmployeeID = emp_id;
END $$

DELIMITER ;

CALL test3(1004);