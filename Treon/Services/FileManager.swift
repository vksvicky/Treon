import Foundation
import SwiftUI
import Combine
import UniformTypeIdentifiers
import OSLog

// MARK: - File Manager Errors
enum FileManagerError: LocalizedError {
    case fileNotFound(String)
    case invalidJSON(String)
    case fileTooLarge(Int64, Int64) // actual size, max size
    case unsupportedFileType(String)
    case permissionDenied(String)
    case corruptedFile(String)
    case networkError(String)
    case userCancelled
    case unknownError(String)
    
    var errorDescription: String? {
        switch self {
        case .fileNotFound(let path):
            return "\(ErrorMessages.fileNotFound): \(path)"
        case .invalidJSON(let reason):
            return "\(ErrorMessages.invalidJSON): \(reason)"
        case .fileTooLarge(let actual, let max):
            // For user clarity and to match tests, display sizes in raw bytes
            return "\(ErrorMessages.fileTooLarge): \(actual) bytes (max: \(max) bytes)"
        case .unsupportedFileType(let type):
            return "\(ErrorMessages.unsupportedFileType): \(type)"
        case .permissionDenied(let path):
            return "\(ErrorMessages.permissionDenied): \(path)"
        case .corruptedFile(let path):
            return "\(ErrorMessages.corruptedFile): \(path)"
        case .networkError(let message):
            return "\(ErrorMessages.networkError): \(message)"
        case .userCancelled:
            return ErrorMessages.userCancelled
        case .unknownError(let message):
            return "\(ErrorMessages.unknownError): \(message)"
        }
    }
    
    private func formatFileSize(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}

// MARK: - File Info
struct FileInfo {
    nonisolated let url: URL?
    nonisolated let name: String
    nonisolated let size: Int64
    nonisolated let modifiedDate: Date
    nonisolated let isValidJSON: Bool
    nonisolated let errorMessage: String?
    nonisolated let content: String?
    
    nonisolated var formattedSize: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useBytes, .useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: size)
    }
    
    nonisolated var formattedModifiedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: modifiedDate)
    }
}

// MARK: - Recent File
struct RecentFile: Codable, Identifiable {
    nonisolated let id = UUID()
    nonisolated let url: URL
    nonisolated let name: String
    nonisolated let lastOpened: Date
    nonisolated let size: Int64
    nonisolated let isValidJSON: Bool
    
    nonisolated var formattedSize: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useBytes, .useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: size)
    }
    
    enum CodingKeys: String, CodingKey {
        case url, name, lastOpened, size, isValidJSON
    }
    
    init(url: URL, name: String, lastOpened: Date, size: Int64, isValidJSON: Bool) {
        self.url = url
        self.name = name
        self.lastOpened = lastOpened
        self.size = size
        self.isValidJSON = isValidJSON
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        url = try container.decode(URL.self, forKey: .url)
        name = try container.decode(String.self, forKey: .name)
        lastOpened = try container.decode(Date.self, forKey: .lastOpened)
        size = try container.decode(Int64.self, forKey: .size)
        isValidJSON = try container.decode(Bool.self, forKey: .isValidJSON)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(url, forKey: .url)
        try container.encode(name, forKey: .name)
        try container.encode(lastOpened, forKey: .lastOpened)
        try container.encode(size, forKey: .size)
        try container.encode(isValidJSON, forKey: .isValidJSON)
    }
}

// MARK: - Treon File Manager
class TreonFileManager: ObservableObject {
    static let shared = TreonFileManager()
    
    // MARK: - Constants
    let maxFileSize = FileConstants.maxFileSize
    let sizeSlackBytes = FileConstants.sizeSlackBytes
    private let recentFilesKey = UserDefaultsKeys.recentFiles
    private let maxRecentFiles = FileConstants.maxRecentFiles
    let logger = Loggers.fileManager
    
    // MARK: - Properties
    @Published var recentFiles: [RecentFile] = []
    @Published var currentFile: FileInfo? {
        didSet {
            // Update TabManager when currentFile changes
            if let fileInfo = currentFile {
                Task { @MainActor in
                    TabManager.shared.openFile(fileInfo)
                }
            }
        }
    }
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Cached Panel for Performance
    private var cachedOpenPanel: NSOpenPanel {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = false
        panel.allowedContentTypes = [.json]
        panel.title = "Open JSON Files"
        panel.message = "Select one or more JSON files to open"
        // Note: directoryURL will be set when the panel is used, not during initialization
        return panel
    }
    
