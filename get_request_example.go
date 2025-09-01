package main

import (
	"flag"
	"fmt"
	"io"
	"log"
	"net/http"
	"time"
)

func main() {
	var url string
	var count int
	flag.StringVar(&url, "url", "https://www.google.com", "url to fetch")
	flag.IntVar(&count, "count", 1, "number of requests to make")
	flag.Parse()

	for i := 0; i < count; i++ {
		_ = makeRequest(url)
		time.Sleep(time.Second)
	}
	time.Sleep(time.Second * 5)
}

func makeRequest(url string) error {
	client := &http.Client{
		Timeout: 15 * time.Second,
	}
	resp, err := client.Get(url)
	if err != nil {
		// If the request fails (e.g., network error, DNS lookup failure, timeout),
		// log the error and exit the program.
		log.Fatalf("Error fetching URL: %v", err)
	}

	// It is crucial to close the response body when you are done with it.
	// `defer` ensures this happens at the end of the function.
	// If you don't close it, you can leak resources (like file descriptors).
	defer resp.Body.Close()

	// Print the HTTP status from the response.
	// e.g., 200 OK, 404 Not Found, etc.
	fmt.Printf("Status: %s\n", resp.Status)
	fmt.Printf("Status Code: %d\n", resp.StatusCode)

	_, err = io.Copy(io.Discard, resp.Body)
	if err != nil {
		// If there's an error reading the response body, log it and exit.
		log.Fatalf("Error reading response body: %v", err)
	}
	return nil
}
