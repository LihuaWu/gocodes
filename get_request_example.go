package main

import (
	"context"
	"flag"
	"fmt"
	"io"
	"log"
	"net"
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
		log.Printf("--- Making Request #%d ---", i+1)
		if err := makeRequest(url); err != nil {
			log.Printf("Error on request #%d: %v", i+1, err)
		}
		time.Sleep(time.Second)
	}
}

func makeRequest(url string) error {
	// Create a custom dialer that will be used by the transport.
	dialer := &net.Dialer{
		Timeout:   5 * time.Second, // Timeout for the connection phase.
		KeepAlive: 30 * time.Second,
	}

	client := &http.Client{
		Timeout: 15 * time.Second, // Overall request timeout.
		Transport: &http.Transport{
			// This setting forces a new connection for every request.
			DisableKeepAlives: true,
			// This custom DialContext is the key to forcing IPv4.
			// It wraps the dialer and overrides the network type.
			DialContext: func(ctx context.Context, network, addr string) (net.Conn, error) {
				// Force the network to be 'tcp4' for IPv4 only.
				return dialer.DialContext(ctx, "tcp4", addr)
			},
		},
	}
	resp, err := client.Get(url)
	if err != nil {
		// If the request fails (e.g., network error, DNS lookup failure, timeout),
		// return an error instead of exiting to allow the loop to continue.
		return fmt.Errorf("error fetching URL: %w", err)
	}

	// It is crucial to close the response body when you are done with it.
	defer resp.Body.Close()

	// Print the HTTP status from the response.
	fmt.Printf("Status: %s\n", resp.Status)
	fmt.Printf("Status Code: %d\n", resp.StatusCode)

	_, err = io.Copy(io.Discard, resp.Body)
	if err != nil {
		// If there's an error reading the response body, log it and exit.
		return fmt.Errorf("error reading response body: %w", err)
	}
	return nil
}
