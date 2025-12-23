# can use min() and max() functions

# list = input("Enter a list of numbers separated by spaces: ").split()

# max_num = max(map(int, list))
# print(f"The maximum number is: {max_num}")

# min_num = min(map(int, list))
# print(f"The minimum number is: {min_num}")
# ================================================================

list = input("Enter a list of numbers separated by spaces: ").split()

max_num = 0
min_num = 0

for i in list:
    if int(i) > int(max_num):
        max_num = i
print(f"The maximum number is: {max_num}")

for i in list:
    if int(i) < int(min_num):
        min_num = i
print(f"The minimum number is: {min_num}")
