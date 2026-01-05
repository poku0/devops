class Employee:
    def __init__(self, name, salary):
        self.name = name
        self.salary = salary


class Manager(Employee):
    def __init__(self, name, salary, team_size):
        super().__init__(name, salary)
        self.team_size = team_size


class Engineer(Employee):
    def __init__(self, name, salary, programming_language):
        super().__init__(name, salary)
        self.programming_language = programming_language


class Intern(Employee):
    def __init__(self, name, salary):
        super().__init__(name, salary)


manager = Manager("Jonas", 85000, 10)
engineer = Engineer("Tomas", 70000, "Python")
intern = Intern("Paulius", 30000)

print(manager.name, manager.salary, manager.team_size)
print(engineer.name, engineer.salary, engineer.programming_language)
print(intern.name, intern.salary)

