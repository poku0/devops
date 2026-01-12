from sqlalchemy import Column, Integer, String
from database import Base

class Book(Base):
    __tablename__ = "books"

    id = Column(Integer, primary_key=True)
    title = Column(String, nullable=False)
    author = Column(String, nullable=False)
    year = Column(Integer)

    def __repr__(self):
        return f"<Book(title='{self.title}', author='{self.author}', year={self.year})>"
    
