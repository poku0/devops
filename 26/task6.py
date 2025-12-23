sentence = input("Enter a sentence: ")

sentence = sentence.lower()
letter_count = {}

for letter in sentence:
    if letter.isalpha():
        if letter in letter_count:
            letter_count[letter] += 1
        else:
            letter_count[letter] = 1

print(letter_count)
