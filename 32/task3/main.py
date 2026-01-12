from sqlalchemy import create_engine, Column, Integer, String
from sqlalchemy.orm import declarative_base, sessionmaker

# Create engine that connects to existing SQLite DB)
engine = create_engine("sqlite:///my_database.db", echo=True)

Base = declarative_base()

# define table as python class (same as CREATE TABLE user)
class User(Base):
    __tablename__ = "user"

    name = Column(String, primary_key=True)
    age = Column(Integer)

# create table if doesn't exist
Base.metadata.create_all(engine)

# create a session (replaces cursor)
Session = sessionmaker(bind=engine)
session = Session()

# insert data
session.add_all([
    User(name="Povilas", age=37),
    User(name="Tomas", age=29),
    User(name="Jonas", age=41),
])

# commit changes
session.commit()

# update data
povilas = session.query(User).filter_by(name="Povilas").first()
povilas.age = 42

# commit changes
session.commit()

# select and print data (same as SELECT)
users = session.query(User).all()

for user in users:
    print(user.name, user.age)

# close session
session.close()
