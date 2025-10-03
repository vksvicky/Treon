#!/bin/zsh
set -euo pipefail
# Build and run the Treon app from Xcode project
xcodebuild -project Treon.xcodeproj -scheme Treon -configuration Debug -derivedDataPath build
open build/Build/Products/Debug/Treon.app

