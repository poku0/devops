operator = input("Enter an operator (+, -, *, /): ")
num1 = int(input("Enter the first number: "))
num2 = int(input("Enter the second number: "))

if operator == "+":
    result = int(num1) + int(num2)
    print(f"The result is: {result}")
elif operator == "-":
    result = int(num1) - int(num2)
    print(f"The result is: {result}")
elif operator == "*":
    result = int(num1) * int(num2)
    print(f"The result is: {result}")
elif operator == "/":
    if num2 != 0:
        result = int(num1) / int(num2)
        print(f"The result is: {result}")
    else:
        print("Error: Division by zero is not allowed.")
else:
    print("Error: Invalid operator.")

