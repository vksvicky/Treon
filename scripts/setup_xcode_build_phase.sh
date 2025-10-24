#!/bin/bash
set -euo pipefail

# Script to add Rust library deployment as a build phase in Xcode
# This script modifies the project.pbxproj file to include the deployment script

echo "🔧 Setting up Xcode build phase for Rust library deployment..."

PROJECT_FILE="Treon.xcodeproj/project.pbxproj"
SCRIPT_PATH="scripts/deploy_rust_lib.sh"

# Check if the script exists
if [ ! -f "$SCRIPT_PATH" ]; then
    echo "❌ Deployment script not found at: $SCRIPT_PATH"
    exit 1
fi

# Make sure the script is executable
chmod +x "$SCRIPT_PATH"

# Create a backup of the project file
cp "$PROJECT_FILE" "$PROJECT_FILE.backup"
echo "📋 Created backup: $PROJECT_FILE.backup"

# Check if the build phase already exists
if grep -q "deploy_rust_lib.sh" "$PROJECT_FILE"; then
    echo "✅ Build phase already exists in Xcode project"
    exit 0
fi

echo "⚠️  Manual setup required:"
echo ""
echo "To add the Rust library deployment to your Xcode build process:"
echo ""
echo "1. Open Treon.xcodeproj in Xcode"
echo "2. Select the 'Treon' target in the project navigator"
echo "3. Go to the 'Build Phases' tab"
echo "4. Click the '+' button and select 'New Run Script Phase'"
echo "5. Set the script to:"
echo "   bash \${SRCROOT}/scripts/deploy_rust_lib.sh"
echo "6. Move this phase to run AFTER 'Copy Bundle Resources'"
echo "7. Name it 'Deploy Rust Library'"
echo ""
echo "Alternatively, you can run the app using the Makefile:"
echo "   make run-app"
echo ""
echo "This will automatically build and deploy the Rust library."
