from sqlalchemy import create_engine
from sqlalchemy import text


engine = create_engine(
    "mssql+pyodbc://Forsting_studie/BookStoreDB?driver=ODBC+Driver+17+for+SQL+Server&trusted_connection=yes"
) 

query = text("""
SELECT
    b.Titel,
    bu.Butiksnamn,
    ls.Antal
FROM Böcker b
JOIN LagerSaldo ls
    ON b.ISBN13 = ls.ISBN13
JOIN Butiker bu
    ON ls.ButikID = bu.ID
WHERE b.Titel LIKE :search
""")

while True:
    searchTitle = input("Sök boktitel (tom rad avslutar): ")
    if searchTitle == "":
        break

    with engine.connect() as conn:
        result = conn.execute(query, {"search": f"%{searchTitle}%"})
        resultsFound = False

        for row in result:
            print(f"{row.Titel} | {row.Butiksnamn} | {row.Antal} st")
            resultsFound = True

        if not resultsFound:
            print("Inga böcker hittades.")