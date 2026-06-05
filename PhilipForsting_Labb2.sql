--CREATE DATABASE BookStoreDB;
--GO

USE BookStoreDB;
GO

DROP TABLE IF EXISTS Ordrar;
DROP TABLE IF EXISTS Kunder;
DROP TABLE IF EXISTS LagerSaldo;
DROP TABLE IF EXISTS Böcker;
DROP TABLE IF EXISTS Butiker;
DROP TABLE IF EXISTS Författare;
DROP TABLE IF EXISTS TitlarPerFörfattare;
GO

CREATE TABLE Författare (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    Förnamn NVARCHAR(50) NOT NULL,
    Efternamn NVARCHAR(50) NOT NULL,
    Födelsedatum DATE NOT NULL
)
GO

CREATE TABLE Böcker (
    ISBN13 CHAR(13) PRIMARY KEY,
    Titel NVARCHAR(200) NOT NULL,
    Språk NVARCHAR(50) NOT NULL,
    Pris DECIMAL(10,2) NOT NULL,
    Utgivningsdatum DATE NOT NULL,
    FörfattareID INT NOT NULL,
    FOREIGN KEY (FörfattareID)
        REFERENCES Författare(ID)
)
GO


CREATE TABLE Butiker (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    Butiksnamn NVARCHAR(50) NOT NULL,
    Adress NVARCHAR(200) NOT NULL
)
GO

CREATE TABLE LagerSaldo (
    ButikID INT NOT NULL,
    ISBN13 CHAR(13) NOT NULL,
    Antal INT NOT NULL,
    PRIMARY KEY (ButikID, ISBN13),
    FOREIGN KEY (ButikID)
        REFERENCES Butiker(ID),
    FOREIGN KEY (ISBN13)
        REFERENCES Böcker(ISBN13)
)
GO

CREATE TABLE Kunder (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    Förnamn NVARCHAR(50) NOT NULL,
    Efternamn NVARCHAR(50) NOT NULL,
    KundAdress NVARCHAR(50) NOT NULL
)
GO

CREATE TABLE Ordrar(
    ID INT IDENTITY(1,1) PRIMARY KEY,
    ISBN13 CHAR(13) NOT NULL,
    KundID INT NOT NULL,
    ButikID INT NOT NULL,

    FOREIGN KEY (KundID)
        REFERENCES Kunder(ID),
    FOREIGN KEY (ButikID)
        REFERENCES Butiker(ID),
    FOREIGN KEY (ISBN13)
        REFERENCES Böcker(ISBN13)
)
GO

INSERT INTO Författare (
    Förnamn,
    Efternamn,
    Födelsedatum 
)
VALUES 
    ('Joanne', 'Rowling', '1965-07-31'),
    ('Stephen', 'King', '1947-09-21'),
    ('Dan', 'Brown', '1964-07-22'),
    ('Stephenie', 'Meyer', '1973-12-24')
GO

INSERT INTO Böcker (
    ISBN13,
    Titel,
    Språk,
    Pris,
    Utgivningsdatum,
    FörfattareID 
)
VALUES 
    ('9780747532699', 'Harry Potter and the Philosopher''s Stone', 'Engelska', 236, '1997-06-26', 1),
    ('9780747538492', 'Harry Potter and the Chamber of Secrets', 'Engelska', 237, '1998-07-02', 1),
    ('9780747542155', 'Harry Potter and the Prisoner of Azkaban', 'Engelska', 238, '1999-07-08', 1),
    ('9780747550794', 'Harry Potter and the Goblet of Fire', 'Engelska', 239, '2000-07-08', 1),
    ('9780385086950', 'Carrie', 'Engelska', 150, '1974-04-05', 2),
    ('9780670315413', 'Firestarter', 'Engelska', 151, '1980-09-29', 2),
    ('9780670451937', 'Cujo', 'Engelska', 152, '1981-09-08', 2),
    ('9780593055045', 'Angels & Demons', 'Engelska', 160, '2000-05-01', 3),
    ('9780307474278', 'The Da Vinci Code', 'Engelska', 161, '1981-09-08', 3),
    ('9780316160179', 'Twilight', 'Engelska', 170, '1981-09-08', 4)
GO


INSERT INTO Butiker  (
    Butiksnamn,
    Adress
)
VALUES
    ('Bokstugan Alfabetika', 'Hovås Pilbladsstig 1'),
    ('Bokbussen Kyrillisko', 'Pepparrotsvägen 2'),
    ('Boktaxin Hieroglyfen', 'Lilla torget 3')
GO


INSERT INTO LagerSaldo(
    ButikID,
    ISBN13,
    Antal
)
VALUES 
    (1,'9780747532699', 11),
    (1,'9780747538492', 12),
    (1,'9780747542155', 13),
    (1,'9780747550794', 14),
    (2,'9780385086950', 15),
    (2,'9780670315413', 16),
    (2,'9780670451937', 17),
    (3,'9780593055045', 18),
    (3,'9780307474278', 19),
    (3,'9780316160179', 20)
GO


INSERT INTO Kunder  (
    Förnamn,
    Efternamn,
    KundAdress
)
VALUES
    ('Kalle', 'Anka', 'Storvägen 1'),
    ('Musse', 'Pigg', 'Musikantvägen 2'),
    ('Janne', 'Långben', 'Korsitaketvägen 3')
GO


INSERT INTO Ordrar  (
    ISBN13,
    KundID,
    ButikID
)
VALUES
    ('9780747532699', 'Anka', 'Storvägen 1'),
    ('9780385086950', 'Pigg', 'Musikantvägen 2'),
    ('9780307474278', 'Långben', 'Korsitaketvägen 3')
GO

CREATE VIEW TitlarPerFörfattare
AS
SELECT
    CONCAT(f.Förnamn, ' ', f.Efternamn) AS Namn,
    DATEDIFF(YEAR, f.Födelsedatum, GETDATE()) AS Ålder,
    COUNT(DISTINCT b.ISBN13) AS Titlar,
    SUM(b.Pris * ls.Antal) AS Lagervärde
FROM Författare f
JOIN Böcker b
    ON f.ID = b.FörfattareID
JOIN LagerSaldo ls
    ON b.ISBN13 = ls.ISBN13
GROUP BY
    f.Förnamn,
    f.Efternamn,
    f.Födelsedatum;
GO
