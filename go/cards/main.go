package main

func main (){
	// cards := newDeck()
	//
	// player, remainingCards := deal(cards,5)
	//
	// player.print()
	// remainingCards.print()

	// cards := newDeck()
	// cards.saveToFile("my_cards")

	// cards := newDeckFromFile("my_cards")
	// cards.print()

	cards := newDeck()
	cards.shuffleDeck()
	cards.print()

}
