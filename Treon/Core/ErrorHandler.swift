//
//  ErrorHandler.swift
//  Treon
//
//  Created by Vivek on 2025-10-19.
//  Copyright © 2025 Treon. All rights reserved.
//

import Foundation
import SwiftUI
import OSLog
import Combine

// MARK: - Error Handling Protocol
protocol ErrorHandling {
    func handleError(_ error: Error, context: String?)
    func showErrorAlert(_ error: Error, context: String?)
    func logError(_ error: Error, context: String?)
}

// MARK: - Error Recovery Actions
enum ErrorRecoveryAction {
    case retry
    case cancel
    case ignore
    case openSettings
    case contactSupport
}

// MARK: - Error Context
struct ErrorContext {
    let operation: String
    let userAction: String?
    let timestamp: Date
    let additionalInfo: [String: Any]?

    init(operation: String, userAction: String? = nil, additionalInfo: [String: Any]? = nil) {
        self.operation = operation
        self.userAction = userAction
        self.timestamp = Date()
        self.additionalInfo = additionalInfo
    }
}

// MARK: - Enhanced Error Handler
class TreonErrorHandler: ObservableObject, ErrorHandling {
    @Published var currentError: Error?
    @Published var errorMessage: String = ""
    @Published var showErrorAlert: Bool = false
    @Published var isRecoverable: Bool = false
    @Published var recoveryActions: [ErrorRecoveryAction] = []

    private let logger = Loggers.error

    // MARK: - Error Handling Methods

    func handleError(_ error: Error, context: String? = nil) {
        logError(error, context: context)
        if isRunningUnderTests() {
            updateStateSynchronously(error: error, context: context)
            postErrorNotification(error: error, context: context)
            return
        }
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.updateStateAsynchronously(error: error, context: context)
            self.postErrorNotification(error: error, context: context)
        }
    }

    private func isRunningUnderTests() -> Bool {
        ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
    }

    private func updateStateSynchronously(error: Error, context: String?) {
        currentError = error
        errorMessage = getUserFriendlyMessage(for: error)
        isRecoverable = isErrorRecoverable(error)
        recoveryActions = getRecoveryActions(for: error)
        showErrorAlert = true
    }

    private func updateStateAsynchronously(error: Error, context: String?) {
        currentError = error
        errorMessage = getUserFriendlyMessage(for: error)
        isRecoverable = isErrorRecoverable(error)
        recoveryActions = getRecoveryActions(for: error)
        showErrorAlert = true
    }

    private func postErrorNotification(error: Error, context: String?) {
        NotificationCenter.default.post(
            name: NotificationNames.errorOccurred,
            object: error,
            userInfo: ["context": context ?? "Unknown"]
        )
    }

    func showErrorAlert(_ error: Error, context: String? = nil) {
        handleError(error, context: context)
    }

    func logError(_ error: Error, context: String? = nil) {
        let contextString = context ?? "Unknown"
        logger.error("Error in \(contextString): \(error.localizedDescription)")

        // Log additional details for debugging
        if let fileManagerError = error as? FileManagerError {
            logger.error("FileManagerError details: \(fileManagerError)")
        }

        // Log to console for development
        #if DEBUG
        logger.error("🚨 Error in \(contextString): \(error)")
        if let nsError = error as NSError? {
            logger.error("   Domain: \(nsError.domain)")
            logger.error("   Code: \(nsError.code)")
            logger.error("   UserInfo: \(nsError.userInfo)")
        }
        #endif
    }

    // MARK: - Error Recovery

    func performRecoveryAction(_ action: ErrorRecoveryAction) {
        switch action {
        case .retry:
            retryLastOperation()
        case .cancel:
            dismissError()
        case .ignore:
            dismissError()
        case .openSettings:
            openAppSettings()
        case .contactSupport:
            contactSupport()
        }
    }

    func dismissError() {
        if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil {
            self.currentError = nil
            self.errorMessage = ""
            self.showErrorAlert = false
            self.isRecoverable = false
            self.recoveryActions = []
        } else {
            DispatchQueue.main.async {
                self.currentError = nil
                self.errorMessage = ""
                self.showErrorAlert = false
                self.isRecoverable = false
                self.recoveryActions = []
            }
        }
    }

    // MARK: - Private Methods

    private func getUserFriendlyMessage(for error: Error) -> String {
        if let fileManagerError = error as? FileManagerError {
            return fileManagerError.errorDescription ?? ErrorMessages.unknownError
        }

        // Handle common system errors
        if let nsError = error as NSError? {
            switch nsError.domain {
            case NSCocoaErrorDomain:
                return handleCocoaError(nsError)
            case NSURLErrorDomain:
                return handleURLError(nsError)
            case NSPOSIXErrorDomain:
                return handlePOSIXError(nsError)
            default:
                return error.localizedDescription.isEmpty ? ErrorMessages.unknownError : error.localizedDescription
            }
        }

        return error.localizedDescription.isEmpty ? ErrorMessages.unknownError : error.localizedDescription
    }

    private func handleCocoaError(_ error: NSError) -> String {
        switch error.code {
        case NSFileReadNoSuchFileError:
            return ErrorMessages.fileNotFound
        case NSFileReadNoPermissionError:
            return ErrorMessages.permissionDenied
        case NSFileReadCorruptFileError:
            return ErrorMessages.corruptedFile
        case NSFileReadTooLargeError:
            return ErrorMessages.fileTooLarge
        default:
            return error.localizedDescription
        }
    }

    private func handleURLError(_ error: NSError) -> String {
        switch error.code {
        case NSURLErrorNotConnectedToInternet:
            return "No internet connection available"
        case NSURLErrorTimedOut:
            return "Request timed out"
        case NSURLErrorCannotFindHost:
            return "Cannot find server"
        case NSURLErrorCannotConnectToHost:
            return "Cannot connect to server"
        case NSURLErrorNetworkConnectionLost:
            return "Network connection lost"
        default:
            return ErrorMessages.networkError
        }
    }

    private func handlePOSIXError(_ error: NSError) -> String {
        switch error.code {
        case Int(ENOENT):
            return ErrorMessages.fileNotFound
        case Int(EACCES):
            return ErrorMessages.permissionDenied
        case Int(EIO):
            return ErrorMessages.corruptedFile
        default:
            return error.localizedDescription
        }
    }

    private func isErrorRecoverable(_ error: Error) -> Bool {
        if let fileManagerError = error as? FileManagerError {
            switch fileManagerError {
            case .fileNotFound, .permissionDenied, .networkError:
                return true
            case .userCancelled, .invalidJSON, .fileTooLarge, .unsupportedFileType, .corruptedFile:
                return false
            case .unknownError:
                return true
            }
        }

        if let nsError = error as NSError? {
            switch nsError.domain {
            case NSURLErrorDomain:
                return true // Network errors are usually recoverable
            case NSCocoaErrorDomain:
                switch nsError.code {
                case NSFileReadNoSuchFileError, NSFileReadNoPermissionError:
                    return true
                default:
                    return false
                }
            case NSPOSIXErrorDomain:
                switch nsError.code {
                case Int(ENOENT), Int(EACCES):
                    return true
                default:
                    return false
                }
            default:
                return false
            }
        }

        return false
    }

    private func getRecoveryActions(for error: Error) -> [ErrorRecoveryAction] {
        var actions: [ErrorRecoveryAction] = [.cancel]

        if isErrorRecoverable(error) {
            actions.insert(.retry, at: 0)
        }

        if let fileManagerError = error as? FileManagerError {
            switch fileManagerError {
            case .permissionDenied:
                actions.append(.openSettings)
            case .networkError, .unknownError:
                actions.append(.contactSupport)
            default:
                break
            }
        }

        return actions
    }

    private func retryLastOperation() {
        // This would be implemented based on the specific operation that failed
        // For now, we'll just dismiss the error
        dismissError()
    }

    private func openAppSettings() {
        // Open system preferences for the app
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy") {
            NSWorkspace.shared.open(url)
        }
    }

    private func contactSupport() {
        // Open email client with support information
        let subject = "Treon Support Request"
        let body = """
        Error Details:
        - App Version: \(AppConstants.version)
        - Build: \(AppConstants.buildNumber)
        - Error: \(currentError?.localizedDescription ?? "Unknown")
        - Timestamp: \(Date())

        Please describe what you were doing when this error occurred:

        """

        let mailtoURL = "mailto:\(AppConstants.supportEmail)?subject=\(subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&body=\(body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"

        if let url = URL(string: mailtoURL) {
            NSWorkspace.shared.open(url)
        }
    }
}

