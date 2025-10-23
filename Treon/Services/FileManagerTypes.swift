import Foundation
import SwiftUI
import UniformTypeIdentifiers

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
    nonisolated let bookmarkData: Data?

    nonisolated var formattedSize: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useBytes, .useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: size)
    }

    enum CodingKeys: String, CodingKey {
        case url, name, lastOpened, size, isValidJSON, bookmarkData
    }

    init(url: URL, name: String, lastOpened: Date, size: Int64, isValidJSON: Bool, bookmarkData: Data? = nil) {
        self.url = url
        self.name = name
        self.lastOpened = lastOpened
        self.size = size
        self.isValidJSON = isValidJSON
        self.bookmarkData = bookmarkData
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        url = try container.decode(URL.self, forKey: .url)
        name = try container.decode(String.self, forKey: .name)
        lastOpened = try container.decode(Date.self, forKey: .lastOpened)
        size = try container.decode(Int64.self, forKey: .size)
        isValidJSON = try container.decode(Bool.self, forKey: .isValidJSON)
        bookmarkData = try container.decodeIfPresent(Data.self, forKey: .bookmarkData)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(url, forKey: .url)
        try container.encode(name, forKey: .name)
        try container.encode(lastOpened, forKey: .lastOpened)
        try container.encode(size, forKey: .size)
        try container.encode(isValidJSON, forKey: .isValidJSON)
        try container.encodeIfPresent(bookmarkData, forKey: .bookmarkData)
    }
}
