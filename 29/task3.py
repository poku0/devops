class Shape:
    def area(self):
        return 0
    
class Rectangle(Shape):
    def __init__(self):
        self.width = 10
        self.height = 5
    def area(self):
        return self.width * self.height
    
class Circle(Shape):
    def __init__(self):
        self.radius = 7
    def area(self):
        return 3.14 * self.radius * self.radius
    
rectangle = Rectangle()
circle = Circle()
print(rectangle.area())
print(circle.area())