#!/bin/bash

# Script to create macOS app icon from PNG

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
ICON_PNG="$PROJECT_ROOT/Treon.png"
ICONSET_DIR="$SCRIPT_DIR/icon.iconset"
ICNS_FILE="$SCRIPT_DIR/icon.icns"

echo "Creating macOS app icon from Treon.png..."

# Check if PNG file exists
if [ ! -f "$ICON_PNG" ]; then
    echo "Error: Treon.png not found at $ICON_PNG"
    exit 1
fi

# Create iconset directory
rm -rf "$ICONSET_DIR"
mkdir -p "$ICONSET_DIR"

# Check if sips is available (macOS built-in image tool)
if command -v sips >/dev/null 2>&1; then
    echo "Using sips for PNG conversion..."
    
    # Create different icon sizes
    sips -z 16 16 "$ICON_PNG" --out "$ICONSET_DIR/icon_16x16.png"
    sips -z 32 32 "$ICON_PNG" --out "$ICONSET_DIR/icon_16x16@2x.png"
    sips -z 32 32 "$ICON_PNG" --out "$ICONSET_DIR/icon_32x32.png"
    sips -z 64 64 "$ICON_PNG" --out "$ICONSET_DIR/icon_32x32@2x.png"
    sips -z 128 128 "$ICON_PNG" --out "$ICONSET_DIR/icon_128x128.png"
    sips -z 256 256 "$ICON_PNG" --out "$ICONSET_DIR/icon_128x128@2x.png"
    sips -z 256 256 "$ICON_PNG" --out "$ICONSET_DIR/icon_256x256.png"
    sips -z 512 512 "$ICON_PNG" --out "$ICONSET_DIR/icon_256x256@2x.png"
    sips -z 512 512 "$ICON_PNG" --out "$ICONSET_DIR/icon_512x512.png"
    sips -z 1024 1024 "$ICON_PNG" --out "$ICONSET_DIR/icon_512x512@2x.png"
    
elif command -v convert >/dev/null 2>&1; then
    echo "Using ImageMagick convert for PNG conversion..."
    
    # Create different icon sizes
    convert -resize 16x16 "$ICON_PNG" "$ICONSET_DIR/icon_16x16.png"
    convert -resize 32x32 "$ICON_PNG" "$ICONSET_DIR/icon_16x16@2x.png"
    convert -resize 32x32 "$ICON_PNG" "$ICONSET_DIR/icon_32x32.png"
    convert -resize 64x64 "$ICON_PNG" "$ICONSET_DIR/icon_32x32@2x.png"
    convert -resize 128x128 "$ICON_PNG" "$ICONSET_DIR/icon_128x128.png"
    convert -resize 256x256 "$ICON_PNG" "$ICONSET_DIR/icon_128x128@2x.png"
    convert -resize 256x256 "$ICON_PNG" "$ICONSET_DIR/icon_256x256.png"
    convert -resize 512x512 "$ICON_PNG" "$ICONSET_DIR/icon_256x256@2x.png"
    convert -resize 512x512 "$ICON_PNG" "$ICONSET_DIR/icon_512x512.png"
    convert -resize 1024x1024 "$ICON_PNG" "$ICONSET_DIR/icon_512x512@2x.png"
    
else
    echo "Error: Neither sips nor ImageMagick convert found."
    echo "Please install ImageMagick:"
    echo "  macOS: brew install imagemagick"
    exit 1
fi

# Create the .icns file
echo "Creating .icns file..."
iconutil -c icns "$ICONSET_DIR" -o "$ICNS_FILE"

# Clean up iconset directory
rm -rf "$ICONSET_DIR"

echo "✅ App icon created successfully: $ICNS_FILE"
echo "Icon sizes created: 16x16, 32x32, 128x128, 256x256, 512x512 (including @2x variants)"
