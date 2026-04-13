package main

import (
	"fmt"
)

func main() {
	phoneBook := make(map[string]string)

	phoneBook["Alice"] = "555-0101"
	phoneBook["Bob"] = "555-0202"
	phoneBook["Charlie"] = "555-0303"
	phoneBook["Diana"] = "555-0404"
	phoneBook["Edward"] = "555-0505"

	fmt.Println("Entire Phone Book:")
	for name, number := range phoneBook {
		fmt.Printf("- %s: %s\n", name, number)
	}
	fmt.Println()

	nameToFind := "Alice"
	if number, ok := phoneBook[nameToFind]; ok {
		fmt.Printf("Looking up %s: %s\n", nameToFind, number)
	} else {
		fmt.Printf("Contact %s not found\n", nameToFind)
	}

	nameNotFound := "Frank"
	if number, ok := phoneBook[nameNotFound]; ok {
		fmt.Printf("Looking up %s: %s\n", nameNotFound, number)
	} else {
		fmt.Println("Contact not found")
	}
	fmt.Println()

	fmt.Println("Updating Bob's number...")
	phoneBook["Bob"] = "555-9999"

	fmt.Println("Deleting Edward...")
	delete(phoneBook, "Edward")
	fmt.Println()

	fmt.Println("Final Phone Book:")
	for name, number := range phoneBook {
		fmt.Printf("- %s: %s\n", name, number)
	}
	fmt.Printf("Total contacts: %d\n", len(phoneBook))
}
