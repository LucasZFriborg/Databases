USE master;
GO

DROP DATABASE IF EXISTS Bokhandel;
GO

CREATE DATABASE Bokhandel;
GO

USE Bokhandel;
GO

CREATE TABLE Författare (
    ID INT PRIMARY KEY IDENTITY(1, 1),
    Förnamn NVARCHAR(50) NOT NULL,
    Efternamn NVARCHAR(50) NOT NULL,
    Födelsedatum DATE NOT NULL
);
GO

CREATE TABLE Förlag (
    ID INT PRIMARY KEY IDENTITY(1, 1),
    Namn NVARCHAR(100) NOT NULL,
    Stad NVARCHAR(100),
    Land NVARCHAR(100)
);
GO

CREATE TABLE Böcker (
    ISBN13 CHAR(13) PRIMARY KEY,
    Titel NVARCHAR(200) NOT NULL,   
    Språk NVARCHAR(50) NOT NULL,
    Pris DECIMAL(10, 2) NOT NULL
        CHECK (Pris >= 0),
    Utgivningsdatum DATE NOT NULL,
    FörfattareID INT NOT NULL,
    FörlagID INT NOT NULL,

    CONSTRAINT FK_Böcker_Författare
        FOREIGN KEY (FörfattareID)
        REFERENCES Författare(ID),
    CONSTRAINT FK_Böcker_Förlag
        FOREIGN KEY (FörlagID)
        REFERENCES Förlag(ID),
    CONSTRAINT Check_ISBN13
        CHECK (ISBN13 NOT LIKE '%[^0-9]%')
);
GO

CREATE TABLE Butiker (
    ID INT PRIMARY KEY IDENTITY(1, 1),
    Butiknamn NVARCHAR(100) NOT NULL,
    Adress NVARCHAR(200) NOT NULL,
    Stad NVARCHAR(100) NOT NULL,
    Postnummer NVARCHAR(20) NOT NULL
);
GO

CREATE TABLE LagerSaldo (
    ButikID INT NOT NULL,
    ISBN13 CHAR(13) NOT NULL,
    Antal INT NOT NULL
        CHECK (Antal >= 0),
    
    PRIMARY KEY (ButikID, ISBN13),

    CONSTRAINT FK_LagerSaldo_Butiker
        FOREIGN KEY (ButikID)
        REFERENCES Butiker(ID),
    CONSTRAINT FK_LagerSaldo_Böcker
        FOREIGN KEY (ISBN13)
        REFERENCES Böcker(ISBN13)
);
GO

CREATE TABLE Kunder (
    ID INT PRIMARY KEY IDENTITY(1, 1),
    Förnamn NVARCHAR(50) NOT NULL,
    Efternamn NVARCHAR(50) NOT NULL,
    Email NVARCHAR(100) UNIQUE NOT NULL,
    Telefonnummer NVARCHAR(20)
);
GO

INSERT INTO Författare (
    Förnamn,
    Efternamn,
    Födelsedatum
)
VALUES
    ('Aldous', 'Huxley', '1894-07-26'),
    ('George', 'Orwell', '1903-06-25'),
    ('Wilhelm', 'Agrell', '1950-10-13'),
    ('Stephen', 'Mitford Goodson', '1948-08-04');
GO

INSERT INTO Förlag (
    Namn,
    Stad,
    Land
)
VALUES
    ('Chatto & Windus', 'London', 'England'),
    ('Secker & Warburg', 'London', 'England'),
    ('Historiska Media', 'Lund', 'Sverige'),
    ('Black House Publishing', 'London', 'England');
GO

INSERT INTO Butiker (
    Butiknamn,
    Adress,
    Stad,
    Postnummer
)
VALUES
    ('Akademibokhandeln', 'Norra Hamngatan 26', 'Göteborg', '41106'),
    ('The English Bookshop Göteborg', 'Kungsgatan 19', 'Göteborg', '41119'),
    ('Adlibris', 'Kungsgatan 34', 'Göteborg', '41119');
GO

INSERT INTO Böcker (
    ISBN13,
    Titel,
    Språk,
    Pris,
    Utgivningsdatum,
    FörfattareID,
    FörlagID
)
VALUES
    ('9780060850524', 'Brave New World', 'Engelska', 129.00, '1932-01-01', 1, 1),
    ('9780060898526', 'The Doors of Perception', 'Engelska', 109.00, '1954-01-01', 1, 1),
    ('9780061767647', 'Island', 'Engelska', 139.00, '1962-01-01', 1, 1),
    ('9780451524935', '1984', 'Engelska', 119.00, '1949-01-01', 2, 2),
    ('9780451526342', 'Animal Farm', 'Engelska', 99.00, '1945-01-01', 2, 2),
    ('9780141036144', 'Homage to Catalonia', 'Engelska', 149.00, '1938-01-01', 2, 2),
    ('9789177899020', 'Stockholm som spioncentral', 'Svenska', 189.00, '2020-01-01', 3, 3),
    ('9789173291682', 'Fredens illusioner', 'Svenska', 179.00, '2010-01-01', 3, 3),
    ('9781910881491', 'A History of Central Banking and the Enslavement of Mankind', 'Engelska', 249.00, '2017-04-01', 4, 4),
    ('9781905570980', 'The Debasement of World Currency', 'Engelska', 199.00, '2011-01-01', 4, 4);
GO

INSERT INTO LagerSaldo (
    ButikID,
    ISBN13,
    Antal
)
VALUES
    (1, '9780060850524', 8),
    (1, '9780060898526', 5),
    (1, '9780451524935', 10),
    (1, '9780451526342', 7),

    (2, '9780141036144', 4),
    (2, '9789177899020', 6),
    (2, '9789173291682', 5),

    (3, '9781910881491', 3),
    (3, '9781905570980', 4),
    (3, '9780061767647', 6);
GO

CREATE VIEW TitlarPerFörfattare AS
SELECT
    Författare.Förnamn + ' ' + Författare.Efternamn AS Namn,
    DATEDIFF(YEAR, Författare.Födelsedatum, GETDATE()) AS Ålder,
    COUNT(DISTINCT Böcker.ISBN13) AS Titlar,
    SUM(Böcker.Pris * LagerSaldo.Antal) AS Lagervärde
FROM Författare
JOIN Böcker
    ON Författare.ID = Böcker.FörfattareID
JOIN LagerSaldo
    ON Böcker.ISBN13 = LagerSaldo.ISBN13
GROUP BY
    Författare.Förnamn,
    Författare.Efternamn,
    Författare.Födelsedatum;
GO

BACKUP DATABASE Bokhandel
TO DISK = '/var/opt/mssql/backup/LucasZachauFriborg.bak'
WITH FORMAT;
GO