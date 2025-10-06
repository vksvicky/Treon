import XCTest
import Foundation
import SwiftUI
@testable import Treon

class ErrorHandlerTests: XCTestCase {
    var errorHandler: TreonErrorHandler!
    
    override func setUp() {
        super.setUp()
        errorHandler = TreonErrorHandler()
    }
    
    override func tearDown() {
        errorHandler = nil
        super.tearDown()
    }
    
    // MARK: - Error Handling Tests
    
    func testHandleError_fileManagerError_setsExpectedState() {
        let error = FileManagerError.fileNotFound("/path/to/nonexistent/file.json")
        let context = "Test file operation"
        
        errorHandler.handleError(error, context: context)
        
        XCTAssertNotNil(errorHandler.currentError)
        XCTAssertEqual(errorHandler.errorMessage, "\(ErrorMessages.fileNotFound): /path/to/nonexistent/file.json")
        XCTAssertTrue(errorHandler.showErrorAlert)
        XCTAssertTrue(errorHandler.isRecoverable)
        XCTAssertTrue(errorHandler.recoveryActions.contains(.retry))
    }
    
    func testHandleError_userCancelled_setsExpectedState() {
        let error = FileManagerError.userCancelled
        let context = "File selection"
        
        errorHandler.handleError(error, context: context)
        
        XCTAssertNotNil(errorHandler.currentError)
        XCTAssertEqual(errorHandler.errorMessage, ErrorMessages.userCancelled)
        XCTAssertTrue(errorHandler.showErrorAlert)
        XCTAssertFalse(errorHandler.isRecoverable)
        XCTAssertFalse(errorHandler.recoveryActions.contains(.retry))
    }
    
    func testHandleError_network_setsExpectedState() {
        let error = FileManagerError.networkError("Connection timeout")
        let context = "URL loading"
        
        errorHandler.handleError(error, context: context)
        
        XCTAssertNotNil(errorHandler.currentError)
        XCTAssertEqual(errorHandler.errorMessage, "\(ErrorMessages.networkError): Connection timeout")
        XCTAssertTrue(errorHandler.showErrorAlert)
        XCTAssertTrue(errorHandler.isRecoverable)
        XCTAssertTrue(errorHandler.recoveryActions.contains(.retry))
        XCTAssertTrue(errorHandler.recoveryActions.contains(.contactSupport))
    }
    
    func testHandleError_permissionDenied_setsExpectedState() {
        let error = FileManagerError.permissionDenied("/protected/file.json")
        let context = "File access"
        
        errorHandler.handleError(error, context: context)
        
        XCTAssertNotNil(errorHandler.currentError)
        XCTAssertEqual(errorHandler.errorMessage, "\(ErrorMessages.permissionDenied): /protected/file.json")
        XCTAssertTrue(errorHandler.showErrorAlert)
        XCTAssertTrue(errorHandler.isRecoverable)
        XCTAssertTrue(errorHandler.recoveryActions.contains(.retry))
        XCTAssertTrue(errorHandler.recoveryActions.contains(.openSettings))
    }
    
    func testHandleError_fileTooLarge_setsExpectedState() {
        let error = FileManagerError.fileTooLarge(100_000_000, 50_000_000)
        let context = "File validation"
        
        errorHandler.handleError(error, context: context)
        
        XCTAssertNotNil(errorHandler.currentError)
        XCTAssertTrue(errorHandler.errorMessage.contains(ErrorMessages.fileTooLarge))
        XCTAssertTrue(errorHandler.showErrorAlert)
        XCTAssertFalse(errorHandler.isRecoverable)
        XCTAssertFalse(errorHandler.recoveryActions.contains(.retry))
    }
    
    func testHandleError_invalidJSON_setsExpectedState() {
        let error = FileManagerError.invalidJSON("Unexpected character at line 5")
        let context = "JSON parsing"
        
        errorHandler.handleError(error, context: context)
        
        XCTAssertNotNil(errorHandler.currentError)
        XCTAssertEqual(errorHandler.errorMessage, "\(ErrorMessages.invalidJSON): Unexpected character at line 5")
        XCTAssertTrue(errorHandler.showErrorAlert)
        XCTAssertFalse(errorHandler.isRecoverable)
        XCTAssertFalse(errorHandler.recoveryActions.contains(.retry))
    }
    
