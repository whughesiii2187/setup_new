package main

import (
	"bookingapp/helper"
	"fmt"
	"strings"
)

var conferenceName = "Go Conference"
const conferenceTickets = 50
var remainingTickets = 50
var bookings = []string{}

func greeting() {
	fmt.Printf("Welcome to our %v convention booking app.\n", conferenceName)
	fmt.Printf("Whe have a total of %v total and we have %v still available.\n", conferenceTickets, remainingTickets)
	fmt.Println("Get your tickets here to attend!")
}

func getFirstNames() []string {
	firstNames := []string{}
	for _, booking := range bookings {
		var names = strings.Fields(booking)
		firstNames = append(firstNames, names[0])
	}
	return firstNames
}

func getUserInput()(string,string,string,int){
		var userFName string
		var userLName string
		var userEmail string
		var userTickets int

		fmt.Println("Please enter your first name")
		fmt.Scan(&userFName)

		fmt.Println("Please enter your last name")
		fmt.Scan(&userLName)

		fmt.Println("Please enter your email address")
		fmt.Scan(&userEmail)

		fmt.Println("How many tickets would you like?")
		fmt.Scan(&userTickets)

		return userFName, userLName, userEmail, userTickets
}

func bookTicket(userFName string, userLName string, userEmail string, userTickets int){
	remainingTickets = remainingTickets - userTickets
	bookings = append(bookings, userFName+" "+userLName)

	fmt.Printf("Thank you, %v %v for booking %v tickets. You will recieve an email with your confirmation at %v\n", userFName, userLName, userTickets, userEmail)
	fmt.Printf("%v tickets remaining for %v\n", remainingTickets, conferenceName)
}

func main() {

	greeting()

	for {

		userFName,userLName,userEmail,userTickets := getUserInput()
		isValidName, isValidEmail, isValidTicketCount := helper.ValidateInput(userFName, userLName, userEmail, userTickets, remainingTickets)

		if isValidName && isValidEmail && isValidTicketCount {

			bookTicket(userFName,userLName,userEmail,userTickets)
			firstNames := getFirstNames()
			fmt.Printf("The following people have signed up %v\n", firstNames)

			if remainingTickets == 0 {
				fmt.Println("All tickets are sold. Try again next time.")
				break
			}
		} else {
			if !isValidName {
				fmt.Println("First or Last Name entered is too short")
			}
			if !isValidEmail {
				fmt.Println("Email entered does not contain @")
			}
			if !isValidTicketCount {
				fmt.Println("Ticket count requested is invalid")
			}
		}
	}
}