    // MARK: - Initialization
    private init() {
        logger.info("Initializing TreonFileManager")
        loadRecentFiles()
        
        // Pre-warm the cached panel on the main thread (NSWindow must be created on main thread)
        DispatchQueue.main.async {
            _ = self.cachedOpenPanel
            self.logger.info("Pre-warmed file dialog panel")
        }
    }
    
    // MARK: - File Operations
    func openFile() async throws -> FileInfo {
        logger.info("Starting file open operation")
        return try await withCheckedThrowingContinuation { continuation in
            // Use cached panel for faster launch - no need to create/configure each time
            DispatchQueue.main.async {
                // Set panel to last opened directory
                let panel = self.cachedOpenPanel
                panel.directoryURL = DirectoryManager.shared.getLastOpenedDirectory()
                
                if panel.runModal() == .OK {
                    let urls = self.cachedOpenPanel.urls
                    self.logger.info("User selected \(urls.count) file(s)")
                    
                    Task {
                        do {
                            // Open all selected files
                            for url in urls {
                                let fileInfo = try await FileValidator.shared.validateAndLoadFile(url: url)
                                self.logger.info("Successfully loaded file: \(fileInfo.name)")
                                
                                // Save the directory of the selected file for next time
                                Task { @MainActor in
                                    DirectoryManager.shared.saveLastOpenedDirectory(url: url)
                                }
                                
                                // Open each file as a tab
                                Task { @MainActor in
                                    TabManager.shared.openFile(fileInfo)
                                }
                                
                                // Add to recent files
                                self.addToRecentFiles(fileInfo: fileInfo)
                            }

                            // Return the first file as the "current" file for backward compatibility
                            if let firstFile = urls.first {
                                let fileInfo = try await FileValidator.shared.validateAndLoadFile(url: firstFile)
                                continuation.resume(returning: fileInfo)
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
        // Try to access the file directly first
        do {
            let fileInfo = try await FileValidator.shared.validateAndLoadFile(url: url)
            
            // Save the directory of the opened file for next time
            Task { @MainActor in
                DirectoryManager.shared.saveLastOpenedDirectory(url: url)
            }
            
            // Add to recent files
            addToRecentFiles(fileInfo: fileInfo)
            
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
    
    // MARK: - Recent Files Management
    private func addToRecentFiles(fileInfo: FileInfo) {
        // Only add to recent files if there's a valid URL (not content-based files) and valid JSON
        guard let url = fileInfo.url, fileInfo.isValidJSON else { return }
        
        let recentFile = RecentFile(
            url: url,
            name: fileInfo.name,
            lastOpened: Date(),
            size: fileInfo.size,
            isValidJSON: fileInfo.isValidJSON
        )
        
        // Remove existing entry if it exists
        recentFiles.removeAll { $0.url == url }
        
        // Add to beginning
        recentFiles.insert(recentFile, at: 0)
        
        // Keep only maxRecentFiles
        if recentFiles.count > maxRecentFiles {
            recentFiles = Array(recentFiles.prefix(maxRecentFiles))
        }
        
        saveRecentFiles()
    }
    
    func removeRecentFile(_ recentFile: RecentFile) {
        recentFiles.removeAll { $0.id == recentFile.id }
        saveRecentFiles()
    }
    
    func clearRecentFiles() {
        recentFiles.removeAll()
        saveRecentFiles()
    }
    
    private func loadRecentFiles() {
        guard let data = UserDefaults.standard.data(forKey: recentFilesKey) else { return }
        
        do {
            let decoder = JSONDecoder()
            recentFiles = try decoder.decode([RecentFile].self, from: data)
        } catch {
            print("Failed to load recent files: \(error)")
            recentFiles = []
        }
    }
    
    private func saveRecentFiles() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(recentFiles)
            UserDefaults.standard.set(data, forKey: recentFilesKey)
        } catch {
            print("Failed to save recent files: \(error)")
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
        logger.info("Creating file from content: \(name)")
        
        // Convert content to data
        guard let jsonData = content.data(using: .utf8) else {
            logger.error("Unable to convert content to data")
            throw FileManagerError.invalidJSON("Unable to convert content to data")
        }
        
        // Check file size limit
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
