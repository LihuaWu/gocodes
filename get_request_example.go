package main

import (
	"context"
	"flag"
	"fmt"
	"io"
	"log"
	"net"
	"net/http"
	"os"
	"time"
)

func main() {
	// Define command-line flags to control behavior.
	enableHTTP2 := flag.Bool("http2", true, "Enable HTTP/2 protocol")
	flag.Parse()

	// Best practice: Don't use the default client in production code.
	// Create a custom client with a reasonable timeout to prevent the program
	// from hanging indefinitely. To control protocol versions, we customize the Transport.

	// By default, Go's transport will try to negotiate HTTP/2.
	// We can control this behavior with our flag.
	transport := http.DefaultTransport.(*http.Transport).Clone()
	transport.ForceAttemptHTTP2 = *enableHTTP2

	dialer := &net.Dialer{
		Timeout:   30 * time.Second, // Timeout for the connection phase
		KeepAlive: 30 * time.Second,
	}

	// To force the use of IPv4, we must customize the DialContext.
	// We create a closure that calls the dialer's DialContext method,
	// but overrides the 'network' parameter to be 'tcp4'.
	transport.DialContext = func(ctx context.Context, network, addr string) (net.Conn, error) {
		return dialer.DialContext(ctx, "tcp4", addr)
	}

	client := &http.Client{
		// The transport is responsible for the details of the HTTP transaction.
		Transport: transport,
		// The client-level timeout covers the entire exchange.
		// Note: The transport's DialContext timeout is part of this overall timeout.
		Timeout: 15 * time.Second,
	}

	// Make the program a flexible tool by accepting the URL as a command-line argument.
	if len(flag.Args()) < 1 {
		log.Fatalf("Usage: %s [flags] <URL>", os.Args[0])
	}
	url := flag.Args()[0]
	fmt.Printf("Fetching URL: %s (HTTP/2 enabled: %v)\n\n", url, *enableHTTP2)

	// Use the custom client's Get method. This request will now fail if it
	// takes longer than 15 seconds to complete.
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

	// Read the entire response body.
	_, err = io.ReadAll(resp.Body)
	if err != nil {
		// If there's an error reading the response body, log it and exit.
		log.Fatalf("Error reading response body: %v", err)
	}

}
