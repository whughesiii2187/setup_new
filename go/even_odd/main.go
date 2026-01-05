package main

import "fmt"

func main() {
	var loopme []int

	for i := range 11 {
		loopme = append(loopme,i)
	}

	for _,j := range loopme {
		if j % 2 == 0 {
			fmt.Printf("%v is even\n", j)
		} else {
			fmt.Printf("%v is odd\n", j)
		}
	}
}
