-- För de övningsuppgifter som kräver att ni ändrar i en tabell (insert, update, delete) 
-- se först till att kopiera orginaltabellen i everyloop till en ny tabell, som ni sedan kan modifiera. 
-- På så vis har ni alltid orginalet kvar oförändrat.  Exempel: select * into Users2 from Users; 
-- Om ni råkat ändra orginalet och vill ha tillbaks det så kan ni återställa databasen från backupfilen. 
-- Ni kan antingen återställa backupen och skriva över den databasen ni redan har (då försvinner alla ändringar ni gjort), 
-- eller så kan ni återställa den till en ny databas, t.ex. everyloop2. 

USE everyloop;
GO

-- a) Ta ut data (select) från tabellen GameOfThrones på sådant sätt att ni får ut en kolumn ’Title’ med titeln
-- samt en kolumn ’Episode’ som visar episoder och säsonger i formatet ”S01E01”, ”S01E02”, osv.   
-- Tips: kolla upp funktionen format()
SELECT TOP 10 * 
FROM dbo.GameOfThrones;

SELECT
    Title,
    'S' + FORMAT(Season, '00') + 'E' + FORMAT(EpisodeInSeason, '00') AS Episode
FROM dbo.GameOfThrones;

-- b) Uppdatera (kopia på) tabellen users och sätt username för alla användare så den blir de 2 första bokstäverna i förnamnet, 
-- och de 2 första i efternamnet (istället för 3+3 som det är i orginalet). 
-- Hela användarnamnet ska vara i små bokstäver.
SELECT * 
INTO dbo.Users2
FROM dbo.Users;

UPDATE dbo.Users2
SET UserName = LOWER(
    LEFT(FirstName, 2) + 
    LEFT(LastName, 2)
);

SELECT 
    FirstName, 
    LastName, 
    Username
FROM dbo.Users2;

-- c) Uppdatera (kopia på) tabellen airports så att alla null-värden i kolumnerna Time och DST byts ut mot ’-’
SELECT * 
INTO dbo.Airports2
FROM dbo.Airports;

UPDATE dbo.Airports2
SET Time = '-'
WHERE Time IS NULL;

UPDATE dbo.Airports2
SET DST = '-'
WHERE DST IS NULL;

SELECT top 20 Time, DST
FROM dbo.Airports2;

-- d) Ta bort de rader från (kopia på) tabellen Elements där ”Name” är någon av följande: 'Erbium', 'Helium', 'Nitrogen', 'Platinum', 'Selenium', 
-- samt alla rader där ”Name” börjar på någon av bokstäverna d, k, m, o, eller u.
SELECT * 
INTO dbo.Elements2
FROM dbo.Elements;

SELECT top 20 Name
from dbo.Elements2;

DELETE
from dbo.Elements2
where Name in (
    'Erbium',
    'Helium',
    'Nitrogen',
    'Platinum',
    'Selenium'
)
or Name LIKE 'd%'
or Name like 'k%'
or Name like 'm%'
or Name like 'o%'
or Name like 'u%';

SELECT top 20 *
from dbo.Elements2;

-- e) Skapa en ny tabell med alla rader från tabellen Elements. Den nya tabellen ska innehålla ”Symbol” och ”Name” från orginalet, 
-- samt en tredje kolumn med värdet ’Yes’ för de rader där ”Name” börjar med bokstäverna i ”Symbol”, och ’No’ för de rader där de inte gör det.
-- Ex: ’He’ -> ’Helium’ -> ’Yes’,  ’Mg’ -> ’Magnesium’ -> ’No’.
SELECT
    Symbol,
    Name,
    Case
        when Name like Symbol + '%'
        then 'Yes'
        else 'No'
    end as MatchResult
into dbo.elements3
from dbo.Elements;

SELECT top 20 *
from dbo.elements3;

-- f) Kopiera tabellen Colors till Colors2, men skippa kolumnen ”Code”.
-- Gör sedan en select från Colors2 som ger samma resultat som du skulle fått från select * from Colors; 
-- (Dvs, återskapa den saknade kolumnen från RGB-värdena i resultatet).
SELECT
    Name,
    Red,
    Green,
    Blue
INTO dbo.Colors2
from dbo.Colors;

SELECT
    Name,
    '#' +
    FORMAT(Red, 'X2') +
    FORMAT(Green, 'X2') +
    FORMAT(Blue, 'X2') AS Code,
    Red,
    Green,
    Blue
FROM dbo.Colors2;

-- g) Kopiera kolumnerna ”Integer” och ”String” från tabellen ”Types” till en ny tabell.
-- Gör sedan en select från den nya tabellen som ger samma resultat som du skulle fått från select * from types;
SELECT
    Integer,
    String
INTO dbo.Types2
from dbo.Types;

SELECT top 20 *
from dbo.Types2;

SELECT top 20 *
from dbo.Types;

SELECT
    Integer,
    Integer / 100.0 AS Float,
    String,
    DATEADD(
        Minute, Integer,
        DATEADD(
            Day, Integer - 1,
            '2019-01-01'
        )
    ) AS DateTime,
    Integer % 2 AS Bool
FROM dbo.Types2;

-- Vissa uppgifter ovan kan kräva att ni använder funktioner vi inte gått igenom ännu. Kolla dokumentationen för SQL Server, 
-- och se om ni kan hitta lämpliga funktioner där. Vi kommer gå igenom de vanligaste inbyggda funktionerna vid nästa tillfälle.
-- Spara era queries och ta med vid nästa tillfälle, så går vi igenom uppgifterna och ser om vi kan lösa dem tillsammans.