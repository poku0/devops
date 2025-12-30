class Animal:
    sound = "meow"

    def make_sound(self):
        return self.sound
    
cat = Animal()
print(cat.make_sound())
