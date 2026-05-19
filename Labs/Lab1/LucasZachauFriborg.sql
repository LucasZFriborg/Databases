USE everyloop;
GO

-- MoonMissions
select
    [Spacecraft],
    [Launch date],
    [Carrier rocket],
    [Operator],
    [Mission type]
INTO SuccessfulMissions
FROM dbo.MoonMissions
where Outcome = 'Successful';
GO

select TOP 10 *
FROM SuccessfulMissions;
GO

UPDATE SuccessfulMissions
SET Operator = TRIM(Operator);
GO

select TOP 20 Operator
FROM SuccessfulMissions;
GO

-- Users
select
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

select TOP 20 *
FROM NewUsers;
GO

select
    UserName,
    Count(*) AS DuplicateCount
from NewUsers
GROUP BY UserName
HAVING COUNT(*) > 1;
GO

select
    ID,
    UserName
from NewUsers
WHERE UserName IN (
    select UserName
    FROM NewUsers
    GROUP BY UserName
    HAVING COUNT(*) > 1
);
GO

WITH Duplicates AS (
    Select
        ID,
        UserName,
        ROW_NUMBER() OVER (
            PARTITION by UserName
            ORDER BY ID
        ) AS RowNumber
    from NewUsers
)
UPDATE Duplicates
SET UserName = LEFT(UserName, LEN(UserName) - 2)
                + CAST(RowNumber AS varchar)
Where RowNumber > 1;
GO

select
    UserName,
    count(*) AS DuplicateCount
FROM NewUsers
GROUP BY UserName
HAVING count(*) > 1
GO

DELETE from NewUsers
WHERE Gender = 'Female'
and CAST(LEFT(ID, 2) AS INT) < 70;
GO

SELECT top 20 *
from NewUsers
where Gender = 'Female'
and CAST(LEFT(ID, 2) AS INT) < 70;
GO

insert into NewUsers (
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

select *
from NewUsers
where UserName = 'lucrog';
GO