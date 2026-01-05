package main

import "fmt"

type bot interface{
	getGreeting() string
}

type englishBot struct{}
type spanishBot struct{}

func main() {
	eb := englishBot{}
	sp := spanishBot{}

	printGreeting(eb)
	printGreeting(sp)
}

func printGreeting(b bot) {
	fmt.Println(b.getGreeting())
}

func (englishBot) getGreeting() string {
	// custom logic for english
	return "Hello there!"
}

func (spanishBot) getGreeting() string {
	// custom logic for spanish
	return "Hola, ahi!"
}

