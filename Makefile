# Define the name of the output binary
BINARY_NAME=http-client

# Define the Go source files
SRC=get_request_example.go

# Use .PHONY to declare targets that are not actual files.
# This prevents conflicts with files of the same name and improves performance.
.PHONY: all build build-netgo

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

# Format the Go source files
fmt:
	@echo "Formatting source code..."
	@go fmt ./...

# Clean up the built binary
clean:
	@echo "Cleaning up..."
	@rm -f $(BINARY_NAME)
	@echo "Cleanup complete."