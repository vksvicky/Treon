# Treon Xcode Project Makefile

.PHONY: build test run-app run-cli clean

build:
	xcodebuild -project Treon.xcodeproj -scheme Treon -configuration Debug build

test:
	xcodebuild -project Treon.xcodeproj -scheme Treon -configuration Debug test

run-app:
	bash scripts/run_app.sh

run-cli:
	bash scripts/run_cli.sh

clean:
	xcodebuild -project Treon.xcodeproj -scheme Treon clean
	rm -rf build/

