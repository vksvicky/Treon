import Foundation
import AppKit
import OSLog
import UniformTypeIdentifiers

/// Manages file operations and dialog interactions
class FileOperationsManager {
    static let shared = FileOperationsManager()
    
    private let logger = Loggers.fileManager
    
    // MARK: - Cached Panel for Performance
    private lazy var cachedOpenPanel: NSOpenPanel = {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = false
        panel.allowedContentTypes = [.json]
        panel.allowsOtherFileTypes = false
        panel.title = "Open JSON Files"
        panel.message = "Select one or more JSON files to open"
        panel.prompt = "Open"
        // Note: directoryURL will be set when the panel is used, not during initialization
        return panel
    }()
    
    private init() {}
    
    // MARK: - File Operations
    
    func openFile() async throws -> FileInfo {
        let startTime = CFAbsoluteTimeGetCurrent()
        logger.info("Starting file open operation")
        return try await withCheckedThrowingContinuation { continuation in
            // Use cached panel for faster launch - no need to create/configure each time
            DispatchQueue.main.async {
                // Set panel to last opened directory
                let panel = self.cachedOpenPanel
                panel.directoryURL = DirectoryManager.shared.getLastOpenedDirectory()
                
                self.logger.info("Presenting file dialog with directory: \(panel.directoryURL?.path ?? "nil")")
                self.logger.info("Panel configuration - allowsMultipleSelection: \(panel.allowsMultipleSelection), allowedContentTypes: \(panel.allowedContentTypes)")
                let result = panel.runModal()
                self.logger.info("File dialog result: \(result.rawValue) (OK=1, Cancel=0)")
                
                if result == .OK {
                    let urls = panel.urls
                    self.logger.info("User selected \(urls.count) file(s): \(urls.map { $0.lastPathComponent })")
                    
                    Task {
                        do {
                            var firstFileInfo: FileInfo?
                            
                            // Open all selected files
                            for url in urls {
                                let fileInfo = try await FileValidator.shared.validateAndLoadFile(url: url)
                                self.logger.info("Successfully loaded file: \(fileInfo.name)")
                                
                                // Store the first file for return value
                                if firstFileInfo == nil {
                                    firstFileInfo = fileInfo
                                }
                                
                                // Save the directory of the selected file for next time
                                let directorySaveStart = CFAbsoluteTimeGetCurrent()
                                await MainActor.run {
                                    DirectoryManager.shared.saveLastOpenedDirectory(url: url)
                                }
                                let directorySaveTime = CFAbsoluteTimeGetCurrent() - directorySaveStart
                                self.logger.info("📊 FILE LOADING STEP: Directory save: \(String(format: "%.3f", directorySaveTime))s")
                                
                                // Open each file as a tab
                                let tabOpenStart = CFAbsoluteTimeGetCurrent()
                                await MainActor.run {
                                    TabManager.shared.openFile(fileInfo)
                                }
                                let tabOpenTime = CFAbsoluteTimeGetCurrent() - tabOpenStart
                                self.logger.info("📊 FILE LOADING STEP: Tab open: \(String(format: "%.3f", tabOpenTime))s")
                                
                                // Add to recent files
                                let recentFilesStart = CFAbsoluteTimeGetCurrent()
                                RecentFilesManager.shared.addToRecentFiles(fileInfo: fileInfo)
                                let recentFilesTime = CFAbsoluteTimeGetCurrent() - recentFilesStart
                                self.logger.info("📊 FILE LOADING STEP: Recent files: \(String(format: "%.3f", recentFilesTime))s")
                            }

                            // Return the first file as the "current" file for backward compatibility
                            if let fileInfo = firstFileInfo {
                                let continuationStart = CFAbsoluteTimeGetCurrent()
                                continuation.resume(returning: fileInfo)
                                let continuationTime = CFAbsoluteTimeGetCurrent() - continuationStart
                                self.logger.info("📊 FILE LOADING STEP: continuation resume: \(String(format: "%.3f", continuationTime))s")
                                
                                let totalTime = CFAbsoluteTimeGetCurrent() - startTime
                                self.logger.info("📊 FILE LOADING PERFORMANCE: Total time: \(String(format: "%.3f", totalTime))s")
                            } else {
                                continuation.resume(throwing: FileManagerError.userCancelled)
                            }
                        } catch {
                            self.logger.error("Failed to load files: \(error.localizedDescription)")
                            continuation.resume(throwing: error)
                        }
                    }
                } else {
                    self.logger.info("User cancelled file selection")
                    continuation.resume(throwing: FileManagerError.userCancelled)
                }
            }
        }
    }
    
