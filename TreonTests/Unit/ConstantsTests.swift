import XCTest
import Foundation
import SwiftUI
@testable import Treon

class ConstantsTests: XCTestCase {
    
    // MARK: - App Constants Tests
    
    func testAppConstants() {
        XCTAssertEqual(AppConstants.bundleIdentifierRoot, "club.cycleruncode")
        XCTAssertEqual(AppConstants.appName, "Treon")
        XCTAssertNotNil(AppConstants.websiteURL)
        XCTAssertEqual(AppConstants.supportEmail, "support@cycleruncode.club")
        XCTAssertNotNil(AppConstants.version)
        XCTAssertNotNil(AppConstants.buildNumber)
    }
    
    // MARK: - UI Constants Tests
    
    func testUIConstants() {
        // Window constants
        XCTAssertEqual(UIConstants.defaultWindowWidth, 1200)
        XCTAssertEqual(UIConstants.defaultWindowHeight, 800)
        XCTAssertEqual(UIConstants.minimumWindowWidth, 800)
        XCTAssertEqual(UIConstants.minimumWindowHeight, 600)
        
        // Button constants
        XCTAssertEqual(UIConstants.buttonWidth, 160)
        XCTAssertEqual(UIConstants.buttonHeight, 44)
        XCTAssertEqual(UIConstants.buttonCornerRadius, 8)
        XCTAssertEqual(UIConstants.buttonSpacing, 16)
        
        // Typography constants
        XCTAssertEqual(UIConstants.buttonFontSize, 14)
        XCTAssertEqual(UIConstants.titleFontSize, 24)
        XCTAssertEqual(UIConstants.subtitleFontSize, 16)
        XCTAssertEqual(UIConstants.bodyFontSize, 14)
        XCTAssertEqual(UIConstants.captionFontSize, 12)
        
        // Animation constants
        XCTAssertEqual(UIConstants.hoverAnimationDuration, 0.2)
        XCTAssertEqual(UIConstants.buttonPressAnimationDuration, 0.1)
        XCTAssertEqual(UIConstants.fadeAnimationDuration, 0.3)
        
        // Spacing constants
        XCTAssertEqual(UIConstants.smallSpacing, 8)
        XCTAssertEqual(UIConstants.mediumSpacing, 16)
        XCTAssertEqual(UIConstants.largeSpacing, 24)
        XCTAssertEqual(UIConstants.extraLargeSpacing, 40)
        
        // Input field constants
        XCTAssertEqual(UIConstants.textFieldWidth, 300)
        XCTAssertEqual(UIConstants.textFieldHeight, 32)
        XCTAssertEqual(UIConstants.multilineTextFieldWidth, 400)
        XCTAssertEqual(UIConstants.multilineTextFieldHeight, 60)
    }
    
    func testUIConstantsColors() {
        // Test that color constants are accessible
        let _ = UIConstants.primaryBlue
        let _ = UIConstants.successGreen
        let _ = UIConstants.warningOrange
        let _ = UIConstants.errorRed
        let _ = UIConstants.infoPurple
        let _ = UIConstants.secondaryGray
        
        // Colors should be SwiftUI Color types
        XCTAssertTrue(UIConstants.primaryBlue is Color)
        XCTAssertTrue(UIConstants.successGreen is Color)
        XCTAssertTrue(UIConstants.warningOrange is Color)
        XCTAssertTrue(UIConstants.errorRed is Color)
        XCTAssertTrue(UIConstants.infoPurple is Color)
        XCTAssertTrue(UIConstants.secondaryGray is Color)
    }
    
    // MARK: - File Constants Tests
    
    func testFileConstants() {
        // File size limits
        XCTAssertEqual(FileConstants.maxFileSize, 50 * 1024 * 1024) // 50MB
        XCTAssertEqual(FileConstants.maxJSONSize, 10 * 1024 * 1024) // 10MB
        XCTAssertEqual(FileConstants.maxRecentFiles, 10)
        
        // Supported file types
        XCTAssertTrue(FileConstants.supportedFileTypes.contains("json"))
        XCTAssertTrue(FileConstants.supportedFileTypes.contains("txt"))
        XCTAssertTrue(FileConstants.jsonFileExtensions.contains("json"))
        
        // File operations
        XCTAssertEqual(FileConstants.defaultFileName, "Untitled")
        XCTAssertEqual(FileConstants.pasteboardFileName, "Pasteboard Content")
        XCTAssertEqual(FileConstants.urlFileName, "URL Content")
        XCTAssertEqual(FileConstants.curlFileName, "cURL Response")
        
        // Timeouts
        XCTAssertEqual(FileConstants.networkTimeout, 30.0)
        XCTAssertEqual(FileConstants.fileOperationTimeout, 10.0)
    }
    
    // MARK: - Error Messages Tests
    
