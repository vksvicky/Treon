# Treon Xcode Project Makefile

.PHONY: build test run-app run-cli clean install-hooks

build:
	xcodebuild -project Treon.xcodeproj -scheme Treon -configuration Debug build
	@$(MAKE) install-hooks

test:
	xcodebuild -project Treon.xcodeproj -scheme Treon -configuration Debug test

run-app:
	bash scripts/run_app.sh

run-cli:
	bash scripts/run_cli.sh

clean:
	xcodebuild -project Treon.xcodeproj -scheme Treon clean
	rm -rf build/

install-hooks:
	@echo "Installing git hooks..."
	@mkdir -p .git/hooks
	@cp scripts/git-hooks/pre-push .git/hooks/pre-push
	@chmod +x .git/hooks/pre-push
	@echo "Git hooks installed."

