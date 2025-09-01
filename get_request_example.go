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
	flag.StringVar(&url, "url", "https://www.baidu.com", "url to fetch")
	flag.IntVar(&count, "count", 3, "number of requests to make")
	flag.Parse()

	// --- Configuration Phase ---
	// Create a single, reusable dialer and client.
	dialer := &net.Dialer{
		Timeout:   5 * time.Second, // Timeout for the connection phase.
		KeepAlive: 30 * time.Second,
	}
	client := &http.Client{
		Timeout: 15 * time.Second, // Overall request timeout.
		Transport: &http.Transport{
			// Requirement: Disable TCP connection reuse.
			DisableKeepAlives: true,
			// Requirement: Disable DNS lookup reuse by performing it manually.
			DialContext: func(ctx context.Context, network, addr string) (net.Conn, error) {
				// Manually resolve the hostname to bypass any in-process DNS cache.
				host, port, err := net.SplitHostPort(addr)
				if err != nil {
					return nil, err
				}

				// By creating a new resolver for each Dial, we signal our intent
				// to avoid any long-lived resolver-level caches within the Go program.
				resolver := net.Resolver{}
				addrs, err := resolver.LookupHost(ctx, host)
				if err != nil {
					return nil, err
				}
				if len(addrs) == 0 {
					return nil, fmt.Errorf("no addresses found for %s", host)
				}

				// Dial the first resolved IP address directly.
				dialAddr := net.JoinHostPort(addrs[0], port)
				// Force the network to be 'tcp4' for IPv4 only.
				return dialer.DialContext(ctx, "tcp4", dialAddr)
			},
		},
	}

	// --- Execution Phase ---
	for i := 0; i < count; i++ {
		log.Printf("--- Making Request #%d ---", i+1)
		if err := makeRequest(client, url); err != nil {
			log.Printf("Error on request #%d: %v", i+1, err)
		}
		time.Sleep(time.Second)
	}
}

func makeRequest(client *http.Client, url string) error {
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
