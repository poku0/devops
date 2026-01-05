class Car:
    def __init__(self, engine_type, car_model):
        self.engine_type = engine_type
        self.car_model = car_model

class Airplane:
    def __init__(self, plane_model, wingspan, max_altitude, tyres):
        self.plane_model = plane_model
        self.wingspan = wingspan
        self.max_altitude = max_altitude
        self.tyres = tyres

class FlyingCar(Car, Airplane):
    def __init__(self, engine_type, car_model, plane_model, wingspan, max_altitude, tyres):
        Car.__init__(self, engine_type, car_model)
        Airplane.__init__(self, plane_model, wingspan, max_altitude, tyres)    
        self.model = car_model + " " + plane_model

flying_car = FlyingCar("V8", "BMW", "Boeing", 15.0, 12000, 6)
print(f"Flying Car: Engine Type = {flying_car.engine_type}, Model = {flying_car.model}, Wingspan = {flying_car.wingspan}, Max Altitude = {flying_car.max_altitude}, Tyres = {flying_car.tyres}")
