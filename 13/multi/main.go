package main
import "fmt"

func main() {
	v := 42
	fmt.Println("The variable value is",v)
	var p *int = &v
	fmt.Println("The value pointed to is:",*p)
	fmt.Println("The address to the value is: ",p)
	*p = 21
	fmt.Println(p)
	fmt.Println(*p)
}