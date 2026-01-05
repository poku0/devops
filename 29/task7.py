class Vehicle:
    def start(self):
        return "Vehicle started"
    def stop(self):
        return "Vehicle stopped"

class Car(Vehicle):
    def start(self):
        return "Car started - engine roaring"
    def stop(self):
        return "Car stopped - brakes applied"
    
class Truck(Vehicle):
    def start(self):
        return "Truck started - heavy duty engine"
    def stop(self):
        return "Truck stopped - air brakes applied"
    
class Motorcycle(Vehicle):
    def start(self):
        return "Motorcycle started - engine revving"
    def stop(self):
        return "Motorcycle stopped - engine cut off"

vehicle = Vehicle()
car = Car()
truck = Truck()
motorcycle = Motorcycle()

print(vehicle.start())
print(car.start())
print(truck.start())
print(motorcycle.start())

print(vehicle.stop())
print(car.stop())
print(truck.stop())
print(motorcycle.stop())