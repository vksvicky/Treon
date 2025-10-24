//
//  FileManagerTypes.swift
//  Treon
//
//  Created by Vivek on 2025-10-19.
//  Copyright © 2025 Treon. All rights reserved.
//

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
    
    // Lazy content loading - don't store large content in memory
    // Content is loaded on-demand and cleared when not needed
    private nonisolated var _content: String?
    nonisolated var content: String? {
        get { _content }
        set { _content = newValue }
    }
    
    // Flag to track if content has been loaded
    nonisolated var isContentLoaded: Bool {
        _content != nil
    }
    
    // Initializer
    init(url: URL?, name: String, size: Int64, modifiedDate: Date, isValidJSON: Bool, errorMessage: String?, content: String? = nil) {
        self.url = url
        self.name = name
        self.size = size
        self.modifiedDate = modifiedDate
        self.isValidJSON = isValidJSON
        self.errorMessage = errorMessage
        self._content = content
    }

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
    
    // Clear content from memory to free up space
    nonisolated mutating func clearContent() {
        _content = nil
    }
    
    // Load content on-demand (to be implemented by FileManager)
    nonisolated mutating func loadContent() async throws -> String {
        if let existingContent = _content {
            return existingContent
        }
        
        // This will be implemented by FileManager to load content from URL
        throw FileManagerError.unknownError("Content loading not implemented")
    }
}

// MARK: - Recent File
struct RecentFile: Codable, Identifiable, Equatable {
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
    
    // MARK: - Equatable
    static func == (lhs: RecentFile, rhs: RecentFile) -> Bool {
        return lhs.url == rhs.url && lhs.name == rhs.name
    }
}
