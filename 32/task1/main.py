import sqlite3

# Connect to SQLite database
conn = sqlite3.connect("my_database.db")
# create cursor
cursor = conn.cursor()

# drop table if exists
cursor.execute("DROP TABLE IF EXISTS user;")
# create table
cursor.execute("CREATE TABLE user (name TEXT, age INTEGER);")
# insert data into table
cursor.execute("INSERT INTO user (name, age) VALUES ('Povilas', 37);")
cursor.execute("INSERT INTO user (name, age) VALUES ('Tomas', 29);")
cursor.execute("INSERT INTO user (name, age) VALUES ('Jonas', 41);")

# modify data
cursor.execute("UPDATE user SET age = 42 WHERE name = 'Povilas';")

# commit changes
conn.commit()

cursor.execute("SELECT * FROM user;")
rows = cursor.fetchall()
for row in rows:
    print(row)

# close connection
conn.close()
