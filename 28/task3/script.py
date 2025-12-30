class Rectangle:
    def __init__(self, length, width):
        self.length = length
        self.width = width

    def area(self):
        return self.length * self.width
    
    def perimeter(self):
        return 2 * (self.length + self.width)
    

r1 = Rectangle(5, 3)
print("r1")
print("Area:", r1.area())
print("Perimeter:", r1.perimeter())
print("")

r2 = Rectangle(5, 10)
print("r2")
print("Area:", r2.area())
print("Perimeter:", r2.perimeter())
print("")


r3 = Rectangle(7, 14)
print("r3")
print("Area:", r3.area())
print("Perimeter:", r3.perimeter())
print("")


