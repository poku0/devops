class Person:
    def __init__(self, name, age):
        self.name = name
        self.age = age

class Student(Person):
    def __init__(self, name, age, grade):
        super().__init__(name, age)
        self.grade = grade

Person = Person("Povilas", 24)
Student = Student("Povilas", 24, "A")

print(f"Person: Name = {Person.name}, Age = {Person.age}")
print(f"Student: Name = {Student.name}, Age = {Student.age}, Grade = {Student.grade}")

