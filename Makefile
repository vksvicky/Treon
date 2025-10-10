# Treon C++ Project Makefile

.PHONY: build test run-app clean install-hooks setup-deps

# Default target
all: build

# Setup dependencies (Qt6)
setup-deps:
	@echo "Setting up dependencies..."
	@if ! command -v qmake6 &> /dev/null; then \
		echo "Error: Qt6 not found. Please install Qt6:"; \
		echo "  macOS: brew install qt6"; \
		echo "  Ubuntu: sudo apt install qt6-base-dev qt6-declarative-dev"; \
		echo "  Windows: Download from https://www.qt.io/download"; \
		exit 1; \
	fi
	@echo "Qt6 found: $$(qmake6 -version | head -1)"

# Build the C++ application
build: setup-deps
	@echo "Building Treon C++ application..."
	cd cpp && bash build.sh
	@$(MAKE) install-hooks

# Run tests
test: build
	@echo "Running tests..."
	cd cpp/build && ctest -C Debug --output-on-failure

# Run the application
run-app: build
	@echo "Running Treon application..."
	./scripts/run_app.sh debug

# Run in release mode
run-release: build
	@echo "Running Treon application in release mode..."
	./scripts/run_app.sh release

# Development mode
dev: 
	@echo "Starting development mode..."
	./scripts/dev_run.sh run

# Watch mode for development
watch:
	@echo "Starting watch mode..."
	./scripts/dev_run.sh watch

# Debug mode
debug:
	@echo "Starting debug mode..."
	./scripts/dev_run.sh debug

# Profile mode
profile:
	@echo "Starting profile mode..."
	./scripts/dev_run.sh profile

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	rm -rf cpp/build/
	rm -rf build/

# Install git hooks
install-hooks:
	@echo "Installing git hooks..."
	@mkdir -p .git/hooks
	@cp scripts/git-hooks/pre-push .git/hooks/pre-push
	@chmod +x .git/hooks/pre-push
	@echo "Git hooks installed."

# Development setup
dev-setup: setup-deps install-hooks
	@echo "Development environment ready!"
	@echo "Run 'make build' to build the application"
	@echo "Run 'make test' to run tests"
	@echo "Run 'make run-app' to run the application"

