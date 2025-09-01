# Define the name of the output binary
BINARY_NAME=http-client

# Define the Go source files
SRC=get_request_example.go

# Define default arguments for the run commands. Can be overridden from the command line.
# Example: make run ARGS=https://www.bing.com
ARGS  ?= https://www.google.com
FLAGS ?=

# Use .PHONY to declare targets that are not actual files.
# This prevents conflicts with files of the same name and improves performance.
.PHONY: all build build-netgo run run-debug run-debug-netgo run-strace fmt clean help

# The default goal executed when you just run `make`
all: build

# A self-documenting help target
help:
	@echo "Usage: make [target]"
	@echo ""
	@echo "You can pass flags via FLAGS. Example: make run FLAGS=\"-http2=false\""
	@echo "You can override the default URL by passing ARGS. Example: make run ARGS=https://example.com"
	@echo ""
	@echo "Targets:"
	@echo "  build           Build the application using the system's cgo resolver."
	@echo "  build-netgo     Build the application using the pure Go resolver."
	@echo "  run             Run the compiled application (cgo version)."
	@echo "  run-netgo       Run the compiled application (netgo version)."
	@echo "  run-debug       Run the cgo-built application with network debug logs."
	@echo "  run-debug-netgo Run the netgo-built app with network debug logs."
	@echo "  run-strace      Trace network system calls on Linux using strace."
	@echo "  fmt             Format the Go source code."
	@echo "  clean           Remove the compiled binary."
	@echo "  help            Show this help message."

# Build the Go application
build: fmt
	@echo "Building the application..."
	@go build -o $(BINARY_NAME) $(SRC)
	@echo "Build complete: ./$(BINARY_NAME)"

# Build the application using the pure Go DNS resolver (no cgo for networking).
# This creates a more portable, static binary.
build-netgo: fmt
	@echo "Building with pure Go resolver (-tags netgo)..."
	@go build -tags netgo -o $(BINARY_NAME) $(SRC)
	@echo "Build complete: ./$(BINARY_NAME)"

# Run the compiled application
run: build
	@echo "Running the application..."
	@./$(BINARY_NAME) $(FLAGS) $(ARGS)

# Run the netgo-built application
run-netgo: build-netgo
	@echo "Running the netgo-built application..."
	@./$(BINARY_NAME) $(FLAGS) $(ARGS)

# Run the application with GODEBUG for verbose network logging
# netdns=1: Traces DNS lookups.
# http1trace=1: Traces HTTP/1.1 requests.
# http2debug=2: Traces HTTP/2 frames with verbose detail.
run-debug: build
	@echo "Running with GODEBUG enabled..."
	@GODEBUG=netdns=1,http1trace=1,http2debug=2 ./$(BINARY_NAME) $(FLAGS) $(ARGS)

run-debug-netgo: build-netgo
	@echo "Running netgo build with GODEBUG enabled..."
	@GODEBUG=netdns=1,http1trace=1,http2debug=2 ./$(BINARY_NAME) $(FLAGS) $(ARGS)

# Trace network system calls on Linux.
run-strace: build
	@echo "Tracing network system calls with strace..."
	@strace -e trace=network ./$(BINARY_NAME) $(FLAGS) $(ARGS)

# Format the Go source files
fmt:
	@echo "Formatting source code..."
	@go fmt ./...

# Clean up the built binary
clean:
	@echo "Cleaning up..."
	@rm -f $(BINARY_NAME)
	@echo "Cleanup complete."