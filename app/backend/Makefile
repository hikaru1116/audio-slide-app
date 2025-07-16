.PHONY: build test coverage mocks clean dev lint

# Go parameters
GOCMD=go
GOBUILD=$(GOCMD) build
GOCLEAN=$(GOCMD) clean
GOTEST=$(GOCMD) test
GOGET=$(GOCMD) get
GOMOD=$(GOCMD) mod
BINARY_NAME=audio-slide-app
BINARY_UNIX=$(BINARY_NAME)_unix

# Build the application
build:
	$(GOBUILD) -o $(BINARY_NAME) -v ./cmd/api

# Test all packages
test:
	$(GOTEST) -v ./...

# Generate test coverage report
coverage:
	$(GOTEST) -race -coverprofile=coverage.out -covermode=atomic ./...
	$(GOCMD) tool cover -html=coverage.out -o coverage.html

# Generate mocks
mocks:
	$(GOCMD) generate ./...

# Clean build artifacts
clean:
	$(GOCLEAN)
	rm -f $(BINARY_NAME)
	rm -f $(BINARY_UNIX)
	rm -f coverage.out
	rm -f coverage.html

# Run the application in development mode
dev:
	$(GOCMD) run ./cmd/api/main.go

# Lint the code
lint:
	golangci-lint run

# Download dependencies
deps:
	$(GOMOD) download
	$(GOMOD) tidy

# Build for Linux
build-linux:
	CGO_ENABLED=0 GOOS=linux GOARCH=amd64 $(GOBUILD) -o $(BINARY_UNIX) -v ./cmd/api

# Install dependencies
install-deps:
	$(GOGET) go.uber.org/mock/mockgen@latest
	$(GOGET) github.com/golangci/golangci-lint/cmd/golangci-lint@latest