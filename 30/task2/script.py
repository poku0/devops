# create a function that takes 2 numbers and divides them
def division(a, b):
    try:
        print(a / b)
    except ZeroDivisionError: # handle division by zero
        print("Error: Division by zero is not allowed.")


input1 = input("Enter the first number: ")
input2 = input("Enter the second number: ")

try:
    num1 = float(input1) # convert input to float
    num2 = float(input2) # using float instead of int to allow decimal numbers 
    division(num1, num2)
except ValueError:
    print("Error: Please enter valid numbers.") # handle non-numeric input
