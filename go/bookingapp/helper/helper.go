package helper

import ( "strings")

func ValidateInput(userFName string, userLName string, userEmail string, userTickets int, remainingTickets int) (bool, bool, bool) {
	isValidName := len(userFName) >= 2 && len(userLName) >= 2
	isValidEmail := strings.Contains(userEmail, "@")
	isValidTicketCount := userTickets > 0 && userTickets <= remainingTickets

	return isValidName, isValidEmail, isValidTicketCount
}