    func testErrorMessages() {
        XCTAssertEqual(ErrorMessages.fileNotFound, "File not found")
        XCTAssertEqual(ErrorMessages.invalidJSON, "Invalid JSON format")
        XCTAssertEqual(ErrorMessages.fileTooLarge, "File size exceeds maximum limit")
        XCTAssertEqual(ErrorMessages.unsupportedFileType, "Unsupported file type")
        XCTAssertEqual(ErrorMessages.permissionDenied, "Permission denied")
        XCTAssertEqual(ErrorMessages.corruptedFile, "File appears to be corrupted")
        XCTAssertEqual(ErrorMessages.networkError, "Network connection failed")
        XCTAssertEqual(ErrorMessages.userCancelled, "Operation cancelled by user")
        XCTAssertEqual(ErrorMessages.unknownError, "An unexpected error occurred")
        XCTAssertEqual(ErrorMessages.invalidURL, "Invalid URL format")
        XCTAssertEqual(ErrorMessages.curlCommandFailed, "cURL command execution failed")
        XCTAssertEqual(ErrorMessages.emptyPasteboard, "No content found in pasteboard")
        XCTAssertEqual(ErrorMessages.loadingFailed, "Failed to load content")
    }
    
    // MARK: - Success Messages Tests
    
    func testSuccessMessages() {
        XCTAssertEqual(SuccessMessages.fileOpened, "File opened successfully")
        XCTAssertEqual(SuccessMessages.fileSaved, "File saved successfully")
        XCTAssertEqual(SuccessMessages.fileCreated, "File created successfully")
        XCTAssertEqual(SuccessMessages.contentLoaded, "Content loaded successfully")
        XCTAssertEqual(SuccessMessages.operationCompleted, "Operation completed successfully")
    }
    
    // MARK: - Localization Keys Tests
    
    func testLocalizationKeys() {
        // General keys
        XCTAssertEqual(LocalizationKeys.General.ok, "general.ok")
        XCTAssertEqual(LocalizationKeys.General.cancel, "general.cancel")
        XCTAssertEqual(LocalizationKeys.General.save, "general.save")
        XCTAssertEqual(LocalizationKeys.General.open, "general.open")
        XCTAssertEqual(LocalizationKeys.General.close, "general.close")
        XCTAssertEqual(LocalizationKeys.General.retry, "general.retry")
        XCTAssertEqual(LocalizationKeys.General.loading, "general.loading")
        XCTAssertEqual(LocalizationKeys.General.error, "general.error")
        XCTAssertEqual(LocalizationKeys.General.success, "general.success")
        
        // Error keys
        XCTAssertEqual(LocalizationKeys.Errors.parseFailed, "errors.parse_failed")
        XCTAssertEqual(LocalizationKeys.Errors.fileNotFound, "errors.file_not_found")
        XCTAssertEqual(LocalizationKeys.Errors.invalidJSON, "errors.invalid_json")
        XCTAssertEqual(LocalizationKeys.Errors.fileTooLarge, "errors.file_too_large")
        XCTAssertEqual(LocalizationKeys.Errors.unsupportedFileType, "errors.unsupported_file_type")
        XCTAssertEqual(LocalizationKeys.Errors.permissionDenied, "errors.permission_denied")
        XCTAssertEqual(LocalizationKeys.Errors.corruptedFile, "errors.corrupted_file")
        XCTAssertEqual(LocalizationKeys.Errors.networkError, "errors.network_error")
        XCTAssertEqual(LocalizationKeys.Errors.userCancelled, "errors.user_cancelled")
        XCTAssertEqual(LocalizationKeys.Errors.unknownError, "errors.unknown_error")
        
        // UI keys
        XCTAssertEqual(LocalizationKeys.UI.openFile, "ui.open_file")
        XCTAssertEqual(LocalizationKeys.UI.newFile, "ui.new_file")
        XCTAssertEqual(LocalizationKeys.UI.fromPasteboard, "ui.from_pasteboard")
        XCTAssertEqual(LocalizationKeys.UI.fromURL, "ui.from_url")
        XCTAssertEqual(LocalizationKeys.UI.fromCurl, "ui.from_curl")
        XCTAssertEqual(LocalizationKeys.UI.recentFiles, "ui.recent_files")
        XCTAssertEqual(LocalizationKeys.UI.enterURL, "ui.enter_url")
        XCTAssertEqual(LocalizationKeys.UI.enterCurlCommand, "ui.enter_curl_command")
        XCTAssertEqual(LocalizationKeys.UI.load, "ui.load")
        XCTAssertEqual(LocalizationKeys.UI.execute, "ui.execute")
    }
    
    // MARK: - User Defaults Keys Tests
    
    func testUserDefaultsKeys() {
        XCTAssertEqual(UserDefaultsKeys.recentFiles, "recentFiles")
        XCTAssertEqual(UserDefaultsKeys.lastOpenedDirectory, "lastOpenedDirectory")
        XCTAssertEqual(UserDefaultsKeys.windowFrame, "windowFrame")
        XCTAssertEqual(UserDefaultsKeys.showLineNumbers, "showLineNumbers")
        XCTAssertEqual(UserDefaultsKeys.wordWrap, "wordWrap")
        XCTAssertEqual(UserDefaultsKeys.fontSize, "fontSize")
        XCTAssertEqual(UserDefaultsKeys.theme, "theme")
    }
    