    func openFile(url: URL) async throws -> FileInfo {
        logger.info("Starting direct file open operation for: \(url.lastPathComponent)")
        
        // Try to access the file directly first
        do {
            let fileInfo = try await FileValidator.shared.validateAndLoadFile(url: url)
            
            // Save the directory of the opened file for next time
            Task { @MainActor in
                DirectoryManager.shared.saveLastOpenedDirectory(url: url)
            }
            
            // Add to recent files
            RecentFilesManager.shared.addToRecentFiles(fileInfo: fileInfo)

            logger.info("📊 DIRECT FILE LOADING PERFORMANCE: Successfully loaded \(url.lastPathComponent)")
            
            return fileInfo
        } catch {
            // Log the actual error for debugging
            logger.warning("Error accessing file \(url.path): \(error)")
            logger.warning("Error type: \(type(of: error))")

            // Check for various permission-related errors
            if let nsError = error as NSError? {
                logger.warning("NSError domain: \(nsError.domain), code: \(nsError.code)")
                logger.warning("NSError description: \(nsError.localizedDescription)")

                // Check for different permission error codes and domains
                let isPermissionError = (nsError.domain == NSCocoaErrorDomain &&
                                       (nsError.code == NSFileReadNoPermissionError ||
                                        nsError.code == NSFileReadCorruptFileError ||
                                        nsError.code == 257)) ||
                                      (nsError.domain == "NSCocoaErrorDomain" && nsError.code == 257) ||
                                      (nsError.localizedDescription.contains("permission") && nsError.localizedDescription.contains("view"))

                if isPermissionError {
                    logger.warning("Permission required for file: \(url.path)")
                    throw FileManagerError.permissionDenied("File requires permission. Please use 'Open File' to grant access to this file.")
                }
            }

            // Also check if the error message contains permission-related text
            let errorMessage = error.localizedDescription.lowercased()
            if errorMessage.contains("permission") && errorMessage.contains("view") {
                logger.warning("Permission error detected from message: \(error.localizedDescription)")
                throw FileManagerError.permissionDenied("File requires permission. Please use 'Open File' to grant access to this file.")
            }

            // Re-throw other errors
            throw error
        }
    }
    
    /// Opens a file using a security-scoped bookmark (for recent files)
    func openFileWithBookmark(_ recentFile: RecentFile) async throws -> FileInfo {
        logger.info("🚀 Starting recent file open operation for: \(recentFile.name)")
        logger.debug("File path: \(recentFile.url.path)")
        
        // First, check if the file still exists at the original location
        if FileManager.default.fileExists(atPath: recentFile.url.path) {
            logger.info("🚀 File exists at original location: \(recentFile.name)")
            
            // Check if we have a bookmark for this file
            if let bookmarkData = recentFile.bookmarkData,
               let url = SecurityScopedBookmarkManager.shared.resolveBookmark(bookmarkData) {
                // We have a valid bookmark, use it
                logger.info("🚀 Using existing bookmark for: \(recentFile.name)")
                logger.debug("Bookmark resolved to: \(url.path)")
                
                // Start accessing the security-scoped resource
                guard SecurityScopedBookmarkManager.shared.startAccessingSecurityScopedResource(url) else {
                    logger.error("🚀 Failed to start accessing security-scoped resource: \(recentFile.name)")
                    throw FileManagerError.permissionDenied("Failed to access file. Please use 'Open File' to grant access.")
                }
                logger.debug("🚀 Successfully started accessing security-scoped resource")
                
                defer {
                    // Always stop accessing the resource when done
                    SecurityScopedBookmarkManager.shared.stopAccessingSecurityScopedResource(url)
                }
                
                do {
                    logger.debug("🚀 About to call FileValidator.shared.validateAndLoadFile")
                    let fileInfo = try await FileValidator.shared.validateAndLoadFile(url: url)
                    logger.info("🚀 Successfully validated and loaded file: \(fileInfo.name)")
                    
                    // Update the recent file access time
                    RecentFilesManager.shared.updateRecentFileAccess(recentFile)
                    
                    return fileInfo
                } catch {
                    logger.error("🚀 Error accessing file with bookmark \(url.path): \(error)")
                    throw error
                }
            } else {
                // File exists but no bookmark - this shouldn't happen with the new implementation
                // but if it does, show a helpful message
                logger.warning("🚀 File exists but no bookmark available for \(recentFile.name) - this shouldn't happen")
                logger.debug("No bookmark data found for: \(recentFile.name)")
                
                // Show a helpful message to the user
                await MainActor.run {
                    let alert = NSAlert()
                    alert.messageText = "File Access Required"
                    alert.informativeText = "To open '\(recentFile.name)' from your recent files, please use 'Open File' to grant access. This is a one-time permission that will be remembered for future use."
                    alert.alertStyle = .informational
                    alert.addButton(withTitle: "OK")
                    alert.runModal()
                }
                
                // Don't show the file dialog - let the user use "Open File" instead
                throw FileManagerError.permissionDenied("Please use 'Open File' to grant access to this file.")
            }
        } else {
            // File doesn't exist, remove it from recent files and show alert
            logger.warning("File no longer exists: \(recentFile.name), removing from recent files")
            RecentFilesManager.shared.removeRecentFile(recentFile)
            
            // Show alert to user
            await MainActor.run {
                let alert = NSAlert()
                alert.messageText = "File Not Found"
                alert.informativeText = "The file '\(recentFile.name)' could not be found. It may have been moved or deleted. The file has been removed from your recent files list."
                alert.alertStyle = .warning
                alert.addButton(withTitle: "OK")
                alert.runModal()
            }
            
            throw FileManagerError.fileNotFound("File '\(recentFile.name)' could not be found")
        }
    }
    