// MARK: - Error Alert View
struct ErrorAlertView: View {
    @ObservedObject var errorHandler: TreonErrorHandler
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: UIConstants.mediumSpacing) {
            // Error Icon
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundColor(UIConstants.errorRed)

            // Error Title
            Text("Error")
                .font(.headline)
                .foregroundColor(.primary)

            // Error Message
            Text(errorHandler.errorMessage)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            // Recovery Actions
            if errorHandler.isRecoverable {
                VStack(spacing: UIConstants.smallSpacing) {
                    Text("What would you like to do?")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    HStack(spacing: UIConstants.smallSpacing) {
                        ForEach(errorHandler.recoveryActions, id: \.self) { action in
                            Button(actionTitle(for: action)) {
                                errorHandler.performRecoveryAction(action)
                                onDismiss()
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                }
            } else {
                Button("OK") {
                    errorHandler.dismissError()
                    onDismiss()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(UIConstants.largeSpacing)
        .frame(maxWidth: 400)
    }

    private func actionTitle(for action: ErrorRecoveryAction) -> String {
        switch action {
        case .retry:
            return "Retry"
        case .cancel:
            return "Cancel"
        case .ignore:
            return "Ignore"
        case .openSettings:
            return "Settings"
        case .contactSupport:
            return "Contact Support"
        }
    }
}

// MARK: - Error Handling View Modifier
struct ErrorHandlingModifier: ViewModifier {
    @StateObject private var errorHandler = TreonErrorHandler()

    func body(content: Content) -> some View {
        content
            .environmentObject(errorHandler)
            .alert("Error", isPresented: $errorHandler.showErrorAlert) {
                ForEach(errorHandler.recoveryActions, id: \.self) { action in
                    Button(actionTitle(for: action)) {
                        errorHandler.performRecoveryAction(action)
                    }
                }
                Button("Cancel") {
                    errorHandler.dismissError()
                }
            } message: {
                Text(errorHandler.errorMessage)
            }
    }

    private func actionTitle(for action: ErrorRecoveryAction) -> String {
        switch action {
        case .retry:
            return "Retry"
        case .cancel:
            return "Cancel"
        case .ignore:
            return "Ignore"
        case .openSettings:
            return "Settings"
        case .contactSupport:
            return "Contact Support"
        }
    }
}

// MARK: - View Extension
extension View {
    func withErrorHandling() -> some View {
        self.modifier(ErrorHandlingModifier())
    }
}
