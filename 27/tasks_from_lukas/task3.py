def create_acronym(*args):
    acronym = ""
    for word in args:
        acronym += word[0].upper()
    return acronym

# print(create_acronym("Code", "Academy", "Lithuania"))  # Expected: "CAL"
print(create_acronym("Hyper", "Text", "Markup", "Language"))  # Expected: "HTML"