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
    private let maxFileSize = FileConstants.maxFileSize
    private let sizeSlackBytes = FileConstants.sizeSlackBytes
    private let recentFilesKey = UserDefaultsKeys.recentFiles
    private let maxRecentFiles = FileConstants.maxRecentFiles
    private let logger = Loggers.fileManager
    
    // MARK: - Properties
    @Published var recentFiles: [RecentFile] = []
    @Published var currentFile: FileInfo?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Initialization
    private init() {
        logger.info("Initializing TreonFileManager")
        loadRecentFiles()
    }
    
    // MARK: - File Operations
    func openFile() async throws -> FileInfo {
        logger.info("Starting file open operation")
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.main.async {
                let panel = NSOpenPanel()
                panel.allowsMultipleSelection = false
                panel.canChooseDirectories = false
                panel.allowedContentTypes = [.json]
                panel.title = "Open JSON File"
                panel.message = "Select a JSON file to open"

                if panel.runModal() == .OK, let url = panel.url {
                    self.logger.info("User selected file: \(url.path)")
                    Task {
                        do {
                            let fileInfo = try await self.validateAndLoadFile(url: url)
                            self.logger.info("Successfully loaded file: \(fileInfo.name)")
                            continuation.resume(returning: fileInfo)
                        } catch {
                            self.logger.error("Failed to load file: \(error.localizedDescription)")
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
        return try await validateAndLoadFile(url: url)
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
    
    // MARK: - File Validation
    private func validateAndLoadFile(url: URL) async throws -> FileInfo {
        // Check if file exists
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw FileManagerError.fileNotFound(url.path)
        }
        
        // Get file attributes
        let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
        let fileSize = attributes[.size] as? Int64 ?? 0
        let modifiedDate = attributes[.modificationDate] as? Date ?? Date()
        
        // Check file size
        if fileSize > maxFileSize + sizeSlackBytes {
            throw FileManagerError.fileTooLarge(fileSize, maxFileSize)
        }
        
        // Check file type
        let fileExtension = url.pathExtension.lowercased()
        guard fileExtension == "json" else {
            throw FileManagerError.unsupportedFileType(fileExtension)
        }
        
        // Validate JSON content
        let (isValidJSON, errorMessage) = await validateJSONContent(url: url)
        
        let fileInfo = FileInfo(
            url: url,
            name: url.lastPathComponent,
            size: fileSize,
            modifiedDate: modifiedDate,
            isValidJSON: isValidJSON,
            errorMessage: errorMessage,
            content: nil
        )
        
        // Add to recent files if valid
        if isValidJSON {
            addToRecentFiles(fileInfo: fileInfo)
        }
        
        return fileInfo
    }
    
    private func validateJSONContent(url: URL) async -> (Bool, String?) {
        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    let data = try Data(contentsOf: url)
                    if let raw = String(data: data, encoding: .utf8) {
                        // Quick pre-parse checks for common malformations the parser may not flag clearly
                        if raw.contains(",]") || raw.contains(",}") {
                            continuation.resume(returning: (false, "Invalid JSON structure: Trailing comma"))
                            return
                        }
                        if raw.contains("[,]") {
                            continuation.resume(returning: (false, "Invalid JSON structure: Invalid array"))
                            return
                        }
                    }
                    
                    // Try to parse JSON
                    let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
                    
                    // Validate it's a valid JSON structure
                    if JSONSerialization.isValidJSONObject(jsonObject) {
                        continuation.resume(returning: (true, nil))
                    } else {
                        continuation.resume(returning: (false, "Invalid JSON structure"))
                    }
                } catch {
                    continuation.resume(returning: (false, error.localizedDescription))
                }
            }
        }
    }
    
    // MARK: - Recent Files Management
    private func addToRecentFiles(fileInfo: FileInfo) {
        // Only add to recent files if there's a valid URL (not content-based files)
        guard let url = fileInfo.url else { return }
        
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
    
    func loadFromURL(_ url: URL) async throws -> FileInfo {
        logger.info("Loading content from URL: \(url.absoluteString)")
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            // Check HTTP status
            if let httpResponse = response as? HTTPURLResponse {
                guard 200...299 ~= httpResponse.statusCode else {
                    logger.error("HTTP error: \(httpResponse.statusCode)")
                    throw FileManagerError.networkError("HTTP \(httpResponse.statusCode)")
                }
            }
            
            // Validate content size
            guard data.count <= maxFileSize else {
                logger.error("Content size exceeds limit: \(data.count) bytes")
                throw FileManagerError.fileTooLarge(Int64(data.count), maxFileSize)
            }
            
            // Convert to string
            guard let content = String(data: data, encoding: .utf8) else {
                logger.error("Unable to decode content as UTF-8")
                throw FileManagerError.invalidJSON("Unable to decode content as UTF-8")
            }
            
            // Validate JSON format
            do {
                _ = try JSONSerialization.jsonObject(with: data, options: [])
            } catch {
                throw FileManagerError.invalidJSON("Invalid JSON format: \(error.localizedDescription)")
            }
            
            // Create file info
            let fileName = url.lastPathComponent.isEmpty ? "URL Content" : url.lastPathComponent
            let fileInfo = FileInfo(
                url: url,
                name: fileName,
                size: Int64(data.count),
                modifiedDate: Date(),
                isValidJSON: true,
                errorMessage: nil,
                content: content
            )
            
            return fileInfo
        } catch let error as FileManagerError {
            throw error
        } catch {
            throw FileManagerError.networkError(error.localizedDescription)
        }
    }
    
    func executeCurlCommand(_ command: String) async throws -> FileInfo {
        // Parse cURL command to extract URL and options
        let parsedCommand = try parseCurlCommand(command)
        
        // Create URL request
        var request = URLRequest(url: parsedCommand.url)
        request.httpMethod = parsedCommand.method
        request.allHTTPHeaderFields = parsedCommand.headers
        
        if let body = parsedCommand.body {
            request.httpBody = body.data(using: .utf8)
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // Check HTTP status
            if let httpResponse = response as? HTTPURLResponse {
                guard 200...299 ~= httpResponse.statusCode else {
                    throw FileManagerError.networkError("HTTP \(httpResponse.statusCode)")
                }
            }
            
            // Validate content size
            guard data.count <= maxFileSize else {
                throw FileManagerError.fileTooLarge(Int64(data.count), maxFileSize)
            }
            
            // Convert to string
            guard let content = String(data: data, encoding: .utf8) else {
                throw FileManagerError.invalidJSON("Unable to decode response as UTF-8")
            }
            
            // Validate JSON format
            do {
                _ = try JSONSerialization.jsonObject(with: data, options: [])
            } catch {
                throw FileManagerError.invalidJSON("Response is not valid JSON: \(error.localizedDescription)")
            }
            
            // Create file info
            let fileInfo = FileInfo(
                url: parsedCommand.url,
                name: "cURL Response",
                size: Int64(data.count),
                modifiedDate: Date(),
                isValidJSON: true,
                errorMessage: nil,
                content: content
            )
            
            return fileInfo
        } catch let error as FileManagerError {
            throw error
        } catch {
            throw FileManagerError.networkError(error.localizedDescription)
        }
    }
    
    // MARK: - cURL Command Parsing
    
    private struct ParsedCurlCommand {
        let url: URL
        let method: String
        let headers: [String: String]
        let body: String?
    }
    
    private func parseCurlCommand(_ command: String) throws -> ParsedCurlCommand {
        let components = command.components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
        
        guard components.first?.lowercased() == "curl" else {
            throw FileManagerError.invalidJSON("Command must start with 'curl'")
        }
        
        var url: URL?
        var method = "GET"
        var headers: [String: String] = [:]
        var body: String?
        
        var i = 1
        while i < components.count {
            let component = components[i]
            
            switch component {
            case "-X", "--request":
                if i + 1 < components.count {
                    method = components[i + 1].uppercased()
                    i += 1
                }
            case "-H", "--header":
                if i + 1 < components.count {
                    let header = components[i + 1]
                    if let colonIndex = header.firstIndex(of: ":") {
                        let key = String(header[..<colonIndex]).trimmingCharacters(in: .whitespaces)
                        let value = String(header[header.index(after: colonIndex)...]).trimmingCharacters(in: .whitespaces)
                        headers[key] = value
                    }
                    i += 1
                }
            case "-d", "--data", "--data-raw":
                if i + 1 < components.count {
                    body = components[i + 1]
                    i += 1
                }
            default:
                // Check if it's a URL
                if component.hasPrefix("http://") || component.hasPrefix("https://") {
                    url = URL(string: component)
                }
            }
            i += 1
        }
        
        guard let finalURL = url else {
            throw FileManagerError.invalidJSON("No valid URL found in cURL command")
        }
        
        return ParsedCurlCommand(url: finalURL, method: method, headers: headers, body: body)
    }
}