    // MARK: - Notification Names Tests
    
    func testNotificationNames() {
        XCTAssertEqual(NotificationNames.fileOpened.rawValue, "fileOpened")
        XCTAssertEqual(NotificationNames.fileSaved.rawValue, "fileSaved")
        XCTAssertEqual(NotificationNames.fileCreated.rawValue, "fileCreated")
        XCTAssertEqual(NotificationNames.errorOccurred.rawValue, "errorOccurred")
        XCTAssertEqual(NotificationNames.operationCompleted.rawValue, "operationCompleted")
    }
    
    // MARK: - Constants Consistency Tests
    
    func testConstantsConsistency() {
        // Test that UI constants are consistent
        XCTAssertGreaterThan(UIConstants.defaultWindowWidth, UIConstants.minimumWindowWidth)
        XCTAssertGreaterThan(UIConstants.defaultWindowHeight, UIConstants.minimumWindowHeight)
        
        // Test that button dimensions are reasonable
        XCTAssertGreaterThan(UIConstants.buttonWidth, 0)
        XCTAssertGreaterThan(UIConstants.buttonHeight, 0)
        XCTAssertGreaterThan(UIConstants.buttonCornerRadius, 0)
        
        // Test that font sizes are reasonable
        XCTAssertGreaterThan(UIConstants.titleFontSize, UIConstants.subtitleFontSize)
        XCTAssertGreaterThan(UIConstants.subtitleFontSize, UIConstants.bodyFontSize)
        XCTAssertGreaterThan(UIConstants.bodyFontSize, UIConstants.captionFontSize)
        
        // Test that spacing is consistent
        XCTAssertGreaterThan(UIConstants.mediumSpacing, UIConstants.smallSpacing)
        XCTAssertGreaterThan(UIConstants.largeSpacing, UIConstants.mediumSpacing)
        XCTAssertGreaterThan(UIConstants.extraLargeSpacing, UIConstants.largeSpacing)
        
        // Test that file size limits are reasonable
        XCTAssertGreaterThan(FileConstants.maxFileSize, FileConstants.maxJSONSize)
        XCTAssertGreaterThan(FileConstants.maxFileSize, 0)
        XCTAssertGreaterThan(FileConstants.maxJSONSize, 0)
        
        // Test that timeouts are reasonable
        XCTAssertGreaterThan(FileConstants.networkTimeout, 0)
        XCTAssertGreaterThan(FileConstants.fileOperationTimeout, 0)
        XCTAssertGreaterThan(FileConstants.networkTimeout, FileConstants.fileOperationTimeout)
    }
    
    // MARK: - Constants Performance Tests
    
    func testConstantsAccessPerformance() {
        measure {
            for _ in 0..<10000 {
                let _ = UIConstants.buttonWidth
                let _ = UIConstants.buttonHeight
                let _ = UIConstants.buttonCornerRadius
                let _ = UIConstants.buttonSpacing
                let _ = FileConstants.maxFileSize
                let _ = FileConstants.maxJSONSize
                let _ = ErrorMessages.fileNotFound
                let _ = SuccessMessages.fileOpened
            }
        }
    }
    
    // MARK: - Constants Validation Tests
    
    func testConstantsValidation() {
        // Validate that all constants have non-empty values where appropriate
        XCTAssertFalse(AppConstants.appName.isEmpty)
        XCTAssertFalse(AppConstants.bundleIdentifierRoot.isEmpty)
        XCTAssertFalse(AppConstants.supportEmail.isEmpty)
        XCTAssertFalse(FileConstants.defaultFileName.isEmpty)
        XCTAssertFalse(FileConstants.pasteboardFileName.isEmpty)
        XCTAssertFalse(FileConstants.urlFileName.isEmpty)
        XCTAssertFalse(FileConstants.curlFileName.isEmpty)
        
        // Validate that all error messages are non-empty
        XCTAssertFalse(ErrorMessages.fileNotFound.isEmpty)
        XCTAssertFalse(ErrorMessages.invalidJSON.isEmpty)
        XCTAssertFalse(ErrorMessages.fileTooLarge.isEmpty)
        XCTAssertFalse(ErrorMessages.unsupportedFileType.isEmpty)
        XCTAssertFalse(ErrorMessages.permissionDenied.isEmpty)
        XCTAssertFalse(ErrorMessages.corruptedFile.isEmpty)
        XCTAssertFalse(ErrorMessages.networkError.isEmpty)
        XCTAssertFalse(ErrorMessages.userCancelled.isEmpty)
        XCTAssertFalse(ErrorMessages.unknownError.isEmpty)
        
        // Validate that all success messages are non-empty
        XCTAssertFalse(SuccessMessages.fileOpened.isEmpty)
        XCTAssertFalse(SuccessMessages.fileSaved.isEmpty)
        XCTAssertFalse(SuccessMessages.fileCreated.isEmpty)
        XCTAssertFalse(SuccessMessages.contentLoaded.isEmpty)
        XCTAssertFalse(SuccessMessages.operationCompleted.isEmpty)
    }
}
