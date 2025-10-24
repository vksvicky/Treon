# Treon Xcode Project Makefile with Rust Backend

.PHONY: build test test-all test-rust test-swift test-integration test-quick test-legacy run-app run-cli clean install-hooks build-rust clean-rust deploy-rust-lib

# Build Rust backend first, then Swift app
build: build-rust
	xcodebuild -project Treon.xcodeproj -scheme Treon -configuration Debug build
	@echo "📦 Deploying Rust library to app bundle..."
	@$(MAKE) deploy-rust-lib
	@echo "✅ Build complete with Rust library deployed"

# Build Rust backend
build-rust:
	@echo "🔨 Building Rust backend..."
	cd rust_backend && cargo build --release
	@echo "✅ Rust backend built successfully"

# Deploy Rust library to app bundle
deploy-rust-lib:
	@echo "📦 Deploying Rust library to app bundle..."
	@# Find the app bundle in DerivedData
	@APP_BUNDLE=$$(find ~/Library/Developer/Xcode/DerivedData -name "Treon.app" -path "*/Build/Products/Debug/*" | head -1); \
	if [ -z "$$APP_BUNDLE" ]; then \
		echo "❌ App bundle not found. Please build the project first."; \
		exit 1; \
	fi; \
	echo "📱 Found app bundle: $$APP_BUNDLE"; \
	FRAMEWORKS_DIR="$$APP_BUNDLE/Contents/Frameworks"; \
	mkdir -p "$$FRAMEWORKS_DIR"; \
	cp rust_backend/target/release/libtreon_rust_backend.dylib "$$FRAMEWORKS_DIR/"; \
	echo "✅ Rust library deployed to: $$FRAMEWORKS_DIR/libtreon_rust_backend.dylib"

# Clean Rust backend
clean-rust:
	@echo "🧹 Cleaning Rust backend..."
	cd rust_backend && cargo clean
	@echo "✅ Rust backend cleaned"

# Test targets
test: test-all

test-all:
	bash scripts/test_all.sh

test-rust:
	bash scripts/test_rust.sh

test-swift:
	bash scripts/test_swift.sh

test-integration:
	bash scripts/test_integration.sh

test-quick:
	bash scripts/test_quick.sh

# Legacy test target (runs all tests)
test-legacy:
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
	@echo "📦 Deploying Rust library to app bundle..."
	@$(MAKE) deploy-rust-lib
	@echo "✅ Development build complete"

# Production build
prod: build-rust
	@echo "🚀 Starting production build..."
	xcodebuild -project Treon.xcodeproj -scheme Treon -configuration Release build
	@echo "📦 Deploying Rust library to app bundle..."
	@$(MAKE) deploy-rust-lib
	@echo "✅ Production build complete"