    func testHandleError_unknown_setsExpectedState() {
        let error = FileManagerError.unknownError("Something went wrong")
        let context = "Unknown operation"
        
        errorHandler.handleError(error, context: context)
        
        XCTAssertNotNil(errorHandler.currentError)
        XCTAssertEqual(errorHandler.errorMessage, "\(ErrorMessages.unknownError): Something went wrong")
        XCTAssertTrue(errorHandler.showErrorAlert)
        XCTAssertTrue(errorHandler.isRecoverable)
        XCTAssertTrue(errorHandler.recoveryActions.contains(.retry))
        XCTAssertTrue(errorHandler.recoveryActions.contains(.contactSupport))
    }
    
    // MARK: - System Error Tests
    
    func testHandleError_cocoa_setsExpectedState() {
        let error = NSError(domain: NSCocoaErrorDomain, code: NSFileReadNoSuchFileError, userInfo: [
            NSLocalizedDescriptionKey: "The file doesn't exist."
        ])
        let context = "File system operation"
        
        errorHandler.handleError(error, context: context)
        
        XCTAssertNotNil(errorHandler.currentError)
        XCTAssertEqual(errorHandler.errorMessage, ErrorMessages.fileNotFound)
        XCTAssertTrue(errorHandler.showErrorAlert)
        XCTAssertTrue(errorHandler.isRecoverable)
    }
    
    func testHandleError_url_setsExpectedState() {
        let error = NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet, userInfo: [
            NSLocalizedDescriptionKey: "The Internet connection appears to be offline."
        ])
        let context = "Network operation"
        
        errorHandler.handleError(error, context: context)
        
