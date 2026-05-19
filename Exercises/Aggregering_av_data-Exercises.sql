-- Nu när vi lärt oss grunderna i hur man plockar ut data ur tabeller med hjälp av SQL så ska vi kolla på 
-- hur vi får ut sådan information som inte står i klartext,
-- men som vi kan räkna ut och sammanställa på olika vis.
USE everyloop;
GO
-- a) Ta ut (select) en rad för varje (unik) period i tabellen ”Elements” med följande kolumner: 
-- ”period”, ”from” med lägsta atomnumret i perioden, ”to” med högsta atomnumret i perioden, 
-- ”average isotopes” med genomsnittligt antal isotoper visat med 2 decimaler,
-- ”symbols” med en kommaseparerad lista av alla ämnen i perioden.
SELECT
    Period,
    MIN(Number) AS [FROM],
    MAX(Number) AS [TO],
    FORMAT(AVG(Stableisotopes), 'N2') AS [Average Isotopes],
    STRING_AGG(Symbol, ', ') AS Symbols
FROM dbo.Elements
GROUP BY Period;

-- b) För varje stad som har 2 eller fler kunder i tabellen Customers, ta ut (select) följande kolumner: ”Region”, ”Country”, ”City”,
-- samt ”Customers” som anger hur många kunder som finns i staden.
SELECT
    Region,
    Country,
    City,
    COUNT(*) AS Customers
FROM company.Customers
GROUP BY
    Region,
    Country,
    City
HAVING COUNT(*) >= 2;

-- c) Skapa en varchar-variabel och skriv en select-sats som sätter värdet: ”Säsong 1 sändes från april till juni 2011.
-- Totalt sändes 10 avsnitt, som i genomsnitt sågs av 2.5 miljoner människor i USA.”, följt av radbyte/char(13), följt av ”Säsong 2 sändes ...” osv.
-- När du sedan skriver (print) variabeln till messages ska du alltså få en rad för varje säsong enligt ovan, med data sammanställt från tabellen GameOfThrones.
-- Tips: Ange ’sv’ som tredje parameter i format() för svenska månader.
SELECT *
from dbo.GameOfThrones;

SELECT
    Season,
    MIN([Original air date]) AS StartDate,
    MAX([Original air date]) AS EndDate,
    COUNT(*) AS EpisodeCount,
    AVG([U.S. viewers(millions)]) AS AvgViewers
FROM dbo.GameOfThrones
GROUP BY Season;

DECLARE @report NVARCHAR(MAX) = '';

SELECT @report = @report +
    'Säsong ' + CAST(Season AS varchar) +
    ' sändes från ' +
    FORMAT(MIN([Original air date]), 'MMMM', 'sv') +
    ' till ' +
    FORMAT(MAX([Original air date]), 'MMMM yyyy', 'sv') +
    '. Totalt sändes ' +
    CAST(COUNT(*) AS varchar) +
    ' avsnitt, som i genomsnitt sågs av ' +
    CAST(ROUND(AVG([U.S. viewers(millions)]), 1) AS varchar) +
    ' miljoner människor i USA.' +
    CHAR(13) + CHAR(10)
FROM dbo.GameOfThrones
GROUP BY Season;

Print @report;

-- d) Ta ut (select) alla användare i tabellen ”Users” så du får tre kolumner: ”Namn” som har fulla namnet;
-- ”Ålder” som visar hur många år personen är idag (ex. ’45 år’);
-- ”Kön” som visar om det är en man eller kvinna. Sortera raderna efter för- och efternamn.
SELECT Top 10 *
from dbo.Users;

SELECT
    FirstName + ' ' + LastName as Namn,
    CAST(
        DATEDIFF(
            Year,
            TRY_CONVERT(date, LEFT(ID, 6)),
            GETDATE()
        ) AS varchar
    ) + ' år' AS Ålder,
    CASE
        WHEN CAST(SUBSTRING(ID, 10, 1) AS int) % 2 = 0
            THEN 'Kvinna'
        ELSE 'Man'
    END AS Kön
FROM dbo.Users
ORDER BY
    FirstName,
    LastName;

-- e) Ta ut en lista över regioner i tabellen ”Countries” där det för varje region framgår regionens namn, antal länder i regionen, totalt antal invånare,
-- total area, befolkningstätheten med 2 decimaler, samt spädbarnsdödligheten per 100.000 födslar avrundat till heltal.

-- f) Från tabellen ”Airports”, gruppera per land och ta ut kolumner som visar: land, antal flygplatser (IATA-koder), 
-- antal som saknar ICAO-kod, samt hur många procent av flygplatserna i varje land som saknar ICAO-kod.