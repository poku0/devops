class Shape:
    def area(self):
        return 0
    def perimeter(self):
        return 0
    
class Rectangle(Shape):
    def __init__(self):
        self.width = 10
        self.height = 5
    def area(self):
        return self.width * self.height
    def perimeter(self):
        return 2 * (self.width + self.height)
    
class Circle(Shape):
    def __init__(self):
        self.radius = 7
    def area(self):
        return 3.14 * self.radius * self.radius
    def perimeter(self):
        return 2 * 3.14 * self.radius
    
rectangle = Rectangle()
circle = Circle()

print(f"Rectangle: Area = {rectangle.area()}, Perimeter = {rectangle.perimeter()}")
print(f"Circle: Area = {circle.area()}, Perimeter = {circle.perimeter()}")
