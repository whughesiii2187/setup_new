package main

import "fmt"

func main() {
	colors := map[string]string{
		"red": "#ff0000",
		"green": "#008000",
		"white": "#ffffff",
	}

	iterateMap(colors)	
}

func iterateMap(c map[string]string) {
	for color,hex := range c {
		fmt.Printf("Color %v : hex %v\n", color,hex)
	}
}
