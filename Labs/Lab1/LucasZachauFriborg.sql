USE everyloop;
GO

DROP TABLE IF EXISTS SuccessfulMissions;
DROP TABLE IF EXISTS NewUsers;
GO

-- MoonMissions
SELECT
    [Spacecraft],
    [Launch date],
    [Carrier rocket],
    [Operator],
    [Mission type]
INTO SuccessfulMissions
FROM dbo.MoonMissions
WHERE Outcome = 'Successful';
GO

SELECT top 10 *
FROM SuccessfulMissions;
GO

UPDATE SuccessfulMissions
SET Operator = TRIM(Operator);
GO

SELECT TOP 20 Operator
FROM SuccessfulMissions;
GO

SELECT
    Operator,
    [Mission type],
    COUNT(*) AS [Mission count]
FROM SuccessfulMissions
GROUP BY
    Operator,
    [Mission type]
HAVING COUNT(*) > 1
ORDER BY
    Operator,
    [Mission type];
GO

-- Users
SELECT
    ID,
    UserName,
    Password,
    FirstName + ' ' + LastName AS Name,
    Email,
    Phone,
    CASE
        WHEN CAST(SUBSTRING(ID, LEN(ID) - 1, 1) AS INT) % 2 = 0
            THEN 'Female'
        ELSE 'Male'
    END AS Gender
INTO NewUsers
FROM dbo.Users;
GO

SELECT TOP 20 *
FROM NewUsers;
GO

SELECT
    UserName,
    Count(*) AS DuplicateCount
FROM NewUsers
GROUP BY UserName
HAVING COUNT(*) > 1;
GO

SELECT
    ID,
    UserName
FROM NewUsers
WHERE UserName IN (
    SELECT UserName
    FROM NewUsers
    GROUP BY UserName
    HAVING COUNT(*) > 1
);
GO

WITH Duplicates AS (
    SELECT
        ID,
        UserName,
        ROW_NUMBER() OVER (
            PARTITION BY UserName
            ORDER BY ID
        ) AS RowNumber
    FROM NewUsers
)
UPDATE Duplicates
SET UserName = LEFT(UserName, LEN(UserName) - 2)
                + CAST(RowNumber AS VARCHAR)
WHERE RowNumber > 1;
GO

SELECT
    UserName,
    count(*) AS DuplicateCount
FROM NewUsers
GROUP BY UserName
HAVING count(*) > 1;
GO

DELETE FROM NewUsers
WHERE Gender = 'Female'
AND CAST(LEFT(ID, 2) AS INT) < 70;
GO

SELECT TOP 20 *
FROM NewUsers
WHERE Gender = 'Female'
AND CAST(LEFT(ID, 2) AS INT) < 70;
GO

INSERT INTO NewUsers (
    ID,
    UserName,
    Password,
    Name,
    Email,
    Phone,
    Gender
)
VALUES (
    '010180-1234',
    'lucrog',
    'Zapp1980',
    'Lucas Rogers',
    'lucas.rogers@gmail.com',
    '0701236780',
    'Male'
);
GO

SELECT *
FROM NewUsers
WHERE UserName = 'lucrog';
GO

-- Company (Joins)
SELECT
    company.products.ID AS Id,
    company.products.ProductName AS Product,
    company.suppliers.CompanyName AS Supplier,
    company.categories.CategoryName AS Category
FROM company.products
JOIN company.suppliers
    ON company.products.SupplierId = company.suppliers.ID
JOIN company.categories
    ON company.products.CategoryId = company.categories.ID;
GO

SELECT
    company.regions.RegionDescription,
    COUNT(DISTINCT company.employees.ID) AS EmployeeCount
FROM company.employees
JOIN company.employee_territory
    ON company.employees.ID = company.employee_territory.EmployeeId
JOIN company.territories
    ON company.employee_territory.TerritoryId = company.territories.ID
JOIN company.regions
    ON company.territories.RegionId = company.regions.ID
GROUP BY company.regions.RegionDescription;
GO