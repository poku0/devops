class Person:
    def __init__(self):
        self.__name = "Povilas"
        self.__age = 24
    def get_private_vars(self):
        return self.__name, self.__age

object = Person()
# print(object.get_private_vars())
print(object.get_private_vars())
