package main

import (
	"fmt"
	"net/http"
	"time"
)

func main() {
	links := []string{
		"https://google.com",
		"https://facebook.com",
		"https://amazon.com",
		"https://golang.org",
		"https://aur.archlinux.org",
	}

	c := make(chan string)

	for _, link := range links {
		go requests(link, c)
	}

	for l := range c {
		go func() {
			time.Sleep(5 * time.Second)
			requests(l, c)
		}()
	}
}

func requests(link string, c chan string) {
	_, err := http.Get(link)

	if err != nil {
		fmt.Println(link, "might be down!")
		c <- link
		return
	}

	fmt.Println(link, "is up!")
	c <- link
}
