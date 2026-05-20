USE everyloop;
GO

drop table if exists SuccessfulMissions;
drop table if exists NewUsers;
GO

-- MoonMissions
SELECT
    [Spacecraft],
    [Launch date],
    [Carrier rocket],
    [Operator],
    [Mission type]
into SuccessfulMissions
from dbo.MoonMissions
where Outcome = 'Successful';
GO

SELECT top 10 *
from SuccessfulMissions;
GO

UPDATE SuccessfulMissions
set Operator = TRIM(Operator);
GO

SELECT top 20 Operator
from SuccessfulMissions;
GO

-- Users
SELECT
    ID,
    UserName,
    Password,
    FirstName + ' ' + LastName as Name,
    Email,
    Phone,
    case
        when CAST(SUBSTRING(ID, LEN(ID) - 1, 1) as int) % 2 = 0
            then 'Female'
        else 'Male'
    end as Gender
into NewUsers
from dbo.Users;
GO

SELECT top 20 *
from NewUsers;
GO

SELECT
    UserName,
    Count(*) as DuplicateCount
from NewUsers
group by UserName
having COUNT(*) > 1;
GO

SELECT
    ID,
    UserName
from NewUsers
where UserName in (
    select UserName
    from NewUsers
    group by UserName
    having COUNT(*) > 1
);
GO

WITH Duplicates as (
    select
        ID,
        UserName,
        ROW_NUMBER() over (
            partition by UserName
            order by ID
        ) as RowNumber
    from NewUsers
)
update Duplicates
set UserName = LEFT(UserName, LEN(UserName) - 2)
                + CAST(RowNumber as varchar)
where RowNumber > 1;
GO

SELECT
    UserName,
    count(*) as DuplicateCount
from NewUsers
group by UserName
having count(*) > 1;
GO

DELETE from NewUsers
where Gender = 'Female'
and CAST(LEFT(ID, 2) as int) < 70;
GO

SELECT top 20 *
from NewUsers
where Gender = 'Female'
and CAST(LEFT(ID, 2) as int) < 70;
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
values (
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
from NewUsers
where UserName = 'lucrog';
GO

-- Company (Joins)
SELECT
    company.products.ID as Id,
    company.products.ProductName as Product,
    company.suppliers.CompanyName as Supplier,
    company.categories.CategoryName as Category
from company.products
join company.suppliers
    on company.products.SupplierId = company.suppliers.ID
join company.categories
    on company.products.CategoryId = company.categories.ID;
GO

SELECT
    company.regions.RegionDescription,
    COUNT(distinct company.employees.ID) as EmployeeCount
from company.employees
join company.employee_territory
    on company.employees.ID = company.employee_territory.EmployeeId
join company.territories
    on company.employee_territory.TerritoryId = company.territories.ID
join company.regions
    on company.territories.RegionId = company.regions.ID
group by company.regions.RegionDescription;
GO