    /// Opens a file using the file dialog to grant access
    func openFileWithDialog(for url: URL) async throws -> FileInfo {
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.main.async {
                let panel = NSOpenPanel()
                panel.allowsMultipleSelection = false
                panel.canChooseDirectories = false
                panel.allowedContentTypes = [.json]
                panel.title = "Grant Access to File"
                panel.message = "Please select the file to grant Treon access to it."
                panel.directoryURL = url.deletingLastPathComponent()
                
                // Try to pre-select the specific file
                if FileManager.default.fileExists(atPath: url.path) {
                    panel.nameFieldStringValue = url.lastPathComponent
                    self.logger.info("Pre-selecting file: \(url.lastPathComponent)")
                } else {
                    // File doesn't exist, just show the directory
                    panel.nameFieldStringValue = ""
                    self.logger.warning("File no longer exists at path: \(url.path)")
                }
                
                if panel.runModal() == .OK {
                    let selectedURL = panel.urls.first!
                    self.logger.info("User granted access to file: \(selectedURL.lastPathComponent)")
                    
                    Task {
                        do {
                            let fileInfo = try await FileValidator.shared.validateAndLoadFile(url: selectedURL)
                            
                            // Create a bookmark for this file so it can be opened directly next time
                            if let bookmarkData = SecurityScopedBookmarkManager.shared.createBookmark(for: selectedURL) {
                                self.logger.info("Created bookmark for future access to: \(selectedURL.lastPathComponent)")
                                // Update the recent file entry with the bookmark
                                RecentFilesManager.shared.updateRecentFileWithBookmark(url: selectedURL, bookmarkData: bookmarkData)
                            }
                            
                            continuation.resume(returning: fileInfo)
                        } catch {
                            continuation.resume(throwing: error)
                        }
                    }
                } else {
                    self.logger.info("User cancelled file access grant")
                    continuation.resume(throwing: FileManagerError.userCancelled)
                }
            }
        }
    }
    
    // MARK: - Utility Methods
    
    func getFileContent(url: URL) async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    let content = try String(contentsOf: url, encoding: .utf8)
                    continuation.resume(returning: content)
                } catch {
                    continuation.resume(throwing: FileManagerError.corruptedFile(url.path))
                }
            }
        }
    }

    func saveFile(url: URL, content: String) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try content.write(to: url, atomically: true, encoding: .utf8)
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: FileManagerError.permissionDenied(url.path))
                }
            }
        }
    }
    
    func createNewFile() -> FileInfo {
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("Untitled.json")

        let initialContent = "{\n  \"example\": \"This is a new JSON file\"\n}"

        do {
            try initialContent.write(to: tempURL, atomically: true, encoding: .utf8)
            let fileInfo = FileInfo(
                url: tempURL,
                name: "Untitled.json",
                size: Int64(initialContent.utf8.count),
                modifiedDate: Date(),
                isValidJSON: true,
                errorMessage: nil,
                content: initialContent
            )
            return fileInfo
        } catch {
            return FileInfo(
                url: tempURL,
                name: "Untitled.json",
                size: 0,
                modifiedDate: Date(),
                isValidJSON: false,
                errorMessage: error.localizedDescription,
                content: nil
            )
        }
    }
    
    func createFileFromContent(_ content: String, name: String) async throws -> FileInfo {
        logger.info("Creating file from content: \(name)")

        // Convert content to data
        guard let jsonData = content.data(using: .utf8) else {
            logger.error("Unable to convert content to data")
            throw FileManagerError.invalidJSON("Unable to convert content to data")
        }

        // Check file size limit
        let maxFileSize = FileConstants.maxFileSize
        if jsonData.count > maxFileSize {
            logger.error("Content size exceeds limit: \(jsonData.count) bytes")
            throw FileManagerError.fileTooLarge(Int64(jsonData.count), maxFileSize)
        }

        // Try to validate JSON format, but don't fail if it's not valid JSON
        var isValidJSON = false
        var errorMessage: String? = nil

        do {
            _ = try JSONSerialization.jsonObject(with: jsonData, options: [])
            isValidJSON = true
            logger.info("Content is valid JSON")
        } catch {
            // Content is not valid JSON, but we'll still create a file
            isValidJSON = false
            errorMessage = "Content is not valid JSON: \(error.localizedDescription)"
            logger.warning("Content is not valid JSON: \(error.localizedDescription)")
        }

        // Create file info from content (even if not valid JSON)
        let fileInfo = FileInfo(
            url: nil, // No file URL for content-based files
            name: name,
            size: Int64(jsonData.count),
            modifiedDate: Date(),
            isValidJSON: isValidJSON,
            errorMessage: errorMessage,
            content: content
        )
        logger.info("Successfully created file from content: \(name)")
        return fileInfo
    }
}
