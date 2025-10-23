import Foundation
import SwiftUI
import Combine
import OSLog

// MARK: - Treon File Manager
class TreonFileManager: ObservableObject {
    static let shared = TreonFileManager()

    // MARK: - Constants
    let maxFileSize = FileConstants.maxFileSize
    let sizeSlackBytes = FileConstants.sizeSlackBytes
    let logger = Loggers.fileManager

    // MARK: - Properties
    @Published var recentFiles: [RecentFile] = []
    @Published var currentFile: FileInfo? {
        didSet {
            // Note: TabManager is updated directly in openFile methods to avoid duplicate opening
            // This didSet observer is kept for potential future UI updates
        }
    }
    @Published var isLoading = false
    @Published var errorMessage: String?

    // MARK: - Initialization
    private init() {
        logger.info("Initializing TreonFileManager")
        loadRecentFiles()
    }

    // MARK: - File Operations
    func openFile() async throws -> FileInfo {
        let fileInfo = try await FileOperationsManager.shared.openFile()
        // Update the published recent files list
        await MainActor.run {
            recentFiles = RecentFilesManager.shared.loadRecentFiles()
        }
        return fileInfo
    }

    func openFile(url: URL) async throws -> FileInfo {
        let fileInfo = try await FileOperationsManager.shared.openFile(url: url)
        // Update the published recent files list
        await MainActor.run {
            recentFiles = RecentFilesManager.shared.loadRecentFiles()
        }
        return fileInfo
    }
    
    /// Opens a file using a security-scoped bookmark (for recent files)
    func openFileWithBookmark(_ recentFile: RecentFile) async throws -> FileInfo {
        return try await FileOperationsManager.shared.openFileWithBookmark(recentFile)
    }
    
    /// Opens a file using the file dialog to grant access
    private func openFileWithDialog(for url: URL) async throws -> FileInfo {
        return try await FileOperationsManager.shared.openFileWithDialog(for: url)
    }
    
    /// Removes a recent file from the list
    func removeRecentFile(_ recentFile: RecentFile) {
        RecentFilesManager.shared.removeRecentFile(recentFile)
        recentFiles = RecentFilesManager.shared.loadRecentFiles()
    }
    
    func clearAllRecentFiles() {
        RecentFilesManager.shared.clearAllRecentFiles()
        recentFiles = []
    }

    func createNewFile() -> FileInfo {
        return FileOperationsManager.shared.createNewFile()
    }

    // MARK: - Recent Files Management
    private func loadRecentFiles() {
        recentFiles = RecentFilesManager.shared.loadRecentFiles()
    }

    // MARK: - Utility Methods
    func getFileContent(url: URL) async throws -> String {
        return try await FileOperationsManager.shared.getFileContent(url: url)
    }

    func saveFile(url: URL, content: String) async throws {
        return try await FileOperationsManager.shared.saveFile(url: url, content: content)
    }

    // MARK: - Error Handling
    func clearError() {
        errorMessage = nil
    }

    func setError(_ error: Error) {
        if let fmError = error as? FileManagerError {
            switch fmError {
            case .invalidJSON(let reason):
                errorMessage = "Invalid JSON: \(reason)"
            default:
                errorMessage = fmError.errorDescription
            }
        } else {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - New Content Creation Methods
    func createFileFromContent(_ content: String, name: String) async throws -> FileInfo {
        return try await FileOperationsManager.shared.createFileFromContent(content, name: name)
    }
}
