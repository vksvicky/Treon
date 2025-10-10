#!/bin/bash
set -euo pipefail

echo "Removing Swift files and Xcode project..."

# Remove Swift source files
echo "Removing Swift source files..."
rm -rf Treon/
rm -rf TreonTests/
rm -rf TreonUITests/

# Remove Xcode project
echo "Removing Xcode project..."
rm -rf Treon.xcodeproj/

# Remove Swift-specific files
echo "Removing Swift-specific files..."
rm -f Package.swift
rm -f Package.resolved
rm -rf .swiftpm/

# Remove build artifacts
echo "Removing build artifacts..."
rm -rf build/
rm -rf DerivedData/

# Update .gitignore to remove Swift-specific entries
echo "Updating .gitignore..."
cat > .gitignore << 'EOF'
# C++ Build artifacts
cpp/build/
cpp/CMakeCache.txt
cpp/CMakeFiles/
cpp/cmake_install.cmake
cpp/Makefile
cpp/*.cmake

# Qt specific
*.pro.user
*.pro.user.*
*.qbs.user
*.qbs.user.*
*.moc
moc_*.cpp
moc_*.h
qrc_*.cpp
ui_*.h
*.qm
*.prl

# IDE files
.vscode/
.idea/
*.swp
*.swo
*~

# OS files
.DS_Store
Thumbs.db

# Temporary files
*.tmp
*.temp
EOF

echo "Swift files removed successfully!"
echo "The project is now a pure C++ implementation."
