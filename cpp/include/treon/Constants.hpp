#pragma once

#include <QString>
#include <QUrl>
#include <QSize>

namespace treon {

// MARK: - App Constants
namespace AppConstants {
    constexpr const char* bundleIdentifierRoot = "club.cycleruncode";
    constexpr const char* appName = "Treon";
    constexpr const char* websiteURL = "https://cycleruncode.club";
    constexpr const char* supportEmail = "support@cycleruncode.club";
    constexpr const char* version = "1.0.0";
    constexpr const char* buildNumber = "1";
}

// MARK: - UI Constants
namespace UIConstants {
    // Window
    constexpr int defaultWindowWidth = 1200;
    constexpr int defaultWindowHeight = 800;
    constexpr int minimumWindowWidth = 800;
    constexpr int minimumWindowHeight = 600;

    // Button Sizing
    constexpr int buttonWidth = 160;
    constexpr int buttonHeight = 44;
    constexpr int buttonCornerRadius = 8;
    constexpr int buttonSpacing = 16;

    // Typography
    constexpr int buttonFontSize = 14;
    constexpr int titleFontSize = 24;
    constexpr int subtitleFontSize = 16;
    constexpr int bodyFontSize = 14;
    constexpr int captionFontSize = 12;

    // Animation
    constexpr double hoverAnimationDuration = 0.2;
    constexpr double buttonPressAnimationDuration = 0.1;
    constexpr double fadeAnimationDuration = 0.3;

    // Spacing
    constexpr int smallSpacing = 8;
    constexpr int mediumSpacing = 16;
    constexpr int largeSpacing = 24;
    constexpr int extraLargeSpacing = 40;

    // Input Fields
    constexpr int textFieldWidth = 300;
    constexpr int textFieldHeight = 32;
    constexpr int multilineTextFieldWidth = 400;
    constexpr int multilineTextFieldHeight = 60;
}

// MARK: - File Constants
namespace FileConstants {
    // File Size Limits
    constexpr qint64 maxFileSize = 500 * 1024 * 1024; // 500MB
    constexpr qint64 sizeSlackBytes = 2 * 1024; // 2KB
    constexpr qint64 maxJSONSize = 10 * 1024 * 1024; // 10MB
    constexpr int maxRecentFiles = 10;

    // Supported File Types
    constexpr const char* supportedFileTypes[] = {"json", "txt"};
    constexpr const char* jsonFileExtensions[] = {"json"};

    // File Operations
    constexpr const char* defaultFileName = "Untitled";
    constexpr const char* pasteboardFileName = "Pasteboard Content";
    constexpr const char* urlFileName = "URL Content";
    constexpr const char* curlFileName = "cURL Response";

    // Timeouts
    constexpr int networkTimeout = 30000; // 30 seconds
    constexpr int fileOperationTimeout = 10000; // 10 seconds
}

// MARK: - Error Messages
namespace ErrorMessages {
    constexpr const char* fileNotFound = "File not found";
    constexpr const char* invalidJSON = "Invalid JSON format";
    constexpr const char* fileTooLarge = "File size exceeds maximum limit";
    constexpr const char* unsupportedFileType = "Unsupported file type";
    constexpr const char* permissionDenied = "Permission denied";
    constexpr const char* corruptedFile = "File appears to be corrupted";
    constexpr const char* networkError = "Network connection failed";
    constexpr const char* userCancelled = "Operation cancelled by user";
    constexpr const char* unknownError = "An unexpected error occurred";
    constexpr const char* invalidURL = "Invalid URL format";
    constexpr const char* curlCommandFailed = "cURL command execution failed";
    constexpr const char* emptyPasteboard = "No content found in pasteboard";
    constexpr const char* loadingFailed = "Failed to load content";
}

// MARK: - Success Messages
namespace SuccessMessages {
    constexpr const char* fileOpened = "File opened successfully";
    constexpr const char* fileSaved = "File saved successfully";
    constexpr const char* fileCreated = "File created successfully";
    constexpr const char* contentLoaded = "Content loaded successfully";
    constexpr const char* operationCompleted = "Operation completed successfully";
}

// MARK: - User Defaults Keys
namespace UserDefaultsKeys {
    constexpr const char* recentFiles = "recentFiles";
    constexpr const char* lastOpenedDirectory = "lastOpenedDirectory";
    constexpr const char* windowFrame = "windowFrame";
    constexpr const char* showLineNumbers = "showLineNumbers";
    constexpr const char* wordWrap = "wordWrap";
    constexpr const char* fontSize = "fontSize";
    constexpr const char* theme = "theme";
}

} // namespace treon
