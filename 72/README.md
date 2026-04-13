# Go: Maps and Structs - Practice Tasks

## Task 1: Phone Book (Maps Basics)

Create a program that simulates a simple phone book using a map.

**Requirements:**
1. Create a `map[string]string` to store contacts where the key is the person's name and the value is their phone number.
2. Add at least 5 contacts to the phone book.
3. Print the entire phone book.
4. Look up a contact that exists and print their number.
5. Look up a contact that does **not** exist — use the second return value (`ok`) to print `"Contact not found"`.
6. Update one contact's phone number.
7. Delete one contact from the phone book.
8. Print the final phone book and the total number of contacts using `len`.

---

## Task 2: Word Counter (Maps)

Write a program that counts how many times each word appears in a given sentence.

**Requirements:**
1. Define a string variable with a sentence of your choice (at least 10 words, with some repeated words).
2. Split the sentence into words (hint: use `strings.Split`).
3. Use a `map[string]int` to count occurrences of each word.
4. Iterate over the map and print each word with its count.

**Example output:**
```
"the" appears 3 times
"go" appears 2 times
"is" appears 1 time
```

---

## Task 3: Student Grades (Maps + Iteration)

Create a program that manages student grades.

**Requirements:**
1. Create a `map[string][]int` where the key is the student's name and the value is a slice of their grades.
2. Add at least 3 students with 3–5 grades each.
3. Write a function `averageGrade(grades []int) float64` that calculates the average of a slice of grades.
4. Iterate over the map and print each student's name, their grades, and their average grade.
5. Find and print who has the highest average grade.

---

## Task 4: Simple Struct (Structs Basics)

Create a program that models a `Book` struct.

**Requirements:**
1. Define a `Book` struct with the following fields: `Title` (string), `Author` (string), `Pages` (int), `IsRead` (bool).
2. Create at least 3 `Book` instances using different initialization methods:
   - Positional values: `Book{"Title", "Author", 200, false}`
   - Named fields: `Book{Title: "...", Author: "..."}`
   - Named fields with some omitted (zero-valued)
3. Print all books.
4. Access and modify one book's `IsRead` field to `true`.
5. Print the updated book.

---

## Task 5: Struct with Methods

Create a program that models a `Rectangle` struct with methods.

**Requirements:**
1. Define a `Rectangle` struct with fields `Width` and `Height` (both `float64`).
2. Define a method `Area()` that returns the area of the rectangle.
3. Define a method `Perimeter()` that returns the perimeter of the rectangle.
4. Define a method `IsSquare()` that returns `true` if the rectangle is a square.
5. Create at least 2 rectangles (one square, one non-square) and print their area, perimeter, and whether they are a square.

---

## Task 6: Pointers to Structs

Create a program that demonstrates struct pointers.

**Requirements:**
1. Define an `Employee` struct with fields: `Name` (string), `Position` (string), `Salary` (float64).
2. Write a function `promote(e *Employee, newPosition string, raise float64)` that:
   - Changes the employee's position to `newPosition`
   - Increases their salary by `raise` amount
3. Create an employee, print their details, call `promote`, and print their details again to show the values changed via pointer.

---

## Task 7: Map of Structs (Combined)

Create a program that combines maps and structs to build a simple inventory system.

**Requirements:**
1. Define a `Product` struct with fields: `Name` (string), `Price` (float64), `Quantity` (int).
2. Create a `map[string]Product` where the key is the product ID (e.g., `"SKU001"`).
3. Add at least 4 products to the inventory.
4. Write a function `totalInventoryValue(inventory map[string]Product) float64` that calculates the total value of all products (`Price * Quantity` for each).
5. Print the full inventory with product IDs.
6. Simulate a "purchase" — decrease the quantity of one product by 1. Remember: you cannot modify a struct field directly in a map — you must copy, modify, and reassign.
7. Print the updated inventory and the new total value.

---

## Task 8: Struct Embedding & Anonymous Structs (Advanced)

Create a program that uses anonymous structs and explores struct composition.

**Requirements:**
1. Define an `Address` struct with fields: `Street` (string), `City` (string), `Country` (string).
2. Define a `Person` struct with fields: `Name` (string), `Age` (int), and an embedded `Address` field (struct embedding).
3. Create a `Person` instance and demonstrate accessing the address fields directly (e.g., `person.City` instead of `person.Address.City`).
4. Create an anonymous struct variable that holds a `Name` (string) and `Score` (int), assign it values, and print it.

---

## Bonus Task: Contact Manager (Full Application)

Build a small interactive contact manager using everything you've learned.

**Requirements:**
1. Define a `Contact` struct with: `Name`, `Email`, `Phone` (all strings).
2. Use a `map[string]Contact` as the contact storage (key = name).
3. Implement the following functions:
   - `addContact(contacts map[string]Contact, c Contact)` — adds a contact
   - `deleteContact(contacts map[string]Contact, name string)` — deletes a contact
   - `findContact(contacts map[string]Contact, name string) (Contact, bool)` — finds a contact by name
   - `listContacts(contacts map[string]Contact)` — prints all contacts
4. In `main()`, demonstrate all four operations: add several contacts, find one, delete one, and list all remaining contacts.

---

**Good luck! Remember to run your programs with `go run filename.go` and check the output.**