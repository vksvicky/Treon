# Treon Xcode Project Makefile with Rust Backend

.PHONY: build test run-app run-cli clean install-hooks build-rust clean-rust

# Build Rust backend first, then Swift app
build: build-rust
	xcodebuild -project Treon.xcodeproj -scheme Treon -configuration Debug build

# Build Rust backend
build-rust:
	@echo "🔨 Building Rust backend..."
	cd rust_backend && cargo build --release
	@echo "✅ Rust backend built successfully"

# Clean Rust backend
clean-rust:
	@echo "🧹 Cleaning Rust backend..."
	cd rust_backend && cargo clean
	@echo "✅ Rust backend cleaned"

test:
	xcodebuild -project Treon.xcodeproj -scheme Treon -configuration Debug test

run-app: build
	bash scripts/run_app.sh

run-cli:
	bash scripts/run_cli.sh

clean: clean-rust
	xcodebuild -project Treon.xcodeproj -scheme Treon clean
	rm -rf build/

install-hooks:
	@echo "Installing git hooks..."
	@mkdir -p .git/hooks
	@cp scripts/git-hooks/pre-push .git/hooks/pre-push
	@chmod +x .git/hooks/pre-push
	@echo "Git hooks installed."

# Development targets
dev: build-rust
	@echo "🚀 Starting development build..."
	xcodebuild -project Treon.xcodeproj -scheme Treon -configuration Debug build
	@echo "✅ Development build complete"

# Production build
prod: build-rust
	@echo "🚀 Starting production build..."
	xcodebuild -project Treon.xcodeproj -scheme Treon -configuration Release build
	@echo "✅ Production build complete"

