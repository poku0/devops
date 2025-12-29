def create_email(first_name, last_name, domain="codeacademy.lt"):
    first = first_name.replace(" ", "").lower()
    last = last_name.replace(" ", "").lower()
    return f"{first}.{last}@{domain}"


# print(create_email("John Paul", "Smith"))  # Expected: "johnpaul.smith@codeacademy.lt"
print(create_email("Anna", "Doe", "gmail.com"))  # Expected: "anna.doe@gmail.com"