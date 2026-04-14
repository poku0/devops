package main
import "fmt"

func main() {
	i, j := 2, 9

	p := &i
	fmt.Println(*p)
	*p = 1
	fmt.Println(i)

	p = &j
	*p = *p / 3
	fmt.Println(j)
}