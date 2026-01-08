with open("file.txt", 'r') as file:
    lines = sum(1 for line in file)
    print('Total Number of lines:', lines)
