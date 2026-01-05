package main

import "fmt"

type shape interface {
	getArea() float64
}

type triangle struct {
	base float64
	height float64
}
type square struct {
	side float64
}

func main() {

	t := triangle{base: 10, height: 10}
	s := square{side: 10}

	printArea(t)
	printArea(s)

}

func (t triangle) getArea() float64 {
	return 0.5 * t.base * t.height
}

func (s square) getArea() float64 {
	return s.side * s.side
}

func printArea(s shape) {
	fmt.Println(s.getArea())
}

