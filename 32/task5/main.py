from database import SessionLocal, engine
from models import Base, Book

def create_tables():
    Base.metadata.create_all(engine)

def add_book():
    session = SessionLocal()

    title = input("Title: ")
    author = input("Author: ")
    year = input("Year: ")

    book = Book(title=title, author=author, year=int(year))

    session.add(book)
    session.commit()
    session.close()

    print("Book added successfully!")

def view_book():
    session = SessionLocal()
    books = session.query(Book).all()

    if not books:
        print("No books found.")
    else:
        for book in books:
            print(f"{book.id}: {book.title} by {book.author} ({book.year})")

    session.close()

def update_book():
    session = SessionLocal()
    book_id = int(input("Enter book ID to update: "))
    
    book = session.query(Book).get(book_id)

    if not book:
        print("Book not found.")
        session.close()
        return  
    
    book.title = input(f"New title ({book.title}): ") or book.title
    book.author = input(f"New author ({book.author}): ") or book.author
    book.year = input(f"New year ({book.year}): ") or book.year

    session.commit()
    session.close()

    print("Book updated.")

def delete_book():
    session = SessionLocal()
    book_id = int(input("Enter book ID to delete: "))

    book = session.query(Book).get(book_id)

    if not book: 
        print("Book not found.")
    else:
        session.delete(book)
        session.commit()
        print("Book deleted.")

    session.close()

def menu():
    while True:
        print("\nBook Manager")
        print("1. Add Book")
        print("2. View Books")
        print("3. Update Book")
        print("4. Delete Book")
        print("5. Exit")

        choice = input("Enter your choice: ")

        if choice == "1":
            add_book()
        elif choice == "2":
            view_book()
        elif choice == "3":
            update_book()
        elif choice == "4":
            delete_book()
        elif choice == "5":
            break
        else:
            print("Invalid choice.")

if __name__ == "__main__":
    create_tables()
    menu()
