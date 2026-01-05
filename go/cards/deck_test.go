package main

import (
	"os"
	"testing"
)

func TestNewDeck(t *testing.T) {
	d := newDeck()

	if len(d) != 52 {
		t.Errorf("Expected length of 52 but got %v\n", len(d))
	}

	if d[0] != "Ace of Clubs" {
		t.Errorf("Expected first card to be Ace of Clubs but got %v\n", d[0])
	}
	
	if d[len(d) - 1] != "King of Spades" {
		t.Errorf("Expected last card to be King of Spades but got %v\n", d[len(d) - 1])
	}

}

func TestSaveToDeckAndNewDeckFromFile(t *testing.T) {
	os.Remove("_decktesting")

	deck := newDeck()
	deck.saveToFile("_decktesting")

	loadedDeck := newDeckFromFile("_decktesting")

	if len(loadedDeck) != 52 {
		t.Errorf("Expected 52 cards and received %v\n",len(loadedDeck))
	}

}

