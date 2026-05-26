from sqlalchemy import create_engine, text
from getpass import getpass

server = 'localhost'
database = 'Bokhandel'
username = 'sa'
password = getpass('Password: ')

connection_string = (
    f"mssql+pyodbc://{username}:{password}@{server}/{database}"
    "?driver=ODBC+Driver+18+for+SQL+Server"
    "&TrustServerCertificate=yes"
)

engine = create_engine(connection_string)

sokord = input('Sök efter boktitel: ')

query = text("""
SELECT
    Böcker.Titel,
    Butiker.Butiknamn,
    LagerSaldo.Antal
FROM Böcker
JOIN LagerSaldo
    ON Böcker.ISBN13 = LagerSaldo.ISBN13
JOIN Butiker
    ON LagerSaldo.ButikID = Butiker.ID
WHERE Böcker.Titel LIKE :sokning
""")

with engine.connect() as connection:
    result = connection.execute(
        query, 
        {'sokning': f'%{sokord}%'}
    )
    print('\nResultat:\n')

    for row in result:
        print(
            f"Bok: {row.Titel} | "
            f"Butik: {row.Butiknamn} | "
            f"Antal: {row.Antal}"
        )