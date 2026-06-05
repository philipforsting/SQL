USE everyloop;
GO

DROP TABLE IF EXISTS
    SuccessfulMissions,
    NewUsers
GO



/* MoonMissions */

/* Använd ”select into” för att ta ut kolumnerna ’Spacecraft’, ’Launch date’,
’Carrier rocket’, ’Operator’, samt ’Mission type’ för alla lyckade uppdrag
(Successful outcome) och sätt in i en ny tabell med namn ”SuccessfulMissions”. */
SELECT 
    [Spacecraft],
    [Launch date],
    [Carrier rocket],
    [Operator],
    [Mission type]
INTO
    SuccessfulMissions
FROM 
    MoonMissions
WHERE Outcome = 'Successful';

GO

/* I kolumnen ’Operator’ har det smugit sig in ett eller flera mellanslag före
operatörens namn skriv en query som uppdaterar ”SuccessfulMissions” och tar
bort mellanslagen kring operatör. */ 
UPDATE 
    SuccessfulMissions
SET
    Operator = TRIM(Operator)
GO

/* Skriv en select query som tar ut, grupperar, samt sorterar på kolumnerna
’Operator’ och ’Mission type’ från ”SuccessfulMissions”. Som en tredje kolumn
’Mission count’ i resultatet vill vi ha antal uppdrag av varje operatör och typ. Ta
bara med de grupper som har fler än ett (>1) uppdrag av samma typ och
operatör. */
select * from SuccessfulMissions

SELECT 
    [Operator],
    [Mission type],
    COUNT(*) AS 'Mission count'
FROM 
    SuccessfulMissions
GROUP BY
    [Operator],
    [Mission type]
HAVING 
    COUNT(*) >1; 
GO

/* Users
Ta ut samtliga rader och kolumner från tabellen ”Users”, men slå ihop
’Firstname’ och ’Lastname’ till en ny kolumn ’Name’, samt lägg till en extra
kolumn ’Gender’ som du ger värdet ’Female’ för alla användare vars näst sista
siffra i personnumret är jämn, och värdet ’Male’ för de användare där siffran är
udda. Sätt in resultatet i en ny tabell ”NewUsers”.*/
SELECT
    *,
    FirstName + ' ' + LastName AS 'Name',
    CASE 
        WHEN (CAST(SUBSTRING(ID, LEN(ID)-1, 1) AS INT) % 2 = 0) /* CAST() AS INT-> Stringtoint, SUBSTRING() -> Maskning av näst sista siffran  */
            THEN 'Female'
        ELSE 'Male'
    END AS 'Gender'
INTO
    NewUsers
FROM 
    Users
GO


/*Skriv en query som returnerar en tabell med alla användarnamn i ”NewUsers”
som inte är unika i den första kolumnen, och antalet gånger de är duplicerade i
den andra kolumnen. */
SELECT
    [UserName],
    COUNT(*) AS 'Nr of duplicates'
FROM 
    NewUsers
GROUP BY
    UserName
HAVING
    COUNT(UserName) > 1
GO



/*Skriv en följd av queries som uppdaterar de användare med dubblerade
användarnamn som du fann ovan, så att alla användare får ett unikt
användarnamn. D.v.s du kan hitta på nya användarnamn för de användarna, så
länge du ser till att alla i ”NewUsers” har unika värden på ’Username’. */
ALTER TABLE NewUsers
ALTER COLUMN UserName VARCHAR(50);

-- Inspiration: https://stackoverflow.com/questions/62335295/add-a-unique-id-number-to-duplicate-rows-sql
WITH CTE AS
(
    SELECT
        ID, UserName, ROW_NUMBER() OVER(PARTITION BY UserName ORDER BY ID) AS RowNumber
    FROM NewUsers
)

UPDATE CTE
SET UserName =
    CASE
        WHEN RowNumber = 1 THEN UserName
        ELSE UserName + '_' + CAST(RowNumber AS VARCHAR)
    END;
GO

/*Skapa en query som tar bort alla kvinnor födda före 1970 från ”NewUsers”. */
DELETE FROM 
    NewUsers
WHERE  
    Gender = 'Female' AND  (CAST(SUBSTRING(ID, 1, 6) AS INT) < 700101);
GO

/*Lägg till en ny användare i tabellen ”NewUsers”.*/
INSERT INTO
    NewUsers(
        ID,
        UserName,
        Password,
        FirstName,
        LastName,
        Email,
        Phone,
        Name,
        Gender
    )
VALUES
    ('123456-7890',
     'kallea', 
     'abc123', 
     'Kalle', 
     'Anka', 
     'kalle@anka.se', 
     '031-123456', 
     'Kalle Anka', 
     'Male')
GO


/* Company (Joins)
Skriv en query som selectar ut alla (77) produkter i company.products
Dessa ska visas i 4 kolumner:
Id – produktens id
Product – produktens namn
Supplier – namnet på företaget som leverar produkten
Category – namnet på kategorin som produkten tillhör
GO */
SELECT
    p.Id,
    p.ProductName AS Product,
    s.CompanyName AS Supplier,
    c.CategoryName AS Category
FROM company.products p
JOIN company.suppliers s ON p.SupplierId = s.Id
JOIN company.categories c ON p.CategoryId = c.Id
GO

/* Skriv en query som listar antal anställda i var och en av de fyra regionerna i
tabellen company.regions
GO */ 

SELECT
    r.RegionDescription,
    COUNT(DISTINCT et.EmployeeId) AS 'Nr of employees per region'


FROM company.regions r
JOIN company.territories t ON r.Id = t.RegionId
JOIN company.employee_territory et ON t.Id = et.TerritoryId
GROUP BY r.RegionDescription
GO
