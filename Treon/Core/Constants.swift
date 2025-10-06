import Foundation
import OSLog
import SwiftUI

// MARK: - App Constants
public enum AppConstants {
    public static let bundleIdentifierRoot = "club.cycleruncode"
    public static let appName = "Treon"
    public static let websiteURL = URL(string: "https://cycleruncode.club")!
    public static let supportEmail = "support@cycleruncode.club"
    public static let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    public static let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
}

// MARK: - Logging
public enum Loggers {
    public static let subsystem = "club.cycleruncode.treon"
    public static let ui = Logger(subsystem: subsystem, category: "ui")
    public static let parsing = Logger(subsystem: subsystem, category: "parsing")
    public static let format = Logger(subsystem: subsystem, category: "format")
    public static let query = Logger(subsystem: subsystem, category: "query")
    public static let history = Logger(subsystem: subsystem, category: "history")
    public static let scripts = Logger(subsystem: subsystem, category: "scripts")
    public static let integrations = Logger(subsystem: subsystem, category: "integrations")
    public static let perf = Logger(subsystem: subsystem, category: "perf")
    public static let fileManager = Logger(subsystem: subsystem, category: "filemanager")
    public static let network = Logger(subsystem: subsystem, category: "network")
    public static let error = Logger(subsystem: subsystem, category: "error")
}

// MARK: - UI Constants
public enum UIConstants {
    // Window
    public static let defaultWindowWidth: CGFloat = 1200
    public static let defaultWindowHeight: CGFloat = 800
    public static let minimumWindowWidth: CGFloat = 800
    public static let minimumWindowHeight: CGFloat = 600
    
    // Button Sizing
    public static let buttonWidth: CGFloat = 160
    public static let buttonHeight: CGFloat = 44
    public static let buttonCornerRadius: CGFloat = 8
    public static let buttonSpacing: CGFloat = 16
    
    // Typography
    public static let buttonFontSize: CGFloat = 14
    public static let buttonFontWeight: Font.Weight = .medium
    public static let titleFontSize: CGFloat = 24
    public static let subtitleFontSize: CGFloat = 16
    public static let bodyFontSize: CGFloat = 14
    public static let captionFontSize: CGFloat = 12
    
    // Animation
    public static let hoverAnimationDuration: Double = 0.2
    public static let buttonPressAnimationDuration: Double = 0.1
    public static let fadeAnimationDuration: Double = 0.3
    
    // Spacing
    public static let smallSpacing: CGFloat = 8
    public static let mediumSpacing: CGFloat = 16
    public static let largeSpacing: CGFloat = 24
    public static let extraLargeSpacing: CGFloat = 40
    
    // Input Fields
    public static let textFieldWidth: CGFloat = 300
    public static let textFieldHeight: CGFloat = 32
    public static let multilineTextFieldWidth: CGFloat = 400
    public static let multilineTextFieldHeight: CGFloat = 60
    
    // Colors
    public static let primaryBlue = Color.blue
    public static let successGreen = Color.green
    public static let warningOrange = Color.orange
    public static let errorRed = Color.red
    public static let infoPurple = Color.purple
    public static let secondaryGray = Color.secondary
}

// MARK: - File Constants
public enum FileConstants {
    // File Size Limits
    public static let maxFileSize: Int64 = 50 * 1024 * 1024 // 50MB
    public static let maxJSONSize: Int64 = 10 * 1024 * 1024 // 10MB
    public static let maxRecentFiles: Int = 10
    
    // Supported File Types
    public static let supportedFileTypes: [String] = ["json", "txt"]
    public static let jsonFileExtensions: [String] = ["json"]
    
    // File Operations
    public static let defaultFileName = "Untitled"
    public static let pasteboardFileName = "Pasteboard Content"
    public static let urlFileName = "URL Content"
    public static let curlFileName = "cURL Response"
    
    // Timeouts
    public static let networkTimeout: TimeInterval = 30.0
    public static let fileOperationTimeout: TimeInterval = 10.0
}

// MARK: - Error Messages
public enum ErrorMessages {
    public static let fileNotFound = "File not found"
    public static let invalidJSON = "Invalid JSON format"
    public static let fileTooLarge = "File size exceeds maximum limit"
    public static let unsupportedFileType = "Unsupported file type"
    public static let permissionDenied = "Permission denied"
    public static let corruptedFile = "File appears to be corrupted"
    public static let networkError = "Network connection failed"
    public static let userCancelled = "Operation cancelled by user"
    public static let unknownError = "An unexpected error occurred"
    public static let invalidURL = "Invalid URL format"
    public static let curlCommandFailed = "cURL command execution failed"
    public static let emptyPasteboard = "No content found in pasteboard"
    public static let loadingFailed = "Failed to load content"
}

// MARK: - Success Messages
public enum SuccessMessages {
    public static let fileOpened = "File opened successfully"
    public static let fileSaved = "File saved successfully"
    public static let fileCreated = "File created successfully"
    public static let contentLoaded = "Content loaded successfully"
    public static let operationCompleted = "Operation completed successfully"
}

// MARK: - Localization Keys
public enum LocalizationKeys {
    public enum General {
        public static let ok = "general.ok"
        public static let cancel = "general.cancel"
        public static let save = "general.save"
        public static let open = "general.open"
        public static let close = "general.close"
        public static let retry = "general.retry"
        public static let loading = "general.loading"
        public static let error = "general.error"
        public static let success = "general.success"
    }
    
    public enum Errors {
        public static let parseFailed = "errors.parse_failed"
        public static let fileNotFound = "errors.file_not_found"
        public static let invalidJSON = "errors.invalid_json"
        public static let fileTooLarge = "errors.file_too_large"
        public static let unsupportedFileType = "errors.unsupported_file_type"
        public static let permissionDenied = "errors.permission_denied"
        public static let corruptedFile = "errors.corrupted_file"
        public static let networkError = "errors.network_error"
        public static let userCancelled = "errors.user_cancelled"
        public static let unknownError = "errors.unknown_error"
    }
    
    public enum UI {
        public static let openFile = "ui.open_file"
        public static let newFile = "ui.new_file"
        public static let fromPasteboard = "ui.from_pasteboard"
        public static let fromURL = "ui.from_url"
        public static let fromCurl = "ui.from_curl"
        public static let recentFiles = "ui.recent_files"
        public static let enterURL = "ui.enter_url"
        public static let enterCurlCommand = "ui.enter_curl_command"
        public static let load = "ui.load"
        public static let execute = "ui.execute"
    }
}

// MARK: - User Defaults Keys
public enum UserDefaultsKeys {
    public static let recentFiles = "recentFiles"
    public static let lastOpenedDirectory = "lastOpenedDirectory"
    public static let windowFrame = "windowFrame"
    public static let showLineNumbers = "showLineNumbers"
    public static let wordWrap = "wordWrap"
    public static let fontSize = "fontSize"
    public static let theme = "theme"
}

// MARK: - Notification Names
public enum NotificationNames {
    public static let fileOpened = Notification.Name("fileOpened")
    public static let fileSaved = Notification.Name("fileSaved")
    public static let fileCreated = Notification.Name("fileCreated")
    public static let errorOccurred = Notification.Name("errorOccurred")
    public static let operationCompleted = Notification.Name("operationCompleted")
}