        XCTAssertNotNil(errorHandler.currentError)
        XCTAssertEqual(errorHandler.errorMessage, "No internet connection available")
        XCTAssertTrue(errorHandler.showErrorAlert)
        XCTAssertTrue(errorHandler.isRecoverable)
    }
    
    func testHandleError_posix_setsExpectedState() {
        let error = NSError(domain: NSPOSIXErrorDomain, code: Int(ENOENT), userInfo: [
            NSLocalizedDescriptionKey: "No such file or directory"
        ])
        let context = "File system operation"
        
        errorHandler.handleError(error, context: context)
        
        XCTAssertNotNil(errorHandler.currentError)
        XCTAssertEqual(errorHandler.errorMessage, ErrorMessages.fileNotFound)
        XCTAssertTrue(errorHandler.showErrorAlert)
        XCTAssertTrue(errorHandler.isRecoverable)
    }
    
    // MARK: - Error Recovery Tests
    
    func testDismissError_clearsState() {
        let error = FileManagerError.fileNotFound("/test/file.json")
        errorHandler.handleError(error, context: "Test")
        
        XCTAssertNotNil(errorHandler.currentError)
        XCTAssertTrue(errorHandler.showErrorAlert)
        
        errorHandler.dismissError()
        
        XCTAssertNil(errorHandler.currentError)
        XCTAssertFalse(errorHandler.showErrorAlert)
        XCTAssertEqual(errorHandler.errorMessage, "")
        XCTAssertFalse(errorHandler.isRecoverable)
        XCTAssertTrue(errorHandler.recoveryActions.isEmpty)
    }
    
    func testRecoveryActions_varyByErrorType() {
        // Test retry action for recoverable errors
        let recoverableError = FileManagerError.networkError("Timeout")
        errorHandler.handleError(recoverableError, context: "Test")
        XCTAssertTrue(errorHandler.recoveryActions.contains(.retry))
        
        // Test no retry for non-recoverable errors
        let nonRecoverableError = FileManagerError.invalidJSON("Parse error")
        errorHandler.handleError(nonRecoverableError, context: "Test")
        XCTAssertFalse(errorHandler.recoveryActions.contains(.retry))
        
        // Test settings action for permission errors
        let permissionError = FileManagerError.permissionDenied("/test")
        errorHandler.handleError(permissionError, context: "Test")
        XCTAssertTrue(errorHandler.recoveryActions.contains(.openSettings))
        
        // Test support action for network/unknown errors
        let supportError = FileManagerError.unknownError("Unknown")
        errorHandler.handleError(supportError, context: "Test")
        XCTAssertTrue(errorHandler.recoveryActions.contains(.contactSupport))
    }
    
    // MARK: - Error Message Tests
    
    func testErrorMessage_userFriendly_forVariousErrors() {
        let testCases: [(Error, String)] = [
            (FileManagerError.fileNotFound("/test"), "\(ErrorMessages.fileNotFound): /test"),
            (FileManagerError.invalidJSON("Parse error"), "\(ErrorMessages.invalidJSON): Parse error"),
            (FileManagerError.userCancelled, ErrorMessages.userCancelled),
            (FileManagerError.networkError("Timeout"), "\(ErrorMessages.networkError): Timeout"),
            (FileManagerError.permissionDenied("/test"), "\(ErrorMessages.permissionDenied): /test"),
            (FileManagerError.fileTooLarge(100, 50), "\(ErrorMessages.fileTooLarge): 100 bytes (max: 50 bytes)"),
            (FileManagerError.unsupportedFileType("txt"), "\(ErrorMessages.unsupportedFileType): txt"),
            (FileManagerError.corruptedFile("/test"), "\(ErrorMessages.corruptedFile): /test"),
            (FileManagerError.unknownError("Test"), "\(ErrorMessages.unknownError): Test")
        ]
        
        for (error, expectedMessage) in testCases {
            errorHandler.handleError(error, context: "Test")
            XCTAssertEqual(errorHandler.errorMessage, expectedMessage, "Failed for error: \(error)")
            errorHandler.dismissError()
        }
    }
    
    // MARK: - Error Context Tests
    
    func testErrorContext_loggingSupported() {
        let error = FileManagerError.fileNotFound("/test/file.json")
        let context = "Test operation"
        
        // This test verifies that the error handler can handle context
        // In a real implementation, you might want to verify logging behavior
        errorHandler.handleError(error, context: context)
        
        XCTAssertNotNil(errorHandler.currentError)
        XCTAssertTrue(errorHandler.showErrorAlert)
    }
    
    // MARK: - Notification Tests
    
    func testErrorNotification_isPosted() {
        let expectation = XCTestExpectation(description: "Error notification posted")
        
        let observer = NotificationCenter.default.addObserver(
            forName: NotificationNames.errorOccurred,
            object: nil,
            queue: .main
        ) { notification in
            XCTAssertNotNil(notification.object)
            XCTAssertEqual(notification.userInfo?["context"] as? String, "Test context")
            expectation.fulfill()
        }
        
        let error = FileManagerError.fileNotFound("/test/file.json")
        errorHandler.handleError(error, context: "Test context")
        
        wait(for: [expectation], timeout: 1.0)
        NotificationCenter.default.removeObserver(observer)
    }
    
    // MARK: - Error Handler Integration Tests
    
    func testErrorHandler_handlesMultipleErrorsSequentially() {
        let errors: [Error] = [
            FileManagerError.fileNotFound("/test1.json"),
            FileManagerError.networkError("Timeout"),
            FileManagerError.userCancelled,
            FileManagerError.invalidJSON("Parse error")
        ]
        
        for (index, error) in errors.enumerated() {
            errorHandler.handleError(error, context: "Test \(index)")
            
            XCTAssertNotNil(errorHandler.currentError)
            XCTAssertTrue(errorHandler.showErrorAlert)
            
            // Verify the last error is the current one
            if let fileManagerError = error as? FileManagerError,
               let currentError = errorHandler.currentError as? FileManagerError {
                XCTAssertEqual(fileManagerError, currentError)
            }
            
            errorHandler.dismissError()
        }
    }
    
    // MARK: - Performance Tests
    
    func testErrorHandling_performanceIsAcceptable() {
        measure {
            for i in 0..<1000 {
                let error = FileManagerError.unknownError("Test error \(i)")
                errorHandler.handleError(error, context: "Performance test")
                errorHandler.dismissError()
            }
        }
    }
}

// MARK: - FileManagerError Equatable Extension for Testing
extension FileManagerError: @retroactive Equatable {
    public static func == (lhs: FileManagerError, rhs: FileManagerError) -> Bool {
        switch (lhs, rhs) {
        case (.fileNotFound(let l), .fileNotFound(let r)):
            return l == r
        case (.invalidJSON(let l), .invalidJSON(let r)):
            return l == r
        case (.fileTooLarge(let l1, let l2), .fileTooLarge(let r1, let r2)):
            return l1 == r1 && l2 == r2
        case (.unsupportedFileType(let l), .unsupportedFileType(let r)):
            return l == r
        case (.permissionDenied(let l), .permissionDenied(let r)):
            return l == r
        case (.corruptedFile(let l), .corruptedFile(let r)):
            return l == r
        case (.networkError(let l), .networkError(let r)):
            return l == r
        case (.userCancelled, .userCancelled):
            return true
        case (.unknownError(let l), .unknownError(let r)):
            return l == r
        default:
            return false
        }
    }
}
